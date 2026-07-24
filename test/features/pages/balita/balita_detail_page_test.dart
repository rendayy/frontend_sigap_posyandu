import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/services/balita/pemantauan_balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/balita/balita_detail_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPemantauanService extends PemantauanBalitaService {
  final PemantauanBalitaDetailResponse? stubData;
  final bool stubThrowError;
  _MockPemantauanService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<PemantauanBalitaDetailResponse> getDetail({
    required String idBalita,
    required String idPantau,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }
}

PemantauanBalitaDetailResponse _makeDetail() {
  return const PemantauanBalitaDetailResponse(
    idPantau: 'p-001',
    idKader: 'k-001',
    idCabang: 'c-001',
    namaKader: 'Zidan Kusuma',
    namaPosyandu: 'Posyandu Melati',
    tanggalPantau: '2026-06-15',
    usiaBulan: 6,
    berat: 12.8,
    tinggi: 86.0,
    lingkarKepala: 48.8,
    lingkarLengan: 18.2,
    statusGizi: 'gizi_baik',
    imunisasi: 'BCG, DPT, Polio, Campak',
    vitaminA: 'ya',
    keluhan: 'Keluhan diperbarui',
    saran: 'Saran diperbarui',
    createdAt: '2026-07-05T01:41:35',
    updatedAt: '2026-07-19T13:27:51',
  );
}

PemantauanBalitaDetailResponse _makeDetailMinimal() {
  return const PemantauanBalitaDetailResponse(
    idPantau: 'p-002',
    idKader: 'k-001',
    idCabang: 'c-001',
    namaKader: 'Zidan Kusuma',
    namaPosyandu: 'Posyandu Melati',
    tanggalPantau: '2026-06-15',
    usiaBulan: 6,
    berat: 12.0,
    tinggi: 80.0,
    lingkarKepala: null,
    lingkarLengan: null,
    statusGizi: 'gizi_kurang',
    imunisasi: null,
    vitaminA: 'tidak',
    keluhan: null,
    saran: null,
    createdAt: null,
    updatedAt: null,
  );
}

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

  group('BalitaDetailPage', () {
    testWidgets('shows skeleton loading initially, then data when loaded',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubData: _makeDetail());

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      expect(find.text('Detail pemeriksaan'), findsOneWidget);
      expect(find.text('Berat Badan'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Detail pemeriksaan'), findsOneWidget);
      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('Tinggi Badan'), findsOneWidget);
      expect(find.text('Lingkar Kepala'), findsOneWidget);
      expect(find.text('Lingkar Lengan'), findsOneWidget);
      expect(find.text('12.8 kg'), findsOneWidget);
      expect(find.text('86.0 cm'), findsOneWidget);
      expect(find.text('48.8 cm'), findsOneWidget);
      expect(find.text('18.2 cm'), findsOneWidget);
      expect(find.text('BCG, DPT, Polio, Campak'), findsOneWidget);
      expect(find.text('ya'), findsOneWidget);
      expect(find.text('Baik'), findsOneWidget);
      expect(find.text('Catatan Petugas'), findsOneWidget);
      expect(find.text('Keluhan'), findsOneWidget);
      expect(find.text('Saran'), findsOneWidget);
      expect(find.text('Keluhan diperbarui'), findsOneWidget);
      expect(find.text('Saran diperbarui'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Info Kader & Posyandu'), 200);
      expect(find.text('Info Kader & Posyandu'), findsOneWidget);
      expect(find.text('Zidan Kusuma'), findsOneWidget);
      expect(find.text('Posyandu Melati'), findsOneWidget);
    });

    testWidgets('appBar has back button and title', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubData: _makeDetail());

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Detail pemeriksaan'), findsOneWidget);
    });

    testWidgets('hides Catatan Petugas when keluhan and saran are null',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubData: _makeDetailMinimal());

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-002',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Catatan Petugas'), findsNothing);
      expect(find.text('Info Kader & Posyandu'), findsOneWidget);
      expect(find.text('Zidan Kusuma'), findsOneWidget);
      expect(find.text('gizi_kurang'), findsNothing);
    });

    testWidgets('shows error with retry when API fails and no cache',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    });

    testWidgets('shows cached data with offline banner when API fails and cache exists',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'detail_pemantauan_cache_mod-001_p-001':
            '{"id_pantau":"p-001","id_kader":"k-001","id_cabang":"c-001","nama_kader":"Zidan Kusuma","nama_posyandu":"Posyandu Melati","tanggal_pantau":"2026-06-15","usia_bulan":6,"berat":12.8,"tinggi":86.0,"lingkar_kepala":48.8,"lingkar_lengan":18.2,"status_gizi":"gizi_baik","imunisasi":"BCG, DPT, Polio, Campak","vitamin_a":"ya","keluhan":"Cached keluhan","saran":"Cached saran","created_at":"2026-07-05T01:41:35","updated_at":"2026-07-19T13:27:51"}',
      });

      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Cached keluhan'), findsOneWidget);
      expect(find.text('Cached saran'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final pemantauanService = _MockPemantauanService(stubData: _makeDetail());

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Data balita tidak ditemukan'), findsOneWidget);
    });

    testWidgets('shows read-only note at bottom', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubData: _makeDetail());

      await tester.pumpWidget(_buildTestApp(
        BalitaDetailPage(
          idPantau: 'p-001',
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.textContaining('read-only'), 200);
      expect(find.textContaining('read-only'), findsOneWidget);
      expect(find.textContaining('Hubungi bidan'), findsOneWidget);
    });
  });
}
