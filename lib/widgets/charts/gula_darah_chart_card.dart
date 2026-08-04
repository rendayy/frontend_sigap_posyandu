import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_status.dart';
import 'package:frontend_posyandu/widgets/common/app_card.dart';

class GulaDarahChartCard extends StatelessWidget {
  final GulaDarahChartData data;
  final List<GulaDarahMeasurement> currentMeasurements;

  const GulaDarahChartCard({
    super.key,
    required this.data,
    required this.currentMeasurements,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeasurements = List<GulaDarahMeasurement>.from(
      currentMeasurements,
    )..sort((a, b) => a.tanggalPeriksa.compareTo(b.tanggalPeriksa));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grafik Gula Darah',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gula darah (mg/dL) vs zona status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          GulaDarahChart(data: data, currentMeasurements: sortedMeasurements),
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final sortedZones = List<GulaDarahZone>.from(data.gulaDarahZones)
      ..sort((a, b) => a.min.compareTo(b.min));

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: sortedZones.map((zone) {
        final color = parseHexColor(zone.color);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              zone.label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
