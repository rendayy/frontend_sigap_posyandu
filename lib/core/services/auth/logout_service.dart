import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';

class LogoutService {
  final ApiClient _apiClient;

  LogoutService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<void> logout(String refreshToken) async {
    try {
      await _apiClient.dio.post(
        '/api/v1/auth/logout',
        data: {'refresh_token': refreshToken},
      );
    } on DioException {
      // Tetap lanjutkan logout lokal meskipun backend gagal
    }
  }
}
