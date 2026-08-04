import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

Dio _mockDio(int statusCode, Object data, {bool throwError = false}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (throwError) {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.connectionTimeout,
            ),
          );
        } else {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: statusCode,
              data: data,
            ),
          );
        }
      },
    ),
  );
  return dio;
}

void main() {
  group('PosbinduService', () {
    group('getPosbinduDetail', () {
      test('returns PosbinduDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_anggota': '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
            'nik': '0123456789876545',
            'nama': 'Mochamad Ramadhan Alfikri',
            'jenis_kelamin': 'L',
            'tanggal_lahir': '2004-09-10',
            'usia': 21,
            'status_aktif': 'aktif',
            'status_gizi': null,
            'no_hp': '081234567891',
            'berat_badan': 65.5,
            'tinggi_badan': 170.0,
            'bmi': 22.66,
            'gula_darah_sewaktu': 110,
            'status_bmi': 'berat_badan_normal',
            'status_gula_darah': 'normal',
            'faktor_risiko_merokok': 'tidak',
            'faktor_risiko_kurang_aktifitas': 'ya',
            'tanggal_periksa_terakhir': '2026-08-01',
            'created_at': '2026-08-01T10:00:00Z',
            'updated_at': '2026-08-01T10:00:00Z',
          },
          'timestamp': '2026-08-03T03:14:20.954912Z',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getPosbinduDetail(
          '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
        );

        expect(result.idAnggota, '1f67e7f7-bd46-44d6-aad4-89a6c96272cb');
        expect(result.nama, 'Mochamad Ramadhan Alfikri');
        expect(result.usia, 21);
        expect(result.statusBmi, 'berat_badan_normal');
        expect(result.statusGulaDarah, 'normal');
        expect(result.faktorRisikoMerokok, 'tidak');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data posbindu tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getPosbinduDetail('invalid-id'),
          throwsA(
            predicate(
              (e) =>
                  e is ServerException &&
                  e.message.contains('Data posbindu tidak ditemukan'),
            ),
          ),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {
            'code': 401,
            'message': 'Token JWT tidak valid atau expired',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getPosbinduDetail('valid-id'),
          throwsA(
            predicate((e) => e is ServerException && e.statusCode == 401),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getPosbinduDetail('valid-id'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getList', () {
      test('returns PemeriksaanPosbinduListResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': [
            {
              'no': 1,
              'id_periksa_posbindu': '961a6b2e-1234-5678-9abc-def012345678',
              'id_kader': '49568e7c-abcd-ef12-3456-789abcdef012',
              'tanggal_periksa': '2026-06-27',
              'berat_badan': 60.65,
              'tinggi_badan': 170.0,
              'bmi': 21.0,
              'sistol': 116,
              'distol': 79,
              'gula_darah_sewaktu': 105,
              'status_bmi': 'berat_badan_normal',
            },
          ],
          'pagination': {'page': 1, 'limit': 5, 'total': 12, 'total_pages': 3},
          'timestamp': '2026-08-04T01:38:04.734253Z',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getList(
          idAnggota: '1bee01e5-abcd-ef12-3456-789abcdef012',
          page: 1,
          limit: 5,
        );

        expect(result.data.length, 1);
        expect(
          result.data.first.idPeriksaPosbindu,
          '961a6b2e-1234-5678-9abc-def012345678',
        );
        expect(result.pagination.page, 1);
        expect(result.pagination.total, 12);
        expect(result.pagination.totalPages, 3);
        expect(result.success, true);
      });

      test('returns empty list when no data', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': [],
          'pagination': {'page': 1, 'limit': 5, 'total': 0, 'total_pages': 0},
          'timestamp': '2026-08-04T01:37:00.121271Z',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getList(
          idAnggota: 'test-id',
          page: 1,
          limit: 5,
        );

        expect(result.data, isEmpty);
        expect(result.pagination.total, 0);
        expect(result.pagination.totalPages, 0);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data anggota tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getList(idAnggota: 'invalid-id'),
          throwsA(
            predicate(
              (e) =>
                  e is ServerException &&
                  e.message.contains('Data anggota tidak ditemukan'),
            ),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getList(idAnggota: 'valid-id'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getDetail', () {
      test('returns PemeriksaanPosbinduDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_periksa_posbindu': '961a6b2e-1234-5678-9abc-def012345678',
            'id_anggota': '1bee01e5-abcd-ef12-3456-789abcdef012',
            'id_kader': '49568e7c-abcd-ef12-3456-789abcdef012',
            'id_cabang': '0bb10b9e-abcd-ef12-3456-789abcdef012',
            'tanggal_periksa': '2026-06-27',
            'berat_badan': 60.65,
            'tinggi_badan': 170.0,
            'bmi': 21.0,
            'lingkar_perut': 73.2,
            'sistol': 116,
            'distol': 79,
            'gula_darah_sewaktu': 105,
            'kolesterol_total': 165,
            'asam_urat': 4.2,
            'status_bmi': 'berat_badan_normal',
            'status_gula_darah': 'normal',
            'status_rujukan': 'tidak',
            'faktor_risiko_merokok': 'tidak',
            'faktor_risiko_kurang_aktifitas': 'tidak',
            'keluhan': 'Tidak ada keluhan.',
            'saran': 'Pertahankan gaya hidup sehat.',
            'catatan': 'Pemeriksaan rutin bulan ke-10. Kondisi sangat baik.',
            'riwayat_penyakit_keluarga': 'Tidak ada riwayat penyakit serius.',
            'created_at': '2026-07-27T16:29:46',
            'updated_at': '2026-07-27T16:29:46',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getDetail(
          idAnggota: '1bee01e5-abcd-ef12-3456-789abcdef012',
          idPeriksaPosbindu: '961a6b2e-1234-5678-9abc-def012345678',
        );

        expect(
          result.idPeriksaPosbindu,
          '961a6b2e-1234-5678-9abc-def012345678',
        );
        expect(result.idAnggota, '1bee01e5-abcd-ef12-3456-789abcdef012');
        expect(result.beratBadan, 60.65);
        expect(result.tinggiBadan, 170.0);
        expect(result.bmi, 21.0);
        expect(result.sistol, 116);
        expect(result.distol, 79);
        expect(result.gulaDarahSewaktu, 105);
        expect(result.statusBmi, 'berat_badan_normal');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Pemeriksaan tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getDetail(
            idAnggota: 'valid-id',
            idPeriksaPosbindu: 'invalid-id',
          ),
          throwsA(
            predicate(
              (e) =>
                  e is ServerException &&
                  e.message.contains('Pemeriksaan tidak ditemukan'),
            ),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getDetail(
            idAnggota: 'valid-id',
            idPeriksaPosbindu: 'valid-id',
          ),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getGulaDarahChart', () {
      test('returns GulaDarahChartData on success with data', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'gula_darah_zones': [
              {
                'color': '#43A047',
                'label': 'Normal',
                'max': 126,
                'min': 0,
                'status': 'normal',
              },
              {
                'color': '#FFA726',
                'label': 'Pra-diabetes',
                'max': 200,
                'min': 126,
                'status': 'pra_diabetes',
              },
              {
                'color': '#B71C1C',
                'label': 'Diabetes',
                'max': 999,
                'min': 200,
                'status': 'diabetes',
              },
            ],
            'label': 'Normal',
            'latest_gula_darah': 105,
            'latest_status': 'normal',
            'measurements': [
              {'gula_darah': 96, 'tanggal_periksa': '2025-09-30'},
              {'gula_darah': 118, 'tanggal_periksa': '2026-06-27'},
              {'gula_darah': 105, 'tanggal_periksa': '2026-06-27'},
            ],
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getGulaDarahChart(
          '1bee01e5-abcd-ef12-3456-789abcdef012',
        );

        expect(result.gulaDarahZones.length, 3);
        expect(result.gulaDarahZones.first.label, 'Normal');
        expect(result.label, 'Normal');
        expect(result.latestGulaDarah, 105);
        expect(result.latestStatus, 'normal');
        expect(result.measurements.length, 3);
      });

      test('returns GulaDarahChartData on success with empty data', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'gula_darah_zones': [
              {
                'color': '#43A047',
                'label': 'Normal',
                'max': 126,
                'min': 0,
                'status': 'normal',
              },
              {
                'color': '#FFA726',
                'label': 'Pra-diabetes',
                'max': 200,
                'min': 126,
                'status': 'pra_diabetes',
              },
              {
                'color': '#B71C1C',
                'label': 'Diabetes',
                'max': 999,
                'min': 200,
                'status': 'diabetes',
              },
            ],
            'label': null,
            'latest_gula_darah': null,
            'latest_status': null,
            'measurements': [],
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        final result = await service.getGulaDarahChart('test-id');

        expect(result.gulaDarahZones.length, 3);
        expect(result.label, 'Gula Darah'); // default fallback
        expect(result.latestGulaDarah, null);
        expect(result.latestStatus, null);
        expect(result.measurements, isEmpty);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data anggota tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('invalid-id'),
          throwsA(
            predicate(
              (e) =>
                  e is ServerException &&
                  e.message.contains('Data anggota tidak ditemukan'),
            ),
          ),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {
            'code': 401,
            'message': 'Token JWT tidak valid atau expired',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('valid-id'),
          throwsA(
            predicate((e) => e is ServerException && e.statusCode == 401),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = PosbinduService(apiClient: apiClient);

        expect(
          () => service.getGulaDarahChart('valid-id'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
