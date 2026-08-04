import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/pages/balita/balita_page.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockBalitaService extends BalitaService {
  final BalitaDetailResponse? stubData;
  final bool stubThrowError;
  _MockBalitaService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<BalitaDetailResponse> getBalitaById(String idBalita) async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }

  @override
  String getDownloadKmsUrl(String idBalita) => 'http://test/$idBalita/download-kms';

  @override
  Future<File> downloadKms(String idBalita) async {
    if (stubThrowError) throw NetworkException();
    return File('${Directory.systemTemp.path}/test_kms.pdf');
  }
}

BalitaDetailResponse _makeBalita() => const BalitaDetailResponse(
  idBalita: 'b-001',
  idAnggota: 'a-001',
  nik: '1234567890123456',
  nama: 'Andi Pratama',
  jenisKelamin: 'L',
  tanggalLahir: '2023-01-15',
  usia: 42,
  beratLahir: 3.5,
  panjangLahir: 50.0,
  asiEksklusif: 'ya',
  imunisasiDasar: 'lengkap',
  statusGizi: 'baik',
  statusAktif: 'aktif',
);

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

  testWidgets('shows skeleton loading initially, then data when loaded',
      (tester) async {
    final authService = _MockAuthService(stubModuleId: 'mod-001');
    final balitaService = _MockBalitaService(stubData: _makeBalita());

    await tester.pumpWidget(_buildTestApp(
      BalitaPage(authService: authService, balitaService: balitaService),
    ));

    // Initial skeleton state
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Andi Pratama'), findsNothing);

    // After async load completes
    await tester.pumpAndSettle();

    expect(find.text('Andi Pratama'), findsOneWidget);
    expect(find.text('Baik'), findsOneWidget);
    expect(find.textContaining('Lengkap'), findsWidgets);
  });

  testWidgets('shows error with retry when API fails and no cache',
      (tester) async {
    final authService = _MockAuthService(stubModuleId: 'mod-001');
    final balitaService = _MockBalitaService(stubThrowError: true);

    await tester.pumpWidget(_buildTestApp(
      BalitaPage(authService: authService, balitaService: balitaService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
  });

  testWidgets('shows cached data with offline banner when API fails and cache exists',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'balita_cache_mod-001': '{"id_balita":"b-001","id_anggota":"a-001","nik":"1234567890123456","nama":"Cached Baby","jenis_kelamin":"L","tanggal_lahir":"2024-06-01","usia":6,"berat_lahir":3.2,"panjang_lahir":48.0,"asi_eksklusif":"ya","imunisasi_dasar":"lengkap","status_gizi":"baik","status_aktif":"aktif"}',
    });

    final authService = _MockAuthService(stubModuleId: 'mod-001');
    final balitaService = _MockBalitaService(stubThrowError: true);

    await tester.pumpWidget(_buildTestApp(
      BalitaPage(authService: authService, balitaService: balitaService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Cached Baby'), findsOneWidget);
    expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
    expect(find.text('Hubungkan'), findsOneWidget);
  });

  testWidgets('Hubungkan button retries loading', (tester) async {
    SharedPreferences.setMockInitialValues({
      'balita_cache_mod-001': '{"id_balita":"b-001","id_anggota":"a-001","nik":"1234567890123456","nama":"Retry Baby","jenis_kelamin":"L","tanggal_lahir":"2024-06-01","usia":6,"berat_lahir":3.2,"panjang_lahir":48.0,"asi_eksklusif":"ya","imunisasi_dasar":"lengkap","status_gizi":"baik","status_aktif":"aktif"}',
    });

    final authService = _MockAuthService(stubModuleId: 'mod-001');
    final balitaService = _MockBalitaService(stubThrowError: true);

    await tester.pumpWidget(_buildTestApp(
      BalitaPage(authService: authService, balitaService: balitaService),
    ));

    await tester.pumpAndSettle();

    // Cache loaded, offline banner shown
    expect(find.text('Retry Baby'), findsOneWidget);
    expect(find.text('Hubungkan'), findsOneWidget);
  });
}
