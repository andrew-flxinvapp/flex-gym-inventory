import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../src/data/dtos/feedback_dto.dart';

class FeedbackResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  FeedbackResult({required this.success, this.message, this.data});
}

/// Service to submit feedback via the Supabase Edge Function `submit-feedback`.
///
/// This service does NOT rely on Supabase Auth or include diagnostics.
class FeedbackService {
  final SupabaseClient _client;
  final String _edgeFunctionName;

  FeedbackService({SupabaseClient? client, String edgeFunctionName = 'submit-feedback'})
      : _client = client ?? Supabase.instance.client,
        _edgeFunctionName = edgeFunctionName;

  Future<FeedbackResult> submitFeedback(FeedbackDto dto) async {
    try {
      final payload = dto.toJson();

      try {
        final jsonStr = json.encode(payload);
        debugPrint('FeedbackService: invoking $_edgeFunctionName payloadLen=${jsonStr.length}');
      } catch (_) {}

      final dynamic res = await _client.functions.invoke(_edgeFunctionName, body: payload);

      final Map<String, dynamic>? body = _decodeResponseBody(res);

      if (body != null) {
        final success = body['success'];
        if (success is bool) {
          if (success) return FeedbackResult(success: true, message: 'Submitted', data: body);
          final err = body['error'] ?? body['message'] ?? 'Unknown error';
          return FeedbackResult(success: false, message: err.toString(), data: body);
        }
      }

      // If structured response unavailable, treat as success when call didn't throw.
      return FeedbackResult(success: true, message: 'Submitted', data: body ?? {'raw': res});
    } catch (e, st) {
      debugPrint('FeedbackService: submitFeedback failed: $e\n$st');
      return FeedbackResult(success: false, message: e.toString());
    }
  }

  Map<String, dynamic>? _decodeResponseBody(dynamic res) {
    try {
      if (res == null) return null;
      if (res is Map) return Map<String, dynamic>.from(res);
      if (res is String) return json.decode(res) as Map<String, dynamic>?;

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
      debugPrint('FeedbackService: failed to decode response body: $e');
      return null;
    }
  }
}
