import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flex_gym_inventory/src/data/repositories/account_repository.dart';

/// Adapter that implements the `SupabaseService` interface expected by
/// `AccountRepository`.
class SupabaseAccountService implements SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch the account row from the `profiles` table by id.
  @override
  Future<Map<String, dynamic>?> fetchAccountRow(String id) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle() as Map<String, dynamic>?;
      return res;
    } catch (err) {
      rethrow;
    }
  }

  /// Update the `profiles` table for the given user id.
  @override
  Future<void> updateAccountRow(String id, Map<String, dynamic> row) async {
    try {
      await _client.from('profiles').update(row).eq('id', id);
    } catch (err) {
      rethrow;
    }
  }

  /// Stream realtime changes from the `profiles` table for the given id.
  /// Emits the latest row as a `Map<String,dynamic>` whenever the row changes.
  @override
  Stream<Map<String, dynamic>> onAccountChanges(String id) {
    final stream = _client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) => (list.isNotEmpty) ? Map<String, dynamic>.from(list.first) : <String, dynamic>{});
    return stream;
  }
}
