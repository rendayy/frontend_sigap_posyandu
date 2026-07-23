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
    } catch (_) {}
    _initialized = true;
  }

  static String get apiBaseUrl {
    if (!_initialized) return 'http://localhost:5000';
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
  }
}
