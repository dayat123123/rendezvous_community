import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rendezvous_community/src/core/error/community_exception.dart';
import 'package:rendezvous_community/src/core/error/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef AnonymousRpcCall = Future<Object?> Function(String fn, Map<String, Object?> params);

class AnonymousRpc {
  AnonymousRpc({
    required String supabaseUrl,
    required this._anonKey,
    this._httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _supabaseUrl = supabaseUrl.replaceAll(RegExp(r'/+$'), '');

  final String _supabaseUrl;
  final String _anonKey;
  final http.Client? _httpClient;
  final Duration timeout;

  AnonymousRpcCall inSchema(String? schema) =>
      (fn, params) => call(fn, params, schema: schema);

  Future<Object?> call(String fn, Map<String, Object?> params, {String? schema}) async {
    final uri = Uri.parse('$_supabaseUrl/rest/v1/rpc/$fn');
    final headers = {
      'apikey': _anonKey,
      'Authorization': 'Bearer $_anonKey',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Content-Profile': ?schema,
    };
    final shared = _httpClient;
    final client = shared ?? http.Client();
    try {
      final response = await client.post(uri, headers: headers, body: jsonEncode(params)).timeout(timeout);
      final text = utf8.decode(response.bodyBytes);
      final body = text.isEmpty ? null : jsonDecode(text);
      if (response.statusCode >= 400) {
        final map = body is Map ? body : const <String, Object?>{};
        throw mapError(
          PostgrestException(
            message: map['message']?.toString() ?? 'HTTP ${response.statusCode}',
            code: map['code']?.toString() ?? '${response.statusCode}',
            details: map['details']?.toString(),
            hint: map['hint']?.toString(),
          ),
        );
      }
      return body;
    } on CommunityException {
      rethrow;
    } catch (e) {
      throw mapError(e);
    } finally {
      if (shared == null) client.close();
    }
  }
}
