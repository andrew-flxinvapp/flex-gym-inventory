import 'dart:async';
import 'dart:convert';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/routes/routes.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/src/screens/add_equipment.dart';
import 'package:flex_gym_inventory/src/screens/gym_detail.dart';
import 'package:flex_gym_inventory/src/widgets/cards/gym_stats_card.dart';
import 'package:flex_gym_inventory/src/widgets/inputs/dropdown_field.dart';
import 'package:flex_gym_inventory/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userId = 'gym-detail-test-user';

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

class _EquipmentDraft {
  const _EquipmentDraft({
    required this.name,
    required this.quantity,
    required this.value,
  });

  final String name;
  final int quantity;
  final double value;
}

class _FakeEquipmentRepository extends EquipmentRepository {
  final List<Equipment> items = [];
  final StreamController<void> changes = StreamController<void>.broadcast(
    sync: true,
  );
  int _nextId = 1;

  @override
  Stream<void> watchForGym(Gym gym) => changes.stream;

  @override
  Future<List<Equipment>> getAllForGym(
    String gymId, {
    String? search,
    EquipmentCategory? category,
    EquipmentCondition? condition,
    EquipmentSort sort = EquipmentSort.nameAsc,
  }) async => items.where((item) => item.gymId == gymId).toList();

  Equipment add(_EquipmentDraft draft, String gymId) {
    final item = _equipment(
      gymId: gymId,
      name: draft.name,
      quantity: draft.quantity,
      value: draft.value,
    )..id = _nextId++;
    items.add(item);
    changes.add(null);
    return item;
  }

  @override
  Future<Equipment?> deleteEquipment(int id) async {
    final index = items.indexWhere((item) => item.id == id);
    if (index < 0) return null;
    final deleted = items.removeAt(index);
    changes.add(null);
    return deleted;
  }

  Future<void> close() => changes.close();
}

class _AddEquipmentRoute extends StatefulWidget {
  const _AddEquipmentRoute({
    required this.repository,
    required this.gyms,
    required this.draft,
  });

  final _FakeEquipmentRepository repository;
  final List<Gym> gyms;
  final _EquipmentDraft draft;

  @override
  State<_AddEquipmentRoute> createState() => _AddEquipmentRouteState();
}

class _AddEquipmentRouteState extends State<_AddEquipmentRoute> {
  Equipment? _created;

  @override
  Widget build(BuildContext context) {
    final targetIsarId = ModalRoute.of(context)?.settings.arguments as int?;
    return Scaffold(
      body: Center(
        child:
            _created == null
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Target gym Isar ID: $targetIsarId'),
                    ElevatedButton(
                      onPressed: () {
                        final gym =
                            targetIsarId == null
                                ? widget.gyms.first
                                : widget.gyms.singleWhere(
                                  (candidate) => candidate.id == targetIsarId,
                                );
                        setState(
                          () =>
                              _created = widget.repository.add(
                                widget.draft,
                                gym.gymId,
                              ),
                        );
                      },
                      child: const Text('Save equipment'),
                    ),
                  ],
                )
                : ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_created),
                  child: const Text('Return to gym'),
                ),
      ),
    );
  }
}

class _ControlledEquipmentRepository extends EquipmentRepository {
  final StreamController<void> changes = StreamController<void>.broadcast(
    sync: true,
  );
  final StreamController<int> loadsStarted = StreamController<int>.broadcast(
    sync: true,
  );
  final List<Completer<List<Equipment>>> loads = [];

  @override
  Stream<void> watchForGym(Gym gym) => changes.stream;

  @override
  Future<List<Equipment>> getAllForGym(
    String gymId, {
    String? search,
    EquipmentCategory? category,
    EquipmentCondition? condition,
    EquipmentSort sort = EquipmentSort.nameAsc,
  }) {
    final load = Completer<List<Equipment>>();
    loads.add(load);
    loadsStarted.add(loads.length);
    return load.future;
  }

  Future<void> close() async {
    await changes.close();
    await loadsStarted.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeEquipmentRepository repository;

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://gym-detail-test.supabase.co',
      publishableKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUri: false,
        pkceAsyncStorage: _MemoryAuthStorage(),
      ),
    );
    await Supabase.instance.client.auth.setInitialSession(
      jsonEncode({
        'access_token': 'test-access-token',
        'refresh_token': 'test-refresh-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': {
          'id': _userId,
          'app_metadata': <String, Object>{},
          'user_metadata': <String, Object>{},
          'aud': 'authenticated',
          'created_at': DateTime(2026).toIso8601String(),
        },
      }),
    );
  });

  setUp(() {
    repository = _FakeEquipmentRepository();
  });

  tearDown(() async {
    await repository.close();
  });

  tearDownAll(() async {
    await Supabase.instance.dispose();
  });

  testWidgets(
    'mounted Gym Detail follows add and delete changes while a child route is open',
    (tester) async {
      final gym = _gym(1, 'gym-a', 'Home Gym');
      final drafts = <_EquipmentDraft>[
        const _EquipmentDraft(name: 'Dumbbell', quantity: 2, value: 25),
        const _EquipmentDraft(name: 'Barbell', quantity: 1, value: 100),
      ];

      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
      });
      await tester.pumpWidget(_gymDetailApp(repository, gym, [gym], drafts));
      await _pumpUntilVisible(
        tester,
        find.text('Looks like your gym is empty.'),
      );

      await tester.tap(find.text('Add Equipment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save equipment'));
      await tester.pumpAndSettle();

      expect(
        find.text('Dumbbell', skipOffstage: false),
        findsOneWidget,
        reason: 'The watcher should reload Gym Detail while Add is still open.',
      );
      await tester.tap(find.text('Return to gym'));
      await tester.pumpAndSettle();
      _expectStats(tester, itemCount: 2, estimatedValue: 50);

      final addEquipmentButton = find.ancestor(
        of: find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == AppIcons.plus,
        ),
        matching: find.byType(IconButton),
      );
      await tester.tap(addEquipmentButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save equipment'));
      await tester.pumpAndSettle();
      expect(find.text('Barbell', skipOffstage: false), findsOneWidget);
      await tester.tap(find.text('Return to gym'));
      await tester.pumpAndSettle();
      _expectStats(tester, itemCount: 3, estimatedValue: 150);

      await _deleteFirstEquipment(tester);
      expect(find.text('Dumbbell'), findsNothing);
      expect(find.text('Barbell'), findsOneWidget);
      _expectStats(tester, itemCount: 1, estimatedValue: 100);

      await _deleteFirstEquipment(tester);
      expect(find.text('Looks like your gym is empty.'), findsOneWidget);
      expect(find.byType(GymStatsCard), findsNothing);
    },
  );

  testWidgets('Gym Detail targets its displayed gym when adding equipment', (
    tester,
  ) async {
    final firstGym = _gym(1, 'gym-a', 'A Gym');
    final activeGym = _gym(2, 'gym-b', 'B Gym');

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });
    await tester.pumpWidget(
      _gymDetailApp(
        repository,
        activeGym,
        [firstGym, activeGym],
        [
          const _EquipmentDraft(
            name: 'Active gym equipment',
            quantity: 1,
            value: 10,
          ),
        ],
      ),
    );
    await _pumpUntilVisible(tester, find.text('Looks like your gym is empty.'));
    await tester.tap(find.text('Add Equipment'));
    await tester.pumpAndSettle();

    expect(find.text('Target gym Isar ID: ${activeGym.id}'), findsOneWidget);
    await tester.tap(find.text('Save equipment'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Return to gym'));
    await tester.pumpAndSettle();

    expect(
      repository.items
          .where((item) => item.gymId == activeGym.gymId)
          .map((item) => item.name),
      ['Active gym equipment'],
    );
    expect(
      repository.items.where((item) => item.gymId == firstGym.gymId),
      isEmpty,
    );
    expect(find.text('Active gym equipment'), findsOneWidget);
  });

  testWidgets('Add Equipment selects the gym ID supplied by Gym Detail', (
    tester,
  ) async {
    final firstGym = _gym(1, 'gym-a', 'A Gym');
    final activeGym = _gym(2, 'gym-b', 'B Gym');

    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          routes: {
            AppRoutes.addEquipment:
                (_) => AddEquipmentScreen(
                  gymLoader: () async => [firstGym, activeGym],
                ),
          },
          home: Builder(
            builder:
                (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed:
                        () => Navigator.of(context).pushNamed(
                          AppRoutes.addEquipment,
                          arguments: activeGym.id,
                        ),
                    child: const Text('Open Add Equipment'),
                  ),
                ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open Add Equipment'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final gymDropdown = tester.widget<CustomDropdownField<Gym>>(
      find.byType(CustomDropdownField<Gym>),
    );
    expect(gymDropdown.value?.id, activeGym.id);
    expect(gymDropdown.items.map((gym) => gym.name), ['A Gym', 'B Gym']);

    await tester.tap(find.text('B Gym'));
    await tester.pumpAndSettle();
    expect(find.text('A Gym'), findsOneWidget);
  });

  testWidgets('a late initial Future result cannot overwrite a newer load', (
    tester,
  ) async {
    final gym = _gym(1, 'gym-a', 'Home Gym');
    final controlledRepository = _ControlledEquipmentRepository();
    addTearDown(controlledRepository.close);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
    });

    final firstLoad = controlledRepository.loadsStarted.stream.first;
    await tester.pumpWidget(
      MaterialApp(
        home: GymDetailScreen(
          equipmentRepository: controlledRepository,
          activeGymLoader: () async => gym,
        ),
      ),
    );
    expect(await firstLoad.timeout(const Duration(seconds: 2)), 1);

    final secondLoad = controlledRepository.loadsStarted.stream.first;
    controlledRepository.changes.add(null);
    await tester.pump();
    expect(await secondLoad.timeout(const Duration(seconds: 2)), 2);

    final freshEquipment = _equipment(
      gymId: gym.gymId,
      name: 'Fresh result',
      quantity: 3,
      value: 40,
    );
    controlledRepository.loads[1].complete([freshEquipment]);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Fresh result'), findsOneWidget);
    _expectStats(tester, itemCount: 3, estimatedValue: 120);

    controlledRepository.loads[0].complete([]);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Fresh result'), findsOneWidget);
    _expectStats(tester, itemCount: 3, estimatedValue: 120);
  });
}

Widget _gymDetailApp(
  _FakeEquipmentRepository repository,
  Gym activeGym,
  List<Gym> gyms,
  List<_EquipmentDraft> drafts,
) {
  return MaterialApp(
    routes: {
      AppRoutes.addEquipment:
          (context) => _AddEquipmentRoute(
            repository: repository,
            gyms: gyms,
            draft: drafts.removeAt(0),
          ),
    },
    home: GymDetailScreen(
      equipmentRepository: repository,
      activeGymLoader: () async => activeGym,
    ),
  );
}

Gym _gym(int id, String gymId, String name) =>
    Gym(userId: _userId, gymId: gymId, name: name, createdDate: DateTime(2026))
      ..id = id;

Equipment _equipment({
  required String gymId,
  required String name,
  required int quantity,
  required double value,
}) => Equipment(
  gymId: gymId,
  name: name,
  category: EquipmentCategory.weights,
  brand: 'Brand',
  model: 'Model',
  trainingStyle: TrainingStyle.general,
  quantity: quantity,
  condition: EquipmentCondition.good,
  value: value,
);

Future<void> _deleteFirstEquipment(WidgetTester tester) async {
  await tester.drag(find.byType(Slidable).first, const Offset(-500, 0));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Delete').first);
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
  await tester.pumpAndSettle();
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail('Widget did not appear: $finder');
}

void _expectStats(
  WidgetTester tester, {
  required int itemCount,
  required double estimatedValue,
}) {
  final stats = tester.widget<GymStatsCard>(find.byType(GymStatsCard));
  expect(stats.itemCount, itemCount);
  expect(stats.estimatedValue, estimatedValue);
}
