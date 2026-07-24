import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusGiziBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusGiziBadge({super.key, required this.status, this.compact = false});

  String get _normalized {
    if (status.startsWith('gizi_')) return status.substring(5);
    return status;
  }

  Color get _color {
    switch (_normalized) {
      case 'baik':
        return const Color(0xFF22C55E);
      case 'kurang':
        return const Color(0xFFF97316);
      case 'buruk':
        return const Color(0xFFEF4444);
      case 'stunting':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get _bgColor {
    switch (_normalized) {
      case 'baik':
        return const Color(0xFFF0FDF4);
      case 'kurang':
        return const Color(0xFFFFF7ED);
      case 'buruk':
        return const Color(0xFFFEF2F2);
      case 'stunting':
        return const Color(0xFFFFF1F2);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  String get _label {
    switch (status) {
      case 'baik':
      case 'gizi_baik':
        return 'Baik';
      case 'kurang':
      case 'gizi_kurang':
        return 'Kurang';
      case 'buruk':
      case 'gizi_buruk':
        return 'Buruk';
      case 'stunting':
        return 'Stunting';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _color.withValues(alpha: 0.3)),
        ),
        child: Text(
          _label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _color,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
