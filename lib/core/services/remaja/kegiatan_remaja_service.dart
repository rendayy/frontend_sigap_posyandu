import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class KegiatanRemajaService {
  final ApiClient _apiClient;

  KegiatanRemajaService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<KegiatanRemajaListResponse> getList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/kegiatan-remaja',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message =
            errorData?['message'] as String? ?? 'Gagal memuat daftar kegiatan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return KegiatanRemajaListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat daftar kegiatan';
        throw ServerException(
            statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(
          statusCode: 401,
          message: 'Sesi Anda telah habis. Silakan login kembali.',
        );
      }
      throw NetworkException();
    }
  }

  Future<KegiatanDetailResponse> getDetail(String idKegiatan) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/kegiatan-remaja/$idKegiatan',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message =
            errorData?['message'] as String? ?? 'Gagal memuat detail kegiatan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return KegiatanDetailResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat detail kegiatan';
        throw ServerException(
            statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(
          statusCode: 401,
          message: 'Sesi Anda telah habis. Silakan login kembali.',
        );
      }
      throw NetworkException();
    }
  }
}
