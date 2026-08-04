class PosbinduBmiStatusResponse {
  final double? beratBadan;
  final double? bmi;
  final String? color;
  final String? idAnggota;
  final String? label;
  final String? statusBmi;
  final String? tanggalPeriksaTerakhir;
  final double? tinggiBadan;

  const PosbinduBmiStatusResponse({
    this.beratBadan,
    this.bmi,
    this.color,
    this.idAnggota,
    this.label,
    this.statusBmi,
    this.tanggalPeriksaTerakhir,
    this.tinggiBadan,
  });

  factory PosbinduBmiStatusResponse.fromJson(Map<String, dynamic> json) {
    return PosbinduBmiStatusResponse(
      beratBadan: json['berat_badan'] != null
          ? (json['berat_badan'] as num).toDouble()
          : null,
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      color: json['color'] as String?,
      idAnggota: json['id_anggota'] as String?,
      label: json['label'] as String?,
      statusBmi: json['status_bmi'] as String?,
      tanggalPeriksaTerakhir: json['tanggal_periksa_terakhir'] as String?,
      tinggiBadan: json['tinggi_badan'] != null
          ? (json['tinggi_badan'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'berat_badan': beratBadan,
      'bmi': bmi,
      'color': color,
      'id_anggota': idAnggota,
      'label': label,
      'status_bmi': statusBmi,
      'tanggal_periksa_terakhir': tanggalPeriksaTerakhir,
      'tinggi_badan': tinggiBadan,
    };
  }
}
