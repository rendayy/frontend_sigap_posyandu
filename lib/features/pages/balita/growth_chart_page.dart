import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/charts/growth_chart.dart';

class GrowthChartPage extends StatefulWidget {
  final GrowthChartResponse data;

  const GrowthChartPage({super.key, required this.data});

  @override
  State<GrowthChartPage> createState() => _GrowthChartPageState();
}

class _GrowthChartPageState extends State<GrowthChartPage> {
  int _selectedRange = 0;

  List<int> get _ageRange {
    return _selectedRange == 0 ? [0, 24] : [24, 60];
  }

  String get _rangeLabel {
    return _selectedRange == 0 ? '0 - 24 Bulan' : '24 - 60 Bulan';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Grafik Pertumbuhan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _statusLabel(d.latestStatus),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(d.latestStatus),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${d.measurements.length}x pengukuran',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_chartTypeLabel(d.chartType)} — ${d.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (d.standardSource.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        d.standardSource,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 0, label: Text('0 - 24 Bulan')),
                              ButtonSegment(value: 1, label: Text('24 - 60 Bulan')),
                            ],
                            selected: {_selectedRange},
                            onSelectionChanged: (v) {
                              setState(() => _selectedRange = v.first);
                            },
                            style: ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              textStyle: WidgetStatePropertyAll(
                                GoogleFonts.plusJakartaSans(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fase Pertumbuhan: $_rangeLabel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GrowthChart(
                      data: d,
                      ageRange: _ageRange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Riwayat Pengukuran',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...d.measurements.reversed.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _measurementStatusColor(m.statusGizi),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usia ${m.usiaBulan} bulan',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${_formatDate(m.tanggalPantau)} — ${m.berat} kg',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              _measurementStatusLabel(m.statusGizi),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _measurementStatusColor(m.statusGizi),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _chartTypeLabel(String type) {
    switch (type) {
      case 'BB/U': return 'Berat Badan / Usia';
      case 'TB/U': return 'Tinggi Badan / Usia';
      case 'BB/TB': return 'Berat Badan / Tinggi Badan';
      default: return type;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'gizi_baik': return 'Gizi Baik';
      case 'gizi_kurang': return 'Gizi Kurang';
      case 'gizi_buruk': return 'Gizi Buruk';
      case 'stunting': return 'Stunting';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'gizi_baik': return const Color(0xFF43A047);
      case 'gizi_kurang': return const Color(0xFFFFA726);
      case 'gizi_buruk': return const Color(0xFFEF5350);
      case 'stunting': return const Color(0xFFB71C1C);
      default: return AppColors.textSecondary;
    }
  }

  Color _measurementStatusColor(String status) {
    switch (status) {
      case 'gizi_baik': return const Color(0xFF43A047);
      case 'gizi_kurang': return const Color(0xFFFFA726);
      case 'gizi_buruk': return const Color(0xFFEF5350);
      case 'stunting': return const Color(0xFFB71C1C);
      default: return AppColors.textSecondary;
    }
  }

  String _measurementStatusLabel(String status) {
    switch (status) {
      case 'gizi_baik': return 'Baik';
      case 'gizi_kurang': return 'Kurang';
      case 'gizi_buruk': return 'Buruk';
      case 'stunting': return 'Stunting';
      default: return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final monthIdx = int.tryParse(parts[1]) ?? 1;
      final month = monthIdx >= 1 && monthIdx <= 12 ? months[monthIdx - 1] : parts[1];
      return '${parts[2]} $month ${parts[0]}';
    } catch (_) {
      return dateStr;
    }
  }
}
