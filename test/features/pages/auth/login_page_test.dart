import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/features/pages/auth/login_page.dart';

Widget _buildTestApp() {
  return MaterialApp(
    home: const LoginPage(),
    routes: {
      '/home': (_) => const Scaffold(body: Text('Home Page')),
      '/balita': (_) => const Scaffold(body: Text('Balita Page')),
    },
  );
}

void main() {
  testWidgets('renders title, subtitle, form fields, and button', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk ke SIGAP Posyandu Warga'), findsOneWidget);
    expect(find.text('NIK'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Lupa Kata Sandi?'), findsOneWidget);
  });

  testWidgets('password visibility toggle works', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    var textField = tester.widget<TextField>(find.byType(TextField).last);
    expect(textField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    textField = tester.widget<TextField>(find.byType(TextField).last);
    expect(textField.obscureText, isFalse);

    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();

    textField = tester.widget<TextField>(find.byType(TextField).last);
    expect(textField.obscureText, isTrue);
  });

  testWidgets('Lupa Kata Sandi shows snackbar', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    await tester.tap(find.text('Lupa Kata Sandi?'));
    await tester.pump();

    expect(find.text('Fitur akan segera hadir'), findsOneWidget);
  });

  testWidgets('Masuk button is disabled with empty form', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Masuk button is enabled with valid NIK and password', (tester) async {
    await tester.pumpWidget(_buildTestApp());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, '1234567890123456');
    await tester.enterText(fields.last, 'password123');
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);
  });
}
