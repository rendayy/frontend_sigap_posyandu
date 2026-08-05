import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class PemantauanRemajaService extends RemajaBaseService {
  PemantauanRemajaService({super.apiClient});

  Future<PemantauanRemajaListResponse> getList({
    required String idRemaja,
    int page = 1,
    int limit = 10,
  }) {
    return get(
      '/api/remaja/$idRemaja/pemantauan',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: PemantauanRemajaListResponse.fromJson,
      errorMessage: 'Gagal memuat riwayat pemantauan',
      fromData: false,
    );
  }

  Future<PemantauanRemajaDetailResponse> getDetail({
    required String idRemaja,
    required String idPantau,
  }) {
    return get(
      '/api/remaja/$idRemaja/pemantauan/$idPantau',
      fromJson: PemantauanRemajaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail pemantauan',
    );
  }

  Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja/gula-darah-chart',
      fromJson: GulaDarahChartData.fromJson,
      errorMessage: 'Gagal memuat grafik gula darah',
    );
  }
}
