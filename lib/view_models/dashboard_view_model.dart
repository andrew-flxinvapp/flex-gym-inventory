import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

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
  DashboardViewModel()
      : super(
          DashboardState(
            categoryCounts: {
              EquipmentCategory.specialty: 5,
              EquipmentCategory.weights: 12,
              EquipmentCategory.machines: 2,
              EquipmentCategory.other: 18,
            },
            gyms: [
              DashboardGym(
                gymName: 'Flex Home Gym',
                equipmentCount: 27,
                lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
              ),
            ],
          ),
        );

  /// Simulate a refresh; later replace with a repository call.
  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      // In a real implementation, load from a GymRepository and update state.
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// Provider exposing the dashboard state and notifier.
final dashboardProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel();
});
