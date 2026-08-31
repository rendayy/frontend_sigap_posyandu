import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class JadwalBerikutnyaCard extends StatelessWidget {
  final String? kunjunganKe;
  final String? tanggal;
  final String? lokasi;
  final String status;
  final int? hariLagi;
  final bool isLoading;

  const JadwalBerikutnyaCard({
    super.key,
    this.kunjunganKe,
    this.tanggal,
    this.lokasi,
    this.status = 'Akan Datang',
    this.hariLagi,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          const SkeletonWidget(width: 200, height: 16)
        else
          Text(
            'Jadwal Pemeriksaan Berikutnya',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
              BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          child: isLoading ? _buildSkeleton() : _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final hasSchedule = status != 'Belum Ada Pemeriksaan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.pinkGradientStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.medical_services_outlined,
                    size: 20, color: AppColors.pinkGradientStart),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSchedule
                        ? 'Pemeriksaan ANC ke-$kunjunganKe'
                        : 'Belum Ada Pemeriksaan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (hasSchedule && (tanggal != null || lokasi != null)) ...[
                    if (tanggal != null && tanggal!.isNotEmpty)
                      _infoRow(Icons.calendar_today, tanggal!),
                    if (lokasi != null && lokasi!.isNotEmpty)
                      _infoRow(Icons.location_on_outlined, lokasi!),
                  ],
                ],
              ),
            ),
            if (hasSchedule)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.circleLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueAccent,
                  ),
                ),
              ),
          ],
        ),
        if (hariLagi != null && hasSchedule) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              hariLagi! >= 0 ? '$hariLagi hari lagi' : 'Hari ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.pinkGradientEnd,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Row(
      children: [
        const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonWidget(width: 140, height: 14),
              SizedBox(height: 6),
              SkeletonWidget(width: 100, height: 12),
              SizedBox(height: 4),
              SkeletonWidget(width: 120, height: 12),
            ],
          ),
        ),
        const SkeletonWidget(width: 72, height: 22, borderRadius: 12),
      ],
    );
  }
}
