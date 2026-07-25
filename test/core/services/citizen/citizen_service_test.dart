import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
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
  group('CitizenService', () {
    group('getMyProfile', () {
      test('returns ProfileResponse on success', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {
            'id_anggota': '2d4ecbfe-b33e-404e-b580-339d7ee8fe54',
            'nik': '0821433725931236',
            'nama': 'Emma Elizabeth Myers',
            'no_hp': '089876543210',
            'tempat_lahir': 'Sidoarjo',
            'tanggal_lahir': '2002-04-02',
            'jenis_kelamin': 'P',
            'golongan_darah': 'A',
            'hubungan_keluarga': 'istri',
            'kategori_anggota': 'remaja',
            'status_aktif': 'aktif',
            'status_kesehatan': 'sehat',
            'catatan_khusus': null,
            'roles': ['user'],
            'keluarga': {
              'id_keluarga': '35483e13-b4d2-4556-b19a-69a5fdbafed5',
              'no_kk': '0821433725931234',
              'alamat': 'JL. Raya',
              'rt': '1',
              'rw': '1',
              'dusun': 'Ngaban',
              'cabang': null,
            },
            'created_at': '2026-07-22T12:17:10',
            'updated_at': '2026-07-23T02:58:56',
          },
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        final result = await service.getMyProfile();

        expect(result.idAnggota, '2d4ecbfe-b33e-404e-b580-339d7ee8fe54');
        expect(result.nama, 'Emma Elizabeth Myers');
        expect(result.nik, '0821433725931236');
        expect(result.noHp, '089876543210');
        expect(result.tempatLahir, 'Sidoarjo');
        expect(result.tanggalLahir, '2002-04-02');
        expect(result.jenisKelamin, 'P');
        expect(result.golonganDarah, 'A');
        expect(result.hubunganKeluarga, 'istri');
        expect(result.kategoriAnggota, 'remaja');
        expect(result.statusAktif, 'aktif');
        expect(result.roles, ['user']);
        expect(result.keluarga, isNotNull);
        expect(result.keluarga!.noKk, '0821433725931234');
        expect(result.keluarga!.alamat, 'JL. Raya');
        expect(result.keluarga!.rt, '1');
        expect(result.keluarga!.rw, '1');
        expect(result.keluarga!.dusun, 'Ngaban');
        expect(result.keluarga!.cabang, isNull);
      });

      test('throws ServerException on 404', () async {
        final dio = _mockDio(404, {
          'success': false,
          'error': {'code': 404, 'message': 'Data tidak ditemukan'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        expect(
          () => service.getMyProfile(),
          throwsA(predicate((e) => e is ServerException && e.message.contains('Data tidak ditemukan'))),
        );
      });

      test('throws ServerException on 401', () async {
        final dio = _mockDio(401, {
          'success': false,
          'error': {'code': 401, 'message': 'Token tidak valid'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        expect(
          () => service.getMyProfile(),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        expect(
          () => service.getMyProfile(),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });

    group('updateMyProfile', () {
      test('succeeds with nama and no_hp', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {},
          'message': 'Profil berhasil diperbarui.',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        await service.updateMyProfile(nama: 'Emma Myers', noHp: '089876543210');
      });

      test('succeeds with nama only', () async {
        final dio = _mockDio(200, {
          'success': true,
          'data': {},
          'message': 'Profil berhasil diperbarui.',
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        await service.updateMyProfile(nama: 'Emma Myers');
      });

      test('throws ServerException on 422', () async {
        final dio = _mockDio(422, {
          'success': false,
          'error': {'code': 422, 'message': 'Data yang Anda masukkan tidak valid'},
        });

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        expect(
          () => service.updateMyProfile(nama: ''),
          throwsA(predicate((e) => e is ServerException && e.statusCode == 422)),
        );
      });

      test('throws NetworkException on connection error', () async {
        final dio = _mockDio(0, {}, throwError: true);

        final apiClient = ApiClient(customDio: dio);
        final service = CitizenService(apiClient: apiClient);

        expect(
          () => service.updateMyProfile(nama: 'Test'),
          throwsA(predicate((e) => e is NetworkException)),
        );
      });
    });
  });
}
