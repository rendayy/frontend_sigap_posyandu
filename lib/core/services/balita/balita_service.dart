import 'dart:io';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/config.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class BalitaService {
  final ApiClient _apiClient;

  BalitaService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<BalitaDetailResponse> getBalitaById(String idBalita) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/balita/$idBalita',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat data balita';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return BalitaDetailResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat data balita';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  Future<GrowthChartResponse> getGrowthChart(String idBalita) async {
    try {
      final response = await _apiClient.dio.get(
        '/api/balita/$idBalita/growth-chart',
      );

      if (response.data['success'] != true) {
        final errorData = response.data['error'] as Map?;
        final message = errorData?['message'] as String? ?? 'Gagal memuat grafik pertumbuhan';
        final code = errorData?['code'] as int?;
        throw ServerException(statusCode: code, message: message, rawMessage: message);
      }

      return GrowthChartResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? 'Gagal memuat grafik pertumbuhan';
        throw ServerException(statusCode: statusCode, message: message, rawMessage: message);
      }
      if (statusCode == 401) {
        throw ServerException(statusCode: 401, message: 'Sesi Anda telah habis. Silakan login kembali.');
      }
      throw NetworkException();
    }
  }

  String getDownloadKmsUrl(String idBalita) {
    return '${AppConfig.apiBaseUrl}/api/balita/$idBalita/download-kms';
  }

  Future<File> downloadKms(String idBalita) async {
    final url = '/api/balita/$idBalita/download-kms';
    final dir = await Directory.systemTemp.createTemp('kms_');
    final file = File('${dir.path}/kms_$idBalita.pdf');
    await _apiClient.dio.download(url, file.path);
    return file;
  }
}
