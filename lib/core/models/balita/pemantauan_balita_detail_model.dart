class PemantauanBalitaDetailResponse {
  final String idPantau;
  final String idKader;
  final String idCabang;
  final String namaKader;
  final String namaPosyandu;
  final String tanggalPantau;
  final int usiaBulan;
  final double berat;
  final double tinggi;
  final double? lingkarKepala;
  final double? lingkarLengan;
  final String statusGizi;
  final String? imunisasi;
  final String? vitaminA;
  final String? keluhan;
  final String? saran;
  final String? createdAt;
  final String? updatedAt;

  const PemantauanBalitaDetailResponse({
    required this.idPantau,
    required this.idKader,
    required this.idCabang,
    required this.namaKader,
    required this.namaPosyandu,
    required this.tanggalPantau,
    required this.usiaBulan,
    required this.berat,
    required this.tinggi,
    this.lingkarKepala,
    this.lingkarLengan,
    required this.statusGizi,
    this.imunisasi,
    this.vitaminA,
    this.keluhan,
    this.saran,
    this.createdAt,
    this.updatedAt,
  });

  factory PemantauanBalitaDetailResponse.fromJson(Map<String, dynamic> json) {
    return PemantauanBalitaDetailResponse(
      idPantau: json['id_pantau'] as String,
      idKader: json['id_kader'] as String,
      idCabang: json['id_cabang'] as String,
      namaKader: json['nama_kader'] as String,
      namaPosyandu: json['nama_posyandu'] as String,
      tanggalPantau: json['tanggal_pantau'] as String,
      usiaBulan: json['usia_bulan'] as int,
      berat: (json['berat'] as num).toDouble(),
      tinggi: (json['tinggi'] as num).toDouble(),
      lingkarKepala: json['lingkar_kepala'] != null
          ? (json['lingkar_kepala'] as num).toDouble()
          : null,
      lingkarLengan: json['lingkar_lengan'] != null
          ? (json['lingkar_lengan'] as num).toDouble()
          : null,
      statusGizi: json['status_gizi'] as String,
      imunisasi: json['imunisasi'] as String?,
      vitaminA: json['vitamin_a'] as String?,
      keluhan: json['keluhan'] as String?,
      saran: json['saran'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pantau': idPantau,
      'id_kader': idKader,
      'id_cabang': idCabang,
      'nama_kader': namaKader,
      'nama_posyandu': namaPosyandu,
      'tanggal_pantau': tanggalPantau,
      'usia_bulan': usiaBulan,
      'berat': berat,
      'tinggi': tinggi,
      'lingkar_kepala': lingkarKepala,
      'lingkar_lengan': lingkarLengan,
      'status_gizi': statusGizi,
      'imunisasi': imunisasi,
      'vitamin_a': vitaminA,
      'keluhan': keluhan,
      'saran': saran,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
