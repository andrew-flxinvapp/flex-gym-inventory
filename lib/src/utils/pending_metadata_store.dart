import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small helper to store pending user metadata while the user completes
/// magic-link verification on the same device.
class PendingMetadataStore {
  static const _key = 'pending_user_metadata_v1';

  /// Save metadata (overwrites any existing pending metadata).
  static Future<void> save(Map<String, dynamic> metadata) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(metadata));
  }

  /// Read pending metadata, or `null` if none saved.
  static Future<Map<String, dynamic>?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(raw));
      return map;
    } catch (_) {
      return null;
    }
  }

  /// Remove pending metadata.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
