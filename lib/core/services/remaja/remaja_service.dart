import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/bmi_status_model.dart';
import 'package:frontend_posyandu/core/models/remaja/remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_base_service.dart';

class RemajaService extends RemajaBaseService {
  RemajaService({ApiClient? apiClient}) : super(apiClient: apiClient);

  Future<RemajaDetailResponse> getRemajaById(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja',
      fromJson: RemajaDetailResponse.fromJson,
      errorMessage: 'Gagal memuat data remaja',
    );
  }

  Future<BmiStatusResponse> getBmiStatus(String idRemaja) {
    return get(
      '/api/remaja/$idRemaja/bmi-status',
      fromJson: BmiStatusResponse.fromJson,
      errorMessage: 'Gagal memuat status BMI',
    );
  }
}
