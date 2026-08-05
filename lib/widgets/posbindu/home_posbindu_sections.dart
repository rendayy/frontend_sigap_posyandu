import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class GulaDarahCard extends StatelessWidget {
  final int? gulaDarahSewaktu;
  final String? statusGulaDarah;
  final bool isLoading;

  const GulaDarahCard({
    super.key,
    this.gulaDarahSewaktu,
    this.statusGulaDarah,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? _buildSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEFF6FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bloodtype_outlined,
                            size: 20,
                            color: Color(0xFF162DF9),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Gula Darah Sewaktu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    _buildBadge(statusGulaDarah),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      gulaDarahSewaktu != null ? '$gulaDarahSewaktu' : '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'mg/dL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildBadge(String? status) {
    String label = 'Belum Ada Data';
    Color textColor = AppColors.textSecondary;
    Color bgColor = const Color(0xFFF1F5F9);

    if (status != null) {
      final s = status.toLowerCase();
      if (s == 'normal') {
        label = 'Normal';
        textColor = const Color(0xFF00A63E);
        bgColor = const Color(0xFFF0FDF4);
      } else if (s == 'pra_diabetes' || s == 'pradiabetes') {
        label = 'Pra-Diabetes';
        textColor = const Color(0xFFFFA726);
        bgColor = const Color(0xFFFFF7ED);
      } else if (s == 'diabetes') {
        label = 'Diabetes';
        textColor = const Color(0xFFB71C1C);
        bgColor = const Color(0xFFFEF2F2);
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                SkeletonWidget(width: 36, height: 36, borderRadius: 18),
                SizedBox(width: 12),
                SkeletonWidget(width: 140, height: 14),
              ],
            ),
            const SkeletonWidget(width: 70, height: 24, borderRadius: 12),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            SkeletonWidget(width: 60, height: 32, borderRadius: 6),
            SizedBox(width: 6),
            SkeletonWidget(width: 40, height: 12),
          ],
        ),
      ],
    );
  }
}

class FaktorRisikoCard extends StatelessWidget {
  final String? faktorRisikoMerokok;
  final String? faktorRisikoKurangAktifitas;
  final bool isLoading;

  const FaktorRisikoCard({
    super.key,
    this.faktorRisikoMerokok,
    this.faktorRisikoKurangAktifitas,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: isLoading
          ? _buildSkeleton()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Faktor Risiko Gaya Hidup',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRow(
                  icon: Icons.smoking_rooms_outlined,
                  iconColor: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFEF2F2),
                  label: 'Merokok',
                  value: _formatStatus(faktorRisikoMerokok),
                ),
                const Divider(height: 20, thickness: 0.5),
                _buildRow(
                  icon: Icons.directions_walk,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: const Color(0xFFFFFBEB),
                  label: 'Kurang Aktifitas',
                  value: _formatStatus(faktorRisikoKurangAktifitas),
                ),
              ],
            ),
    );
  }

  String _formatStatus(String? value) {
    if (value == null) return 'Tidak diketahui';
    final v = value.toLowerCase();
    if (v == 'ya') return 'Ya';
    if (v == 'tidak') return 'Tidak';
    return value;
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    final isNegativeRisk = value == 'Tidak';

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isNegativeRisk
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isNegativeRisk
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonWidget(width: 160, height: 14),
        const SizedBox(height: 16),
        ...List.generate(2, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const SkeletonWidget(width: 38, height: 38, borderRadius: 19),
                const SizedBox(width: 12),
                const Expanded(
                  child: SkeletonWidget(width: 100, height: 14),
                ),
                const SkeletonWidget(width: 50, height: 24, borderRadius: 8),
              ],
            ),
          );
        }),
      ],
    );
  }
}
