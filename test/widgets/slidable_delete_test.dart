import 'dart:async';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/wishlist_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/src/screens/wishlist.dart';
import 'package:flex_gym_inventory/src/widgets/cards/equipment_card.dart';
import 'package:flex_gym_inventory/src/widgets/dialogs/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEquipmentRepository extends Mock implements EquipmentRepository {}

class _MockWishlistRepository extends Mock implements WishlistRepository {}

const _equipmentId = 42;
const _wishlistId = 84;

Equipment _equipment() {
  final item = Equipment(
    gymId: 'gym-a',
    name: 'Dumbbell',
    category: EquipmentCategory.weights,
    brand: 'Brand',
    model: 'Model',
    trainingStyle: TrainingStyle.general,
    quantity: 1,
    condition: EquipmentCondition.good,
  );
  item.id = _equipmentId;
  return item;
}

Wishlist _wishlist() {
  final item = Wishlist(
    userId: 'user-a',
    name: 'Power Rack',
    wishlistType: WishlistType.newItem,
    category: EquipmentCategory.racks,
    brand: 'Brand',
    priority: WishlistPriority.high,
  );
  item.id = _wishlistId;
  return item;
}

Widget _equipmentCardApp(EquipmentRepository repository) {
  return MaterialApp(
    home: Builder(
      builder:
          (context) => Scaffold(
            body: EquipmentCard(
              itemName: 'Dumbbell',
              quantity: 1,
              category: EquipmentCategory.weights,
              brand: 'Brand',
              isarId: _equipmentId,
              onDeleteCallback: (id) {
                showDeleteConfirmation<Equipment>(
                  context: context,
                  title: 'Delete Equipment',
                  content: 'Are you sure you want to delete this item?',
                  delete: () => repository.deleteEquipment(id),
                );
              },
            ),
          ),
    ),
  );
}

Future<void> _openDeleteConfirmation(WidgetTester tester) async {
  await tester.drag(find.byType(Slidable).first, const Offset(-500, 0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete').first);
  await tester.pumpAndSettle();
}

Future<void> _confirmDelete(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('equipment delete can be canceled without calling repository', (
    tester,
  ) async {
    final repository = _MockEquipmentRepository();
    await tester.pumpWidget(_equipmentCardApp(repository));

    await _openDeleteConfirmation(tester);
    expect(find.text('Delete Equipment'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => repository.deleteEquipment(any()));
  });

  testWidgets('equipment confirmation sends the card Isar ID to repository', (
    tester,
  ) async {
    final repository = _MockEquipmentRepository();
    when(
      () => repository.deleteEquipment(_equipmentId),
    ).thenAnswer((_) async => _equipment());
    await tester.pumpWidget(_equipmentCardApp(repository));

    await _openDeleteConfirmation(tester);
    await _confirmDelete(tester);

    verify(() => repository.deleteEquipment(_equipmentId)).called(1);
    expect(find.text('Delete failed'), findsNothing);
  });

  testWidgets('wishlist cancel leaves item and does not call repository', (
    tester,
  ) async {
    final repository = _MockWishlistRepository();
    final item = _wishlist();
    when(() => repository.getAll()).thenAnswer((_) async => [item]);
    await tester.pumpWidget(
      MaterialApp(home: WishlistScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await _openDeleteConfirmation(tester);
    expect(find.text('Delete Item'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Power Rack'), findsOneWidget);
    verifyNever(() => repository.deleteWishlist(any()));
  });

  testWidgets('wishlist confirmation deletes the ID and refreshes the list', (
    tester,
  ) async {
    final repository = _MockWishlistRepository();
    final item = _wishlist();
    final items = [item];
    when(
      () => repository.getAll(),
    ).thenAnswer((_) async => List<Wishlist>.of(items));
    when(() => repository.deleteWishlist(_wishlistId)).thenAnswer((_) async {
      items.clear();
      return item;
    });
    await tester.pumpWidget(
      MaterialApp(home: WishlistScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await _openDeleteConfirmation(tester);
    await _confirmDelete(tester);

    verify(() => repository.deleteWishlist(_wishlistId)).called(1);
    expect(find.text('Power Rack'), findsNothing);
    expect(find.text('Looks like your wishlist is empty.'), findsOneWidget);
  });

  testWidgets('failed wishlist deletion reports failure and keeps the item', (
    tester,
  ) async {
    final repository = _MockWishlistRepository();
    final item = _wishlist();
    when(() => repository.getAll()).thenAnswer((_) async => [item]);
    when(
      () => repository.deleteWishlist(_wishlistId),
    ).thenAnswer((_) async => null);
    await tester.pumpWidget(
      MaterialApp(home: WishlistScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await _openDeleteConfirmation(tester);
    await _confirmDelete(tester);

    expect(find.text('Delete failed'), findsOneWidget);
    expect(find.text('Power Rack'), findsOneWidget);
    verify(() => repository.getAll()).called(1);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('disposal during wishlist deletion prevents refresh', (
    tester,
  ) async {
    final repository = _MockWishlistRepository();
    final item = _wishlist();
    final result = Completer<Wishlist?>();
    when(() => repository.getAll()).thenAnswer((_) async => [item]);
    when(
      () => repository.deleteWishlist(_wishlistId),
    ).thenAnswer((_) => result.future);
    await tester.pumpWidget(
      MaterialApp(home: WishlistScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    await _openDeleteConfirmation(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pump();
    await tester.pumpWidget(const MaterialApp(home: Text('Other screen')));

    result.complete(item);
    await tester.pump();

    expect(find.text('Other screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
    verify(() => repository.getAll()).called(1);
  });
}
