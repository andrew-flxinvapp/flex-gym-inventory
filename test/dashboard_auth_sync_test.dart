import 'dart:async';

import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/models/equipment_model.dart';
import 'package:flex_gym_inventory/src/models/gym_model.dart';
import 'package:flex_gym_inventory/view_models/dashboard_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'account switch clears state and ignores the previous refresh result',
    () async {
      var currentUserId = 'account-a';
      final gymsByUser = {
        'account-a': Completer<List<Gym>>(),
        'account-b': Completer<List<Gym>>(),
      };
      final gymRepository = _StubGymRepository((userId) {
        return gymsByUser[userId]!.future;
      });
      final equipmentRepository = _StubEquipmentRepository((gymId) async {
        if (gymId == 'gym-b') return [_equipment('gym-b', quantity: 3)];
        return [_equipment('gym-a', quantity: 7)];
      });
      final viewModel = _createViewModel(
        () => currentUserId,
        gymRepository,
        equipmentRepository,
      );

      final accountARefresh = viewModel.onAuthChanged('account-a');
      currentUserId = 'account-b';
      final accountBRefresh = viewModel.onAuthChanged('account-b');

      expect(viewModel.state.gyms, isEmpty);
      expect(
        viewModel.state.categoryCounts.values.every((count) => count == 0),
        isTrue,
      );
      expect(viewModel.state.loading, isTrue);

      gymsByUser['account-b']!.complete([_gym('account-b', 'gym-b')]);
      await accountBRefresh;
      expect(viewModel.state.gyms.single.gymName, 'Gym account-b');
      expect(viewModel.state.gyms.single.equipmentCount, 3);
      expect(viewModel.state.categoryCounts[EquipmentCategory.weights], 3);
      expect(
        viewModel.state.gymCategoryCounts['gym-b']?[EquipmentCategory.weights],
        3,
      );

      gymsByUser['account-a']!.complete([_gym('account-a', 'gym-a')]);
      await accountARefresh;
      expect(viewModel.state.gyms.single.gymId, 'gym-b');
      expect(viewModel.state.categoryCounts[EquipmentCategory.weights], 3);
      viewModel.dispose();
    },
  );

  test('sign-out clears state and cancels an in-flight refresh', () async {
    String? currentUserId = 'account-a';
    final pendingGyms = Completer<List<Gym>>();
    final viewModel = _createViewModel(
      () => currentUserId,
      _StubGymRepository((_) => pendingGyms.future),
      _StubEquipmentRepository((_) async => []),
    );

    final refresh = viewModel.onAuthChanged('account-a');
    currentUserId = null;
    await viewModel.onAuthChanged(null);
    expect(viewModel.state.gyms, isEmpty);
    expect(
      viewModel.state.categoryCounts.values.every((count) => count == 0),
      isTrue,
    );
    expect(viewModel.state.loading, isFalse);

    pendingGyms.complete([_gym('account-a', 'gym-a')]);
    await refresh;
    expect(viewModel.state.gyms, isEmpty);
    viewModel.dispose();
  });

  test(
    'refresh detects identity changes before the auth stream callback',
    () async {
      var currentUserId = 'account-a';
      final pendingAccountAGyms = Completer<List<Gym>>();
      final viewModel = _createViewModel(
        () => currentUserId,
        _StubGymRepository((userId) {
          if (userId == 'account-a') return pendingAccountAGyms.future;
          return Future.value([_gym('account-b', 'gym-b')]);
        }),
        _StubEquipmentRepository((_) async => []),
      );

      final accountARefresh = viewModel.onAuthChanged('account-a');
      currentUserId = 'account-b';
      pendingAccountAGyms.complete([_gym('account-a', 'gym-a')]);
      await accountARefresh;
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.gyms.single.gymId, 'gym-b');
      viewModel.dispose();
    },
  );

  test(
    'failed refresh after account switch leaves the new user empty',
    () async {
      var currentUserId = 'account-a';
      final viewModel = _createViewModel(
        () => currentUserId,
        _StubGymRepository((userId) {
          if (userId == 'account-a') {
            return Future.value([_gym('account-a', 'gym-a')]);
          }
          return Future.error(StateError('offline'));
        }),
        _StubEquipmentRepository((_) async => []),
      );

      await viewModel.onAuthChanged('account-a');
      expect(viewModel.state.gyms.single.gymId, 'gym-a');

      currentUserId = 'account-b';
      await viewModel.onAuthChanged('account-b');
      expect(viewModel.state.gyms, isEmpty);
      expect(
        viewModel.state.categoryCounts.values.every((count) => count == 0),
        isTrue,
      );
      expect(viewModel.state.error, contains('offline'));
      viewModel.dispose();
    },
  );

  test('same-user refresh failure preserves only that user state', () async {
    var currentUserId = 'account-a';
    var requests = 0;
    final viewModel = _createViewModel(
      () => currentUserId,
      _StubGymRepository((_) {
        requests++;
        if (requests == 1) {
          return Future.value([_gym('account-a', 'gym-a')]);
        }
        return Future.error(StateError('refresh failed'));
      }),
      _StubEquipmentRepository((_) async => [_equipment('gym-a', quantity: 2)]),
    );

    await viewModel.onAuthChanged('account-a');
    await viewModel.refresh();

    expect(viewModel.state.gyms.single.gymId, 'gym-a');
    expect(viewModel.state.gyms.single.equipmentCount, 2);
    expect(viewModel.state.error, contains('refresh failed'));
    viewModel.dispose();
  });

  test(
    'overlapping same-user refreshes only apply the latest result',
    () async {
      var currentUserId = 'account-a';
      final pendingRefreshes = <Completer<List<Gym>>>[
        Completer<List<Gym>>(),
        Completer<List<Gym>>(),
        Completer<List<Gym>>(),
      ];
      var requestIndex = 0;
      final viewModel = _createViewModel(
        () => currentUserId,
        _StubGymRepository((_) => pendingRefreshes[requestIndex++].future),
        _StubEquipmentRepository((_) async => []),
      );

      final initialRefresh = viewModel.onAuthChanged('account-a');
      pendingRefreshes[0].complete([_gym('account-a', 'gym-initial')]);
      await initialRefresh;

      final olderRefresh = viewModel.refresh();
      final newerRefresh = viewModel.refresh();
      pendingRefreshes[2].complete([_gym('account-a', 'gym-newest')]);
      await newerRefresh;
      pendingRefreshes[1].complete([_gym('account-a', 'gym-older')]);
      await olderRefresh;

      expect(viewModel.state.gyms.single.gymId, 'gym-newest');
      viewModel.dispose();
    },
  );

  test(
    'repeated auth events for the same user do not duplicate refreshes',
    () async {
      var currentUserId = 'account-a';
      var requests = 0;
      final viewModel = _createViewModel(
        () => currentUserId,
        _StubGymRepository((_) async {
          requests++;
          return [_gym('account-a', 'gym-a')];
        }),
        _StubEquipmentRepository((_) async => []),
      );

      await viewModel.onAuthChanged('account-a');
      await viewModel.onAuthChanged('account-a');

      expect(requests, 1);
      viewModel.dispose();
    },
  );

  test(
    'equipment and gym changes automatically refresh dashboard data',
    () async {
      var gyms = [_gym('account-a', 'gym-a')];
      var equipmentByGym = <String, List<Equipment>>{
        'gym-a': [_equipment('gym-a', quantity: 2)],
      };
      final gymChanges = StreamController<void>.broadcast(sync: true);
      final equipmentChanges = StreamController<void>.broadcast(sync: true);
      final viewModel = _createViewModel(
        () => 'account-a',
        _StubGymRepository(
          (_) async => List.of(gyms),
          watch: (_) => gymChanges.stream,
        ),
        _StubEquipmentRepository(
          (gymId) async => List.of(equipmentByGym[gymId] ?? const []),
          watch: () => equipmentChanges.stream,
        ),
      );

      await viewModel.onAuthChanged('account-a');
      expect(viewModel.state.gyms.single.equipmentCount, 2);

      equipmentByGym['gym-a'] = [
        _equipment('gym-a', quantity: 7),
        _equipment('gym-a', quantity: 1, category: EquipmentCategory.racks),
      ];
      final equipmentRefresh = Completer<void>();
      final removeEquipmentListener = viewModel.addListener((state) {
        if (state.gyms.singleOrNull?.equipmentCount == 8 &&
            state.categoryCounts[EquipmentCategory.weights] == 7 &&
            state.categoryCounts[EquipmentCategory.racks] == 1) {
          equipmentRefresh.complete();
        }
      }, fireImmediately: false);
      equipmentChanges.add(null);
      await equipmentRefresh.future.timeout(const Duration(seconds: 2));
      removeEquipmentListener();

      gyms = [...gyms, _gym('account-a', 'gym-b')];
      final gymRefresh = Completer<void>();
      final removeGymListener = viewModel.addListener((state) {
        if (state.gyms.length == 2) gymRefresh.complete();
      }, fireImmediately: false);
      gymChanges.add(null);
      await gymRefresh.future.timeout(const Duration(seconds: 2));
      removeGymListener();
      expect(
        viewModel.state.gymCategoryCounts['gym-b']!.values.every((n) => n == 0),
        isTrue,
      );

      equipmentByGym.remove('gym-a');
      gyms = gyms.where((gym) => gym.gymId != 'gym-a').toList();
      final deletionRefresh = Completer<void>();
      final removeDeletionListener = viewModel.addListener((state) {
        if (state.gyms.length == 1 &&
            state.gyms.single.gymId == 'gym-b' &&
            state.categoryCounts.values.every((count) => count == 0)) {
          deletionRefresh.complete();
        }
      }, fireImmediately: false);
      gymChanges.add(null);
      await deletionRefresh.future.timeout(const Duration(seconds: 2));
      removeDeletionListener();

      viewModel.dispose();
      await gymChanges.close();
      await equipmentChanges.close();
    },
  );
}

DashboardViewModel _createViewModel(
  String? Function() currentUserIdReader,
  GymRepository gymRepository,
  EquipmentRepository equipmentRepository,
) {
  return DashboardViewModel(
    currentUserIdReader: currentUserIdReader,
    gymRepository: gymRepository,
    equipmentRepository: equipmentRepository,
  );
}

Gym _gym(String userId, String gymId) {
  return Gym(
    userId: userId,
    gymId: gymId,
    name: 'Gym $userId',
    createdDate: DateTime(2025),
  );
}

Equipment _equipment(
  String gymId, {
  required int quantity,
  EquipmentCategory category = EquipmentCategory.weights,
}) {
  return Equipment(
    gymId: gymId,
    name: 'Equipment',
    category: category,
    brand: 'Brand',
    model: 'Model',
    trainingStyle: TrainingStyle.general,
    quantity: quantity,
    condition: EquipmentCondition.good,
  );
}

class _StubGymRepository extends GymRepository {
  _StubGymRepository(this._load, {this.watch});

  final Future<List<Gym>> Function(String userId) _load;
  final Stream<void> Function(String userId)? watch;

  @override
  Future<List<Gym>> getAllForUser(
    String userId, {
    String? search,
    GymSort sort = GymSort.nameAsc,
  }) {
    return _load(userId);
  }

  @override
  Stream<void> watchForUser(String userId) =>
      watch?.call(userId) ?? const Stream<void>.empty();
}

class _StubEquipmentRepository extends EquipmentRepository {
  _StubEquipmentRepository(this._load, {this.watch});

  final Future<List<Equipment>> Function(String gymId) _load;
  final Stream<void> Function()? watch;

  @override
  Future<List<Equipment>> getAllForGym(
    String gymId, {
    String? search,
    EquipmentCategory? category,
    EquipmentCondition? condition,
    EquipmentSort sort = EquipmentSort.nameAsc,
  }) {
    return _load(gymId);
  }

  @override
  Stream<void> watchChanges() => watch?.call() ?? const Stream<void>.empty();
}
