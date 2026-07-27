class GulaDarahZone {
  final String status;
  final String label;
  final int min;
  final int max;
  final String color;

  const GulaDarahZone({
    required this.status,
    required this.label,
    required this.min,
    required this.max,
    required this.color,
  });

  factory GulaDarahZone.fromJson(Map<String, dynamic> json) => GulaDarahZone(
        status: json['status'] as String,
        label: json['label'] as String,
        min: json['min'] as int,
        max: json['max'] as int,
        color: json['color'] as String,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'label': label,
        'min': min,
        'max': max,
        'color': color,
      };
}

class GulaDarahMeasurement {
  final int gulaDarah;
  final String tanggalPeriksa;

  const GulaDarahMeasurement({
    required this.gulaDarah,
    required this.tanggalPeriksa,
  });

  factory GulaDarahMeasurement.fromJson(Map<String, dynamic> json) =>
      GulaDarahMeasurement(
        gulaDarah: json['gula_darah'] as int,
        tanggalPeriksa: json['tanggal_periksa'] as String,
      );

  Map<String, dynamic> toJson() => {
        'gula_darah': gulaDarah,
        'tanggal_periksa': tanggalPeriksa,
      };
}

class GulaDarahChartData {
  final List<GulaDarahZone> gulaDarahZones;
  final String label;
  final int latestGulaDarah;
  final String latestStatus;
  final List<GulaDarahMeasurement> measurements;

  const GulaDarahChartData({
    required this.gulaDarahZones,
    required this.label,
    required this.latestGulaDarah,
    required this.latestStatus,
    required this.measurements,
  });

  factory GulaDarahChartData.fromJson(Map<String, dynamic> json) {
    final zones = (json['gula_darah_zones'] as List)
        .map((e) => GulaDarahZone.fromJson(e as Map<String, dynamic>))
        .toList();

    final measurements = (json['measurements'] as List)
        .map((e) => GulaDarahMeasurement.fromJson(e as Map<String, dynamic>))
        .toList();

    return GulaDarahChartData(
      gulaDarahZones: zones,
      label: json['label'] as String,
      latestGulaDarah: json['latest_gula_darah'] as int,
      latestStatus: json['latest_status'] as String,
      measurements: measurements,
    );
  }

  Map<String, dynamic> toJson() => {
        'gula_darah_zones': gulaDarahZones.map((z) => z.toJson()).toList(),
        'label': label,
        'latest_gula_darah': latestGulaDarah,
        'latest_status': latestStatus,
        'measurements': measurements.map((m) => m.toJson()).toList(),
      };
}
