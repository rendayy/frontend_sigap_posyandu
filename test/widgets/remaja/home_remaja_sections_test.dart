import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_sections.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_header.dart';
import 'package:frontend_posyandu/widgets/remaja/status_gizi_badge.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

void main() {
  testWidgets('ProfileSummaryCard displays BMI and status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileSummaryCard(
            bmi: 22.3,
            statusGizi: 'berat_badan_normal',
          ),
        ),
      ),
    );

    expect(find.text('22.3'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
  });

  testWidgets('ProfileSummaryCard shows skeleton when loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSummaryCard(isLoading: true)),
      ),
    );

    expect(find.byType(SkeletonWidget), findsWidgets);
  });

  testWidgets('QuickStatsGrid displays values correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: QuickStatsGrid(usia: 24, tinggiBadan: '165', beratBadan: '55'),
        ),
      ),
    );

    expect(find.text('24'), findsOneWidget);
    expect(find.text('165'), findsOneWidget);
    expect(find.text('55'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
  });

  testWidgets('InfoSectionCard displays details correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InfoSectionCard(
            sekolah: 'SMA Sidoarjo',
            kelas: 'Kelas 12',
            hobi: 'Melukis',
          ),
        ),
      ),
    );

    expect(find.text('SMA Sidoarjo'), findsOneWidget);
    expect(find.text('Kelas 12'), findsOneWidget);
    expect(find.text('Melukis'), findsOneWidget);
  });

  testWidgets('AnemiaCard displays ya status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnemiaCard(riwayatAnemia: 'ya')),
      ),
    );

    expect(find.text('Riwayat Anemia Terdeteksi'), findsOneWidget);
  });

  testWidgets('AnemiaCard displays tidak status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AnemiaCard(riwayatAnemia: 'tidak')),
      ),
    );

    expect(find.text('Bebas Anemia'), findsOneWidget);
  });

  testWidgets('GreetingSection displays module name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GreetingSection(
            name: 'Emma Myers',
            initials: 'E',
            moduleName: 'Remaja',
          ),
        ),
      ),
    );

    expect(find.text('Emma Myers'), findsOneWidget);
    expect(find.text('Remaja'), findsOneWidget);
  });
}
