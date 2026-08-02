import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusGiziBadge extends StatelessWidget {
  final String? status;
  final bool compact;

  const StatusGiziBadge({super.key, this.status, this.compact = false});

  String get _raw => status ?? 'unknown';

  Color get _color {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return const Color(0xFF22C55E);
      case 'kurang':
      case 'gizi_kurang':
        return const Color(0xFFF97316);
      case 'buruk':
      case 'gizi_buruk':
        return const Color(0xFFEF4444);
      case 'stunting':
        return const Color(0xFFE11D48);
      case 'berat_badan_kurang':
        return const Color(0xFF2196F3);
      case 'berat_badan_normal':
        return const Color(0xFF43A047);
      case 'berat_badan_berlebih':
        return const Color(0xFFFFA726);
      case 'obesitas_1':
        return const Color(0xFFEF5350);
      case 'obesitas_2':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  Color get _bgColor {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return const Color(0xFFF0FDF4);
      case 'kurang':
      case 'gizi_kurang':
        return const Color(0xFFFFF7ED);
      case 'buruk':
      case 'gizi_buruk':
        return const Color(0xFFFEF2F2);
      case 'stunting':
        return const Color(0xFFFFF1F2);
      case 'berat_badan_kurang':
        return const Color(0xFFE3F2FD);
      case 'berat_badan_normal':
        return const Color(0xFFE8F5E9);
      case 'berat_badan_berlebih':
        return const Color(0xFFFFF3E0);
      case 'obesitas_1':
      case 'obesitas_2':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF8FAFC);
    }
  }

  String get _label {
    switch (_raw) {
      case 'baik':
      case 'gizi_baik':
        return 'Baik';
      case 'kurang':
      case 'gizi_kurang':
      case 'berat_badan_kurang':
        return 'Kurang';
      case 'buruk':
      case 'gizi_buruk':
        return 'Buruk';
      case 'stunting':
        return 'Stunting';
      case 'berat_badan_normal':
        return 'Normal';
      case 'berat_badan_berlebih':
        return 'Berlebih';
      case 'obesitas_1':
        return 'Obesitas 1';
      case 'obesitas_2':
        return 'Obesitas 2';
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
