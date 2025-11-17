import 'package:flutter/material.dart';
import 'package:flex_gym_inventory/utilities/logging_handler.dart';

class ErrorHandler {
  /// Log and show a non-blocking error message to the user.
  static void showError(BuildContext context, String tag, String message, [Object? error, StackTrace? stack]) {
    LogHandler.error(tag, message, error, stack);
    // External error reporting hook (e.g., Sentry)
    // Example: Sentry.captureException(error, stackTrace: stack);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  /// Log a warning or recoverable issue (no UI).
  static void warn(String tag, String message, [Object? error, StackTrace? stack]) {
    LogHandler.warning(tag, message, error, stack);
  }

  /// Log info for non-UI contexts.
  static void info(String tag, String message, [Object? error, StackTrace? stack]) {
    LogHandler.info(tag, message, error, stack);
  }

  /// Log silently for non-UI contexts (e.g., repository or service layer).
  static void silent(String tag, String message, [Object? error, StackTrace? stack]) {
    LogHandler.debug(tag, message, error, stack);
  }

  /// Wrap async operations to catch and log exceptions.
  static Future<void> guard(Future<void> Function() action, {String tag = 'GuardedAction'}) async {
    try {
      await action();
    } catch (e, stack) {
      LogHandler.error(tag, e.toString(), e, stack);
      // External error reporting hook (e.g., Sentry)
      // Example: Sentry.captureException(e, stackTrace: stack);
      debugPrintStack(stackTrace: stack);
    }
  }
}
