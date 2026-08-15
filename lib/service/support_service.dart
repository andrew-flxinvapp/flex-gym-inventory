import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;

import '../src/data/dtos/support_request_dto.dart';
import '../src/utils/diagnostics_helper.dart';
import '../utilities/logging_handler.dart';

class SupportResult {
  final bool success;
  final String? message;
  final dynamic data;

  SupportResult({required this.success, this.message, this.data});
}

class SupportService {
  final SupabaseClient _client;
  final String _screenshotBucket;
  final String _edgeFunctionName;

  SupportService({
    SupabaseClient? client,
    String screenshotBucket = 'support-screenshots',
    String edgeFunctionName = 'submit_support_request',
  })  : _client = client ?? Supabase.instance.client,
        _screenshotBucket = screenshotBucket,
        _edgeFunctionName = edgeFunctionName;

  /// Submits a support request.
  ///
  /// Steps:
  /// 1. Collect diagnostics via `DiagnosticsHelper.collect()`.
  /// 2. If `screenshot` provided, upload to Supabase Storage and include the storage path in payload.
  /// 3. Invoke a Supabase Edge Function with the combined payload.
  Future<SupportResult> submitSupportRequest(
    SupportRequestDto dto, {
    File? screenshot,
  }) async {
    try {
      final diagnostics = await DiagnosticsHelper.collect();

      String? screenshotPath;
      if (screenshot != null) {
        // Ensure we have an authenticated user for namespacing uploads.
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          throw StateError('User must be signed in to upload support screenshots');
        }
        final userId = user.id;

        final id = const Uuid().v4();
        final ext = p.extension(screenshot.path).toLowerCase();
        // Store screenshots under a folder named with the user's UUID: `userId/fileName.ext`
        final remotePath = '$userId/$id$ext';

        dynamic uploadRes;
        try {
          uploadRes = await _client.storage.from(_screenshotBucket).upload(remotePath, screenshot);
        } catch (e, st) {
          LogHandler.error('SupportService', 'Screenshot upload failed', e, st);
          return SupportResult(success: false, message: 'Screenshot upload failed: $e');
        }

        // Handle multiple possible return shapes across supabase client versions.
        if (uploadRes is Map && uploadRes['error'] != null) {
          return SupportResult(success: false, message: 'Screenshot upload failed: ${uploadRes['error']}');
        }

        // Store the storage path (server can resolve public URL)
        screenshotPath = remotePath;
      }

      final payload = {
        ...dto.toJson(),
        'diagnostics': diagnostics.toMap(),
      };

      if (screenshotPath != null) payload['screenshot_storage_path'] = screenshotPath;

      // Invoke edge function
      final fnRes = await _client.functions.invoke(_edgeFunctionName, body: payload);

      // supabase functions.invoke returns a Map or string depending on function
      return SupportResult(success: true, message: 'Submitted', data: fnRes);
    } catch (e, st) {
      LogHandler.error('SupportService', 'submitSupportRequest failed', e, st);
      return SupportResult(success: false, message: e.toString());
    }
  }
}
