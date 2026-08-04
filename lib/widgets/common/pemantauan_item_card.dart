import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/widgets/common/app_card.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';

class PemantauanMetric {
  final String iconAsset;
  final String text;
  const PemantauanMetric({required this.iconAsset, required this.text});
}

class PemantauanItemCard extends StatelessWidget {
  final String date;
  final String? status;
  final String avatarMain;
  final String avatarSub;
  final Color avatarFg;
  final Color avatarBg;
  final List<PemantauanMetric> metrics;
  final VoidCallback? onTap;

  const PemantauanItemCard({
    super.key,
    required this.date,
    this.status,
    required this.avatarMain,
    required this.avatarSub,
    required this.avatarFg,
    required this.avatarBg,
    required this.metrics,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
          const SizedBox(width: 12),
          _buildArrow(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: avatarBg,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                avatarMain,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: avatarFg,
                  height: 1.0,
                ),
              ),
              Text(
                avatarSub,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: avatarFg.withValues(alpha: 0.6),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              date,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            if (status != null)
              StatusGiziBadge(status: status!, compact: true),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: List.generate(metrics.length, (index) {
              final metric = metrics[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == metrics.length - 1 ? 0.0 : 16.0,
                ),
                child: _buildMetricItem(metric),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(PemantauanMetric metric) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          metric.iconAsset,
          width: 13,
          height: 13,
        ),
        const SizedBox(width: 4),
        Text(
          metric.text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildArrow() {
    return const Icon(
      Icons.chevron_right,
      size: 18,
      color: Color(0xFF94A3B8),
    );
  }
}
