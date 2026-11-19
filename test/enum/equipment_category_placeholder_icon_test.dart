import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('maps every equipment category to a bundled placeholder icon', () async {
    const expectedAssets = {
      EquipmentCategory.weights: AppIcons.weights,
      EquipmentCategory.specialty: AppIcons.specialty,
      EquipmentCategory.machines: AppIcons.machines,
      EquipmentCategory.storage: AppIcons.storage,
      EquipmentCategory.racks: AppIcons.racks,
      EquipmentCategory.attachments: AppIcons.attachments,
      EquipmentCategory.benches: AppIcons.benches,
      EquipmentCategory.accessories: AppIcons.accessories,
      EquipmentCategory.safety: AppIcons.safety,
      EquipmentCategory.other: AppIcons.other,
    };

    expect(expectedAssets.keys.toSet(), EquipmentCategory.values.toSet());
    for (final category in EquipmentCategory.values) {
      final asset = category.placeholderIconAsset;
      expect(asset, expectedAssets[category]);
      await rootBundle.load(asset);
    }
  });
}
