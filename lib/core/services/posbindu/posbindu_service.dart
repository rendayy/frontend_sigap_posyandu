import 'package:frontend_posyandu/core/models/posbindu/posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/posbindu_bmi_status_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_base_service.dart';

class PosbinduService extends PosbinduBaseService {
  PosbinduService({super.apiClient});

  Future<PosbinduDetailResponse> getPosbinduDetail(String idAnggota) {
    return get(
      '/api/posbindu/$idAnggota/detail',
      fromJson: PosbinduDetailResponse.fromJson,
      errorMessage: 'Gagal memuat data posbindu',
    );
  }

  Future<PosbinduBmiStatusResponse> getBmiStatus(String idAnggota) {
    return get(
      '/api/posbindu/$idAnggota/bmi-status',
      fromJson: PosbinduBmiStatusResponse.fromJson,
      errorMessage: 'Gagal memuat status BMI posbindu',
    );
  }

  Future<PemeriksaanPosbinduListResponse> getList({
    required String idAnggota,
    int page = 1,
    int limit = 10,
  }) {
    return get(
      '/api/posbindu/$idAnggota',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: PemeriksaanPosbinduListResponse.fromJson,
      errorMessage: 'Gagal memuat riwayat pemeriksaan',
      fromData: false,
    );
  }

  Future<PemeriksaanPosbinduDetailResponse> getDetail({
    required String idAnggota,
    required String idPeriksaPosbindu,
  }) {
    return get(
      '/api/posbindu/$idAnggota/pemeriksaan/$idPeriksaPosbindu',
      fromJson: PemeriksaanPosbinduDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail pemeriksaan',
    );
  }

  Future<GulaDarahChartData> getGulaDarahChart(String idAnggota) {
    return get(
      '/api/posbindu/$idAnggota/gula-darah-chart',
      fromJson: GulaDarahChartData.fromJson,
      errorMessage: 'Gagal memuat grafik gula darah',
    );
  }
}
