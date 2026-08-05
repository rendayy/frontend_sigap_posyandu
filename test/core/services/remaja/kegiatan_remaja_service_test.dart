import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/remaja/kegiatan_remaja_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

Dio _mockDio(int statusCode, Object data, {bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      if (throwError) {
        handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionTimeout));
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
  group('KegiatanRemajaService', () {
    group('getList', () {
      test('returns KegiatanRemajaListResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': [
            {
              'id_kegiatan': '0ec11841-bd2b-411b-8ad8-f95beddde51f',
              'jenis_kegiatan': 'edukasi',
              'nama_kegiatan': 'Penyuluhan Gizi',
              'no': 1,
              'status': 'rencana',
              'tanggal': '2026-07-31',
              'tempat': 'Aula Posyandu Melati',
              'waktu': '09:00:00',
            },
            {
              'id_kegiatan': 'f1a2b3c4-d5e6-7890-abcd-ef1234567890',
              'jenis_kegiatan': 'olahraga',
              'nama_kegiatan': 'Senam Remaja',
              'no': 2,
              'status': 'selesai',
              'tanggal': '2026-07-25',
              'tempat': 'Lapangan Desa',
              'waktu': '07:00:00',
            },
          ],
          'pagination': {
            'page': 1,
            'limit': 10,
            'total': 2,
            'total_pages': 1,
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        final result = await service.getList();

        expect(result.success, true);
        expect(result.data.length, 2);
        expect(result.data[0].idKegiatan, '0ec11841-bd2b-411b-8ad8-f95beddde51f');
        expect(result.data[0].jenisKegiatan, 'edukasi');
        expect(result.data[0].namaKegiatan, 'Penyuluhan Gizi');
        expect(result.data[0].status, 'rencana');
        expect(result.data[0].tanggal, '2026-07-31');
        expect(result.data[0].tempat, 'Aula Posyandu Melati');
        expect(result.data[0].waktu, '09:00:00');
        expect(result.data[1].jenisKegiatan, 'olahraga');
        expect(result.data[1].status, 'selesai');
        expect(result.pagination.page, 1);
        expect(result.pagination.total, 2);
        expect(result.pagination.totalPages, 1);
      });

      test('sends page and limit query parameters', () async {
        int? capturedPage;
        int? capturedLimit;

        final dio = Dio();
        dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedPage = int.tryParse(options.queryParameters['page']?.toString() ?? '');
            capturedLimit = int.tryParse(options.queryParameters['limit']?.toString() ?? '');
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': [],
                'pagination': {'page': 2, 'limit': 10, 'total': 0, 'total_pages': 0},
              },
            ));
          },
        ));

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        await service.getList(page: 2, limit: 10);

        expect(capturedPage, 2);
        expect(capturedLimit, 10);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
