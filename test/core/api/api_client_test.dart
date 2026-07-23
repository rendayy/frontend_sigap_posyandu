import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';

class _RequestCapture {
  String? authorization;
  String? path;
  String? method;
  Object? data;
  int statusCode = 200;
  bool throwError = false;

  InterceptorsWrapper get interceptor => InterceptorsWrapper(
    onRequest: (options, handler) {
      authorization = options.headers['Authorization'] as String?;
      path = options.path;
      method = options.method;
      data = options.data;
      if (throwError) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: statusCode,
            data: {'success': false},
          ),
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: statusCode,
          data: {},
        ));
      }
    },
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('ApiClient', () {
    test('customDio skips default interceptor setup', () async {
      bool intercepted = false;
      final customDio = Dio();
      customDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          intercepted = true;
          handler.resolve(Response(requestOptions: options, statusCode: 200, data: {}));
        },
      ));

      final client = ApiClient(customDio: customDio);
      await client.dio.get('/test');

      expect(intercepted, isTrue);
    });

    test('injects Bearer token from TokenService', () async {
      FlutterSecureStorage.setMockInitialValues({'access_token': 'my_token_123'});

      final client = ApiClient();
      final capture = _RequestCapture();
      client.dio.interceptors.add(capture.interceptor);

      await client.dio.get('/api/balita/b-001');

      expect(capture.authorization, 'Bearer my_token_123');
      expect(capture.path, '/api/balita/b-001');
    });

    test('does not set Authorization when no token stored', () async {
      final client = ApiClient();
      final capture = _RequestCapture();
      client.dio.interceptors.add(capture.interceptor);

      await client.dio.get('/test');

      expect(capture.authorization, isNull);
    });

    test('passes through non-401 errors without refresh attempt', () async {
      FlutterSecureStorage.setMockInitialValues({'access_token': 'at', 'refresh_token': 'rt'});

      final client = ApiClient();
      final capture = _RequestCapture();
      capture.statusCode = 403;
      capture.throwError = true;
      client.dio.interceptors.add(capture.interceptor);

      expect(
        () => client.dio.get('/api/balita/b-001'),
        throwsA(predicate((e) => e is DioException && e.response?.statusCode == 403)),
      );
    });

    test('passes through 401 when no refresh token available', () async {
      FlutterSecureStorage.setMockInitialValues({'access_token': 'expired_at'});

      final client = ApiClient();
      final capture = _RequestCapture();
      capture.statusCode = 401;
      capture.throwError = true;
      client.dio.interceptors.add(capture.interceptor);

      expect(
        () => client.dio.get('/api/balita/b-001'),
        throwsA(predicate((e) => e is DioException && e.response?.statusCode == 401)),
      );
    });
  });
}
