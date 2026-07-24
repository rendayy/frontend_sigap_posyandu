import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/balita/pemantauan_balita_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

Dio _mockDio(int statusCode, Object data,
    {bool throwError = false}) {
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
  group('PemantauanBalitaService', () {
    group('getList', () {
      test('returns PemantauanListResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': [
            {
              'id_pantau': 'p-001',
              'id_kader': 'k-001',
              'nama_kader': 'Zidan Kusuma',
              'no': 1,
              'tanggal_pantau': '2026-07-18',
              'usia_bulan': 34,
              'berat': 12.0,
              'tinggi': 80.0,
              'lingkar_kepala': 48.0,
              'lingkar_lengan': null,
              'status_gizi': 'gizi_kurang',
              'imunisasi': null,
              'vitamin_a': 'ya',
            },
            {
              'id_pantau': 'p-002',
              'id_kader': 'k-001',
              'nama_kader': 'Zidan Kusuma',
              'no': 2,
              'tanggal_pantau': '2026-07-16',
              'usia_bulan': 32,
              'berat': 16.0,
              'tinggi': 85.0,
              'lingkar_kepala': 23.0,
              'lingkar_lengan': 9.9,
              'status_gizi': 'gizi_baik',
              'imunisasi': 'MBG',
              'vitamin_a': 'ya',
            },
          ],
          'pagination': {
            'limit': 5,
            'page': 1,
            'total': 14,
            'total_pages': 3,
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        final result = await service.getList(idBalita: 'b-001');

        expect(result.success, true);
        expect(result.data.length, 2);
        expect(result.data[0].idPantau, 'p-001');
        expect(result.data[0].no, 1);
        expect(result.data[0].usiaBulan, 34);
        expect(result.data[0].berat, 12.0);
        expect(result.data[0].tinggi, 80.0);
        expect(result.data[0].lingkarKepala, 48.0);
        expect(result.data[0].lingkarLengan, isNull);
        expect(result.data[0].statusGizi, 'gizi_kurang');
        expect(result.data[0].vitaminA, 'ya');
        expect(result.data[0].imunisasi, isNull);
        expect(result.data[0].namaKader, 'Zidan Kusuma');
        expect(result.data[1].lingkarKepala, 23.0);
        expect(result.data[1].lingkarLengan, 9.9);
        expect(result.data[1].imunisasi, 'MBG');
        expect(result.pagination.page, 1);
        expect(result.pagination.total, 14);
        expect(result.pagination.totalPages, 3);
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
        final service = PemantauanBalitaService(apiClient: apiClient);

        await service.getList(idBalita: 'b-001', page: 2, limit: 10);

        expect(capturedPage, 2);
        expect(capturedLimit, 10);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getList(idBalita: 'invalid-id'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getList(idBalita: 'b-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getList(idBalita: 'b-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getDetail', () {
      test('returns PemantauanBalitaDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_pantau': 'p-001',
            'id_kader': 'k-001',
            'id_cabang': 'c-001',
            'nama_kader': 'Zidan Kusuma',
            'nama_posyandu': 'Posyandu Melati',
            'tanggal_pantau': '2026-06-15',
            'usia_bulan': 6,
            'berat': 12.8,
            'tinggi': 86.0,
            'lingkar_kepala': 48.8,
            'lingkar_lengan': 18.2,
            'status_gizi': 'gizi_baik',
            'imunisasi': 'BCG, DPT, Polio, Campak',
            'vitamin_a': 'ya',
            'keluhan': 'Keluhan diperbarui',
            'saran': 'Saran diperbarui',
            'created_at': '2026-07-05T01:41:35',
            'updated_at': '2026-07-19T13:27:51',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        final result = await service.getDetail(idBalita: 'b-001', idPantau: 'p-001');

        expect(result.idPantau, 'p-001');
        expect(result.namaKader, 'Zidan Kusuma');
        expect(result.namaPosyandu, 'Posyandu Melati');
        expect(result.usiaBulan, 6);
        expect(result.berat, 12.8);
        expect(result.tinggi, 86.0);
        expect(result.lingkarKepala, 48.8);
        expect(result.lingkarLengan, 18.2);
        expect(result.statusGizi, 'gizi_baik');
        expect(result.imunisasi, 'BCG, DPT, Polio, Campak');
        expect(result.vitaminA, 'ya');
        expect(result.keluhan, 'Keluhan diperbarui');
        expect(result.saran, 'Saran diperbarui');
        expect(result.createdAt, '2026-07-05T01:41:35');
        expect(result.updatedAt, '2026-07-19T13:27:51');
      });

      test('handles nullable fields correctly', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_pantau': 'p-002',
            'id_kader': 'k-001',
            'id_cabang': 'c-001',
            'nama_kader': 'Zidan Kusuma',
            'nama_posyandu': 'Posyandu Melati',
            'tanggal_pantau': '2026-06-15',
            'usia_bulan': 6,
            'berat': 12.0,
            'tinggi': 80.0,
            'lingkar_kepala': null,
            'lingkar_lengan': null,
            'status_gizi': 'gizi_kurang',
            'imunisasi': null,
            'vitamin_a': 'tidak',
            'keluhan': null,
            'saran': null,
            'created_at': null,
            'updated_at': null,
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        final result = await service.getDetail(idBalita: 'b-001', idPantau: 'p-002');

        expect(result.lingkarKepala, isNull);
        expect(result.lingkarLengan, isNull);
        expect(result.imunisasi, isNull);
        expect(result.keluhan, isNull);
        expect(result.saran, isNull);
        expect(result.createdAt, isNull);
        expect(result.updatedAt, isNull);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idBalita: 'b-001', idPantau: 'invalid'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idBalita: 'b-001', idPantau: 'p-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanBalitaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idBalita: 'b-001', idPantau: 'p-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}