import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class StatRow2Widget extends StatelessWidget {
  final double? beratBadanKg;
  final double? deltaKg;
  final String beratBadanStatus;
  final String? tekananDarah;
  final String? tekananDarahTanggal;
  final String tekananDarahStatus;
  final bool isLoading;

  const StatRow2Widget({
    super.key,
    this.beratBadanKg,
    this.deltaKg,
    this.beratBadanStatus = 'Normal',
    this.tekananDarah,
    this.tekananDarahTanggal,
    this.tekananDarahStatus = 'Normal',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: isLoading
              ? _SkeletonStatCard()
              : _BeratBadanCard(
                  beratBadanKg: beratBadanKg,
                  deltaKg: deltaKg,
                  status: beratBadanStatus,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: isLoading
              ? _SkeletonStatCard()
              : _TekananDarahCard(
                  tekananDarah: tekananDarah,
                  tanggal: tekananDarahTanggal,
                  status: tekananDarahStatus,
                ),
        ),
      ],
    );
  }
}

class _BeratBadanCard extends StatelessWidget {
  final double? beratBadanKg;
  final double? deltaKg;
  final String status;

  const _BeratBadanCard({
    this.beratBadanKg,
    this.deltaKg,
    required this.status,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'Normal':
        return AppColors.greenStatusText;
      case 'Perlu Perhatian':
        return AppColors.orange;
      case 'Waspada':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Normal':
        return AppColors.greenStatusBg;
      case 'Perlu Perhatian':
        return AppColors.orangeLight;
      case 'Waspada':
        return AppColors.redLight;
      default:
        return AppColors.inputBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = beratBadanKg != null;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.monitor_weight_outlined,
                      size: 16, color: AppColors.blueAccent),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Berat Badan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  beratBadanKg!.toStringAsFixed(1),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'kg',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            if (deltaKg != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    deltaKg! >= 0 ? Icons.trending_up : Icons.trending_down,
                    size: 14,
                    color: deltaKg! >= 0
                        ? AppColors.greenStatusText
                        : AppColors.orange,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${deltaKg! >= 0 ? '+' : ''}${deltaKg!.toStringAsFixed(1)} kg dari pemeriksaan lalu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Text(
              '--',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Belum ada data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TekananDarahCard extends StatelessWidget {
  final String? tekananDarah;
  final String? tanggal;
  final String status;

  const _TekananDarahCard({
    this.tekananDarah,
    this.tanggal,
    required this.status,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'Normal':
        return AppColors.greenStatusText;
      case 'Perlu Perhatian':
        return AppColors.orange;
      case 'Waspada':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Normal':
        return AppColors.greenStatusBg;
      case 'Perlu Perhatian':
        return AppColors.orangeLight;
      case 'Waspada':
        return AppColors.redLight;
      default:
        return AppColors.inputBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasData = tekananDarah != null && tekananDarah != '-';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.favorite_border,
                      size: 16, color: AppColors.error),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Tekanan Darah',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData) ...[
            Text(
              tekananDarah!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'mmHg${tanggal != null && tanggal!.isNotEmpty ? ' · $tanggal' : ''}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            Text(
              '--/--',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Belum ada data',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(status),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonStatCard extends StatelessWidget {
  const _SkeletonStatCard();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonWidget(width: 32, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              const SkeletonWidget(width: 72, height: 12),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonWidget(width: 60, height: 24, borderRadius: 4),
          const SizedBox(height: 4),
          const SkeletonWidget(width: 80, height: 10),
          const SizedBox(height: 10),
          const SkeletonWidget(width: 56, height: 20, borderRadius: 12),
        ],
      ),
    );
  }
}
