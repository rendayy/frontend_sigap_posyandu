import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/widgets/common/pemantauan_item_card.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  group('PemantauanItemCard Tests', () {
    testWidgets('renders all data fields for balita', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PemantauanItemCard(
            date: '18 Juli 2026',
            status: 'gizi_kurang',
            avatarMain: '34',
            avatarSub: 'bln',
            avatarFg: Color(0xFFF97316),
            avatarBg: Color(0xFFFFF7ED),
            metrics: [
              PemantauanMetric(iconAsset: 'static/svg/ic_berat_badan.svg', text: '12.0 kg'),
              PemantauanMetric(iconAsset: 'static/svg/ic_tinggi_badan.svg', text: '80.0 cm'),
              PemantauanMetric(iconAsset: 'static/svg/ic_lingkar_kepala.svg', text: '48.0 cm'),
            ],
          ),
        ),
      );

      expect(find.text('18 Juli 2026'), findsOneWidget);
      expect(find.text('12.0 kg'), findsOneWidget);
      expect(find.text('80.0 cm'), findsOneWidget);
      expect(find.text('48.0 cm'), findsOneWidget);
      expect(find.textContaining('Kurang'), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      expect(find.text('bln'), findsOneWidget);
    });

    testWidgets('renders all data fields for remaja', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PemantauanItemCard(
            date: '18 Jul 2026',
            status: 'berat_badan_normal',
            avatarMain: 'Jul',
            avatarSub: '2026',
            avatarFg: Color(0xFF43A047),
            avatarBg: Color(0xFFE8F5E9),
            metrics: [
              PemantauanMetric(iconAsset: 'static/svg/ic_berat_badan.svg', text: '55.0 kg'),
              PemantauanMetric(iconAsset: 'static/svg/ic_tinggi_badan.svg', text: '160.0 cm'),
              PemantauanMetric(iconAsset: 'static/svg/ic_gula_darah.svg', text: '90 mg/dl'),
            ],
          ),
        ),
      );

      expect(find.text('18 Jul 2026'), findsOneWidget);
      expect(find.text('55.0 kg'), findsOneWidget);
      expect(find.text('160.0 cm'), findsOneWidget);
      expect(find.text('90 mg/dl'), findsOneWidget);
      expect(find.textContaining('Normal'), findsOneWidget);
      expect(find.text('Jul'), findsOneWidget);
      expect(find.text('2026'), findsOneWidget);
    });

    testWidgets('hides optional status when status is null', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PemantauanItemCard(
            date: '18 Jul 2026',
            status: null,
            avatarMain: 'Jul',
            avatarSub: '2026',
            avatarFg: Color(0xFF43A047),
            avatarBg: Color(0xFFE8F5E9),
            metrics: [
              PemantauanMetric(iconAsset: 'static/svg/ic_berat_badan.svg', text: '55.0 kg'),
            ],
          ),
        ),
      );

      // Status badge should not be present
      expect(find.textContaining('Normal'), findsNothing);
      expect(find.textContaining('Kurang'), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          PemantauanItemCard(
            date: '18 Jul 2026',
            avatarMain: '34',
            avatarSub: 'bln',
            avatarFg: const Color(0xFFF97316),
            avatarBg: const Color(0xFFFFF7ED),
            metrics: const [],
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(PemantauanItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders chevron arrow icon', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const PemantauanItemCard(
            date: '18 Jul 2026',
            avatarMain: '34',
            avatarSub: 'bln',
            avatarFg: Color(0xFFF97316),
            avatarBg: Color(0xFFFFF7ED),
            metrics: [],
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });
}
