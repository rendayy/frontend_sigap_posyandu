import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class GrowthChart extends StatelessWidget {
  final GrowthChartResponse data;
  final bool compact;
  final List<int>? ageRange;

  const GrowthChart({
    super.key,
    required this.data,
    this.compact = false,
    this.ageRange,
  });

  @override
  Widget build(BuildContext context) {
    final ageMin = ageRange?.first ?? 0;
    final ageMax = ageRange?.last ?? 60;
    final isRange0_24 = ageMin == 0 && ageMax == 24;
    final weightMin = isRange0_24 ? 0.0 : 5.0;
    final weightMax = isRange0_24 ? 18.0 : 30.0;
    final gender = data.jenisKelamin;
    final themeColor = gender == 'L'
        ? const Color(0xFF1E40AF)
        : const Color(0xFFBE185D);

    final curveKeys = [
      '-3SD', '-2SD', '-1SD', 'median', '+1SD', '+2SD', '+3SD',
    ];

    final filteredMeasurements = data.measurements
        .where((m) => m.usiaBulan >= ageMin && m.usiaBulan <= ageMax)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!compact) ...[
          Text(
            'Grafik ${_chartTypeLabel(data.chartType)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: compact ? 200 : 320,
          child: LineChart(
            LineChartData(
              minX: ageMin.toDouble(),
              maxX: ageMax.toDouble(),
              minY: weightMin,
              maxY: weightMax,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: !compact,
                drawVerticalLine: true,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  final isMajor = value % 2 == 0;
                  return FlLine(
                    color: isMajor
                        ? const Color(0xFF555555)
                        : const Color(0xFFB0B0B0),
                    strokeWidth: isMajor ? 0.5 : 0.25,
                  );
                },
                getDrawingVerticalLine: (value) {
                  final isMajor = value % 2 == 0;
                  return FlLine(
                    color: isMajor
                        ? const Color(0xFF555555)
                        : const Color(0xFFB0B0B0),
                    strokeWidth: isMajor ? 0.5 : 0.25,
                  );
                },
                checkToShowHorizontalLine: (value) {
                  return value >= weightMin && value <= weightMax;
                },
                checkToShowVerticalLine: (value) {
                  return value >= ageMin && value <= ageMax;
                },
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  axisNameWidget: compact
                      ? null
                      : Text(
                          'Berat (kg)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 2,
                    getTitlesWidget: (value, _) {
                      if (value % 2 == 0) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: compact
                      ? null
                      : Text(
                          'Usia (Bulan)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, _) {
                      if (value % 2 == 0) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: compact
                      ? null
                      : Text(
                          'Berat (kg)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: 2,
                    getTitlesWidget: (value, _) {
                      if (value % 2 == 0) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: !compact,
                border: const Border(
                  bottom: BorderSide(color: Color(0xFF4B5563)),
                  left: BorderSide(color: Color(0xFF4B5563)),
                  right: BorderSide(color: Color(0xFF4B5563)),
                  top: BorderSide.none,
                ),
              ),
              lineBarsData: _buildCurveSpots(
                curveKeys, filteredMeasurements, themeColor, ageMin, ageMax,
              ),
              betweenBarsData: _buildBetweenBars(curveKeys, ageMin, ageMax),
              lineTouchData: const LineTouchData(enabled: false),
            ),
            duration: const Duration(milliseconds: 300),
          ),
        ),
        if (!compact) ...[
          const SizedBox(height: 12),
          _buildLegend(),
        ],
      ],
    );
  }

  List<LineChartBarData> _buildCurveSpots(
    List<String> curveKeys,
    List<GrowthMeasurement> measurements,
    Color themeColor,
    int ageMin,
    int ageMax,
  ) {
    final spots = <LineChartBarData>[];

    for (int i = 0; i < curveKeys.length; i++) {
      final key = curveKeys[i];
      final curve = data.standardCurves[key];
      if (curve == null) continue;

      final filtered = curve.where((p) => p.usia >= ageMin && p.usia <= ageMax).toList();
      if (filtered.isEmpty) continue;

      spots.add(
        LineChartBarData(
          spots: filtered
              .map((p) => FlSpot(p.usia.toDouble(), p.nilai))
              .toList(),
          isCurved: true,
          preventCurveOverShooting: true,
          color: _curveColor(i),
          barWidth: 0.75,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
        ),
      );
    }

    if (measurements.isNotEmpty) {
      final sorted = List<GrowthMeasurement>.from(measurements)
        ..sort((a, b) => a.usiaBulan.compareTo(b.usiaBulan));

      spots.add(
        LineChartBarData(
          spots: sorted
              .map((m) => FlSpot(m.usiaBulan.toDouble(), m.berat))
              .toList(),
          isCurved: true,
          preventCurveOverShooting: true,
          color: themeColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, _, _) {
              return FlDotCirclePainter(
                radius: 3,
                color: themeColor,
                strokeWidth: 0.75,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );
    }

    return spots;
  }

  List<BetweenBarsData> _buildBetweenBars(
    List<String> curveKeys,
    int ageMin,
    int ageMax,
  ) {
    final validIndices = <int>[];
    for (int i = 0; i < curveKeys.length; i++) {
      final curve = data.standardCurves[curveKeys[i]];
      if (curve != null && curve.any((p) => p.usia >= ageMin && p.usia <= ageMax)) {
        validIndices.add(i);
      }
    }

    final bands = <List<int>>[
      [0, 1],  // -3SD to -2SD
      [1, 2],  // -2SD to -1SD
      [2, 4],  // -1SD to +1SD
      [4, 5],  // +1SD to +2SD
      [5, 6],  // +2SD to +3SD
    ];

    final bandColors = [
      const Color(0xCCFCD34D),  // Yellow
      const Color(0xCC6AC96A),  // Light green
      const Color(0xCC2E7D32),  // Dark green
      const Color(0xCC6AC96A),  // Light green
      const Color(0xCCFCD34D),  // Yellow
    ];

    final result = <BetweenBarsData>[];
    for (int b = 0; b < bands.length; b++) {
      final fromIdx = validIndices.indexOf(bands[b][0]);
      final toIdx = validIndices.indexOf(bands[b][1]);
      if (fromIdx >= 0 && toIdx >= 0) {
        result.add(BetweenBarsData(
          fromIndex: fromIdx,
          toIndex: toIdx,
          color: bandColors[b],
        ));
      }
    }
    return result;
  }

  Color _curveColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFEF4444);
      case 1: return const Color(0xFF000000);
      case 2: return const Color(0xFF000000);
      case 3: return const Color(0xFF000000);
      case 4: return const Color(0xFF000000);
      case 5: return const Color(0xFF000000);
      case 6: return const Color(0xFFEF4444);
      default: return const Color(0xFF000000);
    }
  }

  String _chartTypeLabel(String type) {
    switch (type) {
      case 'BB/U': return 'Berat Badan / Usia';
      case 'TB/U': return 'Tinggi Badan / Usia';
      case 'BB/TB': return 'Berat Badan / Tinggi Badan';
      default: return type;
    }
  }

  Widget _buildLegend() {
    final items = [
      ('Normal (-1 s/d +1 SD)', const Color(0xCC2E7D32)),
      ('Waspada (Kurus/Gemuk)', const Color(0xCCFCD34D)),
      ('Bahaya (Sangat Kurus/Sangat Gemuk)', const Color(0xCCEF5350)),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.$2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  item.$1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
