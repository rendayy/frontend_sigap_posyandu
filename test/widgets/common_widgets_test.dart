import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/widgets/common/primary_button.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('renders text and is tappable when not loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Login',
            onPressed: () => tapped = true,
          ),
        ),
      ));

      expect(find.text('Login'), findsOneWidget);
      await tester.tap(find.text('Login'));
      expect(tapped, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Login',
            loading: true,
          ),
        ),
      ));

      expect(find.text('Login'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is disabled when loading', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Login',
            onPressed: () => tapped = true,
            loading: true,
          ),
        ),
      ));

      await tester.tap(find.byType(CircularProgressIndicator));
      expect(tapped, isFalse);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PrimaryButton(text: 'Disabled'),
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });
  });

  group('SkeletonWidget', () {
    testWidgets('renders with given dimensions', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SkeletonWidget(width: 100, height: 20),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });

  group('OfflineBanner', () {
    testWidgets('shows "Menampilkan data tersimpan" and "Hubungkan" button',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: OfflineBanner(onTap: () {})),
      ));

      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('shows spinner when isReconnecting', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: OfflineBanner(isReconnecting: true)),
      ));

      expect(find.text('Hubungkan'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('calls onTap when Hubungkan is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: OfflineBanner(onTap: () => tapped = true)),
      ));

      await tester.tap(find.text('Hubungkan'));
      expect(tapped, isTrue);
    });
  });

  group('StatusGiziBadge', () {
    for (final entry in [
      ('baik', 'Baik'),
      ('kurang', 'Kurang'),
      ('buruk', 'Buruk'),
      ('stunting', 'Stunting'),
      ('unknown', 'Tidak Diketahui'),
    ]) {
      testWidgets('shows "${entry.$2}" for status "${entry.$1}"',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: StatusGiziBadge(status: entry.$1)),
        ));

        expect(find.textContaining(entry.$2), findsOneWidget);
      });
    }
  });
}
