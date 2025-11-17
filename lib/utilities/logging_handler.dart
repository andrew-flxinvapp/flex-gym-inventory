import 'package:logging/logging.dart';

class LogHandler {
  static final Logger _logger = Logger('FlexGymApp');

  static void setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final timestamp = record.time.toIso8601String();
      print('[${record.level.name}][$timestamp] ${record.loggerName}: ${record.message}');
      if (record.error != null) print('Error details: ${record.error}');
      if (record.stackTrace != null) print('Stack: ${record.stackTrace}');
    });
  }

  static void debug(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine('$tag: $message', error, stackTrace);
  }

  static void info(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info('$tag: $message', error, stackTrace);
  }

  static void warning(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning('$tag: $message', error, stackTrace);
  }

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe('$tag: $message', error, stackTrace);
  }
}
