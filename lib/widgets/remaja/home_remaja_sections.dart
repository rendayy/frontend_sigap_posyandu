import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';

class InfoSectionCard extends StatelessWidget {
  final String? sekolah;
  final String? kelas;
  final String? hobi;
  final bool isLoading;

  const InfoSectionCard({
    super.key,
    this.sekolah,
    this.kelas,
    this.hobi,
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
                  'Informasi Akademik & Hobi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRow(
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  bgColor: const Color(0xFFEEF2FF),
                  label: 'Sekolah',
                  value: sekolah ?? '-',
                ),
                const Divider(height: 20, thickness: 0.5),
                _buildRow(
                  icon: Icons.class_rounded,
                  iconColor: const Color(0xFF0D9488),
                  bgColor: const Color(0xFFF0FDFA),
                  label: 'Kelas',
                  value: kelas ?? '-',
                ),
                const Divider(height: 20, thickness: 0.5),
                _buildRow(
                  icon: Icons.palette_rounded,
                  iconColor: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
                  label: 'Hobi / Minat',
                  value: hobi ?? '-',
                ),
              ],
            ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonWidget(width: 150, height: 14),
        const SizedBox(height: 16),
        ...List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const SkeletonWidget(width: 38, height: 38, borderRadius: 19),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonWidget(width: 60, height: 10),
                    const SizedBox(height: 4),
                    const SkeletonWidget(width: 120, height: 14),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class KegiatanHomeCard extends StatelessWidget {
  final List<KegiatanRemajaItem>? items;
  final bool isLoading;
  final VoidCallback? onLihatSemua;

  const KegiatanHomeCard({
    super.key,
    this.items,
    this.isLoading = false,
    this.onLihatSemua,
  });

  static const Map<String, Color> _jenisColors = {
    'edukasi': Color(0xFF3B82F6),
    'skrining': Color(0xFF10B981),
    'konseling': Color(0xFF8B5CF6),
    'olahraga': Color(0xFFF59E0B),
  };

  static const Map<String, String> _jenisLabels = {
    'edukasi': 'Edukasi',
    'skrining': 'Skrining',
    'konseling': 'Konseling',
    'olahraga': 'Olahraga',
  };

  static const Map<String, IconData> _jenisIcons = {
    'edukasi': Icons.menu_book,
    'skrining': Icons.health_and_safety,
    'konseling': Icons.chat_bubble_outline,
    'olahraga': Icons.directions_run,
  };

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildSkeleton();

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (items != null && items!.isNotEmpty)
            ...items!.map((item) => _buildItemCard(item)),
          if (items == null || items!.isEmpty)
            _buildEmptyState(),
          _buildLihatSemua(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(
        'Kegiatan Terdekat',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  String _getJenisLabel(String key) => _jenisLabels[key] ?? key;
  Color _getJenisColor(String key) => _jenisColors[key] ?? const Color(0xFF64748B);
  IconData _getJenisIcon(String key) => _jenisIcons[key] ?? Icons.event;


  Widget _buildItemCard(KegiatanRemajaItem item) {
    final jenisColor = _getJenisColor(item.jenisKegiatan);
    final icon = _getJenisIcon(item.jenisKegiatan);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: jenisColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: jenisColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namaKegiatan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDate(item.tanggal)} • ${item.waktu}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getJenisColor(item.jenisKegiatan).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getJenisLabel(item.jenisKegiatan),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getJenisColor(item.jenisKegiatan),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 0.5, color: const Color(0xFFE2E8F0)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            'Belum ada kegiatan terdekat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLihatSemua() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onLihatSemua,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.emerald,
            side: const BorderSide(color: AppColors.emerald),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Lihat Semua Kegiatan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: const SkeletonWidget(width: 120, height: 14),
          ),
          ...List.generate(2, (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const SkeletonWidget(width: 36, height: 36, borderRadius: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonWidget(width: 140, height: 14),
                          const SizedBox(height: 4),
                          const SkeletonWidget(width: 100, height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SkeletonWidget(width: 50, height: 18, borderRadius: 4),
                  ],
                ),
                if (index == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, thickness: 0.5, color: const Color(0xFFE2E8F0)),
                  ),
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: const SkeletonWidget(width: double.infinity, height: 36, borderRadius: 8),
          ),
        ],
      ),
    );
  }
}

class AnemiaCard extends StatelessWidget {
  final String riwayatAnemia;
  final bool isLoading;

  const AnemiaCard({
    super.key,
    this.riwayatAnemia = 'tidak',
    this.isLoading = false,
  });

  bool get _hasAnemia => riwayatAnemia.toLowerCase() == 'ya';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonWidget(width: 100, height: 14),
                  const SizedBox(height: 4),
                  const SkeletonWidget(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final Color statusColor = _hasAnemia ? const Color(0xFFE11D48) : const Color(0xFF16A34A);
    final Color bgColor = _hasAnemia ? const Color(0xFFFFF1F2) : const Color(0xFFF0FDF4);
    final Color borderColor = _hasAnemia ? const Color(0xFFFECDD3) : const Color(0xFFDCFCE7);
    final IconData icon = _hasAnemia ? Icons.warning_amber_rounded : Icons.check_circle_rounded;
    final String title = _hasAnemia ? 'Riwayat Anemia Terdeteksi' : 'Bebas Anemia';
    final String description = _hasAnemia 
        ? 'Konsumsi tablet tambah darah (TTD) secara teratur & makan tinggi zat besi.'
        : 'Tubuh sehat dan bugar. Pertahankan konsumsi sayur, daging, dan istirahat cukup.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _hasAnemia ? const Color(0xFF9F1239) : const Color(0xFF166534),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
