import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';
import 'package:flex_gym_inventory/src/data/repositories/gym_repository.dart';
import 'package:flex_gym_inventory/src/data/repositories/equipment_repository.dart';
import 'package:flex_gym_inventory/providers/auth_providers.dart';

/// Small model used by the dashboard for gym summaries.
class DashboardGym {
  final String gymId;
  final String gymName;
  final int equipmentCount;
  final DateTime lastUpdated;

  DashboardGym({
    required this.gymId,
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

DashboardState _emptyDashboardState({bool loading = false, String? error}) {
  return DashboardState(
    categoryCounts: {
      for (final category in EquipmentCategory.values) category: 0,
    },
    gyms: const [],
    loading: loading,
    error: error,
  );
}

/// StateNotifier that manages user-scoped dashboard data.
class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel({
    required String? Function() currentUserIdReader,
    GymRepository? gymRepository,
    EquipmentRepository? equipmentRepository,
  }) : _currentUserIdReader = currentUserIdReader,
       _gymRepository = gymRepository ?? GymRepository(),
       _equipmentRepository = equipmentRepository ?? EquipmentRepository(),
       super(_emptyDashboardState());

  final String? Function() _currentUserIdReader;
  final GymRepository _gymRepository;
  final EquipmentRepository _equipmentRepository;
  String? _activeUserId;
  int _requestGeneration = 0;
  bool _hasAuthState = false;
  bool _authUnavailable = false;
  bool _disposed = false;

  /// Synchronizes state with an authenticated identity.
  ///
  /// Repeated auth events for the same user do not cause duplicate refreshes.
  Future<void> onAuthChanged(String? userId) {
    if (_disposed) return Future<void>.value();
    final normalizedUserId = userId == null || userId.isEmpty ? null : userId;
    if (_hasAuthState &&
        !_authUnavailable &&
        normalizedUserId == _activeUserId) {
      return Future<void>.value();
    }

    _hasAuthState = true;
    _authUnavailable = false;
    _activeUserId = normalizedUserId;
    _requestGeneration++;
    state = _emptyDashboardState(loading: normalizedUserId != null);

    if (normalizedUserId == null) return Future<void>.value();
    return _refreshForUser(normalizedUserId);
  }

  /// Clears user-scoped state when authentication is loading or unavailable.
  void onAuthUnavailable([Object? error]) {
    if (_disposed) return;
    final errorMessage = error?.toString();
    if (_hasAuthState &&
        _authUnavailable &&
        _activeUserId == null &&
        state.error == errorMessage) {
      return;
    }

    _hasAuthState = true;
    _authUnavailable = true;
    _activeUserId = null;
    _requestGeneration++;
    state = _emptyDashboardState(error: errorMessage);
  }

  /// Refresh dashboard data from repositories.
  Future<void> refresh() {
    final currentUserId = _currentUserIdReader();
    if (!_hasAuthState || _authUnavailable || currentUserId != _activeUserId) {
      return onAuthChanged(currentUserId);
    }
    if (currentUserId == null) return Future<void>.value();
    return _refreshForUser(currentUserId);
  }

  Future<void> _refreshForUser(String userId) async {
    if (!_isActiveUser(userId)) return;

    final generation = ++_requestGeneration;
    state = state.copyWith(loading: true, error: null);
    try {
      final gyms = await _gymRepository.getAllForUser(userId);
      if (!_canApplyResult(userId, generation)) return;

      // Initialize category counts with zero for every enum value
      final Map<EquipmentCategory, int> counts = {
        for (final c in EquipmentCategory.values) c: 0,
      };

      final List<DashboardGym> dashboardGyms = [];

      for (final g in gyms) {
        if (!_canApplyResult(userId, generation)) return;
        final items = await _equipmentRepository.getAllForGym(g.gymId);
        if (!_canApplyResult(userId, generation)) return;
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

        dashboardGyms.add(
          DashboardGym(
            gymId: g.gymId,
            gymName: g.name,
            equipmentCount: equipmentCount,
            lastUpdated: lastUpdated,
          ),
        );
      }

      if (!_canApplyResult(userId, generation)) return;
      state = state.copyWith(
        loading: false,
        categoryCounts: counts,
        gyms: dashboardGyms,
        error: null,
      );
    } catch (e) {
      if (!_canApplyResult(userId, generation)) return;
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  bool _isActiveUser(String userId) =>
      !_disposed &&
      _hasAuthState &&
      !_authUnavailable &&
      _activeUserId == userId;

  bool _canApplyResult(String userId, int generation) {
    if (!_isActiveUser(userId) || generation != _requestGeneration) {
      return false;
    }
    final currentUserId = _currentUserIdReader();
    if (currentUserId == userId) return true;
    unawaited(onAuthChanged(currentUserId));
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    _requestGeneration++;
    super.dispose();
  }
}

/// Provider exposing the dashboard state and notifier.
final dashboardProvider =
    StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
      final viewModel = DashboardViewModel(
        currentUserIdReader:
            () => ref.read(authServiceProvider).currentUser?.id,
      );
      ref.listen(authStateProvider, (previous, next) {
        if (next.isLoading) {
          viewModel.onAuthUnavailable();
        } else if (next.hasError) {
          viewModel.onAuthUnavailable(next.error);
        } else if (next.hasValue) {
          unawaited(viewModel.onAuthChanged(next.value?.id));
        } else {
          viewModel.onAuthUnavailable();
        }
      });
      return viewModel;
    });
