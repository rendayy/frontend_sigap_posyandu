class WargaBase {
  final String nik;
  final String nama;
  final String jenisKelamin;
  final String? tanggalLahir;
  final int usia;
  final String statusAktif;
  final String? statusGizi;
  final String? createdAt;
  final String? updatedAt;

  const WargaBase({
    required this.nik,
    required this.nama,
    required this.jenisKelamin,
    this.tanggalLahir,
    required this.usia,
    required this.statusAktif,
    this.statusGizi,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'nik': nik,
      'nama': nama,
      'jenis_kelamin': jenisKelamin,
      'tanggal_lahir': tanggalLahir,
      'usia': usia,
      'status_aktif': statusAktif,
      'status_gizi': statusGizi,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
