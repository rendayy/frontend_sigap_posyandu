import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/widgets/balita/status_gizi_badge.dart';

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

  static const _beratIcon = '<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#clip0_1_578)"><path d="M6.48889 4.32599C7.38482 4.32599 8.11112 3.5997 8.11112 2.70377C8.11112 1.80784 7.38482 1.08154 6.48889 1.08154C5.59296 1.08154 4.86667 1.80784 4.86667 2.70377C4.86667 3.5997 5.59296 4.32599 6.48889 4.32599Z" stroke="#FF2B4E" stroke-width="1.08148" stroke-linecap="round" stroke-linejoin="round"/><path d="M3.51482 4.32593C3.28081 4.32836 3.05391 4.40662 2.86817 4.54897C2.68243 4.69132 2.54788 4.89008 2.4847 5.11541L1.13555 10.0037C1.09467 10.1619 1.09018 10.3273 1.1224 10.4875C1.15463 10.6477 1.22274 10.7986 1.32161 10.9287C1.42049 11.0588 1.54756 11.1648 1.69328 11.2387C1.839 11.3126 1.99958 11.3526 2.16296 11.3556H10.8148C10.9817 11.3555 11.1464 11.3168 11.2958 11.2425C11.4453 11.1682 11.5755 11.0603 11.6764 10.9273C11.7772 10.7943 11.8458 10.6397 11.877 10.4757C11.9081 10.3118 11.9008 10.1428 11.8558 9.98209L10.4904 5.13704C10.4308 4.90637 10.2968 4.70181 10.109 4.55514C9.9213 4.40847 9.69039 4.32789 9.45216 4.32593H3.51482Z" stroke="#FF2B4E" stroke-width="1.08148" stroke-linecap="round" stroke-linejoin="round"/></g><defs><clipPath id="clip0_1_578"><rect width="12.9778" height="12.9778" fill="white"/></clipPath></defs></svg>';
  static const _tinggiIcon = '<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#clip0_1_446)"><path d="M11.7934 5.40959C12.0405 6.62204 11.8644 7.88254 11.2946 8.98088C10.7248 10.0792 9.79562 10.949 8.66211 11.4452C7.5286 11.9414 6.25923 12.034 5.0657 11.7076C3.87217 11.3812 2.82662 10.6555 2.1034 9.65147C1.38019 8.64746 1.02303 7.42587 1.09148 6.1904C1.15993 4.95493 1.64986 3.78027 2.47957 2.86231C3.30928 1.94435 4.42861 1.33857 5.65089 1.146C6.87318 0.953431 8.12454 1.18571 9.1963 1.8041" stroke="#00C950" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/><path d="M4.86862 5.95053L6.4915 7.5734L11.9011 2.16382" stroke="#00C950" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/></g><defs><clipPath id="clip0_1_446"><rect width="12.983" height="12.983" fill="white"/></clipPath></defs></svg>';
  static const _lingkarKepalaIcon = '<svg width="13" height="13" viewBox="0 0 13 13" fill="none" xmlns="http://www.w3.org/2000/svg"><g clip-path="url(#clip0_1_424)"><path d="M11.5224 8.27675C11.6434 8.39737 11.7395 8.54069 11.805 8.6985C11.8705 8.85631 11.9043 9.0255 11.9043 9.19638C11.9043 9.36725 11.8705 9.53645 11.805 9.69426C11.7395 9.85207 11.6434 9.99539 11.5224 10.116L10.1159 11.5225C9.9953 11.6435 9.85198 11.7396 9.69417 11.8051C9.53636 11.8706 9.36716 11.9044 9.19629 11.9044C9.02541 11.9044 8.85622 11.8706 8.69841 11.8051C8.5406 11.7396 8.39728 11.6435 8.27666 11.5225L1.46058 4.70643C1.21745 4.46212 1.08096 4.13147 1.08096 3.7868C1.08096 3.44212 1.21745 3.11148 1.46058 2.86717L2.86708 1.46068C3.11138 1.21755 3.44203 1.08105 3.7867 1.08105C4.13138 1.08105 4.46202 1.21755 4.70633 1.46068L11.5224 8.27675Z" stroke="#AD46FF" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/><path d="M7.8439 6.76209L8.92582 5.68018" stroke="#AD46FF" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/><path d="M6.22101 5.13905L7.30292 4.05713" stroke="#AD46FF" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/><path d="M4.59814 3.51624L5.68006 2.43433" stroke="#AD46FF" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/><path d="M9.46677 8.3849L10.5487 7.30298" stroke="#AD46FF" stroke-width="1.08192" stroke-linecap="round" stroke-linejoin="round"/></g><defs><clipPath id="clip0_1_424"><rect width="12.983" height="12.983" fill="white"/></clipPath></defs></svg>';

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

  Widget _buildIconText(String svgString, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.string(
          svgString,
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