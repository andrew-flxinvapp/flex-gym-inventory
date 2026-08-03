import 'package:flex_gym_inventory/enum/app_enums.dart';

class SupportRequestDto {
  final SupportCategory category;
  final String subject;
  final String message;
  final String? screenshotStoragePath;
  final String? appVersion;
  final String? buildNumber;
  final String? platform;
  final String? deviceModel;
  final String? osVersion;

  const SupportRequestDto({
    required this.category,
    required this.subject,
    required this.message,
    this.screenshotStoragePath,
    this.appVersion,
    this.buildNumber,
    this.platform,
    this.deviceModel,
    this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'subject': subject.trim(),
      'message': message.trim(),
      'screenshot_storage_path': screenshotStoragePath,
      'app_version': appVersion,
      'build_number': buildNumber,
      'platform': platform,
      'device_model': deviceModel,
      'os_version': osVersion,
    };
  }
}