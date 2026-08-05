import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class BaseService {
  final ApiClient apiClient;

  BaseService({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<T> _send<T>(
    Future<Response> Function() request,
    T Function(Map<String, dynamic>) fromJson, {
    required String errorMessage,
    bool fromData = true,
  }) async {
    try {
      final response = await request();
      final body = response.data;
      if (body['success'] != true) {
        final errorData = body['error'] as Map?;
        final message = errorData?['message'] as String? ?? errorMessage;
        final code = errorData?['code'] as int?;
        throw ServerException(
          statusCode: code,
          message: message,
          rawMessage: message,
        );
      }
      final json = fromData ? body['data'] : body;
      return fromJson(Map<String, dynamic>.from(json as Map));
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      if (errorData != null && errorData is Map) {
        final error = errorData['error'] as Map?;
        final message = error?['message'] as String? ?? errorMessage;
        throw ServerException(
          statusCode: statusCode,
          message: message,
          rawMessage: message,
        );
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

  Future<T> get<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.get(path, queryParameters: queryParameters),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.post(path, data: data),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.put(path, data: data),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }

  Future<T> delete<T>(
    String path, {
    required T Function(Map<String, dynamic>) fromJson,
    String errorMessage = 'Gagal memuat data',
    bool fromData = true,
  }) {
    return _send(
      () => apiClient.dio.delete(path),
      fromJson,
      errorMessage: errorMessage,
      fromData: fromData,
    );
  }
}
