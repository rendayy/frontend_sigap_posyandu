import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class GrafikBeratBadan extends StatelessWidget {
  final BeratBadanChartResponse data;

  const GrafikBeratBadan({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.measurements.length < 2) {
      return _buildInsufficientData();
    }

    final sorted = List<ChartMeasurement>.from(data.measurements)
      ..sort((a, b) => a.minggu.compareTo(b.minggu));

    final spots = sorted
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.nilai))
        .toList();

    final allY = [
      ...sorted.map((m) => m.nilai),
      ...data.batasAtas.map((r) => r.nilai),
      ...data.batasBawah.map((r) => r.nilai),
    ];
    final minY = allY.reduce((a, b) => a < b ? a : b);
    final maxY = allY.reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15;
    final yMin = (minY - padding).floorToDouble();
    final yMax = (maxY + padding).ceilToDouble();

    final n = sorted.length;
    final xMin = 0.0;
    final xMax = (n - 1).toDouble();

    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: spots,
        isCurved: true,
        preventCurveOverShooting: true,
        color: AppColors.chartPink,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, _, _, _) {
            return FlDotCirclePainter(
              radius: 4,
              color: AppColors.chartPink,
              strokeWidth: 1.5,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.chartPink.withValues(alpha: 0.3),
              AppColors.chartPink.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    ];

    if (data.batasAtas.length >= 2) {
      final atasSpots = List.generate(n, (i) {
        final v = _interpolasi(data.batasAtas, sorted[i].minggu);
        return FlSpot(i.toDouble(), v);
      });
      lineBars.add(LineChartBarData(
        spots: atasSpots,
        isCurved: true,
        color: const Color(0xFF94A3B8),
        barWidth: 1.5,
        dashArray: [5, 5],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    if (data.batasBawah.length >= 2) {
      final bawahSpots = List.generate(n, (i) {
        final v = _interpolasi(data.batasBawah, sorted[i].minggu);
        return FlSpot(i.toDouble(), v);
      });
      lineBars.add(LineChartBarData(
        spots: bawahSpots,
        isCurved: true,
        color: const Color(0xFF94A3B8),
        barWidth: 1.5,
        dashArray: [5, 5],
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (n - 1) * 55.0 + 80,
            height: 220,
            child: LineChart(
              LineChartData(
                minX: xMin,
                maxX: xMax,
                minY: yMin,
                maxY: yMax,
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calcInterval(yMin, yMax),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFE5E7EB),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    );
                  },
                  checkToShowHorizontalLine: (value) => value > yMin && value < yMax,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => _yTitle(value),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= n) return const SizedBox.shrink();
                        return Text(
                          '${sorted[idx].minggu}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: lineBars,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        if (spot.barIndex == 0) {
                          final idx = spot.spotIndex;
                          final point = sorted[idx];
                          return LineTooltipItem(
                            '${point.nilai.toStringAsFixed(1)} kg\nMinggu ${point.minggu}',
                            const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                ),
              ),
              duration: const Duration(milliseconds: 300),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Minggu kehamilan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildLegend(),
        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0x1A000000)),
        const SizedBox(height: 12),
        _buildRingkasan(),
      ],
    );
  }

  double _interpolasi(List<ChartReferencePoint> points, int target) {
    if (points.length == 1) return points[0].nilai;
    for (int i = 0; i < points.length - 1; i++) {
      if (target >= points[i].minggu && target <= points[i + 1].minggu) {
        final ratio = (target - points[i].minggu) / (points[i + 1].minggu - points[i].minggu);
        return points[i].nilai + ratio * (points[i + 1].nilai - points[i].nilai);
      }
    }
    if (target <= points.first.minggu) return points.first.nilai;
    return points.last.nilai;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(AppColors.chartPink, 'BB'),
        const SizedBox(width: 16),
        _legendLine('Batas Atas'),
        const SizedBox(width: 16),
        _legendLine('Batas Bawah'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _legendLine(String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 2, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildInsufficientData() {
    return Container(
      height: 220,
      alignment: Alignment.center,
      child: Text(
        'Data belum cukup untuk menampilkan grafik.\nMinimal 2 kunjungan diperlukan.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRingkasan() {
    final r = data.ringkasan;
    return Row(
      children: [
        _ringkasanKolom('Awal', '${r.awal.toStringAsFixed(1)} kg', AppColors.textPrimary),
        _ringkasanKolom('Terakhir', '${r.terakhir.toStringAsFixed(1)} kg', AppColors.ringkasanTerakhir),
        _ringkasanKolom(
          'Kenaikan',
          '${r.kenaikan >= 0 ? '+' : ''}${r.kenaikan.toStringAsFixed(1)} kg',
          r.kenaikan >= 0 ? AppColors.ringkasanKenaikanPositif : AppColors.chartRed,
        ),
      ],
    );
  }

  Widget _ringkasanKolom(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  double _calcInterval(double min, double max) {
    final range = max - min;
    if (range <= 4) return 1;
    if (range <= 10) return 2;
    return 5;
  }

  Widget _yTitle(double value) {
    return Text(
      value == value.truncateToDouble() ? '${value.toInt()}' : value.toStringAsFixed(1),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    );
  }
}
