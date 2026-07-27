class RemajaDetailResponse {
  final String idRemaja;
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String? tanggalLahir;
  final int usia;
  final String? sekolah;
  final String? kelas;
  final String? prestasi;
  final String? hobi;
  final String riwayatAnemia;
  final String statusAktif;
  final String? statusGizi;
  final double? beratBadan;
  final double? tinggiBadan;
  final String? tanggalPantauTerakhir;
  final String? noHp;
  final String? createdAt;
  final String? updatedAt;

  const RemajaDetailResponse({
    required this.idRemaja,
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    this.tanggalLahir,
    required this.usia,
    this.sekolah,
    this.kelas,
    this.prestasi,
    this.hobi,
    required this.riwayatAnemia,
    required this.statusAktif,
    this.statusGizi,
    this.beratBadan,
    this.tinggiBadan,
    this.tanggalPantauTerakhir,
    this.noHp,
    this.createdAt,
    this.updatedAt,
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
      riwayatAnemia: json['riwayat_anemia'] as String,
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

  Map<String, dynamic> toJson() {
    return {
      'id_remaja': idRemaja,
      'nik': nik,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'usia': usia,
      'sekolah': sekolah,
      'kelas': kelas,
      'prestasi': prestasi,
      'hobi': hobi,
      'riwayat_anemia': riwayatAnemia,
      'status_aktif': statusAktif,
      'status_gizi': statusGizi,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'tanggal_pantau_terakhir': tanggalPantauTerakhir,
      'no_hp': noHp,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
