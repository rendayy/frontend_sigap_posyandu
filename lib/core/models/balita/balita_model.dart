import 'package:frontend_posyandu/core/models/warga_base_model.dart';

class BalitaDetailResponse extends WargaBase {
  final String idBalita;
  final String idAnggota;
  final double beratLahir;
  final double panjangLahir;
  final String asiEksklusif;
  final String imunisasiDasar;
  final String? namaAyah;
  final String? namaIbu;
  final String? noHpWa;

  const BalitaDetailResponse({
    required this.idBalita,
    required this.idAnggota,
    required super.nik,
    required super.nama,
    required super.jenisKelamin,
    required super.tanggalLahir,
    required super.usia,
    required this.beratLahir,
    required this.panjangLahir,
    required this.asiEksklusif,
    required this.imunisasiDasar,
    super.statusGizi,
    required super.statusAktif,
    this.namaAyah,
    this.namaIbu,
    this.noHpWa,
    super.createdAt,
    super.updatedAt,
  });

  factory BalitaDetailResponse.fromJson(Map<String, dynamic> json) {
    return BalitaDetailResponse(
      idBalita: json['id_balita'] as String,
      idAnggota: json['id_anggota'] as String,
      nik: json['nik'] as String,
      nama: json['nama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      tanggalLahir: json['tanggal_lahir'] as String,
      usia: json['usia'] as int,
      beratLahir: (json['berat_lahir'] as num).toDouble(),
      panjangLahir: (json['panjang_lahir'] as num).toDouble(),
      asiEksklusif: json['asi_eksklusif'] as String,
      imunisasiDasar: json['imunisasi_dasar'] as String,
      statusGizi: json['status_gizi'] as String?,
      statusAktif: json['status_aktif'] as String,
      namaAyah: json['nama_ayah'] as String?,
      namaIbu: json['nama_ibu'] as String?,
      noHpWa: json['no_hp_wa'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id_balita': idBalita,
      'id_anggota': idAnggota,
      'berat_lahir': beratLahir,
      'panjang_lahir': panjangLahir,
      'asi_eksklusif': asiEksklusif,
      'imunisasi_dasar': imunisasiDasar,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'no_hp_wa': noHpWa,
    };
  }
}
