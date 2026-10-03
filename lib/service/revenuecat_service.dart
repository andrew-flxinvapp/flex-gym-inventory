import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

import '../utilities/logging_handler.dart' as app_log;

/// Service that centralizes RevenueCat (Purchases) SDK interactions.
///
/// - Keeps RevenueCat-specific code inside this service.
/// - Methods intentionally return SDK types where appropriate so callers
///   can inspect richer details when necessary.
class RevenueCatService {
  // Planned entitlement id for PRO access
  static const String proEntitlementId = 'pro';

  RevenueCatService();

  /// Configure the RevenueCat SDK.
  ///
  /// Do NOT hardcode API keys. Callers should read keys from their
  /// environment/config and pass them here (e.g. from flutter_dotenv).
  Future<void> configure({
    required String apiKey,
    bool observerMode = false,
    String? appUserId,
    bool enableDebugLogs = false,
  }) async {
    try {
      // Prevent accidentally initializing a Test Store API key in non-debug builds.
      final lowerKey = apiKey.toLowerCase();
      final isTestKey = lowerKey.contains('test') || lowerKey.startsWith('test_');
      if (isTestKey && !kDebugMode) {
        app_log.LogHandler.warning(
          'RevenueCatService',
          'Detected a Test Store API key but app is not running in debug mode. Skipping RevenueCat configure to avoid enabling Test Store in release builds.',
        );
        return;
      }

      app_log.LogHandler.info('RevenueCatService', 'Configuring RevenueCat');
      final config = PurchasesConfiguration(apiKey);
      await Purchases.configure(config);
      if (enableDebugLogs) {
        try {
          await Purchases.setDebugLogsEnabled(true);
        } catch (_) {}
      }

      // Optionally identify the user immediately if provided.
      if (appUserId != null && appUserId.isNotEmpty) {
        try {
          await logIn(appUserId);
        } catch (e, st) {
          app_log.LogHandler.warning('RevenueCatService', 'logIn during configure failed', e, st);
        }
      }
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'configure failed', e, st);
      rethrow;
    }
  }

  /// Fetch the current CustomerInfo from RevenueCat.
  Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info;
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'getCustomerInfo failed', e, st);
      rethrow;
    }
  }

  /// Return true if the `pro` entitlement is active for the current user.
  Future<bool> hasProEntitlement() async {
    try {
      final info = await getCustomerInfo();
      if (info == null) return false;
      final ent = info.entitlements.all[proEntitlementId];
      return ent != null && ent.isActive == true;
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'hasProEntitlement failed', e, st);
      rethrow;
    }
  }

  /// Return the current Offerings (may be null).
  Future<Offerings?> getCurrentOffering() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'getCurrentOffering failed', e, st);
      rethrow;
    }
  }

  /// Purchase a RevenueCat package.
  ///
  /// Returns a [PurchaseResult] that distinguishes success, user-cancel,
  /// and failure. Do not treat user cancellation as an error.
  Future<RevenueCatPurchaseResult> purchasePackage(Package package) async {
    try {
      final purchaseResult = await Purchases.purchasePackage(package);
      // In recent SDKs purchasePackage may return a CustomerInfo object or
      // an SDK-specific wrapper. Handle common shapes conservatively.
      if (purchaseResult is CustomerInfo) {
        return RevenueCatPurchaseResult.success(purchaseResult as CustomerInfo);
      }

      try {
        final info = (purchaseResult as dynamic).customerInfo as CustomerInfo?;
        if (info != null) return RevenueCatPurchaseResult.success(info);
      } catch (_) {}

      // Fallback: fetch latest customer info
      final info = await getCustomerInfo();
      if (info != null) return RevenueCatPurchaseResult.success(info);

      return RevenueCatPurchaseResult.failure('Purchase completed but customer info unavailable');
    } on PlatformException catch (e, st) {
      final code = e.code.toString().toLowerCase();
      final message = e.message?.toString() ?? e.toString();
      app_log.LogHandler.warning('RevenueCatService', 'purchasePackage failed', e, st);
      if (code.contains('purchase_cancelled') || message.toLowerCase().contains('cancel')) {
        return RevenueCatPurchaseResult.cancelled();
      }
      return RevenueCatPurchaseResult.failure(message);
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'purchasePackage failed', e, st);
      return RevenueCatPurchaseResult.failure(e.toString());
    }
  }

  /// Restore purchases and return the updated CustomerInfo.
  Future<CustomerInfo?> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      // Latest SDK returns CustomerInfo; return it directly.
      return info;
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'restorePurchases failed', e, st);
      rethrow;
    }
  }

  /// Identify / log in a user to RevenueCat using `appUserId`.
  ///
  /// If the app already uses Supabase for auth, callers can pass the
  /// Supabase user id here (e.g. `Supabase.instance.client.auth.currentUser?.id`).
  Future<CustomerInfo?> logIn(String appUserId) async {
    try {
      if (appUserId.isEmpty) return null;
      final result = await Purchases.logIn(appUserId);
      // `logIn` returns a LogInResult that contains `customerInfo`.
      return result.customerInfo;
    } catch (e, st) {
      app_log.LogHandler.error('RevenueCatService', 'logIn failed', e, st);
      rethrow;
    }
  }

  /// Log out the current RevenueCat user and clear RevenueCat state.
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (e, st) {
      app_log.LogHandler.warning('RevenueCatService', 'logOut failed', e, st);
      rethrow;
    }
  }

  /// Helper: log in current Supabase user to RevenueCat if available.
  Future<CustomerInfo?> logInCurrentSupabaseUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return logIn(user.id);
  }
}

/// Result of a purchase attempt.
class RevenueCatPurchaseResult {
  final bool success;
  final bool cancelled;
  final CustomerInfo? customerInfo;
  final String? errorMessage;

  factory RevenueCatPurchaseResult._from({
    required bool success,
    required bool cancelled,
    CustomerInfo? customerInfo,
    String? errorMessage,
  }) => RevenueCatPurchaseResult._(
        success: success,
        cancelled: cancelled,
        customerInfo: customerInfo,
        errorMessage: errorMessage,
      );

  RevenueCatPurchaseResult._({
    required this.success,
    required this.cancelled,
    this.customerInfo,
    this.errorMessage,
  });

  factory RevenueCatPurchaseResult.success(CustomerInfo info) =>
      RevenueCatPurchaseResult._from(success: true, cancelled: false, customerInfo: info);

  factory RevenueCatPurchaseResult.cancelled() =>
      RevenueCatPurchaseResult._from(success: false, cancelled: true);

  factory RevenueCatPurchaseResult.failure(String message) =>
      RevenueCatPurchaseResult._from(success: false, cancelled: false, errorMessage: message);
}

