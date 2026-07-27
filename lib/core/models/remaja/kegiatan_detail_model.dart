class KegiatanDetailResponse {
  final String idKegiatan;
  final String judulKegiatan;
  final String jenisKegiatan;
  final String tanggal;
  final String waktu;
  final String tempat;
  final String status;
  final int pesertaTarget;
  final int totalKehadiran;
  final double persentaseKehadiran;
  final String? materi;
  final String? narasumber;
  final String? createdAt;
  final String? updatedAt;

  const KegiatanDetailResponse({
    required this.idKegiatan,
    required this.judulKegiatan,
    required this.jenisKegiatan,
    required this.tanggal,
    required this.waktu,
    required this.tempat,
    required this.status,
    required this.pesertaTarget,
    required this.totalKehadiran,
    required this.persentaseKehadiran,
    this.materi,
    this.narasumber,
    this.createdAt,
    this.updatedAt,
  });

  factory KegiatanDetailResponse.fromJson(Map<String, dynamic> json) {
    return KegiatanDetailResponse(
      idKegiatan: json['id_kegiatan'] as String,
      judulKegiatan: json['judul_kegiatan'] as String,
      jenisKegiatan: json['jenis_kegiatan'] as String,
      tanggal: json['tanggal'] as String,
      waktu: json['waktu'] as String,
      tempat: json['tempat'] as String,
      status: json['status'] as String,
      pesertaTarget: json['peserta_target'] as int,
      totalKehadiran: json['total_kehadiran'] as int,
      persentaseKehadiran: (json['persentase_kehadiran'] as num).toDouble(),
      materi: json['materi'] as String?,
      narasumber: json['narasumber'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kegiatan': idKegiatan,
      'judul_kegiatan': judulKegiatan,
      'jenis_kegiatan': jenisKegiatan,
      'tanggal': tanggal,
      'waktu': waktu,
      'tempat': tempat,
      'status': status,
      'peserta_target': pesertaTarget,
      'total_kehadiran': totalKehadiran,
      'persentase_kehadiran': persentaseKehadiran,
      'materi': materi,
      'narasumber': narasumber,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
