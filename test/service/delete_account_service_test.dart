import 'package:flutter_test/flutter_test.dart';
import 'package:flex_gym_inventory/src/data/dtos/delete_account_dto.dart';
import 'package:flex_gym_inventory/service/delete_account_service.dart';

void main() {
  group('DeleteAccountDto', () {
    test('includes reason and details when provided', () {
      final dto = DeleteAccountDto(
        reason: DeleteAccountReason.missingFeatures,
        details: 'Need more workouts',
      );

      expect(dto.toJson(), {
        'reason': 'missing_features',
        'details': 'Need more workouts',
      });
    });

    test('omits empty details and allows no reason', () {
      final dto = DeleteAccountDto();

      expect(dto.toJson(), {});
    });
  });

  group('DeleteAccountService', () {
    test('maps reason values into stable machine-readable keys', () {
      expect(DeleteAccountReason.notUsingApp.backendValue, 'not_using_app');
      expect(DeleteAccountReason.other.backendValue, 'other');
      expect(DeleteAccountReason.switchingApps.backendValue, 'switching_apps');
    });
  });
}
