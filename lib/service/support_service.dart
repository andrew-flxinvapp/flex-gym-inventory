import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../src/data/dtos/support_request_dto.dart';
import '../src/utils/diagnostics_helper.dart';

/// Result of a support request submission.
class SupportResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  SupportResult({required this.success, this.message, this.data});
}

/// Service responsible for submitting support requests to the public
/// Supabase Edge Function `submit-support-request`.
///
/// This implementation does NOT rely on or send any authenticated
/// Supabase session information. It simply invokes the edge function
/// with the payload built from the DTO plus diagnostics collected
/// locally on the device.
class SupportService {
  final SupabaseClient _client;
  final String _edgeFunctionName;

  SupportService({SupabaseClient? client, String edgeFunctionName = 'submit-support-request'})
      : _client = client ?? Supabase.instance.client,
        _edgeFunctionName = edgeFunctionName;

  /// Submits [dto] to the configured Edge Function and returns a
  /// [SupportResult]. The response body is parsed if possible and
  /// returned in [SupportResult.data].
  Future<SupportResult> submitSupportRequest(SupportRequestDto dto) async {
    try {
      final diag = await DiagnosticsHelper.collect();

      final payload = {...dto.toJson(), ...diag.toJson()};

      // Helpful debug output (trimmed)
      try {
        final jsonStr = json.encode(payload);
        debugPrint('SupportService: invoking $_edgeFunctionName payloadLen=${jsonStr.length}');
      } catch (_) {}

      final dynamic res = await _client.functions.invoke(_edgeFunctionName, body: payload);

      final Map<String, dynamic>? body = _decodeResponseBody(res);

      if (body != null) {
        final success = body['success'];
        if (success is bool) {
          if (success) return SupportResult(success: true, message: 'Submitted', data: body);
          final err = body['error'] ?? body['message'] ?? 'Unknown error';
          return SupportResult(success: false, message: err.toString(), data: body);
        }
      }

      // If structured response unavailable, treat as success when call didn't throw.
      return SupportResult(success: true, message: 'Submitted', data: body ?? {'raw': res});
    } catch (e, st) {
      debugPrint('SupportService: submitSupportRequest failed: $e\n$st');
      return SupportResult(success: false, message: e.toString());
    }
  }

  Map<String, dynamic>? _decodeResponseBody(dynamic res) {
    try {
      if (res == null) return null;
      if (res is Map) return Map<String, dynamic>.from(res);
      if (res is String) return json.decode(res) as Map<String, dynamic>?;

      // Common properties on function responses
      final candidate = (res as dynamic).data ?? (res as dynamic).body ?? (res as dynamic).json ?? (res as dynamic).response;
      if (candidate == null) {
        final s = res.toString();
        if (s.isEmpty) return null;
        return json.decode(s) as Map<String, dynamic>?;
      }

      if (candidate is String) return json.decode(candidate) as Map<String, dynamic>?;
      if (candidate is Map) return Map<String, dynamic>.from(candidate);
      return null;
    } catch (e) {
      debugPrint('SupportService: failed to decode response body: $e');
      return null;
    }
  }
}
