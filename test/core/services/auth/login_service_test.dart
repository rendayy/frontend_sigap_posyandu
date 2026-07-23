import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/auth/login_service.dart';

Dio _mockDio(int statusCode, Object data,
    {bool throwError = false, DioExceptionType errorType = DioExceptionType.connectionTimeout}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(requestOptions: options, type: errorType));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        ));
      }
    },
  ));
  return dio;
}

void main() {
  group('LoginService', () {
    test('returns LoginResponse on successful login', () async {
      final dio = _mockDio(200, {
        'success': true,
        'data': {
          'access_token': 'test_access',
          'refresh_token': 'test_refresh',
          'expires_in': 3600,
          'token_type': 'Bearer',
          'state': 'active',
          'roles': ['user'],
          'user': {
            'id_anggota': '123',
            'kategori_anggota': 'balita',
            'module_id': 'mod_123',
            'module_type': 'balita',
            'nama': 'Test User',
            'user_type': 'warga',
          },
        },
      });

      final apiClient = ApiClient(customDio: dio);
      final service = LoginService(apiClient: apiClient);

      final result = await service.login(
        identifier: 'test@test.com',
        password: 'password123',
      );

      expect(result.accessToken, 'test_access');
      expect(result.refreshToken, 'test_refresh');
      expect(result.roles, ['user']);
      expect(result.user, isNotNull);
      expect(result.user!.nama, 'Test User');
      expect(result.user!.moduleId, 'mod_123');
    });

    test('throws Exception on invalid credentials', () async {
      final dio = _mockDio(200, {
        'success': false,
        'error': {
          'code': 401,
          'message': 'Identitas atau kata sandi salah.',
        },
      });

      final apiClient = ApiClient(customDio: dio);
      final service = LoginService(apiClient: apiClient);

      expect(
        () => service.login(identifier: 'wrong', password: 'wrong'),
        throwsA(predicate((e) =>
          e is Exception && e.toString().contains('Identitas atau kata sandi salah'))),
      );
    });

    test('throws Exception on connection error', () async {
      final dio = _mockDio(0, {}, throwError: true);

      final apiClient = ApiClient(customDio: dio);
      final service = LoginService(apiClient: apiClient);

      expect(
        () => service.login(identifier: 'test', password: 'test'),
        throwsA(predicate((e) =>
          e is Exception && e.toString().contains('Tidak dapat terhubung ke server'))),
      );
    });
  });
}
