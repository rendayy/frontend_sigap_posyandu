import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/widgets/posbindu/home_posbindu_sections.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

void main() {
  group('GulaDarahCard', () {
    testWidgets('renders content when data is available', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GulaDarahCard(
              gulaDarahSewaktu: 110,
              statusGulaDarah: 'normal',
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Gula Darah Sewaktu'), findsOneWidget);
      expect(find.text('110'), findsOneWidget);
      expect(find.text('mg/dL'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('renders skeleton when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GulaDarahCard(
              gulaDarahSewaktu: null,
              statusGulaDarah: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonWidget), findsWidgets);
      expect(find.text('110'), findsNothing);
    });

    testWidgets('handles null gulaDarahSewaktu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GulaDarahCard(
              gulaDarahSewaktu: null,
              statusGulaDarah: null,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsOneWidget);
    });
  });

  group('FaktorRisikoCard', () {
    testWidgets('renders risk factor information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FaktorRisikoCard(
              faktorRisikoMerokok: 'tidak',
              faktorRisikoKurangAktifitas: 'ya',
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Faktor Risiko Gaya Hidup'), findsOneWidget);
      expect(find.text('Merokok'), findsOneWidget);
      expect(find.text('Kurang Aktifitas'), findsOneWidget);
      expect(find.text('Tidak'), findsOneWidget);
      expect(find.text('Ya'), findsOneWidget);
    });

    testWidgets('renders skeleton when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FaktorRisikoCard(
              faktorRisikoMerokok: null,
              faktorRisikoKurangAktifitas: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });
}
