import 'package:flex_gym_inventory/enum/app_enums.dart';

class SupportRequestDto {
  final SupportCategory category;
  final String subject;
  final String message;
  final String? appVersion;
  final String? buildNumber;
  final String? platform;
  final String? deviceModel;
  final String? osVersion;

  const SupportRequestDto({
    required this.category,
    required this.subject,
    required this.message,
    this.appVersion,
    this.buildNumber,
    this.platform,
    this.deviceModel,
    this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': _categoryToBackendValue(category),
      'subject': subject.trim(),
      'message': message.trim(),
      'app_version': appVersion,
      'build_number': buildNumber,
      'platform': platform,
      'device_model': deviceModel,
      'os_version': osVersion,
    };
  }

  String _categoryToBackendValue(SupportCategory c) {
    switch (c) {
      case SupportCategory.bugReport:
        return 'bug_report';
      case SupportCategory.account:
        return 'account';
      case SupportCategory.equipment:
        return 'equipment';
      case SupportCategory.gym:
        return 'gyms';
      case SupportCategory.wishlist:
        return 'wishlist';
      case SupportCategory.export:
        return 'export';
      case SupportCategory.subscriptions:
        return 'subscriptions';
      case SupportCategory.featureRequest:
        return 'feature_request';
      case SupportCategory.generalQuestion:
        return 'general_question';
      case SupportCategory.other:
        return 'other';
    }
  }
}