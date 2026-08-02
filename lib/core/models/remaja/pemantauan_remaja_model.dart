import 'package:frontend_posyandu/core/models/pagination_meta.dart';


class PemantauanRemajaItem {
  final int no;
  final String idPantauRemaja;
  final String idKader;
  final String? namaKader;
  final String? namaPosyandu;
  final String tanggalPeriksa;
  final double? beratBadan;
  final double? tinggiBadan;
  final int? sistol;
  final int? distol;
  final int? gulaDarah;
  final double? bmi;
  final String statusGizi;
  final String? keluhan;
  final String? saran;
  final String? createdAt;
  final String? updatedAt;

  const PemantauanRemajaItem({
    required this.no,
    required this.idPantauRemaja,
    required this.idKader,
    this.namaKader,
    this.namaPosyandu,
    required this.tanggalPeriksa,
    this.beratBadan,
    this.tinggiBadan,
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

  factory PemantauanRemajaItem.fromJson(Map<String, dynamic> json) {
    return PemantauanRemajaItem(
      no: json['no'] as int? ?? 0,
      idPantauRemaja: json['id_pantau_remaja'] as String,
      idKader: json['id_kader'] as String,
      namaKader: json['nama_kader'] as String?,
      namaPosyandu: json['nama_posyandu'] as String?,
      tanggalPeriksa: json['tanggal_periksa'] as String,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      sistol: json['sistol'] != null ? json['sistol'] as int : null,
      distol: json['distol'] != null ? json['distol'] as int : null,
      gulaDarah: json['gula_darah'] != null ? json['gula_darah'] as int : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      statusGizi: json['status_gizi'] as String? ?? 'unknown',
      keluhan: json['keluhan'] as String?,
      saran: json['saran'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'id_pantau_remaja': idPantauRemaja,
      'id_kader': idKader,
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

class PemantauanRemajaListResponse {
  final List<PemantauanRemajaItem> data;
  final PaginationMeta pagination;
  final bool success;

  const PemantauanRemajaListResponse({
    required this.data,
    required this.pagination,
    required this.success,
  });

  factory PemantauanRemajaListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List)
        .map((e) => PemantauanRemajaItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PemantauanRemajaListResponse(
      data: dataList,
      pagination: PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
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
