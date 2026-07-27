import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class PemantauanRemajaService {
  final ApiClient _apiClient;

  PemantauanRemajaService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<PemantauanRemajaListResponse> getList({
    required String idRemaja,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/remaja/$idRemaja/pemantauan',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message =
            errorData?['message'] as String? ?? 'Gagal memuat riwayat pemantauan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return PemantauanRemajaListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat riwayat pemantauan';
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

  Future<PemantauanRemajaDetailResponse> getDetail({
    required String idRemaja,
    required String idPantau,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/remaja/$idRemaja/pemantauan/$idPantau',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message =
            errorData?['message'] as String? ?? 'Gagal memuat detail pemantauan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return PemantauanRemajaDetailResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat detail pemantauan';
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

  Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/remaja/$idRemaja/gula-darah-chart',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message =
            errorData?['message'] as String? ?? 'Gagal memuat grafik gula darah';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return GulaDarahChartData.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message =
            error?['message'] as String? ?? 'Gagal memuat grafik gula darah';
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
