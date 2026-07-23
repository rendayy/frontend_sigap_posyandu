import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/services/fcm/fcm_service.dart';

Dio _mockDio(int statusCode, {bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionTimeout));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: statusCode,
          data: {'success': true},
        ));
      }
    },
  ));
  return dio;
}

void main() {
  group('FCMService', () {
    setUp(() {
      FCMService().setJwtToken(null);
    });

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

    group('network methods', () {
      test('registerTokenToServer returns false when token is null', () async {
        final result = await FCMService().registerTokenToServer(null, 'jwt');
        expect(result, isFalse);
      });

      test('registerTokenToServer returns false for empty token', () async {
        final result = await FCMService().registerTokenToServer('', 'jwt');
        expect(result, isFalse);
      });

      test('registerTokenToServer returns true on 200', () async {
        FCMService().setDioForTesting(_mockDio(200));

        final result = await FCMService().registerTokenToServer('valid_token', 'jwt');
        expect(result, isTrue);
      });

      test('registerTokenToServer returns true on 201', () async {
        FCMService().setDioForTesting(_mockDio(201));

        final result = await FCMService().registerTokenToServer('valid_token', 'jwt');
        expect(result, isTrue);
      });

      test('registerTokenToServer returns false on 400', () async {
        FCMService().setDioForTesting(_mockDio(400));

        final result = await FCMService().registerTokenToServer('valid_token', 'jwt');
        expect(result, isFalse);
      });

      test('registerTokenToServer returns false on network error', () async {
        FCMService().setDioForTesting(_mockDio(0, throwError: true));

        final result = await FCMService().registerTokenToServer('valid_token', 'jwt');
        expect(result, isFalse);
      });

      test('registerCurrentToken returns false when no JWT set', () async {
        FCMService().setJwtToken(null);
        final result = await FCMService().registerCurrentToken();
        expect(result, isFalse);
      });

      test('clearFcmToken returns false when no JWT set', () async {
        FCMService().setJwtToken(null);
        final result = await FCMService().clearFcmToken();
        expect(result, isFalse);
      });

      test('clearFcmToken returns true on 204', () async {
        FCMService().setJwtToken('test_jwt');
        FCMService().setDioForTesting(_mockDio(204));

        final result = await FCMService().clearFcmToken();
        expect(result, isTrue);
      });
    });
  });
}
