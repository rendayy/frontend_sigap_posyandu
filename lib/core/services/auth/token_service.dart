import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      _writeToPrefs(_accessTokenKey, accessToken),
      _writeToPrefs(_refreshTokenKey, refreshToken),
      _writeToPrefs(_rolesKey, roles.join(',')),
    ]);
  }

  Future<String?> getAccessToken() async {
    final secure = await _readFromStorage(_accessTokenKey);
    if (secure != null) return secure;
    return _readFromPrefs(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final secure = await _readFromStorage(_refreshTokenKey);
    if (secure != null) return secure;
    return _readFromPrefs(_refreshTokenKey);
  }

  Future<List<String>> getRoles() async {
    final raw = await _readFromStorage(_rolesKey);
    if (raw == null || raw.isEmpty) return [];
    return raw.split(',');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _rolesKey),
      _removeFromPrefs(_accessTokenKey),
      _removeFromPrefs(_refreshTokenKey),
      _removeFromPrefs(_rolesKey),
    ]);
  }

  Future<String?> _readFromStorage(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value != null && value.isNotEmpty) return value;
    } catch (e) {
      debugPrint('TokenService: secure storage read gagal ($key): $e');
    }
    return null;
  }

  Future<String?> _readFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('TokenService: prefs read gagal ($key): $e');
      return null;
    }
  }

  Future<void> _writeToPrefs(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('TokenService: prefs write gagal ($key): $e');
    }
  }

  Future<void> _removeFromPrefs(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('TokenService: prefs remove gagal ($key): $e');
    }
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
