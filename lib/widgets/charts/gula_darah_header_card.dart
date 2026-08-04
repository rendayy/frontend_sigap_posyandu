import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/widgets/common/app_card.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_status.dart';

class GulaDarahHeaderCard extends StatelessWidget {
  final GulaDarahChartData data;
  final Color accent;

  const GulaDarahHeaderCard({
    super.key,
    required this.data,
    this.accent = const Color(0xFF162DF9),
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = gulaDarahStatusColor(data.latestStatus);
    final statusLabel = gulaDarahStatusLabel(data.latestStatus);

    return AppCard(
      child: Row(
        children: [
          _buildStatusBox(statusColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gula Darah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.latestGulaDarah != null
                      ? '${data.latestGulaDarah} mg/dL'
                      : '—',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusBadge(statusLabel, statusColor),
          const SizedBox(width: 12),
          Text(
            '${data.measurements.length}x',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          'static/svg/ic_gula_darah.svg',
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
