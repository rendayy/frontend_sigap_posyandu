import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class GreetingSection extends StatelessWidget {
  final String name;
  final String initials;
  final bool isLoading;
  final String? moduleBadge;      // 'Balita' / 'Remaja' / 'Posbindu' / null
  final Color badgeColor;         // teks + titik badge
  final Color badgeBgColor;       // latar badge
  final List<Color> avatarGradient;

  const GreetingSection({
    super.key,
    required this.name,
    required this.initials,
    this.isLoading = false,
    this.moduleBadge,
    this.badgeColor = AppColors.pinkVivid,
    this.badgeBgColor = AppColors.pinkLight,
    this.avatarGradient = const [Color(0xFF43A047), Color(0xFF26A69A)],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (isLoading)
            const SkeletonWidget(width: 56, height: 56, borderRadius: 28)
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: avatarGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const SkeletonWidget(width: 32, height: 12)
                else
                  Text(
                    'Halo,',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 4),
                if (isLoading)
                  const SkeletonWidget(width: 140, height: 16)
                else
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (moduleBadge != null) ...[
                  const SizedBox(height: 6),
                  if (isLoading)
                    const SkeletonWidget(width: 60, height: 22, borderRadius: 20)
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            moduleBadge!,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileSummaryCard extends StatelessWidget {
  final String label;             // 'Usia Balita' / 'Indeks Massa Tubuh (BMI)'
  final String heroValue;         // '24' / '22.3'
  final String heroUnit;          // 'Bulan' / 'kg/m²'
  final IconData icon;            // Icons.child_care / Icons.monitor_heart
  final List<Color> gradient;     // 3 warna per modul
  final Color labelColor;         // warna teks sekunder di atas gradient
  final Widget? statusRow;        // baris 'Imunisasi: ...' / 'Status: [badge]'
  final String footerLabel;       // default 'Pemantauan Terakhir'
  final String footerValue;       // tanggal terformat / '-'
  final bool isLoading;

  const ProfileSummaryCard({
    super.key,
    required this.label,
    required this.heroValue,
    required this.heroUnit,
    required this.icon,
    required this.gradient,
    required this.labelColor,
    this.statusRow,
    this.footerLabel = 'Pemantauan Terakhir',
    this.footerValue = '-',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isLoading ? const Color(0xFFE2E8F0) : null,
        gradient: isLoading
            ? null
            : LinearGradient(
                colors: gradient,
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: isLoading
          ? _buildSkeleton()
          : Stack(
              children: [
                Positioned(
                  right: -24,
                  top: -40,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: -20,
                  bottom: 10,
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: labelColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      heroValue,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Text(
                                        heroUnit,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: labelColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (statusRow != null) ...[
                                  const SizedBox(height: 6),
                                  statusRow!,
                                ],
                              ],
                            ),
                          ),
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              color: AppColors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            footerLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: labelColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            footerValue,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonWidget(width: 64, height: 12),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SkeletonWidget(width: 48, height: 40, borderRadius: 4),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: SkeletonWidget(width: 32, height: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const SkeletonWidget(width: 120, height: 12),
                  ],
                ),
              ),
              const SkeletonWidget(width: 56, height: 56, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              SkeletonWidget(width: 96, height: 10),
              SizedBox(width: 8),
              SkeletonWidget(width: 72, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickStatItem {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color iconColor;
  const QuickStatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
  });
}

class QuickStatsGrid extends StatelessWidget {
  final List<QuickStatItem> items; // tepat 3 item
  final bool isLoading;

  const QuickStatsGrid({
    super.key,
    required this.items,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        children: [
          Expanded(child: _SkeletonStatCard()),
          const SizedBox(width: 8),
          Expanded(child: _SkeletonStatCard()),
          const SizedBox(width: 8),
          Expanded(child: _SkeletonStatCard()),
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _StatCard(item: items[i]),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final QuickStatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item.iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    item.icon,
                    size: 14,
                    color: item.iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  item.value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                item.unit,
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
}

class _SkeletonStatCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              SkeletonWidget(width: 24, height: 24, borderRadius: 12),
              SizedBox(width: 6),
              SkeletonWidget(width: 48, height: 10),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonWidget(width: 32, height: 16),
              SizedBox(width: 4),
              SkeletonWidget(width: 16, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
