import 'package:frontend_posyandu/core/models/warga_base_model.dart';

class RemajaDetailResponse extends WargaBase {
  final String idRemaja;
  final String? sekolah;
  final String? kelas;
  final String? prestasi;
  final String? hobi;
  final String? riwayatAnemia;
  final double? beratBadan;
  final double? tinggiBadan;
  final String? tanggalPantauTerakhir;
  final String? noHp;

  const RemajaDetailResponse({
    required this.idRemaja,
    required super.nik,
    required super.nama,
    required super.jenisKelamin,
    super.tanggalLahir,
    required super.usia,
    this.sekolah,
    this.kelas,
    this.prestasi,
    this.hobi,
    this.riwayatAnemia,
    required super.statusAktif,
    super.statusGizi,
    this.beratBadan,
    this.tinggiBadan,
    this.tanggalPantauTerakhir,
    this.noHp,
    super.createdAt,
    super.updatedAt,
  });

  factory RemajaDetailResponse.fromJson(Map<String, dynamic> json) {
    return RemajaDetailResponse(
      idRemaja: json['id_remaja'] as String,
      nik: json['nik'] as String,
      nama: json['nama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      tanggalLahir: json['tanggal_lahir'] as String?,
      usia: json['usia'] as int,
      sekolah: json['sekolah'] as String?,
      kelas: json['kelas'] as String?,
      prestasi: json['prestasi'] as String?,
      hobi: json['hobi'] as String?,
      riwayatAnemia: json['riwayat_anemia'] as String?,
      statusAktif: json['status_aktif'] as String,
      statusGizi: json['status_gizi'] as String?,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      tanggalPantauTerakhir: json['tanggal_pantau_terakhir'] as String?,
      noHp: json['no_hp'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id_remaja': idRemaja,
      'sekolah': sekolah,
      'kelas': kelas,
      'prestasi': prestasi,
      'hobi': hobi,
      'riwayat_anemia': riwayatAnemia,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'tanggal_pantau_terakhir': tanggalPantauTerakhir,
      'no_hp': noHp,
    };
  }
}
