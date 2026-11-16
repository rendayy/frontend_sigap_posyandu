import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class HeroKehamilanCard extends StatelessWidget {
  final int usiaMinggu;
  final int trimester;
  final int progressPersen;
  final String hpl;
  final int hariMenujuHpl;
  final int totalMinggu;
  final bool isLoading;

  const HeroKehamilanCard({
    super.key,
    required this.usiaMinggu,
    required this.trimester,
    required this.progressPersen,
    required this.hpl,
    required this.hariMenujuHpl,
    this.totalMinggu = 40,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final sisaMinggu = (totalMinggu - usiaMinggu).clamp(0, totalMinggu);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isLoading
            ? null
            : const LinearGradient(
                colors: [AppColors.pinkGradientStart, AppColors.pinkGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isLoading ? const Color(0xFFE2E8F0) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: isLoading ? _buildSkeleton() : _buildContent(sisaMinggu),
    );
  }

  Widget _buildContent(int sisaMinggu) {
    return Stack(
      children: [
        Positioned(
          right: -16,
          top: -16,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 20,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.child_care, color: AppColors.white, size: 22),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usia Kehamilan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$usiaMinggu',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'minggu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Trimester $trimester · $sisaMinggu minggu lagi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 14),
              _buildProgressBar(),
              const SizedBox(height: 8),
              _buildHplRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = progressPersen.clamp(0, 100) / 100;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Minggu 1',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
            const Spacer(),
            Text(
              '$progressPersen%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const Spacer(),
            Text(
              'Minggu $totalMinggu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildHplRow() {
    final isCountdownValid = hariMenujuHpl > 0;
    return Column(
      children: [
        Divider(
          color: AppColors.white.withValues(alpha: 0.2),
          height: 24,
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hari Perkiraan Lahir (HPL)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hpl,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isCountdownValid ? '$hariMenujuHpl' : '0',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'hari lagi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(width: 96, height: 12),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SkeletonWidget(width: 48, height: 36, borderRadius: 4),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: SkeletonWidget(width: 36, height: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const SkeletonWidget(width: 140, height: 12),
          const SizedBox(height: 20),
          const SkeletonWidget(width: double.infinity, height: 8, borderRadius: 4),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonWidget(width: 80, height: 10),
                    const SizedBox(height: 4),
                    const SkeletonWidget(width: 120, height: 14),
                  ],
                ),
              ),
              const SkeletonWidget(width: 72, height: 28, borderRadius: 20),
            ],
          ),
        ],
      ),
    );
  }
}
