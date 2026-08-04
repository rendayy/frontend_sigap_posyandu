import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_status.dart';
import 'package:frontend_posyandu/widgets/common/app_card.dart';

class GulaDarahHistorySection extends StatelessWidget {
  final List<GulaDarahMeasurement> measurements;
  final List<GulaDarahZone> zones;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color accent;

  const GulaDarahHistorySection({
    super.key,
    required this.measurements,
    required this.zones,
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    this.accent = const Color(0xFF162DF9),
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements = List<GulaDarahMeasurement>.from(measurements)
      ..sort((a, b) => a.tanggalPeriksa.compareTo(b.tanggalPeriksa));

    final paginatedMeasurements = _paginateMeasurements(sortedMeasurements);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pengukuran',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...paginatedMeasurements.map((measurement) {
            final status = determineGulaDarahStatus(
              measurement.gulaDarah,
              zones,
            );
            final statusColor = status != null
                ? parseHexColor(status.color)
                : const Color(0xFF64748B);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      formatDate(measurement.tanggalPeriksa),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          gulaDarahStatusLabel(status?.status),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        '${measurement.gulaDarah} mg/dL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          _buildPagination(),
        ],
      ),
    );
  }

  List<GulaDarahMeasurement> _paginateMeasurements(
    List<GulaDarahMeasurement> allMeasurements,
  ) {
    final pageSize = 5;
    final startIndex = (currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    if (startIndex >= allMeasurements.length) return [];
    return allMeasurements.sublist(
      startIndex,
      endIndex > allMeasurements.length ? allMeasurements.length : endIndex,
    );
  }

  Widget _buildPagination() {
    final showPrev = currentPage > 1;
    final showNext = currentPage < totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showPrev)
          TextButton(
            onPressed: onPrev,
            child: Text(
              'Sebelumnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          )
        else
          const SizedBox(width: 60),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$currentPage / $totalPages',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        if (showNext)
          TextButton(
            onPressed: onNext,
            child: Text(
              'Selanjutnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          )
        else
          const SizedBox(width: 60),
      ],
    );
  }
}
