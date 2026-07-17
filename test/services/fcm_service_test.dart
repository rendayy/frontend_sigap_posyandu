import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/services/fcm_service.dart';

void main() {
  group('FCMService', () {
    test('getInstance returns singleton instance', () {
      final instance1 = FCMService();
      final instance2 = FCMService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('setJwtToken stores token without error', () {
      FCMService().setJwtToken('test_jwt');
    });

    test('setOnNotificationTap stores callback without error', () {
      FCMService().setOnNotificationTap((data) {});
    });

    test('registerTokenToServer returns false when token is null', () async {
      final result = await FCMService().registerTokenToServer(null, 'jwt');
      expect(result, isFalse);
    });

    test('registerTokenToServer returns false for empty token', () async {
      final result = await FCMService().registerTokenToServer('', 'jwt');
      expect(result, isFalse);
    });

    test('registerCurrentToken returns false when no JWT set', () async {
      FCMService().setJwtToken(null);
      final result = await FCMService().registerCurrentToken();
      expect(result, isFalse);
    });

    test('clearFcmToken completes without error when no JWT set', () async {
      FCMService().setJwtToken(null);
      expect(FCMService().clearFcmToken(), completes);
    });

    test('handleInitialMessage is a function', () {
      expect(FCMService().handleInitialMessage, isA<Function>());
    });

    test('onTokenRefresh is a function', () {
      expect(FCMService().onTokenRefresh, isA<Function>());
    });

    test('onMessageOpenedApp is a function', () {
      expect(FCMService().onMessageOpenedApp, isA<Function>());
    });
  });
}
