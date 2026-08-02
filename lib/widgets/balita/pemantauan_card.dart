import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';

class PemantauanCard extends StatelessWidget {
  final PemantauanBalitaItem item;
  final VoidCallback? onTap;

  const PemantauanCard({super.key, required this.item, this.onTap});

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatNullable(double? value, {int digits = 1}) {
    if (value == null) return '-';
    return value.toStringAsFixed(digits);
  }

  static const _beratIcon = 'static/svg/ic_berat_badan.svg';
  static const _tinggiIcon = 'static/svg/ic_lingkar_kepala.svg';
  static const _lingkarKepalaIcon = 'static/svg/ic_tinggi_badan.svg';

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
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7ED),
        shape: BoxShape.circle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${item.usiaBulan}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF97316),
              height: 1,
            ),
          ),
          Text(
            'bln',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0x99F97316),
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
              _formatDate(item.tanggalPantau),
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
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            children: [
              _buildIconText(_beratIcon, '${item.berat.toStringAsFixed(1)} kg'),
              const SizedBox(width: 16),
              _buildIconText(_tinggiIcon, '${item.tinggi.toStringAsFixed(1)} cm'),
              const SizedBox(width: 16),
              _buildIconText(_lingkarKepalaIcon, '${_formatNullable(item.lingkarKepala)} cm'),
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
    return Icon(
      Icons.chevron_right,
      size: 18,
      color: const Color(0xFF94A3B8),
    );
  }
}