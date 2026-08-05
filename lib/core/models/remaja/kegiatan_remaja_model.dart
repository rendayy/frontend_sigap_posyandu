import 'package:frontend_posyandu/core/models/pagination_meta.dart';

class KegiatanRemajaItem {
  final String idKegiatan;
  final String jenisKegiatan;
  final String namaKegiatan;
  final int no;
  final String status;
  final String tanggal;
  final String tempat;
  final String waktu;

  const KegiatanRemajaItem({
    required this.idKegiatan,
    required this.jenisKegiatan,
    required this.namaKegiatan,
    required this.no,
    required this.status,
    required this.tanggal,
    required this.tempat,
    required this.waktu,
  });

  factory KegiatanRemajaItem.fromJson(Map<String, dynamic> json) {
    return KegiatanRemajaItem(
      idKegiatan: json['id_kegiatan'] as String,
      jenisKegiatan: json['jenis_kegiatan'] as String,
      namaKegiatan: json['nama_kegiatan'] as String,
      no: json['no'] as int? ?? 0,
      status: json['status'] as String,
      tanggal: json['tanggal'] as String,
      tempat: json['tempat'] as String,
      waktu: json['waktu'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_kegiatan': idKegiatan,
      'jenis_kegiatan': jenisKegiatan,
      'nama_kegiatan': namaKegiatan,
      'no': no,
      'status': status,
      'tanggal': tanggal,
      'tempat': tempat,
      'waktu': waktu,
    };
  }
}

class KegiatanRemajaListResponse {
  final List<KegiatanRemajaItem> data;
  final PaginationMeta pagination;
  final bool success;

  const KegiatanRemajaListResponse({
    required this.data,
    required this.pagination,
    required this.success,
  });

  factory KegiatanRemajaListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List)
        .map((e) => KegiatanRemajaItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return KegiatanRemajaListResponse(
      data: dataList,
      pagination: PaginationMeta.fromJson(
          json['pagination'] as Map<String, dynamic>),
      success: json['success'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'success': success,
    };
  }
}
