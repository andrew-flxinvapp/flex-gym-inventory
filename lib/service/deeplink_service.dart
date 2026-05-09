import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';

// Wrap AppLinks so the rest of the app can remain unchanged (handler API still
// uses Uri and a params map).

/// A small, testable deep-link service that captures initial and incoming
/// deep links and forwards them to a registered handler.
///
/// Purpose: keep deep link parsing in one place. The service does NOT call
/// Supabase directly so it remains easy to unit test and keeps side-effects
/// in higher-level services or repositories.
class DeeplinkService {
  DeeplinkService._internal();
  static final DeeplinkService instance = DeeplinkService._internal();

  StreamSubscription<Uri?>? _sub;
  final AppLinks _appLinks = AppLinks();
  Future<void> Function(Uri uri, Map<String, String> params)? _handler;

  /// Initialize the deeplink listener. Call once during app startup (for
  /// example in `main()` or inside a top-level service initializer).
  Future<void> init() async {
    // Handle the initial uri if the app was started from a link.
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      }
    } catch (e, st) {
      // swallow errors but allow higher-level logging if needed
      LogHandler.warning('DeeplinkService', 'error getting initial uri: $e', e, st);
    }

    // Listen for subsequent incoming links while the app is running.
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err, st) {
      // ignore errors here, but log for diagnostics
      LogHandler.warning('DeeplinkService', 'uri link stream error: $err', err, st);
    });
  }

  /// Register a handler that will be called whenever a deep link arrives.
  /// The handler receives the parsed [Uri] and a merged map of query and
  /// fragment parameters.
  void registerHandler(Future<void> Function(Uri uri, Map<String, String> params) handler) {
    _handler = handler;
  }

  /// Remove the registered handler.
  void unregisterHandler() {
    _handler = null;
  }

  Future<void> _handleUri(Uri uri) async {
    // Parse fragment params (e.g. URLs like https://example.com/#access_token=...)
    Map<String, String> fragmentParams = {};
    if (uri.fragment.isNotEmpty) {
      try {
        fragmentParams = Uri.splitQueryString(uri.fragment);
      } catch (_) {
        // If fragment is not query-formatted, leave empty.
      }
    }

    final merged = <String, String>{};
    merged.addAll(uri.queryParameters);
    merged.addAll(fragmentParams);

    if (_handler != null) {
      try {
        await _handler!(uri, merged);
      } catch (e, st) {
        LogHandler.error('DeeplinkService', 'handler threw', e, st);
      }
    } else {
      // No handler registered — log for debugging
      LogHandler.info('DeeplinkService', 'received uri but no handler registered: $uri');
    }
  }

  /// Dispose listeners when app is shutting down.
  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
    _handler = null;
  }
}
