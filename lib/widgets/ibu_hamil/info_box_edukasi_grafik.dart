import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class InfoBoxEdukasiGrafik extends StatelessWidget {
  final String konten;

  const InfoBoxEdukasiGrafik({super.key, required this.konten});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBoxBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.infoBoxIcon.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.infoBoxIcon,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              konten,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.infoBoxText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
