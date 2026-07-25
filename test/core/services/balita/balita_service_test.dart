import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
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
  group('BalitaService', () {
    group('getBalitaById', () {
      test('returns BalitaDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_balita': 'b-001',
            'id_anggota': 'a-001',
            'nik': '1234567890123456',
            'nama': 'Andi Pratama',
            'jenis_kelamin': 'L',
            'tanggal_lahir': '2023-01-15',
            'usia': 42,
            'berat_lahir': 3.5,
            'panjang_lahir': 50.0,
            'asi_eksklusif': 'ya',
            'imunisasi_dasar': 'lengkap',
            'status_gizi': 'baik',
            'status_aktif': 'aktif',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        final result = await service.getBalitaById('b-001');

        expect(result.idBalita, 'b-001');
        expect(result.nama, 'Andi Pratama');
        expect(result.usia, 42);
        expect(result.beratLahir, 3.5);
        expect(result.panjangLahir, 50.0);
        expect(result.imunisasiDasar, 'lengkap');
        expect(result.statusGizi, 'baik');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data balita tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        expect(
          () => service.getBalitaById('invalid-id'),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data balita tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token JWT tidak valid atau expired'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        expect(
          () => service.getBalitaById('b-001'),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        expect(
          () => service.getBalitaById('b-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getGrowthChart', () {
      test('returns GrowthChartResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'chart_type': 'bb_u',
            'id_anggota': 'a-001',
            'jenis_kelamin': 'L',
            'latest_status': 'Normal',
            'measurements': [
              {'berat': 8.5, 'status_gizi': 'Normal', 'tanggal_pantau': '2024-01-15', 'usia_bulan': 12},
            ],
            'standard_curves': {
              'median': [{'nilai': 8.0, 'usia': 12}],
              'p3': [{'nilai': 7.0, 'usia': 12}],
              'p97': [{'nilai': 10.0, 'usia': 12}],
            },
            'zone_labels': {'min': 'Bawah', 'max': 'Atas'},
            'standard_source': 'WHO 2006',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        final result = await service.getGrowthChart('b-001');

        expect(result.chartType, 'bb_u');
        expect(result.jenisKelamin, 'L');
        expect(result.latestStatus, 'Normal');
        expect(result.measurements.length, 1);
        expect(result.measurements.first.berat, 8.5);
        expect(result.standardCurves['median']?.length, 1);
        expect(result.standardSource, 'WHO 2006');
      });

      test('throws ServerException on API error', () async {
        final dio = _mockDio(500, {
          'success': false,
          'error': {'code': 500, 'message': 'Gagal memuat grafik'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        expect(
          () => service.getGrowthChart('b-001'),
          throwsA(predicate((e) => e is ServerException)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = BalitaService(apiClient: apiClient);

        expect(
          () => service.getGrowthChart('b-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('getDownloadKmsUrl', () {
      test('returns URL containing endpoint and balita id', () {
        final service = BalitaService();
        final url = service.getDownloadKmsUrl('b-001');
        expect(url, contains('/api/balita/b-001/download-kms'));
        expect(url, startsWith('http'));
      });
    });
  });
}
