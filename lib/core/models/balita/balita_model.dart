class BalitaDetailResponse {
  final String idBalita;
  final String idAnggota;
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String tanggalLahir;
  final int usia;
  final double beratLahir;
  final double panjangLahir;
  final String asiEksklusif;
  final String imunisasiDasar;
  final String? statusGizi;
  final String statusAktif;
  final String? namaAyah;
  final String? namaIbu;
  final String? noHpWa;
  final String? createdAt;
  final String? updatedAt;

  const BalitaDetailResponse({
    required this.idBalita,
    required this.idAnggota,
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.usia,
    required this.beratLahir,
    required this.panjangLahir,
    required this.asiEksklusif,
    required this.imunisasiDasar,
    this.statusGizi,
    required this.statusAktif,
    this.namaAyah,
    this.namaIbu,
    this.noHpWa,
    this.createdAt,
    this.updatedAt,
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

  Map<String, dynamic> toJson() {
    return {
      'id_balita': idBalita,
      'id_anggota': idAnggota,
      'nik': nik,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'usia': usia,
      'berat_lahir': beratLahir,
      'panjang_lahir': panjangLahir,
      'asi_eksklusif': asiEksklusif,
      'imunisasi_dasar': imunisasiDasar,
      'status_gizi': statusGizi,
      'status_aktif': statusAktif,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
      'no_hp_wa': noHpWa,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
