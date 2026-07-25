import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class CitizenService {
  final ApiClient _apiClient;

  CitizenService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<ProfileResponse> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get('/api/v1/citizens/me');

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat profil';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return ProfileResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat profil';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<void> updateMyProfile({
    required String nama,
    String? noHp,
  }) async {
    try {
      final body = <String, dynamic>{'nama': nama};
      if (noHp != null) {
        body['no_hp'] = noHp;
      }

      final response = await _apiClient.dio.put(
        '/api/v1/citizens/me',
        data: body,
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memperbarui profil';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memperbarui profil';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }
}
