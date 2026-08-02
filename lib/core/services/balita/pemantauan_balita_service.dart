import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_base_service.dart';

class PemantauanBalitaService extends BalitaBaseService {
  PemantauanBalitaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<PemantauanListResponse> getList({
    required String idBalita,
    int page = 1,
    int limit = 5,
  }) {
    return get(
      '/api/balita/$idBalita/pemantauan',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: PemantauanListResponse.fromJson,
      errorMessage: 'Gagal memuat riwayat pemeriksaan',
      fromData: false,
    );
  }

  Future<PemantauanBalitaDetailResponse> getDetail({
    required String idBalita,
    required String idPantau,
  }) {
    return get(
      '/api/balita/$idBalita/pemantauan/$idPantau',
      fromJson: PemantauanBalitaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail pemeriksaan',
    );
  }
}
