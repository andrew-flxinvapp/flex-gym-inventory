import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

      // Debug: print masked session info and a truncated payload preview.
      try {
        final session = _client.auth.currentSession;
        final token = session?.accessToken;
        final maskedToken = token == null
            ? 'null'
            : (token.length > 16 ? '${token.substring(0, 8)}...${token.substring(token.length - 8)}' : '<<short>>');
        debugPrint('SupportService: currentUser id=${user.id}');
        debugPrint('SupportService: accessToken=$maskedToken');
        // Decode token claims for debugging (do not print the raw token)
        if (token != null) {
          try {
            final parts = token.split('.');
            if (parts.length > 1) {
              final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
              final claims = json.decode(payloadJson);
              debugPrint('SupportService: token claims (decoded)=$claims');
            }
          } catch (e) {
            debugPrint('SupportService: failed to decode token claims: $e');
          }
        }
        final payloadJson = json.encode(payload);
        debugPrint('SupportService: payload (truncated)=${payloadJson.length > 1000 ? payloadJson.substring(0, 1000) + "..." : payloadJson}');
      } catch (e) {
        debugPrint('SupportService: failed to print debug info: $e');
      }

      // Explicitly attach the Authorization header with the user's JWT.
      // Some runtimes/clients don't include it automatically for functions.
      final token = _client.auth.currentSession?.accessToken;
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
      if (headers != null) debugPrint('SupportService: invoking with Authorization header (masked)');

      dynamic res;
      try {
        res = await _client.functions.invoke(_edgeFunctionName, body: payload, headers: headers);
      } catch (e) {
        debugPrint('SupportService: functions.invoke failed: $e');
        // Fallback: POST directly to the project's Functions URL with Authorization header
        try {
          final base = dotenv.env['SUPABASE_URL'];
          if (base == null) throw Exception('SUPABASE_URL not set');
          final url = Uri.parse('$base/functions/v1/$_edgeFunctionName');
          final reqHeaders = <String, String>{'Content-Type': 'application/json'};
          if (token != null) reqHeaders['Authorization'] = 'Bearer $token';
          final httpRes = await http.post(url, headers: reqHeaders, body: json.encode(payload));
          res = httpRes.body;
          debugPrint('SupportService: fallback HTTP POST status=${httpRes.statusCode}');
        } catch (e2) {
          debugPrint('SupportService: fallback HTTP POST failed: $e2');
          rethrow;
        }
      }

      // `res` may be a Supabase FunctionResponse-like object; attempt to
      // extract a JSON body from common fields or string representations.
      // Debug: print raw response (truncated) to help diagnose server replies
      try {
        String rawStr;
        if (res == null) rawStr = 'null';
        else if (res is String) rawStr = res;
        else rawStr = res.toString();
        debugPrint('SupportService: raw response (truncated)=${rawStr.length > 2000 ? rawStr.substring(0, 2000) + "..." : rawStr}');
      } catch (e) {
        debugPrint('SupportService: failed to print raw response: $e');
      }
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
