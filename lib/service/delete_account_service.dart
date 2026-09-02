import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../service/isar_service.dart';
import '../src/data/dtos/delete_account_dto.dart';
import '../src/models/app_state_model.dart';
import '../src/models/equipment_model.dart';
import '../src/models/gym_model.dart';
import '../src/models/user_prefs_model.dart';
import '../src/models/wishlist_model.dart';

class DeleteAccountResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  const DeleteAccountResult({required this.success, this.message, this.data});
}

class DeleteAccountService {
  final SupabaseClient _client;
  final String _edgeFunctionName;

  DeleteAccountService({
    SupabaseClient? client,
    String edgeFunctionName = 'delete-account',
  }) : _client = client ?? Supabase.instance.client,
       _edgeFunctionName = edgeFunctionName;

  Future<DeleteAccountResult> deleteAccount(DeleteAccountDto dto) async {
    try {
      final payload = dto.toJson();

      try {
        final jsonStr = json.encode(payload);
        debugPrint(
          'DeleteAccountService: invoking $_edgeFunctionName payloadLen=${jsonStr.length}',
        );
      } catch (_) {}

      final dynamic res = await _client.functions.invoke(
        _edgeFunctionName,
        body: payload,
      );

      final Map<String, dynamic>? body = _decodeResponseBody(res);

      if (body != null) {
        final success = body['success'];
        if (success is bool) {
          if (success) {
            return DeleteAccountResult(
              success: true,
              message: body['message']?.toString() ?? 'Account deleted',
              data: body,
            );
          }

          final err = body['error'] ?? body['message'] ?? 'Unknown error';
          return DeleteAccountResult(
            success: false,
            message: err.toString(),
            data: body,
          );
        }
      }

      return DeleteAccountResult(
        success: true,
        message: 'Account deleted',
        data: body ?? {'raw': res},
      );
    } catch (e, st) {
      debugPrint('DeleteAccountService: deleteAccount failed: $e\n$st');
      return DeleteAccountResult(success: false, message: e.toString());
    }
  }

  Future<void> clearLocalDataForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final isar = IsarService.isar;
    try {
      await isar.writeTxn(() async {
        final gyms = await isar.gyms.filter().userIdEqualTo(user.id).findAll();
        for (final gym in gyms) {
          await isar.equipments.filter().gymIdEqualTo(gym.gymId).deleteAll();
          await isar.gyms.delete(gym.id);
        }

        await isar.wishlists.filter().userIdEqualTo(user.id).deleteAll();
        await isar.userPrefs.filter().userIdEqualTo(user.id).deleteAll();

        final state = await isar.appStates.get(1);
        if (state != null) {
          state.activeGymId = null;
          await isar.appStates.put(state);
        }
      });

      final prefs = await SharedPreferences.getInstance();
      const keys = [
        'allow_notifications',
        'allow_notifications_maintenance',
        'allow_notifications_new_features',
        'allow_notifications_weekly',
        'allow_notifications_app_updates',
        'pending_user_metadata_v1',
      ];
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e, st) {
      debugPrint('DeleteAccountService: clearLocalDataForCurrentUser failed: $e\n$st');
      rethrow;
    }
  }

  Map<String, dynamic>? _decodeResponseBody(dynamic res) {
    try {
      if (res == null) return null;
      if (res is Map) return Map<String, dynamic>.from(res);
      if (res is String) return json.decode(res) as Map<String, dynamic>?;

      final candidate =
          (res as dynamic).data ??
          (res as dynamic).body ??
          (res as dynamic).json ??
          (res as dynamic).response;
      if (candidate == null) {
        final s = res.toString();
        if (s.isEmpty) return null;
        return json.decode(s) as Map<String, dynamic>?;
      }

      if (candidate is String) return json.decode(candidate) as Map<String, dynamic>?;
      if (candidate is Map) return Map<String, dynamic>.from(candidate);
      return null;
    } catch (e) {
      debugPrint('DeleteAccountService: failed to decode response body: $e');
      return null;
    }
  }
}
