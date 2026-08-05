import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class GulaDarahChart extends StatelessWidget {
  final GulaDarahChartData data;
  final List<GulaDarahMeasurement> currentMeasurements;
  final bool compact;

  const GulaDarahChart({
    super.key,
    required this.data,
    required this.currentMeasurements,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final measurements = currentMeasurements;
    final sorted = List<GulaDarahMeasurement>.from(measurements)
      ..sort((a, b) => a.tanggalPeriksa.compareTo(b.tanggalPeriksa));

    final yMax = 250.0;
    final yMin = 0.0;
    final xMax = sorted.length > 1 ? (sorted.length - 1).toDouble() : 1.0;
    final xMin = 0.0;

    final xLabels = <int, String>{};
    for (int i = 0; i < sorted.length; i++) {
      xLabels[i] = _formatDateShort(sorted[i].tanggalPeriksa);
    }

    return SizedBox(
      height: compact ? 200 : 320,
      child: LineChart(
        LineChartData(
          minX: xMin,
          maxX: xMax,
          minY: yMin,
          maxY: yMax,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: !compact,
            drawVerticalLine: true,
            horizontalInterval: 50,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: const Color(0xFFE2E8F0),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: const Color(0xFFE2E8F0),
                strokeWidth: 1,
              );
            },
            checkToShowHorizontalLine: (value) => value >= yMin && value <= yMax,
            checkToShowVerticalLine: (value) => value >= xMin && value <= xMax,
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              axisNameWidget: compact ? null : _buildAxisLabel('mg/dL'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 50,
                getTitlesWidget: (value, _) => _buildValueLabel('${value.toInt()}'),
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: compact ? null : _buildAxisLabel('Tanggal Periksa'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: 1,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (xLabels.containsKey(idx)) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        xLabels[idx]!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: compact ? null : _buildAxisLabel('Gula Darah (mg/dL)'),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 50,
                getTitlesWidget: (value, _) => _buildValueLabel('${value.toInt()}'),
              ),
            ),
          ),
          borderData: FlBorderData(
            show: !compact,
            border: const Border(
              bottom: BorderSide(color: Color(0xFF4B5563)),
              left: BorderSide(color: Color(0xFF4B5563)),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          lineBarsData: _buildLineBars(sorted, xMin, xMax),
          rangeAnnotations: _buildRangeAnnotations(data.gulaDarahZones, yMax),
          lineTouchData: const LineTouchData(enabled: false),
        ),
        duration: const Duration(milliseconds: 300),
      ),
    );
  }

  RangeAnnotations _buildRangeAnnotations(List<GulaDarahZone> zones, double chartMaxY) {
    return RangeAnnotations(
      horizontalRangeAnnotations: zones.map((zone) {
        final y2 = zone.max.toDouble() > chartMaxY ? chartMaxY : zone.max.toDouble();
        return HorizontalRangeAnnotation(
          y1: zone.min.toDouble(),
          y2: y2,
          color: _parseColor(zone.color).withValues(alpha: 0.12),
        );
      }).toList(),
    );
  }

  List<LineChartBarData> _buildLineBars(
    List<GulaDarahMeasurement> sorted,
    double xMin,
    double xMax,
  ) {
    final bars = <LineChartBarData>[];

    if (sorted.isNotEmpty) {
      bars.add(
        LineChartBarData(
          spots: sorted
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.gulaDarah.toDouble()))
              .toList(),
          isCurved: true,
          preventCurveOverShooting: true,
          color: const Color(0xFF1E40AF),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, _, _) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF1E40AF),
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      );
    }

    return bars;
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _formatDateShort(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final monthIdx = int.tryParse(parts[1]) ?? 1;
      final month = monthIdx >= 1 && monthIdx <= 12 ? months[monthIdx - 1] : parts[1];
      return '${parts[2]} $month';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildAxisLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildValueLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
    );
  }
}
