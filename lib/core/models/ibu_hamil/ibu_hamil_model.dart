import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';

class IbuHamilDetailResponse {
  final String idIbuHamil;
  final String nama;
  final String? nik;
  final String? hpht;
  final String? hpl;
  final int? gravida;
  final int? para;
  final int? abortus;
  final double? tinggiBadan;
  final String? golonganDarah;
  final String? riwayatPenyakit;
  final int? usiaKehamilanSaatIni;

  const IbuHamilDetailResponse({
    required this.idIbuHamil,
    required this.nama,
    this.nik,
    this.hpht,
    this.hpl,
    this.gravida,
    this.para,
    this.abortus,
    this.tinggiBadan,
    this.golonganDarah,
    this.riwayatPenyakit,
    this.usiaKehamilanSaatIni,
  });

  factory IbuHamilDetailResponse.fromJson(Map<String, dynamic> json) {
    return IbuHamilDetailResponse(
      idIbuHamil: json['id_ibu_hamil'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      nik: json['nik'] as String?,
      hpht: json['hpht'] as String?,
      hpl: json['hpl'] as String?,
      gravida: json['gravida'] as int?,
      para: json['para'] as int?,
      abortus: json['abortus'] as int?,
      tinggiBadan: (json['tinggi_badan'] as num?)?.toDouble(),
      golonganDarah: json['golongan_darah'] as String?,
      riwayatPenyakit: json['riwayat_penyakit'] as String?,
      usiaKehamilanSaatIni: ((json['ringkasan_kehamilan'] as Map?)?['usia_kehamilan'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_ibu_hamil': idIbuHamil,
    'nama': nama,
    'nik': nik,
    'hpht': hpht,
    'hpl': hpl,
    'gravida': gravida,
    'para': para,
    'abortus': abortus,
    'tinggi_badan': tinggiBadan,
    'golongan_darah': golonganDarah,
    'riwayat_penyakit': riwayatPenyakit,
    'usia_kehamilan_saat_ini': usiaKehamilanSaatIni,
  };
}

class PemeriksaanIbuHamilItem {
  final String idPeriksa;
  final String? tanggalPeriksa;
  final int? usiaKehamilan;
  final double? beratBadan;
  final int? sistol;
  final int? distol;
  final double? lingkarLengan;
  final double? tinggiFundus;
  final String? letakJanin;
  final int? denyutJantung;
  final String? keluhan;
  final String? tindakan;
  final String? tabletFe;
  final String? rujukan;
  int? no;

  PemeriksaanIbuHamilItem({
    required this.idPeriksa,
    this.tanggalPeriksa,
    this.usiaKehamilan,
    this.beratBadan,
    this.sistol,
    this.distol,
    this.lingkarLengan,
    this.tinggiFundus,
    this.letakJanin,
    this.denyutJantung,
    this.keluhan,
    this.tindakan,
    this.tabletFe,
    this.rujukan,
    this.no,
  });

  factory PemeriksaanIbuHamilItem.fromJson(Map<String, dynamic> json) {
    return PemeriksaanIbuHamilItem(
      idPeriksa: json['id_periksa'] as String? ?? '',
      tanggalPeriksa: json['tanggal_periksa'] as String?,
      usiaKehamilan: json['usia_kehamilan'] as int?,
      beratBadan: (json['berat_badan'] as num?)?.toDouble(),
      sistol: json['sistol'] as int?,
      distol: json['distol'] as int?,
      lingkarLengan: (json['lingkar_lengan'] as num?)?.toDouble(),
      tinggiFundus: (json['tinggi_fundus'] as num?)?.toDouble(),
      letakJanin: json['letak_janin'] as String?,
      denyutJantung: json['denyut_jantung'] as int?,
      keluhan: json['keluhan'] as String?,
      tindakan: json['tindakan'] as String?,
      tabletFe: json['tablet_fe'] as String?,
      rujukan: json['rujukan'] as String?,
      no: json['no'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_periksa': idPeriksa,
    'tanggal_periksa': tanggalPeriksa,
    'usia_kehamilan': usiaKehamilan,
    'berat_badan': beratBadan,
    'sistol': sistol,
    'distol': distol,
    'lingkar_lengan': lingkarLengan,
    'tinggi_fundus': tinggiFundus,
    'letak_janin': letakJanin,
    'denyut_jantung': denyutJantung,
    'keluhan': keluhan,
    'tindakan': tindakan,
    'tablet_fe': tabletFe,
    'rujukan': rujukan,
    'no': no,
  };
}

class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'total': total,
    'total_pages': totalPages,
  };

  bool get hasMore => page < totalPages;
}

class PemeriksaanListResponse {
  final List<PemeriksaanIbuHamilItem> data;
  final PaginationMeta? pagination;

  const PemeriksaanListResponse({required this.data, this.pagination});

  factory PemeriksaanListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final list = <PemeriksaanIbuHamilItem>[];
    if (rawData is List) {
      for (final item in rawData) {
        list.add(PemeriksaanIbuHamilItem.fromJson(item as Map<String, dynamic>));
      }
    }

    PaginationMeta? pagination;
    if (json['pagination'] is Map) {
      pagination = PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>);
    }

    return PemeriksaanListResponse(data: list, pagination: pagination);
  }

  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (pagination != null) 'pagination': pagination!.toJson(),
  };
}

class ChartMeasurement {
  final int minggu;
  final double nilai;

  ChartMeasurement({required this.minggu, required this.nilai});

  factory ChartMeasurement.fromJson(Map<String, dynamic> json, {String nilaiKey = 'nilai'}) {
    return ChartMeasurement(
      minggu: json['minggu'] as int? ?? 0,
      nilai: (json[nilaiKey] as num?)?.toDouble() ?? 0,
    );
  }
}

class ChartReferencePoint {
  final int minggu;
  final double nilai;

  ChartReferencePoint({required this.minggu, required this.nilai});

  factory ChartReferencePoint.fromJson(Map<String, dynamic> json) {
    return ChartReferencePoint(
      minggu: json['minggu'] as int? ?? 0,
      nilai: (json['nilai'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ChartRingkasan {
  final double awal;
  final double terakhir;
  final double kenaikan;

  const ChartRingkasan({
    required this.awal,
    required this.terakhir,
    required this.kenaikan,
  });
}

class BeratBadanChartResponse {
  final String label;
  final List<ChartMeasurement> measurements;
  final List<ChartReferencePoint> batasAtas;
  final List<ChartReferencePoint> batasBawah;
  final double? latestBerat;
  final int? latestUsiaKehamilan;

  BeratBadanChartResponse({
    this.label = 'Berat Badan',
    required this.measurements,
    this.batasAtas = const [],
    this.batasBawah = const [],
    this.latestBerat,
    this.latestUsiaKehamilan,
  });

  factory BeratBadanChartResponse.fromJson(Map<String, dynamic> json) {
    final data = _unwrapData(json);
    final measurementsRaw = data['measurements'] as List? ?? [];
    final batasAtasRaw = data['batas_atas'] as List? ?? [];
    final batasBawahRaw = data['batas_bawah'] as List? ?? [];

    return BeratBadanChartResponse(
      label: data['label'] as String? ?? 'Berat Badan',
      measurements: measurementsRaw
          .map((e) => ChartMeasurement.fromJson(e as Map<String, dynamic>, nilaiKey: 'berat'))
          .toList(),
      batasAtas: batasAtasRaw
          .map((e) => ChartReferencePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      batasBawah: batasBawahRaw
          .map((e) => ChartReferencePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestBerat: (data['latest_berat'] as num?)?.toDouble(),
      latestUsiaKehamilan: data['latest_usia_kehamilan'] as int?,
    );
  }

  ChartRingkasan get ringkasan {
    if (measurements.isEmpty) return const ChartRingkasan(awal: 0, terakhir: 0, kenaikan: 0);
    final sorted = List<ChartMeasurement>.from(measurements)
      ..sort((a, b) => a.minggu.compareTo(b.minggu));
    return ChartRingkasan(
      awal: sorted.first.nilai,
      terakhir: sorted.last.nilai,
      kenaikan: sorted.last.nilai - sorted.first.nilai,
    );
  }
}

class TinggiFundusChartResponse {
  final String label;
  final List<ChartMeasurement> measurements;
  final List<ChartReferencePoint> standar;
  final double? latestTinggi;
  final int? latestUsiaKehamilan;

  TinggiFundusChartResponse({
    this.label = 'Tinggi Fundus',
    required this.measurements,
    this.standar = const [],
    this.latestTinggi,
    this.latestUsiaKehamilan,
  });

  factory TinggiFundusChartResponse.fromJson(Map<String, dynamic> json) {
    final data = _unwrapData(json);
    final measurementsRaw = data['measurements'] as List? ?? [];
    final standarRaw = data['standar'] as List? ?? [];

    return TinggiFundusChartResponse(
      label: data['label'] as String? ?? 'Tinggi Fundus',
      measurements: measurementsRaw
          .map((e) => ChartMeasurement.fromJson(e as Map<String, dynamic>, nilaiKey: 'tinggi'))
          .toList(),
      standar: standarRaw
          .map((e) => ChartReferencePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      latestTinggi: (data['latest_tinggi'] as num?)?.toDouble(),
      latestUsiaKehamilan: data['latest_usia_kehamilan'] as int?,
    );
  }

  ChartRingkasan get ringkasan {
    if (measurements.isEmpty) return const ChartRingkasan(awal: 0, terakhir: 0, kenaikan: 0);
    final sorted = List<ChartMeasurement>.from(measurements)
      ..sort((a, b) => a.minggu.compareTo(b.minggu));
    return ChartRingkasan(
      awal: sorted.first.nilai,
      terakhir: sorted.last.nilai,
      kenaikan: sorted.last.nilai - sorted.first.nilai,
    );
  }
}

class RiwayatPemeriksaanData {
  final List<PemeriksaanIbuHamilItem> items;
  final PaginationMeta? pagination;
  final int trimester;

  const RiwayatPemeriksaanData({
    required this.items,
    this.pagination,
    this.trimester = 1,
  });

  factory RiwayatPemeriksaanData.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List? ?? [];
    return RiwayatPemeriksaanData(
      items: itemsRaw
          .map((e) => PemeriksaanIbuHamilItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
      trimester: json['trimester'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    if (pagination != null) 'pagination': pagination!.toJson(),
    'trimester': trimester,
  };
}

class KunjunganAncInfo {
  final int selesai;
  final int target;

  const KunjunganAncInfo({required this.selesai, this.target = 9});
}

class IbuHamilVitalInfo {
  final double? beratBadanKg;
  final double? beratBadanDeltaKg;
  final String beratBadanStatus;
  final String? tekananDarah;
  final String? tekananDarahTanggal;
  final String tekananDarahStatus;
  final double? lilaCm;
  final double? tinggiFundusCm;
  final KunjunganAncInfo kunjunganAnc;

  const IbuHamilVitalInfo({
    this.beratBadanKg,
    this.beratBadanDeltaKg,
    this.beratBadanStatus = 'Normal',
    this.tekananDarah,
    this.tekananDarahTanggal,
    this.tekananDarahStatus = 'Normal',
    this.lilaCm,
    this.tinggiFundusCm,
    required this.kunjunganAnc,
  });
}

class IbuHamilKehamilanInfo {
  final int usiaMinggu;
  final int trimester;
  final String hpl;
  final int totalMinggu;
  final int progressPersen;
  final int hariMenujuHpl;

  const IbuHamilKehamilanInfo({
    required this.usiaMinggu,
    required this.trimester,
    required this.hpl,
    required this.totalMinggu,
    required this.progressPersen,
    required this.hariMenujuHpl,
  });
}

class IbuHamilJadwalInfo {
  final String? kunjunganKe;
  final String? tanggal;
  final String? lokasi;
  final String status;

  const IbuHamilJadwalInfo({
    this.kunjunganKe,
    this.tanggal,
    this.lokasi,
    this.status = 'Akan Datang',
  });
}

class IbuHamilEdukasiInfo {
  final int trimester;
  final String konten;

  const IbuHamilEdukasiInfo({
    required this.trimester,
    required this.konten,
  });
}

class IbuHamilBerandaData {
  final String nama;
  final String inisial;
  final String statusLabel;
  final ProfileResponse? profile;
  final IbuHamilKehamilanInfo kehamilan;
  final IbuHamilVitalInfo vital;
  final IbuHamilJadwalInfo jadwal;
  final IbuHamilEdukasiInfo edukasi;

  const IbuHamilBerandaData({
    required this.nama,
    required this.inisial,
    required this.statusLabel,
    this.profile,
    required this.kehamilan,
    required this.vital,
    required this.jadwal,
    required this.edukasi,
  });
}

Map<String, dynamic> _unwrapData(Map<String, dynamic> json) {
  final raw = json['data'];
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return json;
}