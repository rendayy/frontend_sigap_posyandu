class GrowthMeasurement {
  final double berat;
  final String statusGizi;
  final String tanggalPantau;
  final int usiaBulan;

  const GrowthMeasurement({
    required this.berat,
    required this.statusGizi,
    required this.tanggalPantau,
    required this.usiaBulan,
  });

  factory GrowthMeasurement.fromJson(Map<String, dynamic> json) {
    return GrowthMeasurement(
      berat: (json['berat'] as num).toDouble(),
      statusGizi: json['status_gizi'] as String,
      tanggalPantau: json['tanggal_pantau'] as String,
      usiaBulan: json['usia_bulan'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'berat': berat,
    'status_gizi': statusGizi,
    'tanggal_pantau': tanggalPantau,
    'usia_bulan': usiaBulan,
  };
}

class StandardCurvePoint {
  final double nilai;
  final int usia;

  const StandardCurvePoint({required this.nilai, required this.usia});

  factory StandardCurvePoint.fromJson(Map<String, dynamic> json) {
    return StandardCurvePoint(
      nilai: (json['nilai'] as num).toDouble(),
      usia: json['usia'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'nilai': nilai,
    'usia': usia,
  };
}

class GrowthChartResponse {
  final String chartType;
  final String idAnggota;
  final String jenisKelamin;
  final String? latestStatus;
  final List<GrowthMeasurement> measurements;
  final Map<String, List<StandardCurvePoint>> standardCurves;
  final Map<String, String> zoneLabels;
  final String standardSource;

  const GrowthChartResponse({
    required this.chartType,
    required this.idAnggota,
    required this.jenisKelamin,
    this.latestStatus,
    required this.measurements,
    required this.standardCurves,
    required this.zoneLabels,
    required this.standardSource,
  });

  factory GrowthChartResponse.fromJson(Map<String, dynamic> json) {
    final measurements = (json['measurements'] as List)
        .map((e) => GrowthMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawCurves = json['standard_curves'] as Map<String, dynamic>;
    final standardCurves = <String, List<StandardCurvePoint>>{};
    for (final entry in rawCurves.entries) {
      standardCurves[entry.key] = (entry.value as List)
          .map((e) => StandardCurvePoint.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final zoneLabels = (json['zone_labels'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));

    return GrowthChartResponse(
      chartType: json['chart_type'] as String,
      idAnggota: json['id_anggota'] as String,
      jenisKelamin: json['jenis_kelamin'] as String,
      latestStatus: json['latest_status'] as String?,
      measurements: measurements,
      standardCurves: standardCurves,
      zoneLabels: zoneLabels,
      standardSource: json['standard_source'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'chart_type': chartType,
    'id_anggota': idAnggota,
    'jenis_kelamin': jenisKelamin,
    'latest_status': latestStatus,
    'measurements': measurements.map((m) => m.toJson()).toList(),
    'standard_curves': standardCurves.map((k, v) => MapEntry(k, v.map((p) => p.toJson()).toList())),
    'zone_labels': zoneLabels,
    'standard_source': standardSource,
  };
}
