import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
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
  group('PemantauanRemajaService', () {
    group('getList', () {
      test('returns PemantauanRemajaListResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': [
            {
              'no': 1,
              'id_pantau_remaja': 'pr-001',
              'id_kader': 'k-001',
              'tanggal_periksa': '2026-07-18',
              'berat_badan': 55.0,
              'tinggi_badan': 160.0,
              'status_gizi': 'berat_badan_normal',
              'sistol': 110,
              'distol': 70,
              'gula_darah': 90,
            },
            {
              'no': 2,
              'id_pantau_remaja': 'pr-002',
              'id_kader': 'k-001',
              'tanggal_periksa': '2026-07-10',
              'berat_badan': null,
              'tinggi_badan': null,
              'status_gizi': 'obesitas_1',
              'sistol': 120,
              'distol': 80,
              'gula_darah': null,
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
        final service = PemantauanRemajaService(apiClient: apiClient);

        final result = await service.getList(idRemaja: 'r-001');

        expect(result.success, true);
        expect(result.data.length, 2);
        expect(result.data[0].no, 1);
        expect(result.data[0].idPantauRemaja, 'pr-001');
        expect(result.data[0].beratBadan, 55.0);
        expect(result.data[0].tinggiBadan, 160.0);
        expect(result.data[0].statusGizi, 'berat_badan_normal');
        expect(result.data[0].sistol, 110);
        expect(result.data[0].gulaDarah, 90);
        expect(result.data[1].beratBadan, isNull);
        expect(result.data[1].tinggiBadan, isNull);
        expect(result.data[1].gulaDarah, isNull);
        expect(result.data[1].statusGizi, 'obesitas_1');
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
        final service = PemantauanRemajaService(apiClient: apiClient);

        await service.getList(idRemaja: 'r-001', page: 2, limit: 10);

        expect(capturedPage, 2);
        expect(capturedLimit, 10);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(idRemaja: 'invalid-id'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(idRemaja: 'r-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getList(idRemaja: 'r-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getDetail', () {
      test('returns PemantauanRemajaDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_pantau_remaja': 'pr-001',
            'id_kader': 'k-001',
            'id_cabang': 'c-001',
            'nama_kader': 'Zidan Kusuma',
            'nama_posyandu': 'Posyandu Melati',
            'tanggal_periksa': '2026-07-18',
            'berat_badan': 55.0,
            'tinggi_badan': 160.0,
            'sistol': 110,
            'distol': 70,
            'gula_darah': 90,
            'bmi': 21.5,
            'status_gizi': 'berat_badan_normal',
            'keluhan': 'Tidak ada keluhan',
            'saran': 'Pertahankan pola makan sehat',
            'created_at': '2026-07-18T01:00:00',
            'updated_at': '2026-07-18T02:00:00',
          },
          'audit': {'alert_created': false, 'recorded': true},
          'timestamp': '2026-07-25T23:40:33.379954Z',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        final result = await service.getDetail(
          idRemaja: 'r-001',
          idPantau: 'pr-001',
        );

        expect(result.idPantauRemaja, 'pr-001');
        expect(result.namaKader, 'Zidan Kusuma');
        expect(result.namaPosyandu, 'Posyandu Melati');
        expect(result.beratBadan, 55.0);
        expect(result.tinggiBadan, 160.0);
        expect(result.sistol, 110);
        expect(result.distol, 70);
        expect(result.gulaDarah, 90);
        expect(result.bmi, 21.5);
        expect(result.statusGizi, 'berat_badan_normal');
        expect(result.keluhan, 'Tidak ada keluhan');
        expect(result.saran, 'Pertahankan pola makan sehat');
      });

      test('returns PemantauanRemajaDetailResponse with nullable fields null', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_pantau_remaja': 'pr-002',
            'id_kader': 'k-001',
            'id_cabang': 'c-001',
            'nama_kader': 'Zidan Kusuma',
            'nama_posyandu': 'Posyandu Melati',
            'tanggal_periksa': '2026-07-10',
            'berat_badan': 50.0,
            'tinggi_badan': 158.0,
            'sistol': null,
            'distol': null,
            'gula_darah': null,
            'bmi': null,
            'status_gizi': 'obesitas_1',
            'keluhan': null,
            'saran': null,
            'created_at': null,
            'updated_at': null,
          },
          'audit': {'alert_created': false, 'recorded': true},
          'timestamp': '2026-07-25T23:40:33.379954Z',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        final result = await service.getDetail(
          idRemaja: 'r-001',
          idPantau: 'pr-002',
        );

        expect(result.idPantauRemaja, 'pr-002');
        expect(result.sistol, isNull);
        expect(result.distol, isNull);
        expect(result.gulaDarah, isNull);
        expect(result.bmi, isNull);
        expect(result.keluhan, isNull);
        expect(result.saran, isNull);
      });

      test('throws ServerException when success is false', () async {
        final dio = _mockDio(200, {
          'success': false,
          'error': {'code': 500, 'message': 'Internal server error'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idRemaja: 'r-001', idPantau: 'pr-001'),
          throwsA(predicate((e) => e is ServerException)),
        );
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idRemaja: 'invalid-id', idPantau: 'invalid-pantau'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idRemaja: 'r-001', idPantau: 'pr-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getDetail(idRemaja: 'r-001', idPantau: 'pr-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getGulaDarahChart', () {
      test('returns GulaDarahChartData on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'gula_darah_zones': [
              {'color': '#43A047', 'label': 'Normal', 'max': 126, 'min': 0, 'status': 'normal'},
              {'color': '#FFA726', 'label': 'Pra-diabetes', 'max': 200, 'min': 126, 'status': 'pra_diabetes'},
              {'color': '#B71C1C', 'label': 'Diabetes', 'max': 999, 'min': 200, 'status': 'diabetes'},
            ],
            'label': 'Normal',
            'latest_gula_darah': 95,
            'latest_status': 'normal',
            'measurements': [
              {'gula_darah': 94, 'tanggal_periksa': '2026-07-04'},
              {'gula_darah': 89, 'tanggal_periksa': '2026-07-11'},
              {'gula_darah': 91, 'tanggal_periksa': '2026-07-18'},
              {'gula_darah': 95, 'tanggal_periksa': '2026-07-22'},
            ],
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        final result = await service.getGulaDarahChart('r-001');

        expect(result.gulaDarahZones.length, 3);
        expect(result.gulaDarahZones[0].status, 'normal');
        expect(result.gulaDarahZones[0].label, 'Normal');
        expect(result.gulaDarahZones[0].min, 0);
        expect(result.gulaDarahZones[0].max, 126);
        expect(result.gulaDarahZones[0].color, '#43A047');
        expect(result.label, 'Normal');
        expect(result.latestGulaDarah, 95);
        expect(result.latestStatus, 'normal');
        expect(result.measurements.length, 4);
        expect(result.measurements[0].gulaDarah, 94);
        expect(result.measurements[0].tanggalPeriksa, '2026-07-04');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('invalid-id'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('r-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PemantauanRemajaService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('r-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
