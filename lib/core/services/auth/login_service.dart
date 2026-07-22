import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';

class LoginService {
  final ApiClient _apiClient;

  LoginService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<LoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.data['success'] != true) {
        throw Exception(
          response.data['error']?['message'] ?? 'Login gagal',
        );
      }

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Login gagal';
        throw Exception(message);
      }
      throw Exception('Tidak dapat terhubung ke server');
    }
  }
}
