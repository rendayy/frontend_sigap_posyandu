import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/posbindu/posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';

void main() {
  group('PosbinduDetailResponse', () {
    test('fromJson parses full data correctly', () {
      final json = {
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
      };

      final model = PosbinduDetailResponse.fromJson(json);

      expect(model.idAnggota, '1f67e7f7-bd46-44d6-aad4-89a6c96272cb');
      expect(model.nik, '0123456789876545');
      expect(model.nama, 'Mochamad Ramadhan Alfikri');
      expect(model.jenisKelamin, 'L');
      expect(model.tanggalLahir, '2004-09-10');
      expect(model.usia, 21);
      expect(model.statusAktif, 'aktif');
      expect(model.statusGizi, isNull);
      expect(model.noHp, '081234567891');
      expect(model.beratBadan, 65.5);
      expect(model.tinggiBadan, 170.0);
      expect(model.bmi, 22.66);
      expect(model.gulaDarahSewaktu, 110);
      expect(model.statusBmi, 'berat_badan_normal');
      expect(model.statusGulaDarah, 'normal');
      expect(model.faktorRisikoMerokok, 'tidak');
      expect(model.faktorRisikoKurangAktifitas, 'ya');
      expect(model.tanggalPeriksaTerakhir, '2026-08-01');

      final exportedJson = model.toJson();
      expect(
        exportedJson['id_anggota'],
        '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
      );
      expect(exportedJson['berat_badan'], 65.5);
      expect(exportedJson['status_bmi'], 'berat_badan_normal');
    });

    test('fromJson handles null values safely', () {
      final json = {
        'id_anggota': '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
        'nik': '0123456789876545',
        'nama': 'Mochamad Ramadhan Alfikri',
        'jenis_kelamin': 'L',
        'tanggal_lahir': null,
        'usia': 21,
        'status_aktif': 'aktif',
        'status_gizi': null,
        'no_hp': null,
        'berat_badan': null,
        'tinggi_badan': null,
        'bmi': null,
        'gula_darah_sewaktu': null,
        'status_bmi': null,
        'status_gula_darah': null,
        'faktor_risiko_merokok': null,
        'faktor_risiko_kurang_aktifitas': null,
        'tanggal_periksa_terakhir': null,
        'created_at': null,
        'updated_at': null,
      };

      final model = PosbinduDetailResponse.fromJson(json);

      expect(model.idAnggota, '1f67e7f7-bd46-44d6-aad4-89a6c96272cb');
      expect(model.beratBadan, isNull);
      expect(model.tinggiBadan, isNull);
      expect(model.bmi, isNull);
      expect(model.gulaDarahSewaktu, isNull);
      expect(model.statusBmi, isNull);
      expect(model.statusGulaDarah, isNull);
      expect(model.faktorRisikoMerokok, isNull);
      expect(model.faktorRisikoKurangAktifitas, isNull);
      expect(model.tanggalPeriksaTerakhir, isNull);
    });
  });

  group('PemeriksaanPosbinduItem', () {
    test('fromJson parses full data correctly', () {
      final json = {
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
      };

      final item = PemeriksaanPosbinduItem.fromJson(json);

      expect(item.no, 1);
      expect(item.idPeriksaPosbindu, '961a6b2e-1234-5678-9abc-def012345678');
      expect(item.idKader, '49568e7c-abcd-ef12-3456-789abcdef012');
      expect(item.tanggalPeriksa, '2026-06-27');
      expect(item.beratBadan, 60.65);
      expect(item.tinggiBadan, 170.0);
      expect(item.bmi, 21.0);
      expect(item.sistol, 116);
      expect(item.distol, 79);
      expect(item.gulaDarahSewaktu, 105);
      expect(item.statusBmi, 'berat_badan_normal');
    });

    test('fromJson handles null values safely', () {
      final json = {
        'no': 2,
        'id_periksa_posbindu': 'abc123',
        'id_kader': 'kader-001',
        'tanggal_periksa': '2026-06-20',
        'berat_badan': null,
        'tinggi_badan': null,
        'bmi': null,
        'sistol': null,
        'distol': null,
        'gula_darah_sewaktu': null,
        'status_bmi': null,
      };

      final item = PemeriksaanPosbinduItem.fromJson(json);

      expect(item.no, 2);
      expect(item.beratBadan, isNull);
      expect(item.tinggiBadan, isNull);
      expect(item.bmi, isNull);
      expect(item.sistol, isNull);
      expect(item.distol, isNull);
      expect(item.gulaDarahSewaktu, isNull);
      expect(item.statusBmi, 'unknown');
    });

    test('fromJson handles missing no field with default 0', () {
      final json = {
        'id_periksa_posbindu': 'test-id',
        'id_kader': 'kader-001',
        'tanggal_periksa': '2026-06-20',
        'berat_badan': 50.0,
        'tinggi_badan': 160.0,
        'bmi': 19.5,
        'sistol': 110,
        'distol': 70,
        'gula_darah_sewaktu': 95,
        'status_bmi': 'berat_badan_normal',
      };

      final item = PemeriksaanPosbinduItem.fromJson(json);

      expect(item.no, 0);
    });
  });

  group('PemeriksaanPosbinduListResponse', () {
    test('fromJson parses full response correctly', () {
      final json = {
        'data': [
          {
            'no': 1,
            'id_periksa_posbindu': 'id-1',
            'id_kader': 'kader-1',
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
        'success': true,
      };

      final response = PemeriksaanPosbinduListResponse.fromJson(json);

      expect(response.data.length, 1);
      expect(response.data.first.idPeriksaPosbindu, 'id-1');
      expect(response.pagination.page, 1);
      expect(response.pagination.limit, 5);
      expect(response.pagination.total, 12);
      expect(response.pagination.totalPages, 3);
      expect(response.success, true);
    });

    test('fromJson handles empty data list', () {
      final json = {
        'data': [],
        'pagination': {'page': 1, 'limit': 5, 'total': 0, 'total_pages': 0},
        'success': true,
      };

      final response = PemeriksaanPosbinduListResponse.fromJson(json);

      expect(response.data, isEmpty);
      expect(response.pagination.total, 0);
      expect(response.pagination.totalPages, 0);
    });
  });

  group('PemeriksaanPosbinduDetailResponse', () {
    test('fromJson parses full detail response correctly', () {
      final json = {
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
      };

      final response = PemeriksaanPosbinduDetailResponse.fromJson(json);

      expect(
        response.idPeriksaPosbindu,
        '961a6b2e-1234-5678-9abc-def012345678',
      );
      expect(response.idAnggota, '1bee01e5-abcd-ef12-3456-789abcdef012');
      expect(response.idKader, '49568e7c-abcd-ef12-3456-789abcdef012');
      expect(response.idCabang, '0bb10b9e-abcd-ef12-3456-789abcdef012');
      expect(response.tanggalPeriksa, '2026-06-27');
      expect(response.beratBadan, 60.65);
      expect(response.tinggiBadan, 170.0);
      expect(response.bmi, 21.0);
      expect(response.lingkarPerut, 73.2);
      expect(response.sistol, 116);
      expect(response.distol, 79);
      expect(response.gulaDarahSewaktu, 105);
      expect(response.kolesterolTotal, 165);
      expect(response.asamUrat, 4.2);
      expect(response.statusBmi, 'berat_badan_normal');
      expect(response.statusGulaDarah, 'normal');
      expect(response.statusRujukan, 'tidak');
      expect(response.faktorRisikoMerokok, 'tidak');
      expect(response.faktorRisikoKurangAktifitas, 'tidak');
      expect(response.keluhan, 'Tidak ada keluhan.');
      expect(response.saran, 'Pertahankan gaya hidup sehat.');
      expect(
        response.catatan,
        'Pemeriksaan rutin bulan ke-10. Kondisi sangat baik.',
      );
      expect(
        response.riwayatPenyakitKeluarga,
        'Tidak ada riwayat penyakit serius.',
      );
    });

    test('fromJson handles null values safely', () {
      final json = {
        'id_periksa_posbindu': 'test-id',
        'id_anggota': 'anggota-001',
        'id_kader': 'kader-001',
        'id_cabang': 'cabang-001',
        'tanggal_periksa': '2026-06-27',
        'berat_badan': null,
        'tinggi_badan': null,
        'bmi': null,
        'lingkar_perut': null,
        'sistol': null,
        'distol': null,
        'gula_darah_sewaktu': null,
        'kolesterol_total': null,
        'asam_urat': null,
        'status_bmi': null,
        'status_gula_darah': null,
        'status_rujukan': null,
        'faktor_risiko_merokok': null,
        'faktor_risiko_kurang_aktifitas': null,
        'keluhan': null,
        'saran': null,
        'catatan': null,
        'riwayat_penyakit_keluarga': null,
        'created_at': null,
        'updated_at': null,
      };

      final response = PemeriksaanPosbinduDetailResponse.fromJson(json);

      expect(response.idPeriksaPosbindu, 'test-id');
      expect(response.beratBadan, isNull);
      expect(response.tinggiBadan, isNull);
      expect(response.bmi, isNull);
      expect(response.lingkarPerut, isNull);
      expect(response.sistol, isNull);
      expect(response.distol, isNull);
      expect(response.gulaDarahSewaktu, isNull);
      expect(response.kolesterolTotal, isNull);
      expect(response.asamUrat, isNull);
      expect(response.statusBmi, isNull);
      expect(response.statusGulaDarah, isNull);
      expect(response.statusRujukan, isNull);
      expect(response.faktorRisikoMerokok, isNull);
      expect(response.faktorRisikoKurangAktifitas, isNull);
      expect(response.keluhan, isNull);
      expect(response.saran, isNull);
      expect(response.catatan, isNull);
      expect(response.riwayatPenyakitKeluarga, isNull);
    });
  });

  group('GulaDarahChartData', () {
    test('fromJson parses full data correctly', () {
      final json = {
        'gula_darah_zones': [
          {'color': '#43A047', 'label': 'Normal', 'max': 126, 'min': 0, 'status': 'normal'},
          {'color': '#FFA726', 'label': 'Pra-diabetes', 'max': 200, 'min': 126, 'status': 'pra_diabetes'},
          {'color': '#B71C1C', 'label': 'Diabetes', 'max': 999, 'min': 200, 'status': 'diabetes'},
        ],
        'label': 'Normal',
        'latest_gula_darah': 105,
        'latest_status': 'normal',
        'measurements': [
          {'gula_darah': 96, 'tanggal_periksa': '2025-09-30'},
          {'gula_darah': 118, 'tanggal_periksa': '2026-06-27'},
          {'gula_darah': 105, 'tanggal_periksa': '2026-06-27'},
        ],
      };

      final data = GulaDarahChartData.fromJson(json);

      expect(data.gulaDarahZones.length, 3);
      expect(data.gulaDarahZones[0].status, 'normal');
      expect(data.gulaDarahZones[1].label, 'Pra-diabetes');
      expect(data.gulaDarahZones[2].color, '#B71C1C');
      expect(data.label, 'Normal');
      expect(data.latestGulaDarah, 105);
      expect(data.latestStatus, 'normal');
      expect(data.measurements.length, 3);
      expect(data.measurements[0].gulaDarah, 96);
      expect(data.measurements[2].tanggalPeriksa, '2026-06-27');
    });

    test('fromJson parses empty data with null latest', () {
      final json = {
        'gula_darah_zones': [
          {'color': '#43A047', 'label': 'Normal', 'max': 126, 'min': 0, 'status': 'normal'},
        ],
        'label': null,
        'latest_gula_darah': null,
        'latest_status': null,
        'measurements': [],
      };

      final data = GulaDarahChartData.fromJson(json);

      expect(data.gulaDarahZones.length, 1);
      expect(data.label, 'Gula Darah');
      expect(data.latestGulaDarah, isNull);
      expect(data.latestStatus, isNull);
      expect(data.measurements, isEmpty);
    });

    test('toJson roundtrip preserves data', () {
      final data = GulaDarahChartData(
        gulaDarahZones: const [
          GulaDarahZone(status: 'normal', label: 'Normal', min: 0, max: 126, color: '#43A047'),
        ],
        label: 'Normal',
        latestGulaDarah: 105,
        latestStatus: 'normal',
        measurements: const [
          GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
        ],
      );

      final parsed = GulaDarahChartData.fromJson(data.toJson());

      expect(parsed.gulaDarahZones.length, 1);
      expect(parsed.gulaDarahZones.first.status, 'normal');
      expect(parsed.label, 'Normal');
      expect(parsed.latestGulaDarah, 105);
      expect(parsed.latestStatus, 'normal');
      expect(parsed.measurements.length, 1);
      expect(parsed.measurements.first.gulaDarah, 96);
    });
  });
}
