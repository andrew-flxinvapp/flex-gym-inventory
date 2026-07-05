import 'dart:async';

import 'dart:convert';

import 'package:isar/isar.dart';
import '../dtos/account_dto.dart';
import '../../models/account_model.dart';

/// Minimal interface the repository expects from a Supabase-backed service.
abstract class SupabaseService {
  Future<Map<String, dynamic>?> fetchAccountRow(String id);
  Future<void> updateAccountRow(String id, Map<String, dynamic> row);
  Stream<Map<String, dynamic>> onAccountChanges(String id);
}

class AccountRepository {
  final Isar isar;
  final SupabaseService supabase;

  AccountRepository({required this.isar, required this.supabase});

  /// Watch account from local Isar cache. Emits updates when local data changes.
  Stream<AccountDto?> watchAccount(String id) async* {
    final col = isar.accountEntitys;
    await for (final _ in col.where().idEqualTo(id).watch(fireImmediately: true)) {
      final e = await col.filter().idEqualTo(id).findFirst();
      if (e == null) {
        yield null;
      } else {
        yield _fromEntity(e);
      }
    }
  }

  /// Read-through get: prefer Isar, fallback to Supabase and persist.
  Future<AccountDto?> getAccount(String id) async {
    final col = isar.accountEntitys;
    final existing = await col.filter().idEqualTo(id).findFirst();
    if (existing != null) return _fromEntity(existing);

    final row = await supabase.fetchAccountRow(id);
    if (row == null) return null;
    final dto = AccountDto.fromSupabase(row);
    await _saveToIsar(dto);
    return dto;
  }

  Future<void> refreshFromSupabase(String id) async {
    final row = await supabase.fetchAccountRow(id);
    if (row == null) return;
    final dto = AccountDto.fromSupabase(row);
    await _saveToIsar(dto);
  }

  /// Update locally and attempt to push to Supabase. On failure, keep local copy and rethrow.
  Future<void> updateAccount(AccountDto dto) async {
    await _saveToIsar(dto.copyWith(updatedAt: DateTime.now()));
    try {
      await supabase.updateAccountRow(dto.id, dto.toSupabaseRow());
    } catch (err) {
      // TODO: implement retry/queue strategy
      rethrow;
    }
  }

  Future<void> _saveToIsar(AccountDto dto) async {
    final col = isar.accountEntitys;
    final entity = AccountEntity()
      ..id = dto.id
      ..email = dto.email
      ..phoneNumber = dto.phoneNumber
      ..displayName = dto.displayName
      ..avatarUrl = dto.avatarUrl
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..settingsJson = dto.settings != null ? jsonEncode(dto.settings) : null
      ..subscriptionStatus = dto.subscriptionStatus
      ..subscriptionPlan = dto.subscriptionPlan
      ..subscriptionProvider = dto.subscriptionProvider
      ..subscriptionExpiresAt = dto.subscriptionExpiresAt
      ..subscriptionActive = dto.subscriptionActive
      ..subscriptionLastSynced = dto.subscriptionLastSynced
      ..subscriptionMetadataJson = dto.subscriptionMetadata != null ? jsonEncode(dto.subscriptionMetadata) : null
      ..deviceIds = dto.deviceIds ?? []
      ..wishlistCount = dto.wishlistCount;

    await isar.writeTxn(() async {
      await col.put(entity);
    });
  }

  AccountDto _fromEntity(AccountEntity e) {
    return AccountDto(
      id: e.id,
      email: e.email,
      phoneNumber: e.phoneNumber,
      displayName: e.displayName,
      avatarUrl: e.avatarUrl,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      settings: e.settingsJson != null ? Map<String, dynamic>.from(jsonDecode(e.settingsJson!) as Map) : null,
      deviceIds: e.deviceIds,
      wishlistCount: e.wishlistCount,
      subscriptionStatus: e.subscriptionStatus,
      subscriptionPlan: e.subscriptionPlan,
      subscriptionProvider: e.subscriptionProvider,
      subscriptionExpiresAt: e.subscriptionExpiresAt,
      subscriptionActive: e.subscriptionActive,
      subscriptionLastSynced: e.subscriptionLastSynced,
      subscriptionMetadata: e.subscriptionMetadataJson != null ? Map<String, dynamic>.from(jsonDecode(e.subscriptionMetadataJson!) as Map) : null,
    );
  }
}
