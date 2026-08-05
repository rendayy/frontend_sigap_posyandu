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
    group('getDetail', () {
      const testId = '0ec11841-bd2b-411b-8ad8-f95beddde51f';

      test('returns KegiatanDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_kegiatan': testId,
            'judul_kegiatan': 'Abogoboga',
            'jenis_kegiatan': 'edukasi',
            'tanggal': '2026-07-31',
            'waktu': '21:00:00',
            'tempat': 'Aula Posyandu Melati',
            'status': 'dibatalkan',
            'peserta_target': 2,
            'total_kehadiran': 0,
            'persentase_kehadiran': 0,
            'materi': null,
            'narasumber': 'Dr. Siti Rahayu',
            'created_at': '2026-07-21T02:00:38',
            'updated_at': null,
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        final result = await service.getDetail(testId);

        expect(result.idKegiatan, testId);
        expect(result.judulKegiatan, 'Abogoboga');
        expect(result.jenisKegiatan, 'edukasi');
        expect(result.tanggal, '2026-07-31');
        expect(result.waktu, '21:00:00');
        expect(result.tempat, 'Aula Posyandu Melati');
        expect(result.status, 'dibatalkan');
        expect(result.pesertaTarget, 2);
        expect(result.totalKehadiran, 0);
        expect(result.persentaseKehadiran, 0);
        expect(result.materi, null);
        expect(result.narasumber, 'Dr. Siti Rahayu');
        expect(result.createdAt, '2026-07-21T02:00:38');
        expect(result.updatedAt, null);
      });

      test('sends correct id in path', () async {
        String? capturedPath;

        final dio = Dio();
        dio.interceptors.add(InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedPath = options.path;
            handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'success': true,
                'data': {
                  'id_kegiatan': testId,
                  'judul_kegiatan': 'Test',
                  'jenis_kegiatan': 'edukasi',
                  'tanggal': '2026-07-31',
                  'waktu': '21:00:00',
                  'tempat': 'Aula',
                  'status': 'rencana',
                  'peserta_target': 1,
                  'total_kehadiran': 0,
                  'persentase_kehadiran': 0,
                },
              },
            ));
          },
        ));

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        await service.getDetail(testId);

        expect(capturedPath, '/api/kegiatan-remaja/$testId');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(testId),
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
          () => service.getDetail(testId),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = KegiatanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(testId),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
