import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_detail_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/common/app_card.dart';

const _posbinduBlue = Color(0xFF162DF9);

String posbinduStatusLabel(String? status) {
  switch (status) {
    case 'normal':
      return 'Normal';
    case 'pra_diabetes':
      return 'Pra-diabetes';
    case 'diabetes':
      return 'Diabetes';
    default:
      return 'Tidak Diketahui';
  }
}

Color posbinduStatusColor(String? status) {
  switch (status) {
    case 'normal':
      return const Color(0xFF43A047);
    case 'pra_diabetes':
      return const Color(0xFFFFA726);
    case 'diabetes':
      return const Color(0xFFB71C1C);
    default:
      return const Color(0xFF94A3B8);
  }
}

String _formatNum(dynamic value) {
  if (value == null) return '-';
  return value.toString();
}

class PemeriksaanHeaderCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const PemeriksaanHeaderCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _posbinduBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SvgPicture.asset('static/svg/ic_chart.svg', width: 40, height: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemeriksaan ${formatDate(d.tanggalPeriksa, short: true)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _posbinduBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d.bmi != null
                      ? 'BMI ${_formatNum(d.bmi)} · ${posbinduStatusLabel(d.statusBmi)}'
                      : posbinduStatusLabel(d.statusBmi),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _posbinduBlue,
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

class PemeriksaanDetailCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const PemeriksaanDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Data Pengukuran'),
          const SizedBox(height: 4),
          _antropometriRow(
            'static/svg/ic_berat_badan.svg',
            'Berat Badan',
            '${_formatNum(d.beratBadan)} kg',
          ),
          _antropometriRow(
            'static/svg/ic_tinggi_badan.svg',
            'Tinggi Badan',
            '${_formatNum(d.tinggiBadan)} cm',
          ),
          if (d.bmi != null)
            _antropometriRow(
              'static/svg/ic_chart.svg',
              'BMI',
              '${_formatNum(d.bmi)} kg/m²',
            ),
          if (d.lingkarPerut != null)
            _antropometriRow(
              Icons.show_chart,
              'Lingkar Perut',
              '${_formatNum(d.lingkarPerut)} cm',
            ),
        ],
      ),
    );
  }
}

class LabDetailCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const LabDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    final hasLabData =
        d.gulaDarahSewaktu != null ||
        d.kolesterolTotal != null ||
        d.asamUrat != null;

    if (!hasLabData) return const SizedBox.shrink();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Lab'),
          const SizedBox(height: 4),
          if (d.gulaDarahSewaktu != null)
            _antropometriRow(
              'static/svg/ic_gula_darah.svg',
              'Gula Darah Sewaktu',
              '${d.gulaDarahSewaktu} mg/dL',
            ),
          if (d.kolesterolTotal != null)
            _antropometriRow(
              Icons.show_chart,
              'Kolesterol Total',
              '${d.kolesterolTotal} mg/dL',
            ),
          if (d.asamUrat != null)
            _antropometriRow(
              Icons.show_chart,
              'Asam Urat',
              '${_formatNum(d.asamUrat)} mg/dL',
            ),
        ],
      ),
    );
  }
}

class StatusDetailCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const StatusDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Status'),
          const SizedBox(height: 12),
          if (d.sistol != null || d.distol != null) ...[
            _sectionHeader('Tekanan Darah'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _statusRow(
                    'Sistol',
                    d.sistol != null ? '${d.sistol} mmHg' : '- mmHg',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statusRow(
                    'Distol',
                    d.distol != null ? '${d.distol} mmHg' : '- mmHg',
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _sectionHeader('Status Gula Darah'),
          const SizedBox(height: 8),
          _gulaDarahRow(d.statusGulaDarah),
          const SizedBox(height: 12),
          _sectionHeader('Status Rujukan'),
          const SizedBox(height: 8),
          _rujukanRow(d.statusRujukan),
        ],
      ),
    );
  }
}

class FaktorRisikoDetailCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const FaktorRisikoDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    final merokok = d.faktorRisikoMerokok;
    final kurangAktifitas = d.faktorRisikoKurangAktifitas;

    if (merokok == null && kurangAktifitas == null) {
      return const SizedBox.shrink();
    }

    final isMerokok = merokok == 'ya';
    final isKurangAktifitas = kurangAktifitas == 'ya';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle('Faktor Risiko'),
          const SizedBox(height: 12),
          if (isMerokok) _statusRow('Merokok', 'Ya'),
          if (isMerokok && isKurangAktifitas) const SizedBox(height: 8),
          if (isKurangAktifitas) _statusRow('Kurang Aktifitas', 'Ya'),
          if (!isMerokok && !isKurangAktifitas)
            Text(
              'Tidak ada faktor risiko.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class CatatanPetugasDetailCard extends StatelessWidget {
  final PemeriksaanPosbinduDetailResponse data;

  const CatatanPetugasDetailCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final d = data;
    final hasKeluhan = d.keluhan != null && d.keluhan!.isNotEmpty;
    final hasSaran = d.saran != null && d.saran!.isNotEmpty;
    final hasCatatan = d.catatan != null && d.catatan!.isNotEmpty;
    final hasRiwayat =
        d.riwayatPenyakitKeluarga != null &&
        d.riwayatPenyakitKeluarga!.isNotEmpty;

    if (!hasKeluhan && !hasSaran && !hasCatatan && !hasRiwayat) {
      return const SizedBox.shrink();
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_outlined,
                size: 16,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 8),
              _cardTitle('Catatan Petugas'),
            ],
          ),
          const SizedBox(height: 12),
          if (hasKeluhan) ...[
            _noteSection('Keluhan', d.keluhan!),
            const SizedBox(height: 12),
          ],
          if (hasSaran) ...[
            _noteSection('Saran', d.saran!),
            const SizedBox(height: 12),
          ],
          if (hasCatatan) ...[
            _noteSection('Catatan', d.catatan!),
            const SizedBox(height: 12),
          ],
          if (hasRiwayat)
            _noteSection('Riwayat Penyakit Keluarga', d.riwayatPenyakitKeluarga!),
        ],
      ),
    );
  }
}

Widget _cardTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );
}

Widget _sectionHeader(String title) {
  return Text(
    title,
    style: GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _posbinduBlue,
      letterSpacing: 0.5,
    ),
  );
}

Widget _antropometriRow(dynamic icon, String label, String value) {
  final iconWidget = icon is IconData
      ? Icon(icon, size: 16, color: const Color(0xFF475569))
      : SvgPicture.asset(icon, width: 16, height: 16);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      children: [
        iconWidget,
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF475569),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget _statusRow(String label, String value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget _gulaDarahRow(String? status) {
  final color = posbinduStatusColor(status);
  return Row(
    children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(
        posbinduStatusLabel(status),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}

Widget _rujukanRow(String? status) {
  final isRujukan = status == 'ya';
  return Row(
    children: [
      Icon(
        isRujukan ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        size: 16,
        color: isRujukan ? const Color(0xFFFFA726) : const Color(0xFF43A047),
      ),
      const SizedBox(width: 8),
      Text(
        isRujukan ? 'Ya' : 'Tidak',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isRujukan ? const Color(0xFFFFA726) : const Color(0xFF43A047),
        ),
      ),
    ],
  );
}

Widget _noteSection(String title, String content) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          content,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );
}
