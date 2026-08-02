import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_detail_model.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class KegiatanRemajaService extends RemajaBaseService {
  KegiatanRemajaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<KegiatanRemajaListResponse> getList({int page = 1, int limit = 10}) {
    return get(
      '/api/kegiatan-remaja',
      queryParameters: {'page': page, 'limit': limit},
      fromJson: KegiatanRemajaListResponse.fromJson,
      errorMessage: 'Gagal memuat daftar kegiatan',
      fromData: false,
    );
  }

  Future<KegiatanDetailResponse> getDetail(String idKegiatan) {
    return get(
      '/api/kegiatan-remaja/$idKegiatan',
      fromJson: KegiatanDetailResponse.fromJson,
      errorMessage: 'Gagal memuat detail kegiatan',
    );
  }
}
