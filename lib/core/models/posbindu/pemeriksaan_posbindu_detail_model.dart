class PemeriksaanPosbinduDetailResponse {
  final String idPeriksaPosbindu;
  final String idAnggota;
  final String idKader;
  final String idCabang;
  final String tanggalPeriksa;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? bmi;
  final double? lingkarPerut;
  final int? sistol;
  final int? distol;
  final int? gulaDarahSewaktu;
  final int? kolesterolTotal;
  final double? asamUrat;
  final String? statusBmi;
  final String? statusGulaDarah;
  final String? statusRujukan;
  final String? faktorRisikoMerokok;
  final String? faktorRisikoKurangAktifitas;
  final String? keluhan;
  final String? saran;
  final String? catatan;
  final String? riwayatPenyakitKeluarga;
  final String? createdAt;
  final String? updatedAt;

  const PemeriksaanPosbinduDetailResponse({
    required this.idPeriksaPosbindu,
    required this.idAnggota,
    required this.idKader,
    required this.idCabang,
    required this.tanggalPeriksa,
    this.beratBadan,
    this.tinggiBadan,
    this.bmi,
    this.lingkarPerut,
    this.sistol,
    this.distol,
    this.gulaDarahSewaktu,
    this.kolesterolTotal,
    this.asamUrat,
    this.statusBmi,
    this.statusGulaDarah,
    this.statusRujukan,
    this.faktorRisikoMerokok,
    this.faktorRisikoKurangAktifitas,
    this.keluhan,
    this.saran,
    this.catatan,
    this.riwayatPenyakitKeluarga,
    this.createdAt,
    this.updatedAt,
  });

  factory PemeriksaanPosbinduDetailResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return PemeriksaanPosbinduDetailResponse(
      idPeriksaPosbindu: json['id_periksa_posbindu'] as String,
      idAnggota: json['id_anggota'] as String,
      idKader: json['id_kader'] as String,
      idCabang: json['id_cabang'] as String,
      tanggalPeriksa: json['tanggal_periksa'] as String,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      lingkarPerut: json['lingkar_perut'] != null
          ? (json['lingkar_perut'] as num).toDouble()
          : null,
      sistol: json['sistol'] != null ? json['sistol'] as int : null,
      distol: json['distol'] != null ? json['distol'] as int : null,
      gulaDarahSewaktu: json['gula_darah_sewaktu'] != null
          ? json['gula_darah_sewaktu'] as int
          : null,
      kolesterolTotal: json['kolesterol_total'] != null
          ? json['kolesterol_total'] as int
          : null,
      asamUrat: json['asam_urat'] != null
          ? (json['asam_urat'] as num).toDouble()
          : null,
      statusBmi: json['status_bmi'] as String?,
      statusGulaDarah: json['status_gula_darah'] as String?,
      statusRujukan: json['status_rujukan'] as String?,
      faktorRisikoMerokok: json['faktor_risiko_merokok'] as String?,
      faktorRisikoKurangAktifitas:
          json['faktor_risiko_kurang_aktifitas'] as String?,
      keluhan: json['keluhan'] as String?,
      saran: json['saran'] as String?,
      catatan: json['catatan'] as String?,
      riwayatPenyakitKeluarga: json['riwayat_penyakit_keluarga'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_periksa_posbindu': idPeriksaPosbindu,
      'id_anggota': idAnggota,
      'id_kader': idKader,
      'id_cabang': idCabang,
      'tanggal_periksa': tanggalPeriksa,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'bmi': bmi,
      'lingkar_perut': lingkarPerut,
      'sistol': sistol,
      'distol': distol,
      'gula_darah_sewaktu': gulaDarahSewaktu,
      'kolesterol_total': kolesterolTotal,
      'asam_urat': asamUrat,
      'status_bmi': statusBmi,
      'status_gula_darah': statusGulaDarah,
      'status_rujukan': statusRujukan,
      'faktor_risiko_merokok': faktorRisikoMerokok,
      'faktor_risiko_kurang_aktifitas': faktorRisikoKurangAktifitas,
      'keluhan': keluhan,
      'saran': saran,
      'catatan': catatan,
      'riwayat_penyakit_keluarga': riwayatPenyakitKeluarga,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
