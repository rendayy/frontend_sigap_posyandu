import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';

void main() {
  group('IbuHamilDetailResponse.fromJson', () {
    test('parses full detail payload', () {
      final json = {
        'id_ibu_hamil': 'ih-001',
        'nama': 'Siti Aminah',
        'nik': '3201012345678901',
        'hpht': '2026-06-01',
        'hpl': '2027-03-08',
        'gravida': 2,
        'para': 1,
        'abortus': 0,
        'tinggi_badan': 156.5,
        'golongan_darah': 'A',
        'riwayat_penyakit': null,
        'ringkasan_kehamilan': {'usia_kehamilan': 12},
      };

      final result = IbuHamilDetailResponse.fromJson(json);

      expect(result.idIbuHamil, 'ih-001');
      expect(result.nama, 'Siti Aminah');
      expect(result.hpht, '2026-06-01');
      expect(result.hpl, '2027-03-08');
      expect(result.gravida, 2);
      expect(result.para, 1);
      expect(result.abortus, 0);
      expect(result.tinggiBadan, 156.5);
      expect(result.golonganDarah, 'A');
      expect(result.usiaKehamilanSaatIni, 12);
    });

    test('parses usia_kehamilan as num (double) without throwing', () {
      final json = {
        'id_ibu_hamil': 'ih-001',
        'nama': 'Siti Aminah',
        'ringkasan_kehamilan': {'usia_kehamilan': 12.0},
      };

      final result = IbuHamilDetailResponse.fromJson(json);

      expect(result.usiaKehamilanSaatIni, 12);
    });

    test('handles missing ringkasan_kehamilan and optional fields', () {
      final json = {'id_ibu_hamil': 'ih-001', 'nama': 'Aminah'};

      final result = IbuHamilDetailResponse.fromJson(json);

      expect(result.usiaKehamilanSaatIni, null);
      expect(result.nik, null);
      expect(result.hpht, null);
      expect(result.gravida, null);
      expect(result.tinggiBadan, null);
    });
  });

  group('PemeriksaanIbuHamilItem.fromJson', () {
    test('parses full pemeriksaan item', () {
      final json = {
        'id_periksa': 'px-1',
        'tanggal_periksa': '2026-08-20',
        'usia_kehamilan': 12,
        'berat_badan': 58.5,
        'sistol': 110,
        'distol': 75,
        'lingkar_lengan': 26.0,
        'tinggi_fundus': 22.0,
        'letak_janin': 'presentasi kepala',
        'denyut_jantung': 148,
        'keluhan': 'Mual',
        'tindakan': 'Edukasi nutrisi',
        'tablet_fe': 'ya',
        'rujukan': 'tidak',
        'no': 1,
      };

      final result = PemeriksaanIbuHamilItem.fromJson(json);

      expect(result.idPeriksa, 'px-1');
      expect(result.tanggalPeriksa, '2026-08-20');
      expect(result.usiaKehamilan, 12);
      expect(result.beratBadan, 58.5);
      expect(result.sistol, 110);
      expect(result.distol, 75);
      expect(result.lingkarLengan, 26.0);
      expect(result.tinggiFundus, 22.0);
      expect(result.denyutJantung, 148);
      expect(result.keluhan, 'Mual');
      expect(result.no, 1);
    });

    test('handles null and missing fields', () {
      final json = {'id_periksa': 'px-1'};

      final result = PemeriksaanIbuHamilItem.fromJson(json);

      expect(result.tanggalPeriksa, null);
      expect(result.beratBadan, null);
      expect(result.usiaKehamilan, null);
      expect(result.no, null);
      expect(result.idPeriksa, 'px-1');
    });
  });

  group('PemeriksaanListResponse.fromJson', () {
    test('parses list with pagination', () {
      final json = {
        'data': [
          {'id_periksa': 'px-1', 'berat_badan': 55.5},
          {'id_periksa': 'px-2', 'berat_badan': 57.0},
        ],
        'pagination': {'page': 1, 'limit': 10, 'total': 12, 'total_pages': 2},
      };

      final result = PemeriksaanListResponse.fromJson(json);

      expect(result.data.length, 2);
      expect(result.data.first.idPeriksa, 'px-1');
      expect(result.pagination!.page, 1);
      expect(result.pagination!.total, 12);
      expect(result.pagination!.totalPages, 2);
      expect(result.pagination!.hasMore, true);
    });

    test('parses empty list without pagination', () {
      final result = PemeriksaanListResponse.fromJson({'data': []});

      expect(result.data, isEmpty);
      expect(result.pagination, null);
    });
  });

  group('PaginationMeta', () {
    test('hasMore is false on last page', () {
      const meta = PaginationMeta(page: 2, limit: 10, total: 12, totalPages: 2);
      expect(meta.hasMore, false);
    });

    test('hasMore is true when more pages remain', () {
      const meta = PaginationMeta(page: 1, limit: 10, total: 12, totalPages: 2);
      expect(meta.hasMore, true);
    });
  });

  group('BeratBadanChartResponse.fromJson', () {
    final envelope = {
      'success': true,
      'data': {
        'label': 'Berat Badan',
        'latest_berat': 57.0,
        'latest_usia_kehamilan': 20,
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
      'timestamp': '2026-08-01T00:00:00Z',
    };

    test('unwraps nested data envelope', () {
      final result = BeratBadanChartResponse.fromJson(envelope);

      expect(result.label, 'Berat Badan');
      expect(result.latestBerat, 57.0);
      expect(result.latestUsiaKehamilan, 20);
      expect(result.measurements.length, 2);
      expect(result.measurements.first.nilai, 55.5);
      expect(result.batasAtas.length, 2);
      expect(result.batasBawah.length, 2);
    });

    test('handles direct payload and empty measurements', () {
      final result = BeratBadanChartResponse.fromJson({'data': {}});

      expect(result.measurements, isEmpty);
      expect(result.batasAtas, isEmpty);
      expect(result.batasBawah, isEmpty);
      expect(result.latestBerat, null);
    });

    test('ringkasan sorts by minggu and computes kenaikan', () {
      final result = BeratBadanChartResponse(
        measurements: [
          ChartMeasurement(minggu: 20, nilai: 57.0),
          ChartMeasurement(minggu: 16, nilai: 55.5),
        ],
      );

      expect(result.ringkasan.awal, 55.5);
      expect(result.ringkasan.terakhir, 57.0);
      expect(result.ringkasan.kenaikan, 1.5);
    });

    test('ringkasan returns zeros when empty', () {
      final result = BeratBadanChartResponse(measurements: []);
      expect(result.ringkasan.awal, 0);
      expect(result.ringkasan.terakhir, 0);
      expect(result.ringkasan.kenaikan, 0);
    });
  });

  group('TinggiFundusChartResponse.fromJson', () {
    test('unwraps nested data envelope with standar', () {
      final json = {
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
      };

      final result = TinggiFundusChartResponse.fromJson(json);

      expect(result.label, 'Tinggi Fundus');
      expect(result.latestTinggi, 22.0);
      expect(result.measurements.length, 2);
      expect(result.standar.length, 2);
    });

    test('handles empty standar and measurements', () {
      final result = TinggiFundusChartResponse.fromJson({'data': {}});

      expect(result.measurements, isEmpty);
      expect(result.standar, isEmpty);
      expect(result.latestTinggi, null);
    });
  });

  group('RiwayatPemeriksaanData', () {
    test('fromJson + toJson roundtrip', () {
      final data = RiwayatPemeriksaanData(
        items: [
          PemeriksaanIbuHamilItem(idPeriksa: 'px-1', tanggalPeriksa: '2026-08-20'),
          PemeriksaanIbuHamilItem(idPeriksa: 'px-2', tanggalPeriksa: '2026-08-01'),
        ],
        pagination: const PaginationMeta(page: 1, limit: 10, total: 2, totalPages: 1),
        trimester: 2,
      );

      final json = data.toJson();
      final parsed = RiwayatPemeriksaanData.fromJson(json);

      expect(parsed.items.length, 2);
      expect(parsed.items.first.idPeriksa, 'px-1');
      expect(parsed.pagination!.total, 2);
      expect(parsed.trimester, 2);
    });
  });
}