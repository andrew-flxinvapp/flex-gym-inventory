import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DiagnosticsInfo {
  final String? appVersion;
  final String? buildNumber;
  final String? platform;
  final String? deviceModel;
  final String? osVersion;

  const DiagnosticsInfo({
    this.appVersion,
    this.buildNumber,
    this.platform,
    this.deviceModel,
    this.osVersion,
  });

  Map<String, String?> toMap() => {
        'appVersion': appVersion,
        'buildNumber': buildNumber,
        'platform': platform,
        'deviceModel': deviceModel,
        'osVersion': osVersion,
      };
}

class DiagnosticsHelper {
  /// Collects basic app + device diagnostics.
  /// Uses `package_info_plus` and `device_info_plus` under the hood.
  static Future<DiagnosticsInfo> collect() async {
    String? appVersion;
    String? buildNumber;
    String? platform;
    String? deviceModel;
    String? osVersion;

    try {
      final pkg = await PackageInfo.fromPlatform();
      appVersion = pkg.version;
      buildNumber = pkg.buildNumber;
    } catch (_) {
      appVersion = null;
      buildNumber = null;
    }

    platform = Platform.operatingSystem;

    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceModel = '${info.manufacturer ?? ''} ${info.model ?? ''}'.trim();
        osVersion = info.version.release;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        // utsname.machine is the device identifier (e.g. iPhone14,3)
        deviceModel = info.utsname.machine ?? info.name;
        osVersion = info.systemVersion;
      } else {
        // Web, linux, macos, windows
        final info = await deviceInfo.deviceInfo;
        deviceModel = info.data['model']?.toString() ?? info.data['name']?.toString();
        osVersion = info.data['osVersion']?.toString() ?? info.data['version']?.toString();
      }
    } catch (_) {
      deviceModel = null;
      osVersion = null;
    }

    return DiagnosticsInfo(
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: platform,
      deviceModel: deviceModel,
      osVersion: osVersion,
    );
  }
}
