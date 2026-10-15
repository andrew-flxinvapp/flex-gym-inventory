import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// AppInfoService provides app version and build number retrieved from the
/// installed package info. It exposes a [ValueNotifier] so UI can react when
/// the information becomes available without introducing delays during startup.
class AppInfoService {
  AppInfoService._internal();
  static final AppInfoService instance = AppInfoService._internal();

  /// Notifier that will hold the PackageInfo once available.
  final ValueNotifier<PackageInfo?> info = ValueNotifier<PackageInfo?>(null);

  /// Initialize and fetch package info asynchronously. Safe to call multiple
  /// times; subsequent calls will overwrite the info value when available.
  Future<void> init() async {
    try {
      final pi = await PackageInfo.fromPlatform();
      info.value = pi;
    } catch (_) {
      // Swallow errors — keep info as null so callers can fall back if needed.
    }
  }

  /// Synchronous helpers that return the most recently fetched values or
  /// sensible defaults until package info is available.
  String get version => info.value?.version ?? '0.0.0';
  String get buildNumber => info.value?.buildNumber ?? '';

  /// Combined display-friendly version (e.g. 0.5.1+2)
  String get displayVersion =>
      buildNumber.isNotEmpty ? '$version+$buildNumber' : version;
}

/// Top-level singleton for easy reuse across the app.
final appInfoService = AppInfoService.instance;
