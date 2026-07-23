import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusGiziBadge extends StatelessWidget {
  final String status;

  const StatusGiziBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'baik':
        return const Color(0xFF43A047);
      case 'kurang':
        return const Color(0xFFFFA726);
      case 'buruk':
        return const Color(0xFFEF5350);
      case 'stunting':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  Color get _bgColor {
    switch (status) {
      case 'baik':
        return const Color(0xFFF0FDF4);
      case 'kurang':
        return const Color(0xFFFFF7ED);
      case 'buruk':
        return const Color(0xFFFEF2F2);
      case 'stunting':
        return const Color(0xFFFCE7F3);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  String get _label {
    switch (status) {
      case 'baik':
        return 'Baik';
      case 'kurang':
        return 'Kurang';
      case 'buruk':
        return 'Buruk';
      case 'stunting':
        return 'Stunting';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Status Gizi: $_label',
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
