import 'package:flutter/foundation.dart';

class LogHandler {
  static void debug(String tag, String message) {
    if (kDebugMode) {
      print('DEBUG: $tag: $message'); // Print debug messages only in debug mode
    }
  }
}

void info(String tag, String message) {
  if(kDebugMode) {
    print('[INFO] $tag: $message'); // Print info messages only in debug mode
  }
}

void warning(String tag, String message) {
  if(kDebugMode) {
    print('[WARNING] $tag: $message'); // Print warning messages only in debug mode
  }
}

void error(String tag, String message, [Object? error]) {
  if(kDebugMode) {
    print('[ERROR] $tag: $message'); // Print error messages only in debug mode
    if (error != null) {
      print('Error details: $error');
    }
  }
}