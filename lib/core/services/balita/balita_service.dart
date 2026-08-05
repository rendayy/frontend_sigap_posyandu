import 'dart:io';
import 'package:frontend_posyandu/config.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_base_service.dart';

class BalitaService extends BalitaBaseService {
  BalitaService({super.apiClient});

  Future<BalitaDetailResponse> getBalitaById(String idBalita) {
    return get(
      '/api/balita/$idBalita',
      fromJson: BalitaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat data balita',
    );
  }

  Future<GrowthChartResponse> getGrowthChart(String idBalita) {
    return get(
      '/api/balita/$idBalita/growth-chart',
      fromJson: GrowthChartResponse.fromJson,
      errorMessage: 'Gagal memuat grafik pertumbuhan',
    );
  }

  String getDownloadKmsUrl(String idBalita) {
    return '${AppConfig.apiBaseUrl}/api/balita/$idBalita/download-kms';
  }

  Future<File> downloadKms(String idBalita) async {
    final url = '/api/balita/$idBalita/download-kms';
    final dir = await Directory.systemTemp.createTemp('kms_');
    final file = File('${dir.path}/kms_$idBalita.pdf');
    await apiClient.dio.download(url, file.path);
    return file;
  }
}
