import 'package:frontend_posyandu/core/models/pagination_meta.dart';


class PemantauanBalitaItem {
  final String idPantau;
  final String idKader;
  final String namaKader;
  final int no;
  final String tanggalPantau;
  final int usiaBulan;
  final double berat;
  final double tinggi;
  final double? lingkarKepala;
  final double? lingkarLengan;
  final String statusGizi;
  final String? imunisasi;
  final String? vitaminA;

  const PemantauanBalitaItem({
    required this.idPantau,
    required this.idKader,
    required this.namaKader,
    required this.no,
    required this.tanggalPantau,
    required this.usiaBulan,
    required this.berat,
    required this.tinggi,
    this.lingkarKepala,
    this.lingkarLengan,
    required this.statusGizi,
    this.imunisasi,
    this.vitaminA,
  });

  factory PemantauanBalitaItem.fromJson(Map<String, dynamic> json) {
    return PemantauanBalitaItem(
      idPantau: json['id_pantau'] as String,
      idKader: json['id_kader'] as String,
      namaKader: json['nama_kader'] as String,
      no: json['no'] as int,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pantau': idPantau,
      'id_kader': idKader,
      'nama_kader': namaKader,
      'no': no,
      'tanggal_pantau': tanggalPantau,
      'usia_bulan': usiaBulan,
      'berat': berat,
      'tinggi': tinggi,
      'lingkar_kepala': lingkarKepala,
      'lingkar_lengan': lingkarLengan,
      'status_gizi': statusGizi,
      'imunisasi': imunisasi,
      'vitamin_a': vitaminA,
    };
  }
}

class PemantauanListResponse {
  final List<PemantauanBalitaItem> data;
  final PaginationMeta pagination;
  final bool success;

  const PemantauanListResponse({
    required this.data,
    required this.pagination,
    required this.success,
  });

  factory PemantauanListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List)
        .map((e) =>
            PemantauanBalitaItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PemantauanListResponse(
      data: dataList,
      pagination:
          PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>),
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