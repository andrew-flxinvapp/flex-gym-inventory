import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../src/data/dtos/support_request_dto.dart';
import '../src/utils/diagnostics_helper.dart';

class SupportResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  SupportResult({required this.success, this.message, this.data});
}

class SupportService {
  final SupabaseClient _client;
  final String _edgeFunctionName;

  SupportService({SupabaseClient? client, String edgeFunctionName = 'submit-support-request'})
      : _client = client ?? Supabase.instance.client,
        _edgeFunctionName = edgeFunctionName;

  /// Submits a support request via the Supabase Edge Function.
  ///
  /// Ensures an authenticated session exists, collects diagnostics, merges
  /// them into the DTO payload, calls the Edge Function, and interprets
  /// the response. Returns a [SupportResult] describing success or failure.
  Future<SupportResult> submitSupportRequest(SupportRequestDto dto) async {
    // Confirm authenticated session
    final user = _client.auth.currentUser;
    if (user == null) {
      return SupportResult(success: false, message: 'Not authenticated');
    }

    try {
      // Collect diagnostics (resilient to failures)
      final diag = await DiagnosticsHelper.collect();

      // Merge diagnostics into a copy of the DTO JSON
      final payload = {...dto.toJson(), ...diag.toJson()};

      // Invoke edge function. The Supabase client will attach the auth
      // session token automatically.
      final dynamic res = await _client.functions.invoke(_edgeFunctionName, body: payload);

      // `res` may be a Supabase FunctionResponse-like object; attempt to
      // extract a JSON body from common fields or string representations.
      Map<String, dynamic>? body;
      try {
        final raw = res;
        if (raw is String) {
          body = json.decode(raw) as Map<String, dynamic>?;
        } else if (raw is Map) {
          body = Map<String, dynamic>.from(raw);
        } else if (raw != null) {
          // Try common response properties found on function responses.
          final dynamic candidate = (raw as dynamic).data ?? (raw as dynamic).body ?? (raw as dynamic).json ?? (raw as dynamic).response;
          if (candidate is String) {
            body = json.decode(candidate) as Map<String, dynamic>?;
          } else if (candidate is Map) {
            body = Map<String, dynamic>.from(candidate);
          } else {
            final s = raw.toString();
            if (s.isNotEmpty) {
              body = json.decode(s) as Map<String, dynamic>?;
            }
          }
        }
      } catch (e) {
        body = null;
      }

      // Interpret response: prefer explicit boolean `success` field
      if (body != null) {
        final success = body['success'];
        if (success is bool) {
          if (success) {
            return SupportResult(success: true, message: 'Submitted', data: body);
          } else {
            final err = body['error'] ?? body['message'] ?? 'Unknown error';
            return SupportResult(success: false, message: err.toString(), data: body);
          }
        }
      }

      // If we couldn't parse a structured response, assume success if no exception
      return SupportResult(success: true, message: 'Submitted', data: body ?? {'raw': res});
    } catch (e) {
      // Log or attach stack for developer debugging (avoid exposing secrets)
      // For now, include a concise error message.
      return SupportResult(success: false, message: e.toString());
    }
  }
}
