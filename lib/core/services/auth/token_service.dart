import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';

class TokenService {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _rolesKey = 'roles';
  static const _categoryKey = 'user_category';
  static const _moduleIdKey = 'module_id';
  static const _userInfoKey = 'user_info';

  final FlutterSecureStorage _storage;

  TokenService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required List<String> roles,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _rolesKey, value: roles.join(',')),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<List<String>> getRoles() async {
    final roles = await _storage.read(key: _rolesKey);
    if (roles == null || roles.isEmpty) return [];
    return roles.split(',');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _rolesKey),
    ]);
  }

  Future<void> saveCategory(UserCategory category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_categoryKey, category.name);
  }

  Future<UserCategory?> getCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_categoryKey);
    if (value == null) return null;
    return UserCategory.fromString(value);
  }

  Future<void> clearCategory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoryKey);
  }

  Future<void> saveModuleId(String moduleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_moduleIdKey, moduleId);
  }

  Future<String?> getModuleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_moduleIdKey);
  }

  Future<void> clearModuleId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_moduleIdKey);
  }

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userInfoKey, jsonEncode(userInfo));
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userInfoKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userInfoKey);
  }
}
