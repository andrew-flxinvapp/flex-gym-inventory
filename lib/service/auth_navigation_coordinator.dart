import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../routes/routes.dart';
import '../utilities/logging_handler.dart';

class AuthNavigationCoordinator extends NavigatorObserver {
  AuthNavigationCoordinator({
    required this.navigatorKey,
    required this.messengerKey,
    required this.currentUserId,
    required Stream<AuthState> authChanges,
  }) : _activeUserId = currentUserId() {
    _subscription = authChanges.listen(_onAuthChange, onError: _onAuthError);
  }

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final String? Function() currentUserId;
  late final StreamSubscription<AuthState> _subscription;
  String? _activeUserId;
  String? _topRoute;
  bool _navigationScheduled = false;
  bool _errorScheduled = false;
  bool _errorPending = false;

  void _onAuthChange(AuthState event) {
    final currentId = currentUserId();
    if (event.event == AuthChangeEvent.signedOut && currentId == null) {
      _activeUserId = null;
      return;
    }
    if ((event.event != AuthChangeEvent.signedIn &&
            event.event != AuthChangeEvent.passwordRecovery) ||
        currentId == null ||
        event.session?.user.id != currentId) {
      return;
    }
    if (_activeUserId == currentId) return;
    _activeUserId = currentId;
    LogHandler.info('Auth', 'Authentication succeeded');
    _scheduleNavigation();
  }

  void _onAuthError(Object error, StackTrace stackTrace) {
    reportAuthenticationError();
  }

  void reportAuthenticationError() {
    LogHandler.warning('Auth', 'Authentication failed');
    _errorPending = true;
    _scheduleError();
  }

  void _scheduleError() {
    if (_errorScheduled) return;
    _errorScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _errorScheduled = false;
      final messenger = messengerKey.currentState;
      if (!_errorPending || messenger == null) return;
      _errorPending = false;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Authentication failed. Check your connection or request a new link.',
          ),
        ),
      );
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    _topRoute = topRoute.settings.name;
    if (_errorPending) _scheduleError();
    if (_topRoute == AppRoutes.verifyEmail && currentUserId() != null) {
      _scheduleNavigation();
    }
  }

  void _scheduleNavigation() {
    // Splash and StartupRouter already resolve the current session.
    if (_navigationScheduled ||
        navigatorKey.currentState == null ||
        _topRoute == AppRoutes.splash ||
        _topRoute == AppRoutes.startupRouter) {
      return;
    }
    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigationScheduled = false;
      if (currentUserId() == null ||
          _topRoute == AppRoutes.splash ||
          _topRoute == AppRoutes.startupRouter) {
        return;
      }
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.startupRouter,
        (_) => false,
      );
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  Future<void> dispose() => _subscription.cancel();
}
