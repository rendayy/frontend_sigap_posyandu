import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/features/pages/profil/edit_profile_page.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login Page')),
    },
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders form with nama and no_hp fields', (tester) async {
    // We can't inject CitizenService into EditProfilePage directly since it creates its own
    // Just test the form fields are rendered
    await tester.pumpWidget(_buildTestApp(const EditProfilePage()));

    // Wait for initial load to fail (no mock)
    await tester.pumpAndSettle();

    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('No. Telepon'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });

  testWidgets('shows validation error when nama is empty', (tester) async {
    await tester.pumpWidget(_buildTestApp(const EditProfilePage()));
    await tester.pumpAndSettle();

    // Clear the nama field and tap save
    final namaField = find.byType(TextFormField).first;
    await tester.enterText(namaField, '');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
  });

  testWidgets('shows validation error when nama exceeds 100 chars', (tester) async {
    await tester.pumpWidget(_buildTestApp(const EditProfilePage()));
    await tester.pumpAndSettle();

    final namaField = find.byType(TextFormField).first;
    await tester.enterText(namaField, 'A' * 101);
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('Nama maksimal 100 karakter'), findsOneWidget);
  });

  testWidgets('shows validation error when no_hp exceeds 15 digits', (tester) async {
    await tester.pumpWidget(_buildTestApp(const EditProfilePage()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.first, 'Nama Valid');
    await tester.enterText(fields.last, '1' * 16);
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(find.text('No. telepon maksimal 15 digit'), findsOneWidget);
  });
}
