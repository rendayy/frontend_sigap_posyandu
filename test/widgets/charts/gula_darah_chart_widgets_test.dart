import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_header_card.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart_card.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_history_section.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart_skeleton.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_status.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

void main() {
  group('GulaDarahStatus Helpers', () {
    test('gulaDarahStatusColor returns correct colors', () {
      expect(gulaDarahStatusColor('normal'), const Color(0xFF43A047));
      expect(gulaDarahStatusColor('pra_diabetes'), const Color(0xFFFFA726));
      expect(gulaDarahStatusColor('diabetes'), const Color(0xFFB71C1C));
      expect(gulaDarahStatusColor(null), const Color(0xFF64748B));
      expect(gulaDarahStatusColor('unknown'), const Color(0xFF64748B));
    });

    test('gulaDarahStatusLabel returns correct labels', () {
      expect(gulaDarahStatusLabel('normal'), 'Normal');
      expect(gulaDarahStatusLabel('pra_diabetes'), 'Pra-diabetes');
      expect(gulaDarahStatusLabel('diabetes'), 'Diabetes');
      expect(gulaDarahStatusLabel(null), 'Belum ada data');
      expect(gulaDarahStatusLabel('unknown'), 'Belum ada data');
    });

    test('determineGulaDarahStatus returns correct zone', () {
      final zones = [
        GulaDarahZone(
          status: 'normal',
          label: 'Normal',
          min: 0,
          max: 126,
          color: '#43A047',
        ),
        GulaDarahZone(
          status: 'pra_diabetes',
          label: 'Pra-diabetes',
          min: 126,
          max: 200,
          color: '#FFA726',
        ),
        GulaDarahZone(
          status: 'diabetes',
          label: 'Diabetes',
          min: 200,
          max: 999,
          color: '#B71C1C',
        ),
      ];

      expect(determineGulaDarahStatus(100, zones)?.status, 'normal');
      expect(determineGulaDarahStatus(150, zones)?.status, 'pra_diabetes');
      expect(determineGulaDarahStatus(250, zones)?.status, 'diabetes');
      expect(determineGulaDarahStatus(50, zones)?.status, 'normal');
    });

    test('parseHexColor parses hex colors correctly', () {
      expect(parseHexColor('#43A047'), const Color(0xFF43A047));
      expect(parseHexColor('#FFA726'), const Color(0xFFFFA726));
      expect(parseHexColor('#B71C1C'), const Color(0xFFB71C1C));
      expect(parseHexColor('43A047'), const Color(0xFF43A047));
    });
  });

  group('GulaDarahHeaderCard', () {
    testWidgets('renders with valid data', (WidgetTester tester) async {
      final data = GulaDarahChartData(
        gulaDarahZones: [
          GulaDarahZone(
            status: 'normal',
            label: 'Normal',
            min: 0,
            max: 126,
            color: '#43A047',
          ),
        ],
        label: 'Normal',
        latestGulaDarah: 105,
        latestStatus: 'normal',
        measurements: [
          GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
          GulaDarahMeasurement(gulaDarah: 105, tanggalPeriksa: '2026-06-27'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GulaDarahHeaderCard(data: data)),
        ),
      );

      expect(find.text('Gula Darah'), findsOneWidget);
      expect(find.text('105 mg/dL'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('renders with null latestGulaDarah', (
      WidgetTester tester,
    ) async {
      final data = GulaDarahChartData(
        gulaDarahZones: [
          GulaDarahZone(
            status: 'normal',
            label: 'Normal',
            min: 0,
            max: 126,
            color: '#43A047',
          ),
        ],
        label: 'Normal',
        latestGulaDarah: null,
        latestStatus: null,
        measurements: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: GulaDarahHeaderCard(data: data)),
        ),
      );

      expect(find.text('Gula Darah'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.text('Belum ada data'), findsOneWidget);
      expect(find.text('0x'), findsOneWidget);
    });
  });

  group('GulaDarahChartCard', () {
    testWidgets('renders chart with measurements', (WidgetTester tester) async {
      final data = GulaDarahChartData(
        gulaDarahZones: [
          GulaDarahZone(
            status: 'normal',
            label: 'Normal',
            min: 0,
            max: 126,
            color: '#43A047',
          ),
          GulaDarahZone(
            status: 'pra_diabetes',
            label: 'Pra-diabetes',
            min: 126,
            max: 200,
            color: '#FFA726',
          ),
        ],
        label: 'Normal',
        latestGulaDarah: 105,
        latestStatus: 'normal',
        measurements: [
          GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
          GulaDarahMeasurement(gulaDarah: 105, tanggalPeriksa: '2026-06-27'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GulaDarahChartCard(
              data: data,
              currentMeasurements: data.measurements,
            ),
          ),
        ),
      );

      expect(find.text('Grafik Gula Darah'), findsOneWidget);
      expect(find.text('Gula darah (mg/dL) vs zona status'), findsOneWidget);
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('Pra-diabetes'), findsWidgets);
    });
  });

  group('GulaDarahHistorySection', () {
    testWidgets('renders history items with pagination', (
      WidgetTester tester,
    ) async {
      final measurements = [
        GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
        GulaDarahMeasurement(gulaDarah: 105, tanggalPeriksa: '2026-06-27'),
        GulaDarahMeasurement(gulaDarah: 110, tanggalPeriksa: '2026-07-01'),
        GulaDarahMeasurement(gulaDarah: 115, tanggalPeriksa: '2026-07-05'),
        GulaDarahMeasurement(gulaDarah: 120, tanggalPeriksa: '2026-07-10'),
        GulaDarahMeasurement(gulaDarah: 125, tanggalPeriksa: '2026-07-15'),
      ];

      final zones = [
        GulaDarahZone(
          status: 'normal',
          label: 'Normal',
          min: 0,
          max: 126,
          color: '#43A047',
        ),
      ];

      int currentPage = 1;
      int totalPages = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GulaDarahHistorySection(
              measurements: measurements,
              zones: zones,
              currentPage: currentPage,
              totalPages: totalPages,
              onPrev: () {
                if (currentPage > 1) {
                  currentPage--;
                }
              },
              onNext: () {
                if (currentPage < totalPages) {
                  currentPage++;
                }
              },
            ),
          ),
        ),
      );

      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsNothing);
      expect(find.text('Selanjutnya'), findsOneWidget);
    });

    testWidgets('hides prev button on first page', (WidgetTester tester) async {
      final measurements = [
        GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
      ];

      final zones = [
        GulaDarahZone(
          status: 'normal',
          label: 'Normal',
          min: 0,
          max: 126,
          color: '#43A047',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GulaDarahHistorySection(
              measurements: measurements,
              zones: zones,
              currentPage: 1,
              totalPages: 1,
              onPrev: () {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sebelumnya'), findsNothing);
      expect(find.text('1 / 1'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsNothing);
    });
  });

  group('GulaDarahChartSkeleton', () {
    testWidgets('renders skeleton widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GulaDarahChartSkeleton())),
      );

      // Check that skeleton renders without errors
      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });
}
