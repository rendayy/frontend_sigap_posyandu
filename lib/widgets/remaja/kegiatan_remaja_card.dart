import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';

class KegiatanRemajaCard extends StatelessWidget {
  final KegiatanRemajaItem item;
  final VoidCallback? onTap;

  const KegiatanRemajaCard({super.key, required this.item, this.onTap});

  static const Map<String, Color> _jenisColors = {
    'edukasi': Color(0xFF3B82F6),
    'skrining': Color(0xFF10B981),
    'konseling': Color(0xFF8B5CF6),
    'olahraga': Color(0xFFF59E0B),
  };

  static const Map<String, Color> _statusColors = {
    'rencana': Color(0xFF64748B),
    'selesai': Color(0xFF10B981),
    'dibatalkan': Color(0xFFEF4444),
  };

  static const Map<String, String> _jenisLabels = {
    'edukasi': 'Edukasi',
    'skrining': 'Skrining',
    'konseling': 'Konseling',
    'olahraga': 'Olahraga',
  };

  static const Map<String, String> _statusLabels = {
    'rencana': 'Rencana',
    'selesai': 'Selesai',
    'dibatalkan': 'Dibatalkan',
  };

  static const Map<String, IconData> _jenisIcons = {
    'edukasi': Icons.menu_book,
    'skrining': Icons.health_and_safety,
    'konseling': Icons.chat_bubble_outline,
    'olahraga': Icons.directions_run,
  };

  String _getJenisLabel(String key) => _jenisLabels[key] ?? key;
  String _getStatusLabel(String key) => _statusLabels[key] ?? key;
  Color _getJenisColor(String key) => _jenisColors[key] ?? const Color(0xFF64748B);
  Color _getStatusColor(String key) => _statusColors[key] ?? const Color(0xFF64748B);
  IconData _getJenisIcon(String key) => _jenisIcons[key] ?? Icons.event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(child: _buildContent()),
                const SizedBox(width: 4),
                _buildArrow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final jenisColor = _getJenisColor(item.jenisKegiatan);
    final icon = _getJenisIcon(item.jenisKegiatan);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: jenisColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: jenisColor),
    );
  }


  String _formatTime(String time) {
    try {
      return time.substring(0, 5);
    } catch (_) {
      return time;
    }
  }

  Widget _buildContent() {
    final jenisColor = _getJenisColor(item.jenisKegiatan);
    final jenisLabel = _getJenisLabel(item.jenisKegiatan);
    final statusLabel = _getStatusLabel(item.status);
    final statusColor = _getStatusColor(item.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.namaKegiatan,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildDateRow(),
        const SizedBox(height: 4),
        _buildLocationRow(),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildBadge(
              label: jenisLabel,
              color: jenisColor,
            ),
            const SizedBox(width: 6),
            _buildBadge(
              label: statusLabel,
              color: statusColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow() {
    return Row(
      children: [
        Icon(Icons.calendar_today_outlined, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          formatDate(item.tanggal),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '•',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ),
        Icon(Icons.access_time, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(
          _formatTime(item.waktu),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 12, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            item.tempat,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Icon(
        Icons.chevron_right,
        size: 18,
        color: const Color(0xFFCBD5E1),
      ),
    );
  }
}
