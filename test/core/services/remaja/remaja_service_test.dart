import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_service.dart';
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
  group('RemajaService', () {
    group('getRemajaById', () {
      test('returns RemajaDetailResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_remaja': 'r-001',
            'nik': '0821433725931236',
            'nama': 'Emma Myers',
            'jenis_kelamin': 'P',
            'tanggal_lahir': '2002-01-15',
            'usia': 24,
            'sekolah': 'SMA Sidoarjo',
            'kelas': 'Kelas 12',
            'prestasi': null,
            'hobi': 'Melukis',
            'riwayat_anemia': 'tidak',
            'status_aktif': 'aktif',
            'status_gizi': null,
            'berat_badan': null,
            'tinggi_badan': null,
            'tanggal_pantau_terakhir': null,
            'no_hp': '089876543210',
            'created_at': '2026-07-22T12:17:10',
            'updated_at': '2026-07-22T12:17:10',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = RemajaService(apiClient: apiClient);

        final result = await service.getRemajaById('r-001');

        expect(result.idRemaja, 'r-001');
        expect(result.nama, 'Emma Myers');
        expect(result.usia, 24);
        expect(result.sekolah, 'SMA Sidoarjo');
        expect(result.kelas, 'Kelas 12');
        expect(result.hobi, 'Melukis');
        expect(result.riwayatAnemia, 'tidak');
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data remaja tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = RemajaService(apiClient: apiClient);

        expect(
          () => service.getRemajaById('invalid-id'),
          throwsA(
            predicate(
              (e) =>
                  e is ServerException &&
                  e.message.contains('Data remaja tidak ditemukan'),
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
        final service = RemajaService(apiClient: apiClient);

        expect(
          () => service.getRemajaById('r-001'),
          throwsA(
            predicate((e) => e is ServerException && e.statusCode == 401),
          ),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = RemajaService(apiClient: apiClient);

        expect(
          () => service.getRemajaById('r-001'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
