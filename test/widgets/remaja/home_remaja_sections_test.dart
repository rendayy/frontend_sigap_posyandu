import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_sections.dart';

void main() {
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
}
