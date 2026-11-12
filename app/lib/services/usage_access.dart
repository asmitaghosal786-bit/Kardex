import 'package:flutter/services.dart';

class UsageAccess {
  static const _channel = MethodChannel('kardex/usage');

  static Future<bool> hasAccess() async {
    return await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;
  }

  static Future<void> requestAccess() async {
    await _channel.invokeMethod<void>('requestUsageAccess');
  }

  static Future<List<Map<String, dynamic>>> query({int days = 30}) async {
    final rows = await _channel.invokeListMethod<dynamic>(
      'queryUsage',
      {'days': days},
    );
    return (rows ?? const []).map((row) => Map<String, dynamic>.from(row as Map)).toList();
  }
}
