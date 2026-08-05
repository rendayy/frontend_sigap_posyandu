class PemantauanRemajaDetailResponse {
  final String idPantauRemaja;
  final String idKader;
  final String idCabang;
  final String namaKader;
  final String namaPosyandu;
  final String tanggalPeriksa;
  final double beratBadan;
  final double tinggiBadan;
  final int? sistol;
  final int? distol;
  final int? gulaDarah;
  final double? bmi;
  final String statusGizi;
  final String? keluhan;
  final String? saran;
  final String? createdAt;
  final String? updatedAt;

  const PemantauanRemajaDetailResponse({
    required this.idPantauRemaja,
    required this.idKader,
    required this.idCabang,
    required this.namaKader,
    required this.namaPosyandu,
    required this.tanggalPeriksa,
    required this.beratBadan,
    required this.tinggiBadan,
    this.sistol,
    this.distol,
    this.gulaDarah,
    this.bmi,
    required this.statusGizi,
    this.keluhan,
    this.saran,
    this.createdAt,
    this.updatedAt,
  });

  factory PemantauanRemajaDetailResponse.fromJson(Map<String, dynamic> json) {
    return PemantauanRemajaDetailResponse(
      idPantauRemaja: json['id_pantau_remaja'] as String,
      idKader: json['id_kader'] as String,
      idCabang: json['id_cabang'] as String,
      namaKader: json['nama_kader'] as String,
      namaPosyandu: json['nama_posyandu'] as String,
      tanggalPeriksa: json['tanggal_periksa'] as String,
      beratBadan: (json['berat_badan'] as num).toDouble(),
      tinggiBadan: (json['tinggi_badan'] as num).toDouble(),
      sistol: json['sistol'] != null ? json['sistol'] as int : null,
      distol: json['distol'] != null ? json['distol'] as int : null,
      gulaDarah: json['gula_darah'] != null ? json['gula_darah'] as int : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      statusGizi: json['status_gizi'] as String,
      keluhan: json['keluhan'] as String?,
      saran: json['saran'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pantau_remaja': idPantauRemaja,
      'id_kader': idKader,
      'id_cabang': idCabang,
      'nama_kader': namaKader,
      'nama_posyandu': namaPosyandu,
      'tanggal_periksa': tanggalPeriksa,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'sistol': sistol,
      'distol': distol,
      'gula_darah': gulaDarah,
      'bmi': bmi,
      'status_gizi': statusGizi,
      'keluhan': keluhan,
      'saran': saran,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
