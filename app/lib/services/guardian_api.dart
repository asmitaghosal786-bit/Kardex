import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class GuardianApi {
  GuardianApi({String? baseUrl, SupabaseClient? supabase})
    : _baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'GUARDIAN_API_URL',
            defaultValue: 'http://10.0.2.2:8000',
          ),
      _supabase = supabase ?? Supabase.instance.client;

  final String _baseUrl;
  final SupabaseClient _supabase;

  Future<String> _accessToken() async {
    final session = _supabase.auth.currentSession;
    if (session?.accessToken == null) {
      throw StateError('Sign in before accessing Kardex data.');
    }
    return session!.accessToken;
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: {'Authorization': 'Bearer ${await _accessToken()}'},
    );
    return _decode(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: {
        'Authorization': 'Bearer ${await _accessToken()}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    return _decode(response);
  }

  Future<String> createWebSession() async {
    final data = await post('/api/web-session') as Map<String, dynamic>;
    return data['code'] as String;
  }

  Future<Map<String, dynamic>> dashboard() async {
    return Map<String, dynamic>.from(await get('/api/dashboard') as Map);
  }

  Future<List<Map<String, dynamic>>> subscriptions() async {
    final data = await get('/api/subscriptions') as List;
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<List<Map<String, dynamic>>> recommendations() async {
    final data = await get('/api/recommendations') as List;
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> approveRecommendation(String id) async {
    return Map<String, dynamic>.from(
      await post('/api/recommendations/$id/approve') as Map,
    );
  }

  Future<Map<String, dynamic>> recommendationStatus(String id) async {
    return Map<String, dynamic>.from(
      await get('/api/recommendations/$id') as Map,
    );
  }

  Future<List<Map<String, dynamic>>> paypalPlans() async {
    final data = await post('/api/paypal/plans') as List;
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> subscribePaypal(String planId) async {
    return Map<String, dynamic>.from(
      await post('/api/paypal/subscribe', body: {'plan_id': planId}) as Map,
    );
  }

  Future<Map<String, dynamic>> addUsage({
    required double usageMinutes,
    required String periodStart,
    required String periodEnd,
    String? androidPackage,
    String source = 'manual',
  }) async {
    return Map<String, dynamic>.from(await post('/api/usage', body: {
      'usage_minutes': usageMinutes,
      'period_start': periodStart,
      'period_end': periodEnd,
      'android_package': androidPackage,
      'source': source,
    }) as Map);
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    if (response.body.isNotEmpty) {
      try {
        data = jsonDecode(response.body);
      } on FormatException {
        data = null;
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final detail = data is Map<String, dynamic> ? data['detail'] : null;
      throw StateError(
        detail?.toString() ??
            'Guardian API request failed (${response.statusCode}): '
                '${response.body.trim()}',
      );
    }
    return data;
  }
}
