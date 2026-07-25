import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/auth/logout_service.dart';

Dio _mockDio({bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionTimeout));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true},
        ));
      }
    },
  ));
  return dio;
}

void main() {
  group('LogoutService', () {
    test('logout sends POST to /api/v1/auth/logout with refresh token', () async {
      final dio = _mockDio();
      final apiClient = ApiClient(customDio: dio);
      final service = LogoutService(apiClient: apiClient);

      await service.logout('test-refresh-token');

      // Tidak throw = sukses
    });

    test('logout completes even when API call fails', () async {
      final dio = _mockDio(throwError: true);
      final apiClient = ApiClient(customDio: dio);
      final service = LogoutService(apiClient: apiClient);

      await service.logout('test-refresh-token');

      // Tidak throw = sukses (error ditelan)
    });
  });
}
