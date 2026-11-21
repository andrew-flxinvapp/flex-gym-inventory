import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utilities/logging_handler.dart' as app_log;

enum RevenueCatInitializationStatus { pending, configured, failed, unavailable }

enum RevenueCatIdentityStatus {
  waitingForConfiguration,
  unavailable,
  syncing,
  synchronized,
  signedOut,
  failed,
  stopped,
}

class RevenueCatInitializationState {
  const RevenueCatInitializationState({
    required this.status,
    this.errorMessage,
  });

  final RevenueCatInitializationStatus status;
  final String? errorMessage;
}

class RevenueCatIdentityState {
  const RevenueCatIdentityState({required this.status, this.errorMessage});

  final RevenueCatIdentityStatus status;
  final String? errorMessage;
}

typedef RevenueCatSdkConfigurer =
    Future<void> Function({required String apiKey, String? appUserId});
typedef RevenueCatCurrentAppUserIdReader = Future<String> Function();
typedef RevenueCatIdentityLogIn =
    Future<CustomerInfo?> Function(String appUserId);
typedef RevenueCatIdentityLogOut = Future<void> Function();
typedef RevenueCatCustomerInfoReader = Future<CustomerInfo?> Function();
typedef RevenueCatCustomerInfoListenerRegistration =
    void Function(CustomerInfoUpdateListener listener);
typedef RevenueCatOfferingsReader = Future<Offerings> Function();
typedef RevenueCatPackagePurchaser =
    Future<CustomerInfo> Function(Package package);
typedef RevenueCatPurchaseRestorer = Future<CustomerInfo> Function();

/// Service that centralizes RevenueCat (Purchases) SDK interactions.
///
/// - Keeps RevenueCat-specific code inside this service.
/// - Methods intentionally return SDK types where appropriate so callers
///   can inspect richer details when necessary.
class RevenueCatService {
  static final RevenueCatService instance = RevenueCatService();

  static const String proEntitlementId = 'flex_gym_inventory_pro';

  static const Duration defaultConfigurationTimeout = Duration(seconds: 10);

  RevenueCatService({
    RevenueCatSdkConfigurer? configureSdk,
    RevenueCatCurrentAppUserIdReader? currentAppUserIdReader,
    RevenueCatIdentityLogIn? identityLogIn,
    RevenueCatIdentityLogOut? identityLogOut,
    RevenueCatCustomerInfoReader? customerInfoReader,
    RevenueCatCustomerInfoListenerRegistration? addCustomerInfoListener,
    RevenueCatCustomerInfoListenerRegistration? removeCustomerInfoListener,
    RevenueCatOfferingsReader? offeringsReader,
    RevenueCatPackagePurchaser? packagePurchaser,
    RevenueCatPurchaseRestorer? purchaseRestorer,
  }) : _configureSdk = configureSdk ?? _configurePurchases,
       _currentAppUserIdReader =
           currentAppUserIdReader ?? _readCurrentAppUserId,
       _identityLogIn = identityLogIn ?? _logInWithPurchases,
       _identityLogOut = identityLogOut ?? _logOutWithPurchases,
       _customerInfoReader = customerInfoReader ?? _readCustomerInfo,
       _addCustomerInfoListener =
           addCustomerInfoListener ?? Purchases.addCustomerInfoUpdateListener,
       _removeCustomerInfoListener =
           removeCustomerInfoListener ??
           Purchases.removeCustomerInfoUpdateListener,
       _offeringsReader = offeringsReader ?? Purchases.getOfferings,
       _packagePurchaser = packagePurchaser ?? _purchasePackage,
       _purchaseRestorer = purchaseRestorer ?? Purchases.restorePurchases;

  final RevenueCatSdkConfigurer _configureSdk;
  final RevenueCatCurrentAppUserIdReader _currentAppUserIdReader;
  final RevenueCatIdentityLogIn _identityLogIn;
  final RevenueCatIdentityLogOut _identityLogOut;
  final RevenueCatCustomerInfoReader _customerInfoReader;
  final RevenueCatCustomerInfoListenerRegistration _addCustomerInfoListener;
  final RevenueCatCustomerInfoListenerRegistration _removeCustomerInfoListener;
  final RevenueCatOfferingsReader _offeringsReader;
  final RevenueCatPackagePurchaser _packagePurchaser;
  final RevenueCatPurchaseRestorer _purchaseRestorer;
  final ValueNotifier<RevenueCatInitializationState> initializationState =
      ValueNotifier(
        const RevenueCatInitializationState(
          status: RevenueCatInitializationStatus.pending,
        ),
      );

  final ValueNotifier<RevenueCatIdentityState> identityState = ValueNotifier(
    const RevenueCatIdentityState(
      status: RevenueCatIdentityStatus.waitingForConfiguration,
    ),
  );

  Future<void>? _initializationTask;
  bool _configurationAttempted = false;
  StreamSubscription<String?>? _authSubscription;
  String? Function()? _currentSupabaseUserIdReader;
  String? _desiredSupabaseUserId;
  String? _synchronizedSupabaseUserId;
  int _identityRevision = 0;
  bool _identityWorkerRunning = false;
  bool _identitySynchronizationStopped = false;
  Future<void>? _identityTask;
  Completer<void>? _transaction;

  static const String _anonymousAppUserIdPrefix = r'$RCAnonymousID:';

  /// Starts RevenueCat initialization without making the caller wait.
  ///
  /// Initialization is attempted at most once per service instance. A timeout
  /// does not cancel the underlying native operation, so timed-out attempts
  /// are not retried during this process.
  void startConfiguration({
    required String apiKey,
    String? appUserId,
    bool enableDebugLogs = false,
    Duration timeout = defaultConfigurationTimeout,
  }) {
    if (_configurationAttempted) return;

    if (apiKey.isEmpty) {
      initializationState.value = const RevenueCatInitializationState(
        status: RevenueCatInitializationStatus.unavailable,
        errorMessage: 'RevenueCat API key is not configured.',
      );
      _setIdentityUnavailable();
      app_log.LogHandler.warning(
        'RevenueCatService',
        'RevenueCat unavailable: API key is not configured.',
      );
      return;
    }

    _configurationAttempted = true;
    initializationState.value = const RevenueCatInitializationState(
      status: RevenueCatInitializationStatus.pending,
    );

    final nativeAttempt = _configure(
      apiKey: apiKey,
      appUserId: appUserId,
      enableDebugLogs: enableDebugLogs,
    );
    _initializationTask = _observeConfiguration(
      nativeAttempt,
      timeout: timeout,
      apiKey: apiKey,
    );
  }

  /// Completes when initialization succeeds, fails, or reaches its timeout.
  ///
  /// It never completes with an error; inspect [initializationState] for the
  /// outcome. The underlying SDK call may still be pending after a timeout.
  Future<void> get initializationTask =>
      _initializationTask ?? Future<void>.value();

  /// Starts one Supabase auth listener for the lifetime of this service.
  ///
  /// Stream events trigger a fresh read from [currentUserId], so late or
  /// coalesced events cannot make an older auth state win.
  void startIdentitySynchronization({
    required Stream<String?> authUserIds,
    required String? Function() currentUserId,
  }) {
    if (_authSubscription != null || _identitySynchronizationStopped) return;

    _currentSupabaseUserIdReader = currentUserId;
    try {
      _authSubscription = authUserIds.listen(
        (_) => _handleAuthStateChanged(),
        onError: (Object error, StackTrace stackTrace) {
          _setIdentityFailed();
          app_log.LogHandler.warning(
            'RevenueCatIdentity',
            'Supabase auth state stream failed; identity synchronization is paused.',
          );
        },
      );
      _handleAuthStateChanged();
    } catch (_) {
      _setIdentityFailed();
      app_log.LogHandler.warning(
        'RevenueCatIdentity',
        'Could not start the Supabase auth state listener.',
      );
    }
  }

  /// Cancels the auth listener and prevents pending operations from updating
  /// identity state after the owning lifecycle has ended.
  Future<void> stopIdentitySynchronization() async {
    if (_identitySynchronizationStopped) return;
    _identitySynchronizationStopped = true;
    _identityRevision++;
    _synchronizedSupabaseUserId = null;
    identityState.value = const RevenueCatIdentityState(
      status: RevenueCatIdentityStatus.stopped,
    );
    final subscription = _authSubscription;
    _authSubscription = null;
    await subscription?.cancel();
  }

  /// Completes when the latest identity synchronization attempt settles.
  Future<void> get identitySynchronizationTask =>
      _identityTask ?? Future<void>.value();

  /// Configure the RevenueCat SDK.
  ///
  /// Do NOT hardcode API keys. Callers should read keys from their
  /// environment/config and pass them here (e.g. from flutter_dotenv).
  Future<void> configure({
    required String apiKey,
    bool observerMode = false,
    String? appUserId,
    bool enableDebugLogs = false,
    Duration timeout = defaultConfigurationTimeout,
  }) async {
    startConfiguration(
      apiKey: apiKey,
      appUserId: appUserId,
      enableDebugLogs: enableDebugLogs,
      timeout: timeout,
    );
    await initializationTask;

    final state = initializationState.value;
    if (state.status != RevenueCatInitializationStatus.configured) {
      throw StateError(
        state.errorMessage ?? 'RevenueCat initialization did not complete.',
      );
    }
  }

  static Future<void> _configurePurchases({
    required String apiKey,
    String? appUserId,
  }) {
    final config = PurchasesConfiguration(apiKey);
    config.entitlementVerificationMode =
        EntitlementVerificationMode.informational;
    if (appUserId != null && appUserId.isNotEmpty) {
      config.appUserID = appUserId;
    }
    return Purchases.configure(config);
  }

  static Future<String> _readCurrentAppUserId() => Purchases.appUserID;

  static Future<CustomerInfo?> _logInWithPurchases(String appUserId) async {
    final result = await Purchases.logIn(appUserId);
    return result.customerInfo;
  }

  static Future<void> _logOutWithPurchases() async {
    await Purchases.logOut();
  }

  static Future<CustomerInfo?> _readCustomerInfo() async {
    return Purchases.getCustomerInfo();
  }

  Future<void> _configure({
    required String apiKey,
    String? appUserId,
    required bool enableDebugLogs,
  }) async {
    app_log.LogHandler.info('RevenueCatService', 'Configuring RevenueCat');
    await _configureSdk(apiKey: apiKey, appUserId: appUserId);
    if (enableDebugLogs) {
      await Purchases.setLogLevel(LogLevel.debug);
    }
  }

  Future<void> _observeConfiguration(
    Future<void> nativeAttempt, {
    required Duration timeout,
    required String apiKey,
  }) async {
    try {
      await nativeAttempt.timeout(timeout);
      initializationState.value = const RevenueCatInitializationState(
        status: RevenueCatInitializationStatus.configured,
      );
      app_log.LogHandler.info('RevenueCatService', 'RevenueCat configured');
      _scheduleIdentitySynchronization();
    } on TimeoutException {
      final message =
          'RevenueCat initialization timed out after ${timeout.inSeconds} seconds.';
      initializationState.value = RevenueCatInitializationState(
        status: RevenueCatInitializationStatus.failed,
        errorMessage: message,
      );
      _setIdentityUnavailable();
      app_log.LogHandler.warning('RevenueCatService', message);
      unawaited(_observeLateConfiguration(nativeAttempt, apiKey));
    } catch (e) {
      final message = _safeErrorMessage(e, apiKey);
      initializationState.value = RevenueCatInitializationState(
        status: RevenueCatInitializationStatus.failed,
        errorMessage: message,
      );
      _setIdentityUnavailable();
      app_log.LogHandler.error(
        'RevenueCatService',
        'RevenueCat initialization failed: $message',
      );
    }
  }

  Future<void> _observeLateConfiguration(
    Future<void> nativeAttempt,
    String apiKey,
  ) async {
    try {
      await nativeAttempt;
      initializationState.value = const RevenueCatInitializationState(
        status: RevenueCatInitializationStatus.configured,
      );
      _scheduleIdentitySynchronization();
      app_log.LogHandler.info(
        'RevenueCatService',
        'RevenueCat initialization completed after its startup timeout',
      );
    } catch (e) {
      app_log.LogHandler.warning(
        'RevenueCatService',
        'RevenueCat initialization failed after its startup timeout: '
            '${_safeErrorMessage(e, apiKey)}',
      );
    }
  }

  void _handleAuthStateChanged() {
    if (_identitySynchronizationStopped) return;

    try {
      final currentUserId = _currentSupabaseUserIdReader?.call();
      final changed = _setDesiredSupabaseUserId(currentUserId);
      if (changed ||
          identityState.value.status ==
              RevenueCatIdentityStatus.waitingForConfiguration ||
          identityState.value.status == RevenueCatIdentityStatus.unavailable) {
        _scheduleIdentitySynchronization();
      }
    } catch (_) {
      _setIdentityFailed();
      app_log.LogHandler.warning(
        'RevenueCatIdentity',
        'Could not read the current Supabase user for identity synchronization.',
      );
    }
  }

  bool _setDesiredSupabaseUserId(String? userId) {
    if (userId == _desiredSupabaseUserId) return false;

    _desiredSupabaseUserId = userId;
    _identityRevision++;
    _synchronizedSupabaseUserId = null;
    identityState.value = switch (initializationState.value.status) {
      RevenueCatInitializationStatus.configured =>
        const RevenueCatIdentityState(status: RevenueCatIdentityStatus.syncing),
      RevenueCatInitializationStatus.failed ||
      RevenueCatInitializationStatus
          .unavailable => const RevenueCatIdentityState(
        status: RevenueCatIdentityStatus.unavailable,
        errorMessage: 'RevenueCat SDK is unavailable.',
      ),
      RevenueCatInitializationStatus.pending => const RevenueCatIdentityState(
        status: RevenueCatIdentityStatus.waitingForConfiguration,
      ),
    };
    return true;
  }

  void _scheduleIdentitySynchronization() {
    if (_identitySynchronizationStopped) return;
    if (_currentSupabaseUserIdReader == null) return;

    if (initializationState.value.status !=
        RevenueCatInitializationStatus.configured) {
      if (initializationState.value.status ==
              RevenueCatInitializationStatus.failed ||
          initializationState.value.status ==
              RevenueCatInitializationStatus.unavailable) {
        _setIdentityUnavailable();
      } else {
        identityState.value = const RevenueCatIdentityState(
          status: RevenueCatIdentityStatus.waitingForConfiguration,
        );
      }
      return;
    }

    if (_identityWorkerRunning) return;

    try {
      final currentUserId = _currentSupabaseUserIdReader?.call();
      _setDesiredSupabaseUserId(currentUserId);
    } catch (_) {
      _setIdentityFailed();
      app_log.LogHandler.warning(
        'RevenueCatIdentity',
        'Could not read the current Supabase user for identity synchronization.',
      );
      return;
    }

    if (identityState.value.status == RevenueCatIdentityStatus.failed) return;
    if (_desiredSupabaseUserId != null &&
        identityState.value.status == RevenueCatIdentityStatus.synchronized &&
        _synchronizedSupabaseUserId == _desiredSupabaseUserId) {
      return;
    }
    if (_desiredSupabaseUserId == null &&
        identityState.value.status == RevenueCatIdentityStatus.signedOut) {
      return;
    }

    _identityWorkerRunning = true;
    _identityTask = _runIdentitySynchronization();
    unawaited(_identityTask!);
  }

  Future<void> _runIdentitySynchronization() async {
    try {
      while (!_identitySynchronizationStopped) {
        try {
          final currentUserId = _currentSupabaseUserIdReader?.call();
          _setDesiredSupabaseUserId(currentUserId);
        } catch (_) {
          _setIdentityFailed();
          app_log.LogHandler.warning(
            'RevenueCatIdentity',
            'Could not read the current Supabase user for identity synchronization.',
          );
          return;
        }

        if (initializationState.value.status !=
            RevenueCatInitializationStatus.configured) {
          _scheduleIdentitySynchronization();
          return;
        }

        final revision = _identityRevision;
        final userId = _desiredSupabaseUserId;
        identityState.value = const RevenueCatIdentityState(
          status: RevenueCatIdentityStatus.syncing,
        );

        final transaction = _transaction;
        if (transaction != null) {
          await transaction.future;
          if (!_isIdentityRequestCurrent(revision, userId)) continue;
        }
        final synchronized = await _synchronizeIdentity(userId, revision);
        if (_identitySynchronizationStopped) return;
        if (!synchronized) {
          if (_isIdentityRequestSuperseded(revision, userId)) continue;
          return;
        }
        if (!_isIdentityRequestCurrent(revision, userId)) continue;

        _synchronizedSupabaseUserId = userId;
        identityState.value = RevenueCatIdentityState(
          status:
              userId == null
                  ? RevenueCatIdentityStatus.signedOut
                  : RevenueCatIdentityStatus.synchronized,
        );
        if (!_identitySynchronizationStopped && revision == _identityRevision) {
          app_log.LogHandler.info(
            'RevenueCatIdentity',
            userId == null
                ? 'RevenueCat identity synchronized for signed-out Supabase session.'
                : 'RevenueCat identity synchronized for authenticated Supabase session.',
          );
        }
        return;
      }
    } catch (_) {
      _setIdentityFailed();
      app_log.LogHandler.warning(
        'RevenueCatIdentity',
        'Unexpected identity synchronization failure.',
      );
    } finally {
      _identityWorkerRunning = false;
      if (!_identitySynchronizationStopped && _identityNeedsProcessing()) {
        _scheduleIdentitySynchronization();
      }
    }
  }

  Future<bool> _synchronizeIdentity(String? userId, int revision) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final currentAppUserId = await _currentAppUserIdReader();
        if (!_isIdentityRequestCurrent(revision, userId)) return false;

        if (userId != null) {
          if (currentAppUserId != userId) {
            await logIn(userId);
            if (!_isIdentityRequestCurrent(revision, userId)) return false;
          }
        } else if (!_isAnonymousAppUserId(currentAppUserId)) {
          await logOut();
          if (!_isIdentityRequestCurrent(revision, userId)) return false;
        }

        final confirmedAppUserId = await _currentAppUserIdReader();
        if (!_isIdentityRequestCurrent(revision, userId)) return false;
        if (userId != null
            ? confirmedAppUserId != userId
            : !_isAnonymousAppUserId(confirmedAppUserId)) {
          throw StateError('RevenueCat identity did not match Supabase auth.');
        }
        return true;
      } catch (_) {
        if (_isIdentityRequestSuperseded(revision, userId)) return false;
        if (!_isIdentityRequestCurrent(revision, userId)) return false;
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          if (!_isIdentityRequestCurrent(revision, userId)) return false;
          continue;
        }

        _setIdentityFailed();
        app_log.LogHandler.warning(
          'RevenueCatIdentity',
          'RevenueCat identity synchronization failed after one retry.',
        );
        return false;
      }
    }
    return false;
  }

  bool _isIdentityRequestCurrent(int revision, String? userId) {
    if (_identitySynchronizationStopped) return false;

    try {
      final currentUserId = _currentSupabaseUserIdReader?.call();
      if (_currentSupabaseUserIdReader == null) {
        _setIdentityFailed();
        return false;
      }
      if (currentUserId != _desiredSupabaseUserId) {
        _setDesiredSupabaseUserId(currentUserId);
        return false;
      }
      return revision == _identityRevision && userId == currentUserId;
    } catch (_) {
      _setIdentityFailed();
      return false;
    }
  }

  bool _isIdentityRequestSuperseded(int revision, String? userId) =>
      revision != _identityRevision || userId != _desiredSupabaseUserId;

  bool _identityNeedsProcessing() {
    if (_currentSupabaseUserIdReader == null) return false;
    try {
      final currentUserId = _currentSupabaseUserIdReader?.call();
      if (currentUserId != _desiredSupabaseUserId) {
        _setDesiredSupabaseUserId(currentUserId);
        return true;
      }
      return initializationState.value.status ==
              RevenueCatInitializationStatus.configured &&
          identityState.value.status == RevenueCatIdentityStatus.syncing;
    } catch (_) {
      _setIdentityFailed();
      return false;
    }
  }

  bool _isAnonymousAppUserId(String appUserId) =>
      appUserId.startsWith(_anonymousAppUserIdPrefix);

  bool get isCurrentSupabaseUserSynchronized {
    if (_identitySynchronizationStopped ||
        identityState.value.status != RevenueCatIdentityStatus.synchronized ||
        _synchronizedSupabaseUserId == null) {
      return false;
    }

    try {
      return _currentSupabaseUserIdReader?.call() ==
          _synchronizedSupabaseUserId;
    } catch (_) {
      return false;
    }
  }

  /// Changes whenever the observed Supabase identity changes.
  int get identityRevision => _identityRevision;

  /// Reads the authoritative auth state without exposing it in subscription state.
  String? get currentSupabaseUserId {
    final reader = _currentSupabaseUserIdReader;
    if (reader == null) {
      throw StateError('Supabase identity synchronization has not started.');
    }
    return reader();
  }

  void addCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) =>
      _addCustomerInfoListener(listener);

  void removeCustomerInfoUpdateListener(CustomerInfoUpdateListener listener) =>
      _removeCustomerInfoListener(listener);

  static bool hasActiveProEntitlement(CustomerInfo info) {
    final verification = info.entitlements.verification;
    if (verification != VerificationResult.verified &&
        verification != VerificationResult.verifiedOnDevice) {
      throw StateError('RevenueCat entitlement verification is unavailable.');
    }
    return info.entitlements.all[proEntitlementId]?.isActive == true;
  }

  void _requireSynchronizedSupabaseUser() {
    if (!isCurrentSupabaseUserSynchronized) {
      throw StateError(
        'A synchronized Supabase user is required for RevenueCat customer data.',
      );
    }
  }

  void _setIdentityUnavailable() {
    _synchronizedSupabaseUserId = null;
    if (_identitySynchronizationStopped) return;
    identityState.value = const RevenueCatIdentityState(
      status: RevenueCatIdentityStatus.unavailable,
      errorMessage: 'RevenueCat SDK is unavailable.',
    );
  }

  void _setIdentityFailed() {
    _synchronizedSupabaseUserId = null;
    if (_identitySynchronizationStopped) return;
    identityState.value = const RevenueCatIdentityState(
      status: RevenueCatIdentityStatus.failed,
      errorMessage: 'RevenueCat identity synchronization failed.',
    );
  }

  String _safeErrorMessage(Object error, String apiKey) {
    final message = error.toString();
    return apiKey.isEmpty ? message : message.replaceAll(apiKey, '[redacted]');
  }

  /// Fetch the current CustomerInfo from RevenueCat.
  Future<CustomerInfo?> getCustomerInfo() async {
    _requireSynchronizedSupabaseUser();
    try {
      final info = await _customerInfoReader();
      _requireSynchronizedSupabaseUser();
      return info;
    } catch (_) {
      app_log.LogHandler.error(
        'RevenueCatService',
        'getCustomerInfo failed or identity changed during the request.',
      );
      rethrow;
    }
  }

  /// Return true if the PRO entitlement is active for the current user.
  Future<bool> hasProEntitlement() async {
    try {
      final info = await getCustomerInfo();
      if (info == null) {
        throw StateError('Customer information is unavailable.');
      }
      return hasActiveProEntitlement(info);
    } catch (_) {
      app_log.LogHandler.error('RevenueCatService', 'hasProEntitlement failed');
      rethrow;
    }
  }

  /// Return the current Offerings (may be null).
  Future<Offerings?> getCurrentOffering() async {
    try {
      final offerings = await _offeringsReader();
      return offerings;
    } catch (e, st) {
      app_log.LogHandler.error(
        'RevenueCatService',
        'getCurrentOffering failed',
        e,
        st,
      );
      rethrow;
    }
  }

  static Future<CustomerInfo> _purchasePackage(Package package) async =>
      (await Purchases.purchase(PurchaseParams.package(package))).customerInfo;

  bool _isTransactionIdentityCurrent(int revision) =>
      identityRevision == revision && isCurrentSupabaseUserSynchronized;

  Completer<void> _beginTransaction() {
    _requireSynchronizedSupabaseUser();
    if (_transaction != null) {
      throw StateError('A RevenueCat transaction is already in progress.');
    }
    return _transaction = Completer<void>();
  }

  void _endTransaction(Completer<void> transaction) {
    _transaction = null;
    transaction.complete();
  }

  /// Purchase a RevenueCat package.
  ///
  /// Returns a [PurchaseResult] that distinguishes success, user-cancel,
  /// and failure. Do not treat user cancellation as an error.
  Future<RevenueCatPurchaseResult> purchasePackage(Package package) async {
    Completer<void>? transaction;
    final revision = identityRevision;
    try {
      transaction = _beginTransaction();
      final info = await _packagePurchaser(package);
      if (!_isTransactionIdentityCurrent(revision)) {
        return RevenueCatPurchaseResult.identityChanged();
      }
      return RevenueCatPurchaseResult.success(info);
    } on PlatformException catch (e) {
      if (!_isTransactionIdentityCurrent(revision)) {
        return RevenueCatPurchaseResult.identityChanged();
      }
      final code = int.tryParse(e.code);
      if (code == PurchasesErrorCode.purchaseCancelledError.index) {
        return RevenueCatPurchaseResult.cancelled();
      }
      if (code == PurchasesErrorCode.paymentPendingError.index) {
        return RevenueCatPurchaseResult.pending();
      }
      app_log.LogHandler.warning('RevenueCatService', 'Purchase failed.');
      return RevenueCatPurchaseResult.failure(
        'Purchase could not be completed.',
      );
    } catch (_) {
      app_log.LogHandler.warning(
        'RevenueCatService',
        'Purchase could not start or complete.',
      );
      return RevenueCatPurchaseResult.failure(
        'Purchase could not be completed.',
      );
    } finally {
      if (transaction != null) _endTransaction(transaction);
    }
  }

  /// Restore purchases and return the updated CustomerInfo.
  Future<CustomerInfo?> restorePurchases() async {
    Completer<void>? transaction;
    final revision = identityRevision;
    try {
      transaction = _beginTransaction();
      final info = await _purchaseRestorer();
      if (!_isTransactionIdentityCurrent(revision)) {
        throw StateError('Authentication changed during restoration.');
      }
      return info;
    } catch (_) {
      app_log.LogHandler.error(
        'RevenueCatService',
        'restorePurchases failed or identity changed during the request.',
      );
      rethrow;
    } finally {
      if (transaction != null) _endTransaction(transaction);
    }
  }

  /// Identify / log in a user to RevenueCat using `appUserId`.
  ///
  /// If the app already uses Supabase for auth, callers can pass the
  /// Supabase user id here (e.g. `Supabase.instance.client.auth.currentUser?.id`).
  Future<CustomerInfo?> logIn(String appUserId) async {
    try {
      if (initializationState.value.status !=
              RevenueCatInitializationStatus.configured ||
          appUserId.isEmpty ||
          _currentSupabaseUserIdReader?.call() != appUserId) {
        throw StateError(
          'A configured SDK and matching Supabase user are required to log in.',
        );
      }
      return await _identityLogIn(appUserId);
    } catch (_) {
      app_log.LogHandler.error('RevenueCatService', 'logIn failed.');
      rethrow;
    }
  }

  /// Log out the current RevenueCat user and clear RevenueCat state.
  Future<void> logOut() async {
    try {
      if (initializationState.value.status !=
              RevenueCatInitializationStatus.configured ||
          _currentSupabaseUserIdReader == null ||
          _currentSupabaseUserIdReader!.call() != null) {
        throw StateError(
          'RevenueCat logout requires a configured SDK and signed-out Supabase state.',
        );
      }
      await _identityLogOut();
    } catch (_) {
      app_log.LogHandler.warning('RevenueCatService', 'logOut failed.');
      rethrow;
    }
  }

  /// Helper: log in current Supabase user to RevenueCat if available.
  Future<CustomerInfo?> logInCurrentSupabaseUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    _handleAuthStateChanged();
    await identitySynchronizationTask;
    if (!isCurrentSupabaseUserSynchronized) return null;
    return getCustomerInfo();
  }
}

/// Result of a purchase attempt.
class RevenueCatPurchaseResult {
  final bool success;
  final bool cancelled;
  final bool pending;
  final bool identityChanged;
  final CustomerInfo? customerInfo;
  final String? errorMessage;

  factory RevenueCatPurchaseResult._from({
    required bool success,
    required bool cancelled,
    bool pending = false,
    bool identityChanged = false,
    CustomerInfo? customerInfo,
    String? errorMessage,
  }) => RevenueCatPurchaseResult._(
    success: success,
    cancelled: cancelled,
    pending: pending,
    identityChanged: identityChanged,
    customerInfo: customerInfo,
    errorMessage: errorMessage,
  );

  RevenueCatPurchaseResult._({
    required this.success,
    required this.cancelled,
    this.pending = false,
    this.identityChanged = false,
    this.customerInfo,
    this.errorMessage,
  });

  factory RevenueCatPurchaseResult.success(CustomerInfo info) =>
      RevenueCatPurchaseResult._from(
        success: true,
        cancelled: false,
        customerInfo: info,
      );

  factory RevenueCatPurchaseResult.cancelled() =>
      RevenueCatPurchaseResult._from(success: false, cancelled: true);

  factory RevenueCatPurchaseResult.pending() => RevenueCatPurchaseResult._from(
    success: false,
    cancelled: false,
    pending: true,
  );

  factory RevenueCatPurchaseResult.identityChanged() =>
      RevenueCatPurchaseResult._from(
        success: false,
        cancelled: false,
        identityChanged: true,
      );

  factory RevenueCatPurchaseResult.failure(String message) =>
      RevenueCatPurchaseResult._from(
        success: false,
        cancelled: false,
        errorMessage: message,
      );
}
