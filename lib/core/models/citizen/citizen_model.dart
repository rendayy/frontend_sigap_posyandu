class CabangInfo {
  final String idCabang;
  final String namaPosyandu;

  const CabangInfo({
    required this.idCabang,
    required this.namaPosyandu,
  });

  factory CabangInfo.fromJson(Map<String, dynamic> json) {
    return CabangInfo(
      idCabang: json['id_cabang'] as String,
      namaPosyandu: json['nama_posyandu'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_cabang': idCabang,
    'nama_posyandu': namaPosyandu,
  };
}

class KeluargaInfo {
  final String idKeluarga;
  final String noKk;
  final String alamat;
  final String rt;
  final String rw;
  final String dusun;
  final CabangInfo? cabang;

  const KeluargaInfo({
    required this.idKeluarga,
    required this.noKk,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.dusun,
    this.cabang,
  });

  factory KeluargaInfo.fromJson(Map<String, dynamic> json) {
    return KeluargaInfo(
      idKeluarga: json['id_keluarga'] as String,
      noKk: json['no_kk'] as String,
      alamat: json['alamat'] as String? ?? '',
      rt: json['rt'] as String? ?? '',
      rw: json['rw'] as String? ?? '',
      dusun: json['dusun'] as String? ?? '',
      cabang: json['cabang'] != null
          ? CabangInfo.fromJson(json['cabang'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_keluarga': idKeluarga,
    'no_kk': noKk,
    'alamat': alamat,
    'rt': rt,
    'rw': rw,
    'dusun': dusun,
    'cabang': cabang?.toJson(),
  };
}

class ProfileResponse {
  final String idAnggota;
  final String nik;
  final String nama;
  final String? noHp;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? golonganDarah;
  final String? hubunganKeluarga;
  final String? kategoriAnggota;
  final String? statusAktif;
  final String? statusKesehatan;
  final String? catatanKhusus;
  final List<String> roles;
  final KeluargaInfo? keluarga;
  final String? createdAt;
  final String? updatedAt;

  const ProfileResponse({
    required this.idAnggota,
    required this.nik,
    required this.nama,
    this.noHp,
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.golonganDarah,
    this.hubunganKeluarga,
    this.kategoriAnggota,
    this.statusAktif,
    this.statusKesehatan,
    this.catatanKhusus,
    this.roles = const [],
    this.keluarga,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      idAnggota: json['id_anggota'] as String,
      nik: json['nik'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      noHp: json['no_hp'] as String?,
      tempatLahir: json['tempat_lahir'] as String?,
      tanggalLahir: json['tanggal_lahir'] as String?,
      jenisKelamin: json['jenis_kelamin'] as String?,
      golonganDarah: json['golongan_darah'] as String?,
      hubunganKeluarga: json['hubungan_keluarga'] as String?,
      kategoriAnggota: json['kategori_anggota'] as String?,
      statusAktif: json['status_aktif'] as String?,
      statusKesehatan: json['status_kesehatan'] as String?,
      catatanKhusus: json['catatan_khusus'] as String?,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'] as List)
          : [],
      keluarga: json['keluarga'] != null
          ? KeluargaInfo.fromJson(json['keluarga'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_anggota': idAnggota,
    'nik': nik,
    'nama': nama,
    'no_hp': noHp,
    'tempat_lahir': tempatLahir,
    'tanggal_lahir': tanggalLahir,
    'jenis_kelamin': jenisKelamin,
    'golongan_darah': golonganDarah,
    'hubungan_keluarga': hubunganKeluarga,
    'kategori_anggota': kategoriAnggota,
    'status_aktif': statusAktif,
    'status_kesehatan': statusKesehatan,
    'catatan_khusus': catatanKhusus,
    'roles': roles,
    'keluarga': keluarga?.toJson(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
