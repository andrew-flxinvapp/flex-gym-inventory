import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/src/widgets/cards/equipment_card.dart';
import 'package:flex_gym_inventory/src/widgets/cards/wishlist_item_card.dart';
import 'package:flex_gym_inventory/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingIconAssetBundle extends CachingAssetBundle {
  _FailingIconAssetBundle(this.asset);

  final String asset;

  @override
  Future<ByteData> load(String key) {
    if (key == asset) {
      return Future.error(StateError('Unavailable asset: $key'));
    }
    return rootBundle.load(key);
  }
}

Finder _categoryIcon(String asset) => find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == asset,
);

void _expectCategoryIcon(WidgetTester tester, EquipmentCategory category) {
  final icon = tester.widget<Image>(
    _categoryIcon(category.placeholderIconAsset),
  );

  expect(icon.width, 32);
  expect(icon.height, 32);
  expect(icon.color, AppTheme.lightTextPrimary);
}

void main() {
  testWidgets('equipment card renders the assigned category placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EquipmentCard(
            itemName: 'Power Rack',
            quantity: 1,
            category: EquipmentCategory.racks,
            brand: 'Brand',
          ),
        ),
      ),
    );

    _expectCategoryIcon(tester, EquipmentCategory.racks);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wishlist card uses the category from its wishlist record', (
    tester,
  ) async {
    final item = Wishlist(
      userId: 'user',
      name: 'Adjustable Bench',
      wishlistType: WishlistType.newItem,
      category: EquipmentCategory.benches,
      brand: 'Brand',
      priority: WishlistPriority.medium,
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WishlistItemCard.fromWishlist(item))),
    );

    _expectCategoryIcon(tester, EquipmentCategory.benches);
    expect(tester.takeException(), isNull);
  });

  for (final category in EquipmentCategory.values) {
    testWidgets('equipment card handles an unavailable ${category.name} icon', (
      tester,
    ) async {
      final reportedErrors = <FlutterErrorDetails>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = reportedErrors.add;
      try {
        await tester.pumpWidget(
          DefaultAssetBundle(
            bundle: _FailingIconAssetBundle(category.placeholderIconAsset),
            child: MaterialApp(
              home: Scaffold(
                body: EquipmentCard(
                  itemName: 'Equipment',
                  quantity: 1,
                  category: category,
                  brand: 'Brand',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(reportedErrors, hasLength(1));
      } finally {
        FlutterError.onError = previousOnError;
      }
    });
  }

  testWidgets('wishlist card handles an unavailable category icon', (
    tester,
  ) async {
    final reportedErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = reportedErrors.add;
    final item = Wishlist(
      userId: 'user',
      name: 'Adjustable Bench',
      wishlistType: WishlistType.newItem,
      category: EquipmentCategory.benches,
      brand: 'Brand',
      priority: WishlistPriority.medium,
    );
    try {
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: _FailingIconAssetBundle(
            EquipmentCategory.benches.placeholderIconAsset,
          ),
          child: MaterialApp(
            home: Scaffold(body: WishlistItemCard.fromWishlist(item)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(reportedErrors, hasLength(1));
    } finally {
      FlutterError.onError = previousOnError;
    }
  });
}
