import 'package:frontend_posyandu/core/models/pagination_meta.dart';

class PemeriksaanPosbinduItem {
  final int no;
  final String idPeriksaPosbindu;
  final String idKader;
  final String tanggalPeriksa;
  final double? beratBadan;
  final double? tinggiBadan;
  final double? bmi;
  final int? sistol;
  final int? distol;
  final int? gulaDarahSewaktu;
  final String? statusBmi;

  const PemeriksaanPosbinduItem({
    required this.no,
    required this.idPeriksaPosbindu,
    required this.idKader,
    required this.tanggalPeriksa,
    this.beratBadan,
    this.tinggiBadan,
    this.bmi,
    this.sistol,
    this.distol,
    this.gulaDarahSewaktu,
    this.statusBmi,
  });

  factory PemeriksaanPosbinduItem.fromJson(Map<String, dynamic> json) {
    return PemeriksaanPosbinduItem(
      no: json['no'] as int? ?? 0,
      idPeriksaPosbindu: json['id_periksa_posbindu'] as String,
      idKader: json['id_kader'] as String,
      tanggalPeriksa: json['tanggal_periksa'] as String,
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      sistol: json['sistol'] != null ? json['sistol'] as int : null,
      distol: json['distol'] != null ? json['distol'] as int : null,
      gulaDarahSewaktu: json['gula_darah_sewaktu'] != null
          ? json['gula_darah_sewaktu'] as int
          : null,
      statusBmi: json['status_bmi'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'id_periksa_posbindu': idPeriksaPosbindu,
      'id_kader': idKader,
      'tanggal_periksa': tanggalPeriksa,
      'berat_badan': beratBadan,
      'tinggi_badan': tinggiBadan,
      'bmi': bmi,
      'sistol': sistol,
      'distol': distol,
      'gula_darah_sewaktu': gulaDarahSewaktu,
      'status_bmi': statusBmi,
    };
  }
}

class PemeriksaanPosbinduListResponse {
  final List<PemeriksaanPosbinduItem> data;
  final PaginationMeta pagination;
  final bool success;

  const PemeriksaanPosbinduListResponse({
    required this.data,
    required this.pagination,
    required this.success,
  });

  factory PemeriksaanPosbinduListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List)
        .map((e) => PemeriksaanPosbinduItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return PemeriksaanPosbinduListResponse(
      data: dataList,
      pagination: PaginationMeta.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
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
