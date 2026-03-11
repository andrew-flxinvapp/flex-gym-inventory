import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/providers/auth_providers.dart';

/// Small model used by the dashboard for gym summaries.
class DashboardGym {
  final String gymName;
  final int equipmentCount;
  final DateTime lastUpdated;

  DashboardGym({
    required this.gymName,
    required this.equipmentCount,
    required this.lastUpdated,
  });
}

/// Immutable state for the dashboard UI.
class DashboardState {
  final Map<EquipmentCategory, int> categoryCounts;
  final List<DashboardGym> gyms;
  final bool loading;
  final String? error;

  const DashboardState({
    required this.categoryCounts,
    required this.gyms,
    this.loading = false,
    this.error,
  });

  DashboardState copyWith({
    Map<EquipmentCategory, int>? categoryCounts,
    List<DashboardGym>? gyms,
    bool? loading,
    String? error,
  }) {
    return DashboardState(
      categoryCounts: categoryCounts ?? this.categoryCounts,
      gyms: gyms ?? this.gyms,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// StateNotifier that manages the dashboard data. Start with sample data and
/// provide refresh() for later wiring to repositories.
class DashboardViewModel extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardViewModel(this.ref)
      : super(
          DashboardState(
            // Ensure every `EquipmentCategory` has at least one item for
            // demo purposes so the dashboard arc chart always displays all
            // categories in the legend and slices.
            categoryCounts: {
              EquipmentCategory.weights: 0,
              EquipmentCategory.specialty: 0,
              EquipmentCategory.machines: 0,
              EquipmentCategory.storage: 0,
              EquipmentCategory.racks: 0,
              EquipmentCategory.attachments: 0,
              EquipmentCategory.benches: 0,
              EquipmentCategory.accessories: 0,
              EquipmentCategory.safety: 0,
              EquipmentCategory.other: 0,
            },
            gyms: [],
          ),
        ) {
    // Trigger a refresh after construction so the dashboard loads when the
    // provider is first created (e.g., on app startup or when the dashboard
    // view is first shown).
    Future.microtask(() => refresh());
  }

  /// Refresh dashboard data from repositories.
  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final auth = ref.read(authServiceProvider);
      final userId = auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(loading: false, error: 'No authenticated user');
        return;
      }

      final gymRepo = GymRepository();
      final equipmentRepo = EquipmentRepository();

      final gyms = await gymRepo.getAllForUser(userId);

      // Initialize category counts with zero for every enum value
      final Map<EquipmentCategory, int> counts = {
        for (final c in EquipmentCategory.values) c: 0,
      };

      final List<DashboardGym> dashboardGyms = [];

      for (final g in gyms) {
        final items = await equipmentRepo.getAllForGym(g.gymId);
        // Sum quantities (if quantity is not present, default to 1)
        final equipmentCount = items.fold<int>(0, (acc, e) => acc + e.quantity);

        // Increment category counts
        for (final e in items) {
          final existing = counts[e.category] ?? 0;
          counts[e.category] = existing + e.quantity;
        }

        // Determine lastUpdated: newest purchaseDate among equipments, or gym.createdDate
        DateTime lastUpdated = g.createdDate;
        for (final e in items) {
          if (e.purchaseDate != null && e.purchaseDate!.isAfter(lastUpdated)) {
            lastUpdated = e.purchaseDate!;
          }
        }

        dashboardGyms.add(DashboardGym(
          gymName: g.name,
          equipmentCount: equipmentCount,
          lastUpdated: lastUpdated,
        ));
      }

      state = state.copyWith(
        loading: false,
        categoryCounts: counts,
        gyms: dashboardGyms,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// Provider exposing the dashboard state and notifier.
final dashboardProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel(ref);
});
