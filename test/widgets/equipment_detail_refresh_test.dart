import 'dart:convert';
import 'dart:io';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/screens/edit_equipment.dart';
import 'package:flex_gym_inventory/src/screens/equipment_detail.dart';
import 'package:flex_gym_inventory/src/widgets/cards/details_card.dart';
import 'package:flex_gym_inventory/src/widgets/cards/notes_card.dart';
import 'package:flex_gym_inventory/src/widgets/cards/purchase_card.dart';
import 'package:flex_gym_inventory/src/widgets/inputs/multiline_text_input.dart';
import 'package:flex_gym_inventory/src/widgets/inputs/text_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = 'equipment-detail-test-user';

class _MemoryAuthStorage extends GotrueAsyncStorage {
  final Map<String, String> _values = {};

  @override
  Future<String?> getItem({required String key}) async => _values[key];

  @override
  Future<void> removeItem({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _values[key] = value;
  }
}

class _CountingRepository extends EquipmentRepository {
  _CountingRepository(Isar isar) : super(isar: isar);

  int loads = 0;
  int pendingLoads = 0;
  bool failNextLoad = false;

  @override
  Future<Equipment?> getByIsarId(int isarId) async {
    loads++;
    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('Test load failure');
    }
    pendingLoads++;
    try {
      return await super.getByIsarId(isarId);
    } finally {
      pendingLoads--;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Isar isar;
  late _CountingRepository repository;
  late Equipment equipment;

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://equipment-detail-test.supabase.co',
      publishableKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryAuthStorage(),
      ),
    );
    await Isar.initializeIsarCore(download: true);
    directory = await Directory.systemTemp.createTemp('equipment_detail_test');
    isar = await Isar.open(
      [GymSchema, EquipmentSchema],
      directory: directory.path,
      name: 'equipment_detail_test',
    );
    await IsarService.initForTesting(instance: isar);
  });

  setUp(() async {
    await _setUser(_userId);
    repository = _CountingRepository(isar);
    await isar.writeTxn(() async {
      await isar.gyms.clear();
      await isar.equipments.clear();
      await isar.gyms.put(
        Gym(
          userId: _userId,
          gymId: 'gym-a',
          name: 'Home Gym',
          createdDate: DateTime(2026),
        ),
      );
      equipment = Equipment(
        gymId: 'gym-a',
        name: 'Original name',
        category: EquipmentCategory.weights,
        brand: 'Original brand',
        model: 'Original model',
        trainingStyle: TrainingStyle.general,
        quantity: 1,
        condition: EquipmentCondition.good,
        value: 25,
        maintenanceNotes: 'Original notes',
      );
      await isar.equipments.put(equipment);
    });
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
    await directory.delete();
    await Supabase.instance.dispose();
  });

  testWidgets('saving reloads the detail card and other displayed fields', (
    tester,
  ) async {
    await _openDetail(tester, repository, equipment.id);
    expect(_details(tester)['Brand'], 'Original brand');

    await _openEdit(tester);
    await _enterField(tester, 'Name', 'Updated name');
    await _enterField(tester, 'Brand', 'Updated brand');
    await _enterField(tester, 'Model', 'Updated model');
    await _enterField(tester, 'Value', '125');
    final notes = find.byType(CustomMultilineTextInput);
    await tester.ensureVisible(notes);
    await tester.enterText(
      find.descendant(of: notes, matching: find.byType(TextFormField)),
      'Updated notes',
    );
    await _save(tester);
    await _waitForEditClosed(tester);
    await _waitFor(tester, find.byType(DetailsCard));

    expect(repository.loads, 2);
    expect(find.text('Updated name'), findsNWidgets(2));
    expect(_details(tester)['Brand'], 'Updated brand');
    expect(_details(tester)['Model'], 'Updated model');
    final purchase = tester.widget<PurchaseCard>(find.byType(PurchaseCard));
    expect(Map.fromEntries(purchase.details)['Purchase Price'], '125.00');
    expect(
      tester.widget<NotesCard>(find.byType(NotesCard)).notes,
      'Updated notes',
    );
    expect(tester.takeException(), isNull);
    await _finishSnackbarTimers(tester);
  });

  testWidgets('cancel and unsuccessful save do not reload details', (
    tester,
  ) async {
    await _openDetail(tester, repository, equipment.id);
    await _openEdit(tester);
    await _cancel(tester);
    expect(repository.loads, 1);
    expect(_details(tester)['Brand'], 'Original brand');

    await _openEdit(tester);
    await tester.runAsync(() async {
      await isar.writeTxn(() => isar.equipments.delete(equipment.id));
    });
    await _save(tester);
    await _waitFor(tester, find.text('Equipment unavailable'));
    expect(find.byType(EditEquipmentScreen), findsOneWidget);
    expect(repository.loads, 1);

    await _cancel(tester);
    expect(repository.loads, 1);
    expect(_details(tester)['Brand'], 'Original brand');
    await _finishSnackbarTimers(tester);
  });

  testWidgets('a successful reload clears an earlier reload error', (
    tester,
  ) async {
    await _openDetail(tester, repository, equipment.id);
    await _openEdit(tester);
    await _enterField(tester, 'Brand', 'First change');
    repository.failNextLoad = true;
    await _save(tester);
    await _waitForEditClosed(tester);
    await _waitFor(tester, find.textContaining('Test load failure'));

    await _openEdit(tester);
    await _enterField(tester, 'Brand', 'Second change');
    await _save(tester);
    await _waitForEditClosed(tester);
    await _waitFor(tester, find.byType(DetailsCard));
    expect(_details(tester)['Brand'], 'Second change');
    expect(find.textContaining('Test load failure'), findsNothing);
    await _finishSnackbarTimers(tester);
  });

  testWidgets(
    'an edit result after an account switch cannot trigger a reload',
    (tester) async {
      await _openDetail(tester, repository, equipment.id, fakeEdit: true);
      await _openEdit(tester, fake: true);
      await tester.runAsync(() => _setUser('another-user'));
      await _waitForLoads(tester, repository, 2);
      await tester.runAsync(() => _setUser(_userId));
      await _waitForLoads(tester, repository, 3);
      await _waitFor(tester, find.text('Original name', skipOffstage: false));

      await tester.tap(find.text('Return saved result'));
      await tester.pumpAndSettle();
      expect(repository.loads, 3);
      expect(_details(tester)['Brand'], 'Original brand');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an edit result after detail disposal does not reload', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    await _openDetail(
      tester,
      repository,
      equipment.id,
      fakeEdit: true,
      navigatorKey: navigatorKey,
    );
    final detailRoute =
        ModalRoute.of(tester.element(find.byType(EquipmentDetailScreen)))!;
    await _openEdit(tester, fake: true);
    navigatorKey.currentState!.removeRoute(detailRoute);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return saved result'));
    await tester.pumpAndSettle();
    expect(repository.loads, 1);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _setUser(String userId) {
  return Supabase.instance.client.auth.setInitialSession(
    jsonEncode({
      'access_token': 'test-access-token',
      'refresh_token': 'test-refresh-token',
      'token_type': 'bearer',
      'expires_in': 3600,
      'user': {
        'id': userId,
        'app_metadata': <String, Object>{},
        'user_metadata': <String, Object>{},
        'aud': 'authenticated',
        'created_at': DateTime(2026).toIso8601String(),
      },
    }),
  );
}

Future<void> _openDetail(
  WidgetTester tester,
  _CountingRepository repository,
  int id, {
  bool fakeEdit = false,
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
  });
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.equipmentDetail) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => EquipmentDetailScreen(repository: repository),
          );
        }
        if (settings.name == AppRoutes.editEquipment) {
          return MaterialPageRoute<Equipment>(
            settings: settings,
            builder:
                (context) =>
                    fakeEdit
                        ? Scaffold(
                          body: Center(
                            child: ElevatedButton(
                              onPressed:
                                  () => Navigator.pop(
                                    context,
                                    Equipment(
                                      gymId: 'gym-a',
                                      name: 'Stale result',
                                      category: EquipmentCategory.weights,
                                      brand: 'Stale brand',
                                      model: 'Stale model',
                                      trainingStyle: TrainingStyle.general,
                                      quantity: 1,
                                      condition: EquipmentCondition.good,
                                    ),
                                  ),
                              child: const Text('Return saved result'),
                            ),
                          ),
                        )
                        : const EditEquipmentScreen(),
          );
        }
        return null;
      },
      home: Builder(
        builder:
            (context) => Scaffold(
              body: ElevatedButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      AppRoutes.equipmentDetail,
                      arguments: id,
                    ),
                child: const Text('Open detail'),
              ),
            ),
      ),
    ),
  );
  await tester.tap(find.text('Open detail'));
  await _waitFor(tester, find.byType(DetailsCard));
}

Future<void> _openEdit(WidgetTester tester, {bool fake = false}) async {
  await tester.tap(
    find.descendant(
      of: find.byType(EquipmentDetailScreen),
      matching: find.byTooltip('Action'),
    ),
  );
  await _waitFor(
    tester,
    fake ? find.text('Return saved result') : find.text('Home Gym'),
  );
}

Future<void> _enterField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CustomTextInputField && widget.hintText == label,
  );
  await tester.ensureVisible(field);
  await tester.enterText(
    find.descendant(of: field, matching: find.byType(TextFormField)),
    value,
  );
  await tester.pump();
}

Future<void> _save(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
}

Future<void> _cancel(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Cancel'));
  await tester.tap(find.text('Cancel'));
  await _waitForEditClosed(tester);
  await _waitFor(tester, find.byType(DetailsCard));
}

Map<String, String> _details(WidgetTester tester) => Map.fromEntries(
  tester.widget<DetailsCard>(find.byType(DetailsCard)).details,
);

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  fail('Widget did not appear: $finder');
}

Future<void> _waitForEditClosed(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(EditEquipmentScreen).evaluate().isEmpty) {
      await tester.pumpAndSettle();
      return;
    }
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  fail('Edit Equipment did not close');
}

Future<void> _finishSnackbarTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Future<void> _waitForLoads(
  WidgetTester tester,
  _CountingRepository repository,
  int count,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (repository.loads >= count && repository.pendingLoads == 0) return;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
  fail('Expected $count loads; got ${repository.loads}');
}
