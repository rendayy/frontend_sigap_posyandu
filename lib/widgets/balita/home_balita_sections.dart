import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class ProfileSummaryCard extends StatelessWidget {
  final int usia;
  final String imunisasiStatus;
  final String lastCheckupDate;
  final bool isLoading;

  const ProfileSummaryCard({
    super.key,
    required this.usia,
    this.imunisasiStatus = '-',
    this.lastCheckupDate = '-',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 211,
      decoration: BoxDecoration(
        color: isLoading ? const Color(0xFFE2E8F0) : null,
        gradient: isLoading
            ? null
            : const LinearGradient(
                colors: [AppColors.gold, AppColors.orange, AppColors.goldDark],
                stops: [0.0, 0.5, 1.0],
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
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usia Balita',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.pinkLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$usia',
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
                                        'Bulan',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.pinkLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Imunisasi: ',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.pinkLight,
                                      ),
                                    ),
                                    Text(
                                      imunisasiStatus,
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
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.child_care,
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
                          'Pemantauan Terakhir',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.pinkLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lastCheckupDate,
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
          const Spacer(),
          Row(
            children: [
              const SkeletonWidget(width: 96, height: 10),
              const SizedBox(width: 8),
              const SkeletonWidget(width: 72, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickStatsGrid extends StatelessWidget {
  final String tinggiBadan;
  final String beratBadan;
  final String lingkarKepala;
  final bool isLoading;

  const QuickStatsGrid({
    super.key,
    this.tinggiBadan = '25,5',
    this.beratBadan = '7',
    this.lingkarKepala = '48,5',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: isLoading
            ? _SkeletonStatCard()
            : _StatCard(
                label: 'Tinggi Badan',
                value: tinggiBadan,
                unit: 'cm',
                svgAsset: 'static/svg/ic_tinggi_badan.svg',
                iconColor: const Color(0xFFAD46FF),
              )),
        const SizedBox(width: 8),
        Expanded(child: isLoading
            ? _SkeletonStatCard()
            : _StatCard(
                label: 'Berat Badan',
                value: beratBadan,
                unit: 'kg',
                svgAsset: 'static/svg/ic_berat_badan.svg',
                iconColor: const Color(0xFFFF2B4E),
              )),
        const SizedBox(width: 8),
        Expanded(child: isLoading
            ? _SkeletonStatCard()
            : _StatCard(
                label: 'Lingkar Kepala',
                value: lingkarKepala,
                unit: 'cm',
                svgAsset: 'static/svg/ic_lingkar_kepala.svg',
                iconColor: const Color(0xFF00C950),
              )),
      ],
    );
  }
}

class _SkeletonStatCard extends StatelessWidget {
  const _SkeletonStatCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
          const SkeletonWidget(width: 24, height: 24, borderRadius: 12),
          const SizedBox(height: 8),
          const SkeletonWidget(width: 60, height: 10),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SkeletonWidget(width: 28, height: 14, borderRadius: 4),
              const SizedBox(width: 4),
              const SkeletonWidget(width: 16, height: 10),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String svgAsset;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.svgAsset,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
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
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgAsset,
                width: 13,
                height: 13,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusGiziInfoCard extends StatelessWidget {
  final String? statusGizi;
  final bool isLoading;

  const StatusGiziInfoCard({super.key, required this.statusGizi, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          if (isLoading)
            const SkeletonWidget(width: 36, height: 36, borderRadius: 18)
          else
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.monitor_heart, size: 17, color: AppColors.greenDark),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading)
                  const SkeletonWidget(width: 72, height: 12)
                else
                  Text(
                    'Status Gizi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                const SizedBox(height: 4),
                if (isLoading)
                  const SkeletonWidget(width: 108, height: 10)
                else
                  Text(
                    'Berat badan menurut usia',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading)
            const SkeletonWidget(width: 80, height: 28, borderRadius: 12)
          else
            StatusGiziBadge(status: statusGizi ?? '-'),
        ],
      ),
    );
  }
}

class ImunisasiCard extends StatelessWidget {
  final String imunisasiStatus;
  final bool isLoading;

  const ImunisasiCard({
    super.key,
    this.imunisasiStatus = '-',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLengkap = imunisasiStatus == 'lengkap';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: isLoading
          ? Row(
              children: [
                const SkeletonWidget(width: 36, height: 36, borderRadius: 18),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonWidget(width: 96, height: 12),
                    SizedBox(height: 4),
                    SkeletonWidget(width: 64, height: 16, borderRadius: 4),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isLengkap ? AppColors.greenLight : AppColors.orangeLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isLengkap ? Icons.check_circle : Icons.vaccines,
                      size: 17,
                      color: isLengkap ? AppColors.greenDark : AppColors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Imunisasi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isLengkap ? 'Lengkap' : 'Tidak Lengkap',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isLengkap ? AppColors.greenDark : AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLengkap ? AppColors.greenLight : AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isLengkap ? 'Lengkap' : 'Tidak Lengkap',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isLengkap ? AppColors.greenDark : AppColors.orange,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class JadwalSectionTitle extends StatelessWidget {
  final bool isLoading;

  const JadwalSectionTitle({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const SkeletonWidget(width: 200, height: 14)
        : Text(
            'Jadwal Pemeriksaan Berikutnya',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          );
  }
}

class JadwalCard extends StatelessWidget {
  final String day;
  final String month;
  final String eventName;
  final String time;
  final String location;
  final bool isLoading;

  const JadwalCard({
    super.key,
    this.day = '15',
    this.month = 'Feb',
    this.eventName = 'Posyandu Bulanan',
    this.time = '08:00-10:00',
    this.location = 'Balai RW 03',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              if (isLoading)
                const SkeletonWidget(width: 13, height: 13, borderRadius: 4)
              else
                const Icon(Icons.calendar_today, size: 13, color: AppColors.orange),
              const SizedBox(width: 6),
              if (isLoading)
                const SkeletonWidget(width: 160, height: 12)
              else
                Text(
                  'Jadwal Posyandu Berikutnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (isLoading)
                const SkeletonWidget(width: 48, height: 48, borderRadius: 20)
              else
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.orangeLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        month,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const SkeletonWidget(width: 120, height: 14)
                    else
                      Text(
                        eventName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (isLoading)
                      const SkeletonWidget(width: 80, height: 12)
                    else
                      Text(
                        time,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isLoading)
                        const SkeletonWidget(width: 96, height: 12)
                      else
                        Text(
                          location,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isLoading)
                const SkeletonWidget(width: 14, height: 14, borderRadius: 4)
              else
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class PerkembanganCard extends StatelessWidget {
  final int usia;
  final String description;
  final List<String> tags;
  final bool isLoading;

  const PerkembanganCard({
    super.key,
    required this.usia,
    this.description = 'Si kecil kini bisa berlari, menaiki tangga, dan mengucapkan 20+ kata! Terus stimulasi dengan mengajakSi kecil berbicara dan bermain di luar ruangan.',
    this.tags = const ['Motorik Kasar', 'Bahasa', 'Kognitif'],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoading ? const Color(0xFFE2E8F0) : null,
        gradient: isLoading
            ? null
            : const LinearGradient(
                colors: [AppColors.purpleLight, Color(0xFFEEF2FF)],
              ),
        borderRadius: BorderRadius.circular(16),
        border: isLoading ? null : Border.all(color: AppColors.textSecondary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isLoading)
                const SkeletonWidget(width: 14, height: 14, borderRadius: 4)
              else
                const Icon(Icons.star, size: 14, color: AppColors.purple),
              const SizedBox(width: 8),
              if (isLoading)
                const SkeletonWidget(width: 120, height: 12)
              else
                Text(
                  'Perkembangan $usia bulan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.purple,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Column(
              children: [
                SkeletonWidget(width: double.infinity, height: 10),
                SizedBox(height: 4),
                SkeletonWidget(width: double.infinity, height: 10),
                SizedBox(height: 4),
                SkeletonWidget(width: 160, height: 10),
              ],
            )
          else
              Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
          const SizedBox(height: 10),
          if (isLoading)
            const Row(
              children: [
                SkeletonWidget(width: 80, height: 20, borderRadius: 20),
                SizedBox(width: 6),
                SkeletonWidget(width: 56, height: 20, borderRadius: 20),
                SizedBox(width: 6),
                SkeletonWidget(width: 64, height: 20, borderRadius: 20),
              ],
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tagBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$tag \u2197',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.tagText,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }
}
