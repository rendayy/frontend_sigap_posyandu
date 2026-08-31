import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class CardRiwayatKunjungan extends StatelessWidget {
  final PemeriksaanIbuHamilItem item;
  final VoidCallback? onTap;

  const CardRiwayatKunjungan({
    super.key,
    required this.item,
    this.onTap,
  });

  String _shortMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    DateTime? parsedDate;
    if (item.tanggalPeriksa != null) {
      try {
        parsedDate = DateTime.parse(item.tanggalPeriksa!);
      } catch (_) {}
    }

    final day = parsedDate?.day.toString() ?? '-';
    final month = parsedDate != null ? _shortMonth(parsedDate.month) : '';
    final formattedDate = parsedDate != null
        ? '${parsedDate.day} ${_shortMonth(parsedDate.month)} ${parsedDate.year}'
        : item.tanggalPeriksa ?? '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateBadge(day, month),
            const SizedBox(width: 12),
            Expanded(child: _buildContent(formattedDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBadge(String day, String month) {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pinkLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.lilaIcon,
              height: 1.2,
            ),
          ),
          if (month.isNotEmpty)
            Text(
              month,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.lilaIcon,
                height: 1.2,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(String formattedDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(),
        const SizedBox(height: 4),
        Text(
          'Usia ${item.usiaKehamilan ?? '-'} minggu · $formattedDate',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        _buildVitalRow(),
        const SizedBox(height: 4),
        _buildLilaRow(),
        const SizedBox(height: 6),
        _buildKeluhanRow(),
      ],
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Text(
          'ANC ke-${item.no ?? '-'}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.statusSuccessBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Selesai',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.statusSuccessText,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 18,
          color: AppColors.textSecondary.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  Widget _buildVitalRow() {
    final bb = item.beratBadan != null ? '${item.beratBadan!.toStringAsFixed(1)} kg' : '- kg';
    final td = item.sistol != null && item.distol != null
        ? '${item.sistol}/${item.distol}'
        : '-/-';
    final tfu = item.tinggiFundus != null ? '${item.tinggiFundus!.toStringAsFixed(0)} cm' : '- cm';

    return Row(
      children: [
        _vitalItem('BB', bb),
        const SizedBox(width: 16),
        _vitalItem('TD', td),
        const SizedBox(width: 16),
        _vitalItem('TFU', tfu),
      ],
    );
  }

  Widget _vitalItem(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLilaRow() {
    final lila = item.lingkarLengan != null
        ? '${item.lingkarLengan!.toStringAsFixed(1)} cm'
        : '- cm';
    return _vitalItem('LILA', lila);
  }

  Widget _buildKeluhanRow() {
    final keluhan = item.keluhan?.isNotEmpty == true
        ? item.keluhan
        : 'Tidak ada keluhan.';
    return Text(
      'Keluhan: $keluhan',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
    );
  }
}
