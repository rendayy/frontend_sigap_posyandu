import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_detail_model.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/remaja/pemantauan_detail_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPemantauanService extends PemantauanRemajaService {
  final PemantauanRemajaDetailResponse? stubData;
  final bool stubThrowError;
  int fetchCount = 0;

  _MockPemantauanService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<PemantauanRemajaDetailResponse> getDetail({
    required String idRemaja,
    required String idPantau,
  }) async {
    fetchCount++;
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }
}

PemantauanRemajaDetailResponse _makeDetail() {
  return PemantauanRemajaDetailResponse(
    idPantauRemaja: 'pr-001',
    idKader: 'k-001',
    idCabang: 'c-001',
    namaKader: 'Zidan Kusuma',
    namaPosyandu: 'Posyandu Melati',
    tanggalPeriksa: '2026-06-25',
    beratBadan: 50.8,
    tinggiBadan: 158.0,
    sistol: 111,
    distol: 70,
    gulaDarah: 87,
    bmi: 20.4,
    statusGizi: 'berat_badan_normal',
    keluhan: 'Tidak ada keluhan',
    saran: 'Pertahankan pola makan sehat',
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

  group('PemantauanDetailPage', () {
    testWidgets('shows skeleton loading initially, then data when loaded',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Detail Pemantauan'), findsOneWidget);
      expect(find.text('Detail Pemeriksaan'), findsOneWidget);
      expect(find.text('50.8 kg'), findsOneWidget);
      expect(find.text('158.0 cm'), findsOneWidget);
      expect(find.text('20.4 kg/m²'), findsOneWidget);
      expect(find.text('111 mmHg'), findsOneWidget);
      expect(find.text('70 mmHg'), findsOneWidget);
      expect(find.text('87 mg/dL'), findsOneWidget);
      expect(find.text('Gula Darah'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.text('Catatan Petugas'), findsOneWidget);
      expect(find.text('Tidak ada keluhan'), findsOneWidget);
      expect(find.text('Pertahankan pola makan sehat'), findsOneWidget);
    });

    testWidgets('shows error with retry when API fails and no cache',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
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
        'remaja_pemantauan_detail_cache_mod-001_pr-001':
            '{"id_pantau_remaja":"pr-001","id_kader":"k-001","id_cabang":"c-001","nama_kader":"Zidan Kusuma","nama_posyandu":"Posyandu Melati","tanggal_periksa":"2026-06-25","berat_badan":50.8,"tinggi_badan":158.0,"sistol":111,"distol":70,"gula_darah":87,"bmi":20.4,"status_gizi":"berat_badan_normal","keluhan":"Tidak ada keluhan","saran":"Pertahankan pola makan sehat","created_at":null,"updated_at":null}',
        'remaja_pemantauan_detail_ts_mod-001_pr-001':
            '2026-07-25T23:00:00.000',
      });

      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('50.8 kg'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    });

    testWidgets('fresh cache (< 30s) skips API fetch', (tester) async {
      final now = DateTime.now().toIso8601String();
      SharedPreferences.setMockInitialValues({
        'remaja_pemantauan_detail_cache_mod-001_pr-001':
            '{"id_pantau_remaja":"pr-001","id_kader":"k-001","id_cabang":"c-001","nama_kader":"Zidan Kusuma","nama_posyandu":"Posyandu Melati","tanggal_periksa":"2026-06-25","berat_badan":50.8,"tinggi_badan":158.0,"sistol":111,"distol":70,"gula_darah":87,"bmi":20.4,"status_gizi":"berat_badan_normal","keluhan":"Tidak ada keluhan","saran":"Pertahankan pola makan sehat","created_at":null,"updated_at":null}',
        'remaja_pemantauan_detail_ts_mod-001_pr-001': now,
      });

      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );
      final authService = _MockAuthService(stubModuleId: 'mod-001');

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('50.8 kg'), findsOneWidget);
      expect(detailService.fetchCount, 0);
    });

    testWidgets('stale cache (>= 30s) shows data then silent refreshes',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'remaja_pemantauan_detail_cache_mod-001_pr-001':
            '{"id_pantau_remaja":"pr-001","id_kader":"k-001","id_cabang":"c-001","nama_kader":"Zidan Kusuma","nama_posyandu":"Posyandu Melati","tanggal_periksa":"2026-06-25","berat_badan":50.8,"tinggi_badan":158.0,"sistol":111,"distol":70,"gula_darah":87,"bmi":20.4,"status_gizi":"berat_badan_normal","keluhan":"Tidak ada keluhan","saran":"Pertahankan pola makan sehat","created_at":null,"updated_at":null}',
        'remaja_pemantauan_detail_ts_mod-001_pr-001':
            '2026-07-25T23:00:00.000',
      });

      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );
      final authService = _MockAuthService(stubModuleId: 'mod-001');

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('50.8 kg'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsNothing);
      expect(detailService.fetchCount, 1);
    });

    testWidgets('StatusGiziBadge is rendered for status gizi',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Status Gizi'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
    });

    testWidgets('shows skeleton on initial load before data arrives',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      // SvgPicture not rendered during skeleton
      expect(find.byType(SvgPicture), findsNothing);

      await tester.pumpAndSettle();
    });

    testWidgets('shows read-only note at bottom', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final detailService = _MockPemantauanService(
        stubData: _makeDetail(),
      );

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: 'mod-001',
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('50.8 kg'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('read_only_note')), findsOneWidget);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final detailService = _MockPemantauanService(stubData: _makeDetail());

      await tester.pumpWidget(_buildTestApp(
        PemantauanDetailPage(
          idPantau: 'pr-001',
          idRemaja: null,
          service: detailService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Data remaja tidak ditemukan'), findsOneWidget);
    });
  });
}
