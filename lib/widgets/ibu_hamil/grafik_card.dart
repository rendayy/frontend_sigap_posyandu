import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_berat_badan.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_tinggi_fundus.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/info_box_edukasi_grafik.dart';

class GrafikCard extends StatelessWidget {
  final int selectedIndicator;
  final int trimester;
  final BeratBadanChartResponse? bbData;
  final TinggiFundusChartResponse? tfuData;

  const GrafikCard({
    super.key,
    required this.selectedIndicator,
    this.trimester = 1,
    this.bbData,
    this.tfuData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 2),
          _buildInfoText(),
          const SizedBox(height: 16),
          _buildChart(),
          _buildInfoBox(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title = _indicatorLabel;
    final satuan = _indicatorSatuan;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$title ($satuan)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          'per kunjungan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoText() {
    final info = _infoIdealText;
    if (info == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text(
        info,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildChart() {
    switch (selectedIndicator) {
      case 1:
        if (tfuData != null) return GrafikTinggiFundus(data: tfuData!);
        return _buildLoading();
      default:
        if (bbData != null) return GrafikBeratBadan(data: bbData!);
        return _buildLoading();
    }
  }

  Widget _buildLoading() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildInfoBox() {
    String konten;
    switch (selectedIndicator) {
      case 1:
        konten = 'TFU normal biasanya mengikuti usia kehamilan (dalam cm) ± 2 cm. '
            'Deviasi signifikan perlu dikonsultasikan dengan bidan atau dokter.';
        break;
      default:
        konten = 'Kenaikan berat badan selama kehamilan umumnya 11–16 kg untuk BMI normal. '
            'Pantau terus setiap kunjungan ANC.';
    }
    return InfoBoxEdukasiGrafik(konten: konten);
  }

  String get _indicatorLabel {
    switch (selectedIndicator) {
      case 1: return 'Tinggi Fundus';
      default: return 'Berat Badan';
    }
  }

  String get _indicatorSatuan {
    switch (selectedIndicator) {
      case 1: return 'cm';
      default: return 'kg';
    }
  }

  String? get _infoIdealText {
    switch (selectedIndicator) {
      case 1:
        return 'TFU normal ≈ usia kehamilan (minggu) ± 2 cm';
      default:
        if (trimester == 3) {
          return 'Penambahan BB ideal: 0.3–0.5 kg/minggu di trimester 3';
        } else if (trimester == 2) {
          return 'Penambahan BB ideal: 0.4–0.6 kg/minggu di trimester 2';
        } else {
          return 'Penambahan BB ideal: 0.1–0.3 kg/minggu di trimester 1';
        }
    }
  }
}
