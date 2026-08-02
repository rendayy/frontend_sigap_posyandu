import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/warga_base_model.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/models/remaja/remaja_model.dart';

void main() {
  group('WargaBase', () {
    test('toJson outputs common fields', () {
      const base = WargaBase(
        nik: '1234567890123456',
        nama: 'Andi',
        jenisKelamin: 'L',
        tanggalLahir: '2023-01-15',
        usia: 42,
        statusAktif: 'aktif',
      );
      final json = base.toJson();
      expect(json['nik'], '1234567890123456');
      expect(json['nama'], 'Andi');
      expect(json['usia'], 42);
      expect(json['status_aktif'], 'aktif');
    });
  });

  group('BalitaDetailResponse extends WargaBase', () {
    test('fromJson maps common fields', () {
      final balita = BalitaDetailResponse.fromJson({
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
      });
      expect(balita, isA<WargaBase>());
      expect(balita.nama, 'Andi Pratama');
      expect(balita.tanggalLahir, '2023-01-15');
      expect(balita.idBalita, 'b-001');
    });
  });

  group('RemajaDetailResponse extends WargaBase', () {
    test('fromJson maps common fields', () {
      final remaja = RemajaDetailResponse.fromJson({
        'id_remaja': 'r-001',
        'nik': '1234567890123456',
        'nama': 'Siti',
        'jenis_kelamin': 'P',
        'tanggal_lahir': '2010-01-15',
        'usia': 16,
        'riwayat_anemia': 'tidak',
        'status_aktif': 'aktif',
        'status_gizi': 'berat_badan_normal',
      });
      expect(remaja, isA<WargaBase>());
      expect(remaja.nama, 'Siti');
      expect(remaja.statusGizi, 'berat_badan_normal');
      expect(remaja.idRemaja, 'r-001');
    });
  });
}
