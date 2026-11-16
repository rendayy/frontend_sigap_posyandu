import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class BannerEdukasiCard extends StatelessWidget {
  final int trimester;
  final String konten;
  final bool isLoading;

  const BannerEdukasiCard({
    super.key,
    required this.trimester,
    required this.konten,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoading ? const Color(0xFFE2E8F0) : AppColors.creamBg,
        borderRadius: BorderRadius.circular(16),
        border: isLoading
            ? null
            : Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: isLoading ? _buildSkeleton() : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, size: 16, color: AppColors.orange),
            const SizedBox(width: 6),
            Text(
              'Trimester $trimester',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          konten,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.creamText,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkeletonWidget(width: 16, height: 16, borderRadius: 4),
            SizedBox(width: 6),
            SkeletonWidget(width: 72, height: 14),
          ],
        ),
        SizedBox(height: 10),
        SkeletonWidget(width: double.infinity, height: 10),
        SizedBox(height: 4),
        SkeletonWidget(width: double.infinity, height: 10),
        SizedBox(height: 4),
        SkeletonWidget(width: 140, height: 10),
      ],
    );
  }
}
