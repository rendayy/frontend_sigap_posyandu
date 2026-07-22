import 'package:dio/dio.dart';
import 'package:frontend_posyandu/config.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

class ApiClient {
  late final Dio dio;
  final TokenService _tokenService;

  ApiClient({TokenService? tokenService})
    : _tokenService = tokenService ?? TokenService() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await _tokenService.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshResponse = await Dio(
                BaseOptions(baseUrl: AppConfig.apiBaseUrl),
              ).post(
                '/api/v1/auth/refresh',
                data: {'refresh_token': refreshToken},
              );

              final newAccessToken =
                  refreshResponse.data['data']['access_token'] as String;
              final newRefreshToken =
                  refreshResponse.data['data']['refresh_token'] as String;

              await _tokenService.saveTokens(
                accessToken: newAccessToken,
                refreshToken: newRefreshToken,
                roles: await _tokenService.getRoles(),
              );

              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';

              final retryResponse = await dio.fetch(error.requestOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await _tokenService.clearTokens();
            }
          }
        }
        handler.next(error);
      },
    ));
  }
}
