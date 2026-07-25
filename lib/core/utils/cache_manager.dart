import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheManager<T> {
  final String prefix;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;

  const CacheManager({
    required this.prefix,
    required this.fromJson,
    required this.toJson,
  });

  Future<void> save(String id, T data) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(toJson(data));
    await prefs.setString('${prefix}_cache_$id', json);
  }

  Future<T?> load(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('${prefix}_cache_$id');
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> has(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('${prefix}_cache_$id');
  }

  Future<void> clear(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${prefix}_cache_$id');
  }
}
