import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/widgets/remaja/status_gizi_badge.dart';

class PemantauanRemajaCard extends StatelessWidget {
  final PemantauanRemajaItem item;
  final VoidCallback? onTap;

  const PemantauanRemajaCard({super.key, required this.item, this.onTap});

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatNum(dynamic value, {int digits = 1}) {
    if (value == null) return '-';
    if (value is double) return value.toStringAsFixed(digits);
    return value.toString();
  }

  static const _beratIcon = 'static/svg/ic_berat_badan.svg';
  static const _tinggiIcon = 'static/svg/ic_lingkar_kepala.svg';
  static const _gulaDarahIcon = 'static/svg/ic_gula_darah.svg';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x14000000)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(child: _buildContent()),
            const SizedBox(width: 12),
            _buildArrow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    String month = '';
    String year = '';
    try {
      final date = DateTime.parse(item.tanggalPeriksa);
      month = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ][date.month - 1];
      year = date.year.toString();
    } catch (_) {
      month = '-';
      year = '-';
    }
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F5E9),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF43A047),
              height: 1,
            ),
          ),
          Text(
            year,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0x9943A047),
              height: 1.2,
            ),
          ),
        ],
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
              _formatDate(item.tanggalPeriksa),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            StatusGiziBadge(status: item.statusGizi, compact: true),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              _buildIconText(_beratIcon, '${_formatNum(item.beratBadan)} kg'),
              const SizedBox(width: 16),
              _buildIconText(_tinggiIcon, '${_formatNum(item.tinggiBadan)} cm'),
              if (item.gulaDarah != null) ...[
                const SizedBox(width: 16),
                _buildIconText(_gulaDarahIcon, '${item.gulaDarah} mg/dl'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconText(String assetPath, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          assetPath,
          width: 13,
          height: 13,
        ),
        const SizedBox(width: 4),
        Text(
          text,
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
