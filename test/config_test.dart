import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/config.dart';

void main() {
  group('AppConfig', () {
    test('apiBaseUrl returns default value when not initialized', () {
      expect(AppConfig.apiBaseUrl, equals('http://localhost:5000'));
    });
  });
}
