import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

class LogHandler {
  static final Logger _logger = Logger('FlexGymApp');

  static void setupLogging() {
    // Be verbose in debug builds, but keep INFO+ in non-debug to avoid noisy SDK logs.
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    Logger.root.onRecord.listen((record) {
      final timestamp = record.time.toIso8601String();
      debugPrint(
        '[${record.level.name}][$timestamp] ${record.loggerName}: ${record.message}',
      );
      if (record.error != null) debugPrint('Error details: ${record.error}');
      if (record.stackTrace != null) debugPrint('Stack: ${record.stackTrace}');
    });
    // Allow adjusting levels on non-root loggers.
    hierarchicalLoggingEnabled = true;
    // Suppress very verbose Supabase auth logs unless explicitly debugging.
    Logger('supabase.auth').level = Level.INFO;
  }

  static void debug(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.fine('$tag: $message', error, stackTrace);
  }

  static void info(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.info('$tag: $message', error, stackTrace);
  }

  static void warning(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.warning('$tag: $message', error, stackTrace);
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _logger.severe('$tag: $message', error, stackTrace);
  }
}
