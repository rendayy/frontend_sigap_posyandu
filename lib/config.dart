import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: ".env");
      log('.env loaded: API_BASE_URL=${dotenv.env['API_BASE_URL']}', name: 'AppConfig');
    } catch (e) {
      log('.env gagal diload: $e', name: 'AppConfig');
    }
    _initialized = true;
  }

  static String get apiBaseUrl {
    if (!_initialized) return 'http://localhost:5000';
    final url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
    log('apiBaseUrl = $url', name: 'AppConfig');
    return url;
  }
}
