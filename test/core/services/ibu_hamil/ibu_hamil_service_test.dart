import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
import 'package:frontend_posyandu/core/services/ibu_hamil/ibu_hamil_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

const _detailPath = '/api/v1/ibu-hamil/ih-001';
const _listPath = '/api/v1/ibu-hamil/ih-001/pemeriksaan';

Dio _mockDioByPath(
  Map<String, Object> byPath, {
  Map<String, int> statusCodes = const {},
  bool notFoundAsError = true,
}) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final data = byPath[options.path];
        if (data == null) {
          if (!notFoundAsError) {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: null),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: options,
                statusCode: 404,
                data: {'success': false, 'error': {'code': 404, 'message': 'Not found'}},
              ),
            ),
          );
          return;
        }
        final code = statusCodes[options.path] ?? 200;
        if (code >= 200 && code < 300) {
          handler.resolve(
            Response(requestOptions: options, statusCode: code, data: data),
          );
        } else {
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: options,
                statusCode: code,
                data: data,
              ),
            ),
          );
        }
      },
    ),
  );
  return dio;
}

Dio _throwDio() {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.reject(
          DioException(requestOptions: options, type: DioExceptionType.connectionTimeout),
        );
      },
    ),
  );
  return dio;
}

class _FakeCitizenService extends CitizenService {
  final ProfileResponse profile;
  _FakeCitizenService(this.profile) : super();

  @override
  Future<ProfileResponse> getMyProfile() async => profile;
}

ProfileResponse _profile(String nama) => ProfileResponse.fromJson({
  'id_anggota': 'ang-001',
  'nik': '3201012345678902',
  'nama': nama,
});

Map<String, dynamic> _detailJson({Object? usia}) => {
  'id_ibu_hamil': 'ih-001',
  'nama': 'Siti Aminah',
  'nik': '3201012345678902',
  'hpht': '2026-06-01',
  'hpl': '2027-03-08',
  'gravida': 2,
  'para': 1,
  'abortus': 0,
  'tinggi_badan': 156.5,
  'golongan_darah': 'A',
  'riwayat_penyakit': null,
  'ringkasan_kehamilan': {'usia_kehamilan': usia ?? 20},
};

Map<String, dynamic> _periksaJson({
  String id = 'px-20',
  String tanggal = '2026-08-20',
  double? bb = 62.0,
  int? sistol = 110,
  int? distol = 75,
  double? lingkar = 26.0,
  double? tfu = 22.0,
  int? usia = 20,
  String keluhan = 'Tidak ada keluhan.',
}) => {
  'id_periksa': id,
  'tanggal_periksa': tanggal,
  'usia_kehamilan': usia,
  'berat_badan': bb,
  'sistol': sistol,
  'distol': distol,
  'lingkar_lengan': lingkar,
  'tinggi_fundus': tfu,
  'letak_janin': 'presentasi kepala',
  'denyut_jantung': 148,
  'keluhan': keluhan,
  'tindakan': null,
  'tablet_fe': null,
  'rujukan': null,
  'no': 1,
};

Map<String, dynamic> _pemeriksaanEnvelope(List<Map<String, dynamic>> data,
        {int total = 2}) =>
    {
      'success': true,
      'data': data,
      'pagination': {'page': 1, 'limit': 10, 'total': total, 'total_pages': 1},
      'timestamp': '2026-08-21T00:00:00Z',
    };

void main() {
  group('IbuHamilService.getDetail', () {
    test('returns IbuHamilDetailResponse on success', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getDetail('ih-001');

      expect(result.idIbuHamil, 'ih-001');
      expect(result.nama, 'Siti Aminah');
      expect(result.usiaKehamilanSaatIni, 20);
      expect(result.hpl, '2027-03-08');
    });

    test('throws ServerException on 404', () async {
      final dio = _mockDioByPath({});
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      expect(
        () => service.getDetail('ih-001'),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 404)),
      );
    });

    test('throws ServerException with message on error payload', () async {
      final dio = _mockDioByPath(
        {_detailPath: {'success': false, 'error': {'code': 404, 'message': 'Data ibu hamil tidak ditemukan'}}},
      );
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      expect(
        () => service.getDetail('ih-001'),
        throwsA(
          predicate((e) => e is ServerException && e.message.contains('Data ibu hamil tidak ditemukan')),
        ),
      );
    });

    test('throws ServerException on 401', () async {
      final dio = _mockDioByPath(
        {_detailPath: {'success': false, 'error': {'code': 401, 'message': 'expired'}}},
        statusCodes: {_detailPath: 401},
      );
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      expect(
        () => service.getDetail('ih-001'),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
      );
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(apiClient: ApiClient(customDio: _throwDio()));

      expect(
        () => service.getDetail('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });

  group('IbuHamilService.getPemeriksaanList', () {
    test('returns items with pagination on success', () async {
      final dio = _mockDioByPath({
        _listPath: _pemeriksaanEnvelope([_periksaJson(), _periksaJson(id: 'px-1', tanggal: '2026-08-01', bb: 60.0)], total: 12)
          ..['pagination'] = {'page': 1, 'limit': 10, 'total': 12, 'total_pages': 2},
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getPemeriksaanList('ih-001', page: 1, limit: 10);

      expect(result.data.length, 2);
      expect(result.data.first.idPeriksa, 'px-20');
      expect(result.pagination!.total, 12);
      expect(result.pagination!.hasMore, true);
    });

    test('returns empty list when no data', () async {
      final dio = _mockDioByPath({
        _listPath: {
          'success': true,
          'data': [],
          'pagination': {'page': 1, 'limit': 10, 'total': 0, 'total_pages': 0},
        },
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getPemeriksaanList('ih-001', page: 1, limit: 10);

      expect(result.data, isEmpty);
      expect(result.pagination!.total, 0);
    });

    test('throws ServerException on 401', () async {
      final dio = _mockDioByPath(
        {_listPath: {'success': false, 'error': {'code': 401, 'message': 'expired'}}},
        statusCodes: {_listPath: 401},
      );
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      expect(
        () => service.getPemeriksaanList('ih-001'),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
      );
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(apiClient: ApiClient(customDio: _throwDio()));

      expect(
        () => service.getPemeriksaanList('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });

  group('IbuHamilService.getBeratBadanChart', () {
    test('returns chart data on success', () async {
      final dio = _mockDioByPath({
        '$_detailPath/berat-badan-chart': {
          'success': true,
          'data': {
            'label': 'Berat Badan',
            'latest_berat': 57.0,
            'measurements': [
              {'minggu': 16, 'berat': 55.5},
              {'minggu': 20, 'berat': 57.0},
            ],
            'batas_atas': [
              {'minggu': 16, 'nilai': 60.0},
              {'minggu': 20, 'nilai': 62.0},
            ],
            'batas_bawah': [
              {'minggu': 16, 'nilai': 48.0},
              {'minggu': 20, 'nilai': 50.0},
            ],
          },
        },
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getBeratBadanChart('ih-001');

      expect(result.measurements.length, 2);
      expect(result.measurements.first.nilai, 55.5);
      expect(result.latestBerat, 57.0);
      expect(result.batasAtas.length, 2);
    });

    test('returns empty chart data', () async {
      final dio = _mockDioByPath({
        '$_detailPath/berat-badan-chart': {'success': true, 'data': {}},
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getBeratBadanChart('ih-001');

      expect(result.measurements, isEmpty);
      expect(result.latestBerat, null);
    });

    test('throws ServerException on 401', () async {
      final dio = _mockDioByPath(
        {'$_detailPath/berat-badan-chart': {'success': false}},
        statusCodes: {'$_detailPath/berat-badan-chart': 401},
      );
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      expect(
        () => service.getBeratBadanChart('ih-001'),
        throwsA(predicate((e) => e is ServerException && e.statusCode == 401)),
      );
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(apiClient: ApiClient(customDio: _throwDio()));

      expect(
        () => service.getBeratBadanChart('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });

  group('IbuHamilService.getTinggiFundusChart', () {
    test('returns chart data on success', () async {
      final dio = _mockDioByPath({
        '$_detailPath/tinggi-fundus-chart': {
          'success': true,
          'data': {
            'label': 'Tinggi Fundus',
            'latest_tinggi': 22.0,
            'measurements': [
              {'minggu': 16, 'tinggi': 20.0},
              {'minggu': 20, 'tinggi': 22.0},
            ],
            'standar': [
              {'minggu': 16, 'nilai': 18.0},
              {'minggu': 20, 'nilai': 22.0},
            ],
          },
        },
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getTinggiFundusChart('ih-001');

      expect(result.measurements.length, 2);
      expect(result.measurements.last.nilai, 22.0);
      expect(result.latestTinggi, 22.0);
      expect(result.standar.length, 2);
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(apiClient: ApiClient(customDio: _throwDio()));

      expect(
        () => service.getTinggiFundusChart('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });

  group('IbuHamilService.getRiwayatPemeriksaan', () {
    test('returns items, pagination and derived trimester', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson(usia: 20)},
        _listPath: _pemeriksaanEnvelope([_periksaJson(), _periksaJson(id: 'px-1', tanggal: '2026-08-01', bb: 60.0)], total: 2),
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getRiwayatPemeriksaan('ih-001', page: 1, limit: 10);

      expect(result.items.length, 2);
      expect(result.items.first.idPeriksa, 'px-20');
      expect(result.pagination!.total, 2);
      expect(result.trimester, 2);
    });

    test('derives trimester 1 when usia <= 13', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson(usia: 12)},
        _listPath: _pemeriksaanEnvelope([]),
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getRiwayatPemeriksaan('ih-001');

      expect(result.trimester, 1);
      expect(result.items, isEmpty);
    });

    test('derives trimester 3 when usia > 27', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson(usia: 30)},
        _listPath: _pemeriksaanEnvelope([]),
      });
      final service = IbuHamilService(apiClient: ApiClient(customDio: dio));

      final result = await service.getRiwayatPemeriksaan('ih-001');

      expect(result.trimester, 3);
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(apiClient: ApiClient(customDio: _throwDio()));

      expect(
        () => service.getRiwayatPemeriksaan('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });

  group('IbuHamilService.getBeranda', () {
    test('builds complete beranda data on success', () async {
      final newer = _periksaJson(); // px-20, 2026-08-20, bb 62.0
      final older = _periksaJson(id: 'px-1', tanggal: '2026-08-01', bb: 60.0);
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: _pemeriksaanEnvelope([newer, older], total: 2),
        '$_listPath/px-20': {
          'success': true,
          'data': _periksaJson(bb: 62.5, sistol: 115),
        },
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.nama, 'Siti Aminah');
      expect(result.inisial, 'S');
      expect(result.statusLabel, 'Ibu Hamil');

      expect(result.kehamilan.usiaMinggu, 20);
      expect(result.kehamilan.trimester, 2);
      expect(result.kehamilan.hpl, '8 Maret 2027');
      expect(result.kehamilan.progressPersen, 50);
      expect(result.kehamilan.hariMenujuHpl, greaterThan(0));

      expect(result.vital.beratBadanKg, 62.5);
      expect(result.vital.beratBadanDeltaKg, 2.5);
      expect(result.vital.beratBadanStatus, 'Normal');
      expect(result.vital.tekananDarah, '115/75');
      expect(result.vital.tekananDarahStatus, 'Normal');
      expect(result.vital.lilaCm, 26.0);
      expect(result.vital.tinggiFundusCm, 22.0);
      expect(result.vital.kunjunganAnc.selesai, 2);
      expect(result.vital.kunjunganAnc.target, 9);

      expect(result.jadwal.kunjunganKe, '3');
      expect(result.jadwal.status, 'Akan Datang');
      expect(result.edukasi.trimester, 2);
    });

    test('sets Waspada status when systolic >= 140', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: _pemeriksaanEnvelope([_periksaJson(sistol: 145, distol: 95)], total: 1),
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.vital.tekananDarah, '145/95');
      expect(result.vital.tekananDarahStatus, 'Waspada');
    });

    test('sets Perlu Perhatian when berat badan di luar rentang normal', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: _pemeriksaanEnvelope([_periksaJson(bb: 41.0)], total: 1),
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.vital.beratBadanKg, 41.0);
      expect(result.vital.beratBadanStatus, 'Perlu Perhatian');
    });

    test('handles empty pemeriksaan list', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: _pemeriksaanEnvelope([], total: 0),
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.vital.beratBadanKg, null);
      expect(result.vital.tekananDarah, '-');
      expect(result.vital.kunjunganAnc.selesai, 0);
      expect(result.jadwal.status, 'Belum Ada Pemeriksaan');
    });

    test('parses pemeriksaan nested data when api returns envelope', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: {
          'success': true,
          'data': {
            'data': [_periksaJson()],
            'pagination': {'page': 1, 'limit': 10, 'total': 5, 'total_pages': 1},
          },
          'pagination': {'page': 1, 'limit': 10, 'total': 5, 'total_pages': 1},
        },
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.vital.kunjunganAnc.selesai, 5);
      expect(result.jadwal.kunjunganKe, '2');
    });

    test('falls back to detail nama when profile nama is empty', () async {
      final dio = _mockDioByPath({
        _detailPath: {'success': true, 'data': _detailJson()},
        _listPath: _pemeriksaanEnvelope([]),
      });
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: dio),
        citizenService: _FakeCitizenService(_profile('')),
      );

      final result = await service.getBeranda('ih-001');

      expect(result.nama, 'Siti Aminah');
      expect(result.inisial, 'S');
    });

    test('throws NetworkException on connection error', () async {
      final service = IbuHamilService(
        apiClient: ApiClient(customDio: _throwDio()),
        citizenService: _FakeCitizenService(_profile('Siti Aminah')),
      );

      expect(
        () => service.getBeranda('ih-001'),
        throwsA(predicate((e) => e is NetworkException)),
      );
    });
  });
}