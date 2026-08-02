import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/api/base_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

Dio _mockDio(int statusCode, Object data, {bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: statusCode,
          data: data,
        ));
      }
    },
  ));
  return dio;
}

void main() {
  group('BaseService', () {
    test('get parses body["data"] by default', () async {
      final dio = _mockDio(200, {
        'success': true,
        'data': {'nama': 'Andi'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final result = await service.get(
        '/api/test',
        fromJson: (j) => j['nama'] as String,
      );
      expect(result, 'Andi');
    });

    test('get parses whole body when fromData=false', () async {
      final dio = _mockDio(200, {
        'success': true,
        'nama': 'Andi',
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final result = await service.get(
        '/api/test',
        fromJson: (j) => j['nama'] as String,
        fromData: false,
      );
      expect(result, 'Andi');
    });

    test('get sends queryParameters', () async {
      Map<String, dynamic>? captured;
      final dio = Dio();
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          captured = options.queryParameters;
          handler.resolve(Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true, 'data': {}},
          ));
        },
      ));
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      await service.get(
        '/api/test',
        queryParameters: {'page': 2, 'limit': 5},
        fromJson: (j) => j,
      );
      expect(captured, {'page': 2, 'limit': 5});
    });

    test('get throws ServerException on success=false with message', () async {
      final dio = _mockDio(200, {
        'success': false,
        'error': {'code': 404, 'message': 'Data tidak ditemukan'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate(
          (e) => e is ServerException && e.message.contains('Data tidak ditemukan'),
        )),
      );
    });

    test('get throws ServerException on 401', () async {
      final dio = _mockDio(401, {
        'success': false,
        'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
      );
    });

    test('get throws NetworkException on connection error', () async {
      final dio = _mockDio(0, {}, throwError: true);
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      expect(
        () => service.get('/api/test', fromJson: (j) => j),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });

    test('post/put/delete send data and parse response', () async {
      final dio = _mockDio(200, {
        'success': true,
        'data': {'id': 'x-1'},
      });
      final service = BaseService(apiClient: ApiClient(customDio: dio));
      final postId = await service.post(
        '/api/test',
        data: {'nama': 'A'},
        fromJson: (j) => j['id'] as String,
      );
      final putId = await service.put(
        '/api/test',
        data: {'nama': 'A'},
        fromJson: (j) => j['id'] as String,
      );
      final delId = await service.delete(
        '/api/test',
        fromJson: (j) => j['id'] as String,
      );
      expect(postId, 'x-1');
      expect(putId, 'x-1');
      expect(delId, 'x-1');
    });
  });
}
