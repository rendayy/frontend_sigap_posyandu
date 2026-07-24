import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/widgets/balita/pemantauan_card.dart';

PemantauanBalitaItem _makeItem({
  double? lingkarKepala,
  double? lingkarLengan,
  String? imunisasi,
  String? vitaminA,
}) {
  return PemantauanBalitaItem(
    idPantau: 'p-001',
    idKader: 'k-001',
    namaKader: 'Zidan Kusuma',
    no: 1,
    tanggalPantau: '2026-07-18',
    usiaBulan: 34,
    berat: 12.0,
    tinggi: 80.0,
    lingkarKepala: lingkarKepala,
    lingkarLengan: lingkarLengan,
    statusGizi: 'gizi_kurang',
    imunisasi: imunisasi,
    vitaminA: vitaminA,
  );
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('PemantauanCard', () {
    testWidgets('renders all data fields', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanCard(item: _makeItem(lingkarKepala: 48.0)),
      ));

      expect(find.textContaining('18 Juli 2026'), findsOneWidget);
      expect(find.text('12.0 kg'), findsOneWidget);
      expect(find.text('80.0 cm'), findsOneWidget);
      expect(find.text('48.0 cm'), findsOneWidget);
      expect(find.textContaining('Kurang'), findsOneWidget);
    });

    testWidgets('shows "-" when lingkarKepala is null', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanCard(item: _makeItem(lingkarKepala: null)),
      ));

      expect(find.text('- cm'), findsOneWidget);
    });

    testWidgets('renders avatar with usia bulan and "bln"', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanCard(item: _makeItem()),
      ));

      expect(find.text('34'), findsOneWidget);
      expect(find.text('bln'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_buildTestApp(
        PemantauanCard(item: _makeItem(), onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(PemantauanCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders chevron arrow icon', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        PemantauanCard(item: _makeItem()),
      ));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}