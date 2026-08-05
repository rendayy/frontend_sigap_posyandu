class BmiStatusResponse {
  final double? bmi;
  final String? color;
  final String? label;
  final String? statusGizi;

  const BmiStatusResponse({
    this.bmi,
    this.color,
    this.label,
    this.statusGizi,
  });

  factory BmiStatusResponse.fromJson(Map<String, dynamic> json) {
    return BmiStatusResponse(
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      color: json['color'] as String?,
      label: json['label'] as String?,
      statusGizi: json['status_gizi'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bmi': bmi,
      'color': color,
      'label': label,
      'status_gizi': statusGizi,
    };
  }
}
