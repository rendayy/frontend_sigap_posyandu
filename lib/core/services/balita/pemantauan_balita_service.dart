import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class PemantauanBalitaService {
  final ApiClient _apiClient;

  PemantauanBalitaService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<PemantauanListResponse> getList({
    required String idBalita,
    int page = 1,
    int limit = 5,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/balita/$idBalita/pemantauan',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat riwayat pemeriksaan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return PemantauanListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat riwayat pemeriksaan';
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

  Future<PemantauanBalitaDetailResponse> getDetail({
    required String idBalita,
    required String idPantau,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/balita/$idBalita/pemantauan/$idPantau',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat detail pemeriksaan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return PemantauanBalitaDetailResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat detail pemeriksaan';
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
