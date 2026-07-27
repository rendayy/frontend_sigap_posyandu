import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/widgets/remaja/pemantauan_remaja_card.dart';

PemantauanRemajaItem _makeItem({
  double? beratBadan = 55.0,
  double? tinggiBadan = 160.0,
  int? gulaDarah,
}) {
  return PemantauanRemajaItem(
    no: 1,
    idPantauRemaja: 'pr-001',
    idKader: 'k-001',
    namaKader: 'Zidan Kusuma',
    namaPosyandu: 'Posyandu Melati',
    tanggalPeriksa: '2026-07-18',
    beratBadan: beratBadan,
    tinggiBadan: tinggiBadan,
    sistol: 110,
    distol: 70,
    gulaDarah: gulaDarah,
    statusGizi: 'berat_badan_normal',
    keluhan: 'Tidak ada',
    saran: 'Pertahankan',
  );
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('PemantauanRemajaCard', () {
    testWidgets('renders all data fields', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem(gulaDarah: 90)),
      ));

      expect(find.textContaining('18 Jul 2026'), findsOneWidget);
      expect(find.text('55.0 kg'), findsOneWidget);
      expect(find.text('160.0 cm'), findsOneWidget);
      expect(find.text('90 mg/dl'), findsOneWidget);
      expect(find.textContaining('Normal'), findsOneWidget);
    });

    testWidgets('hides gulaDarah when null', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem(gulaDarah: null)),
      ));

      expect(find.text('55.0 kg'), findsOneWidget);
      expect(find.text('160.0 cm'), findsOneWidget);
      expect(find.textContaining('mg/dl'), findsNothing);
    });

    testWidgets('shows "-" when beratBadan is null', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem(beratBadan: null)),
      ));

      expect(find.text('- kg'), findsOneWidget);
    });

    testWidgets('renders avatar with month and year from tanggalPeriksa', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem()),
      ));

      expect(find.text('Jul'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem(), onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(PemantauanRemajaCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders chevron arrow icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanRemajaCard(item: _makeItem()),
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
