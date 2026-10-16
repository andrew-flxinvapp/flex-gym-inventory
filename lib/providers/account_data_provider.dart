import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountDataState {
  final String fullName;
  final String email;
  final bool isLoading;
  final Object? error;

  const AccountDataState({
    this.fullName = '',
    this.email = '',
    this.isLoading = true,
    this.error,
  });

  AccountDataState copyWith({
    String? fullName,
    String? email,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return AccountDataState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AccountDataNotifier extends StateNotifier<AccountDataState> {
  final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSubscription;
  String? _activeUserId;
  String _activeEmail = '';
  int _generation = 0;
  int _requestGeneration = 0;

  AccountDataNotifier({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      super(const AccountDataState()) {
    final user = _client.auth.currentUser;
    _activeUserId = user?.id;
    _activeEmail = user?.email ?? '';

    _authSubscription = _client.auth.onAuthStateChange.listen(
      (authState) => _handleUserChange(authState.session?.user),
      onError: (Object error, StackTrace stackTrace) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );

    if (user == null) {
      state = const AccountDataState(isLoading: false);
    } else {
      _watchProfile(user.id);
    }
  }

  void _handleUserChange(User? user) {
    if (user?.id == _activeUserId) {
      final email = user?.email ?? '';
      if (email != _activeEmail) {
        _activeEmail = email;
        state = state.copyWith(email: email);
      }
      return;
    }

    _activeUserId = user?.id;
    _activeEmail = user?.email ?? '';
    if (user == null) {
      _generation++;
      _requestGeneration++;
      state = const AccountDataState(isLoading: false);
      return;
    }

    _watchProfile(user.id);
  }

  void refresh() {
    final userId = _activeUserId;
    if (userId == null) {
      state = const AccountDataState(isLoading: false);
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    unawaited(_fetchProfile(userId, _generation));
  }

  void _watchProfile(String userId) {
    final generation = ++_generation;
    state = AccountDataState(email: _activeEmail);
    unawaited(_fetchProfile(userId, generation));
  }

  Future<void> _fetchProfile(String userId, int generation) async {
    final requestGeneration = ++_requestGeneration;
    try {
      final row =
          await _client
              .from('profiles')
              .select('first_name, last_name')
              .eq('id', userId)
              .maybeSingle();
      if (generation != _generation ||
          requestGeneration != _requestGeneration) {
        return;
      }
      state = AccountDataState(
        fullName: _formatFullName(row),
        email: _activeEmail,
        isLoading: false,
      );
    } catch (error) {
      if (generation != _generation ||
          requestGeneration != _requestGeneration) {
        return;
      }
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  static String _formatFullName(Map<String, dynamic>? row) {
    final firstName = row?['first_name']?.toString().trim() ?? '';
    final lastName = row?['last_name']?.toString().trim() ?? '';
    return [firstName, lastName].where((part) => part.isNotEmpty).join(' ');
  }

  @override
  void dispose() {
    _generation++;
    _requestGeneration++;
    final authSubscription = _authSubscription;
    if (authSubscription != null) unawaited(authSubscription.cancel());
    super.dispose();
  }
}

final accountDataProvider =
    StateNotifierProvider.autoDispose<AccountDataNotifier, AccountDataState>(
      (ref) => AccountDataNotifier(),
    );
