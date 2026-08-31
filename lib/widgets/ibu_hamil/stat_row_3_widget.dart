import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class StatRow3Widget extends StatelessWidget {
  final double? lilaCm;
  final double? tinggiFundusCm;
  final int kunjunganSelesai;
  final int kunjunganTarget;
  final bool isLoading;

  const StatRow3Widget({
    super.key,
    this.lilaCm,
    this.tinggiFundusCm,
    this.kunjunganSelesai = 0,
    this.kunjunganTarget = 9,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isLoading
              ? _SkeletonSmallCard()
              : _SmallStatCard(
                  label: 'LILA',
                  value: lilaCm != null ? '${lilaCm!.toStringAsFixed(1)} cm' : '-',
                  icon: Icons.straighten,
                  bgColor: AppColors.lilaBg,
                  iconColor: AppColors.lilaIcon,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isLoading
              ? _SkeletonSmallCard()
              : _SmallStatCard(
                  label: 'Tinggi Fundus',
                  value: tinggiFundusCm != null
                      ? '${tinggiFundusCm!.toStringAsFixed(1)} cm'
                      : '-',
                  icon: Icons.trending_up,
                  bgColor: AppColors.fundusBg,
                  iconColor: AppColors.fundusIcon,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: isLoading
              ? _SkeletonSmallCard()
              :                 _SmallStatCard(
                  label: 'Kunjungan ANC',
                  value: kunjunganSelesai >= 6
                      ? '$kunjunganSelesai Lengkap'
                      : '$kunjunganSelesai',
                  icon: kunjunganSelesai >= 6
                      ? Icons.verified
                      : Icons.check_circle_outline,
                  bgColor: AppColors.ancBg,
                  iconColor: AppColors.ancIcon,
                ),
        ),
      ],
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 16, color: iconColor),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SkeletonSmallCard extends StatelessWidget {
  const _SkeletonSmallCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: const Column(
        children: [
          SkeletonWidget(width: 32, height: 32, borderRadius: 16),
          SizedBox(height: 6),
          SkeletonWidget(width: 48, height: 10),
          SizedBox(height: 4),
          SkeletonWidget(width: 36, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}
