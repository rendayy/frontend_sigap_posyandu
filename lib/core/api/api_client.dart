import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/config.dart';
import 'package:frontend_posyandu/core/services/auth/token_service.dart';

class ApiClient {
  late final Dio dio;
  final TokenService _tokenService;

  ApiClient({TokenService? tokenService, Dio? customDio})
    : _tokenService = tokenService ?? TokenService() {
    final baseUrl = AppConfig.apiBaseUrl;
    log('ApiClient: baseUrl = $baseUrl', name: 'ApiClient');

    dio = customDio ?? Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (customDio != null) return;

    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (o) => log('$o', name: 'Dio'),
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _tokenService.getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            log('Gagal baca token: $e', name: 'ApiClient');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = await _tokenService.getRefreshToken();
              if (refreshToken != null) {
                final refreshResponse = await Dio(
                  BaseOptions(baseUrl: baseUrl),
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
              }
            } catch (e) {
              log('Gagal refresh token: $e', name: 'ApiClient');
              await _tokenService.clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    ]);
  }
}
