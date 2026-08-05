import 'package:frontend_posyandu/core/models/warga_base_model.dart';

class PosbinduDetailResponse extends WargaBase {
  final String idAnggota;
  final String? noHp;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? bmi;
  final int? gulaDarahSewaktu;
  final String? statusBmi;
  final String? statusGulaDarah;
  final String? faktorRisikoMerokok;
  final String? faktorRisikoKurangAktifitas;
  final String? tanggalPeriksaTerakhir;

  const PosbinduDetailResponse({
    required this.idAnggota,
    required super.nik,
    required super.nama,
    required super.jenisKelamin,
    super.tanggalLahir,
    required super.usia,
    required super.statusAktif,
    super.statusGizi,
    this.noHp,
    this.beratBadan,
    this.tinggiBadan,
    this.bmi,
    this.gulaDarahSewaktu,
    this.statusBmi,
    this.statusGulaDarah,
    this.faktorRisikoMerokok,
    this.faktorRisikoKurangAktifitas,
    this.tanggalPeriksaTerakhir,
    super.createdAt,
    super.updatedAt,
  });

  factory PosbinduDetailResponse.fromJson(Map<String, dynamic> json) {
    return PosbinduDetailResponse(
      idAnggota: json['id_anggota'] as String,
      nik: json['nik'] as String,
      nama: json['nama'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      tanggalLahir: json['tanggal_lahir'] as String?,
      usia: json['usia'] as int,
      statusAktif: json['status_aktif'] as String,
      statusGizi: json['status_gizi'] as String?,
      noHp: json['no_hp'] as String?,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      gulaDarahSewaktu: json['gula_darah_sewaktu'] as int?,
      statusBmi: json['status_bmi'] as String?,
      statusGulaDarah: json['status_gula_darah'] as String?,
      faktorRisikoMerokok: json['faktor_risiko_merokok'] as String?,
      faktorRisikoKurangAktifitas:
          json['faktor_risiko_kurang_aktifitas'] as String?,
      tanggalPeriksaTerakhir: json['tanggal_periksa_terakhir'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id_anggota': idAnggota,
      'no_hp': noHp,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'bmi': bmi,
      'gula_darah_sewaktu': gulaDarahSewaktu,
      'status_bmi': statusBmi,
      'status_gula_darah': statusGulaDarah,
      'faktor_risiko_merokok': faktorRisikoMerokok,
      'faktor_risiko_kurang_aktifitas': faktorRisikoKurangAktifitas,
      'tanggal_periksa_terakhir': tanggalPeriksaTerakhir,
    };
  }
}
