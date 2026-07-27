import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/widgets/remaja/kegiatan_remaja_card.dart';

KegiatanRemajaItem _makeItem({
  String jenisKegiatan = 'edukasi',
  String status = 'rencana',
}) {
  return KegiatanRemajaItem(
    idKegiatan: '0ec11841-bd2b-411b-8ad8-f95beddde51f',
    jenisKegiatan: jenisKegiatan,
    namaKegiatan: 'Penyuluhan Gizi',
    no: 1,
    status: status,
    tanggal: '2026-07-31',
    tempat: 'Aula Posyandu Melati',
    waktu: '09:00:00',
  );
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('KegiatanRemajaCard', () {
    testWidgets('renders all data fields', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem()),
      ));

      expect(find.text('Penyuluhan Gizi'), findsOneWidget);
      expect(find.text('31 Juli 2026'), findsOneWidget);
      expect(find.text('Aula Posyandu Melati'), findsOneWidget);
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Rencana'), findsOneWidget);
    });

    testWidgets('renders avatar icon based on jenis kegiatan', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem(jenisKegiatan: 'edukasi')),
      ));

      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('renders skrining icon for skrining jenis', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem(jenisKegiatan: 'skrining')),
      ));

      expect(find.byIcon(Icons.health_and_safety), findsOneWidget);
    });

    testWidgets('renders badge jenis with correct label', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem(jenisKegiatan: 'skrining')),
      ));

      expect(find.text('Skrining'), findsOneWidget);
    });

    testWidgets('renders badge status with correct label', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem(status: 'selesai')),
      ));

      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem(), onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(KegiatanRemajaCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders chevron arrow icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        KegiatanRemajaCard(item: _makeItem()),
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
