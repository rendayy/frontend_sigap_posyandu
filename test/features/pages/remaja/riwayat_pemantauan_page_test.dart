import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/remaja/riwayat_pemantauan_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPemantauanService extends PemantauanRemajaService {
  final PemantauanRemajaListResponse? stubListData;
  final GulaDarahChartData? stubChartData;
  final bool stubThrowError;
  _MockPemantauanService({this.stubListData, this.stubChartData, this.stubThrowError = false}) : super();

  @override
  Future<PemantauanRemajaListResponse> getList({
    required String idRemaja,
    int page = 1,
    int limit = 10,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubListData != null) return stubListData!;
    throw Exception('not mocked');
  }

  @override
  Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) async {
    if (stubThrowError) throw NetworkException();
    if (stubChartData != null) return stubChartData!;
    throw Exception('not mocked');
  }
}

PemantauanRemajaItem _makeItem({int no = 1}) {
  return PemantauanRemajaItem(
    no: no,
    idPantauRemaja: 'pr-00$no',
    idKader: 'k-001',
    namaKader: 'Zidan Kusuma',
    namaPosyandu: 'Posyandu Melati',
    tanggalPeriksa: '2026-07-18',
    beratBadan: 55.0,
    tinggiBadan: 160.0,
    sistol: 110,
    distol: 70,
    gulaDarah: 90,
    statusGizi: 'berat_badan_normal',
  );
}

PemantauanRemajaListResponse _makeResponse({int totalPages = 3}) {
  return PemantauanRemajaListResponse(
    data: List.generate(5, (i) => _makeItem(no: i + 1)),
    pagination: PaginationMeta(page: 1, limit: 10, total: 14, totalPages: totalPages),
    success: true,
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

  group('RiwayatPemantauanPage', () {
    testWidgets('shows skeleton loading initially, then data when loaded',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(
        stubListData: _makeResponse(),
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
          authService: authService,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Pemantauan'), findsOneWidget);
      expect(find.text('Gula Darah'), findsOneWidget);
      expect(find.text('18 Juli 2026'), findsNWidgets(5));
      await tester.scrollUntilVisible(find.text('Muat Lainnya'), 100);
      expect(find.text('Muat Lainnya'), findsOneWidget);
    });

    testWidgets('shows error with retry when API fails and no cache',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
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
        'remaja_pemantauan_cache_mod-001':
            '{"data":[{"no":1,"id_pantau_remaja":"pr-001","id_kader":"k-001","nama_kader":"Zidan Kusuma","nama_posyandu":"Posyandu Melati","tanggal_periksa":"2026-07-18","berat_badan":55.0,"tinggi_badan":160.0,"sistol":110,"distol":70,"gula_darah":90,"status_gizi":"berat_badan_normal","keluhan":null,"saran":null,"created_at":null,"updated_at":null}],"pagination":{"page":1,"limit":10,"total":1,"total_pages":1},"success":true}',
      });

      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('18 Juli 2026'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    });

    testWidgets('tab Gula Darah shows chart', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final chartData = GulaDarahChartData(
        gulaDarahZones: [
          const GulaDarahZone(status: 'normal', label: 'Normal', min: 0, max: 126, color: '#43A047'),
          const GulaDarahZone(status: 'pra_diabetes', label: 'Pra-diabetes', min: 126, max: 200, color: '#FFA726'),
          const GulaDarahZone(status: 'diabetes', label: 'Diabetes', min: 200, max: 999, color: '#B71C1C'),
        ],
        label: 'Normal',
        latestGulaDarah: 95,
        latestStatus: 'normal',
        measurements: [
          const GulaDarahMeasurement(gulaDarah: 94, tanggalPeriksa: '2026-07-04'),
          const GulaDarahMeasurement(gulaDarah: 89, tanggalPeriksa: '2026-07-11'),
        ],
      );
      final pemantauanService = _MockPemantauanService(
        stubListData: _makeResponse(),
        stubChartData: chartData,
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Gula Darah'));
      await tester.pumpAndSettle();

      expect(find.text('Gula Darah'), findsAtLeastNWidgets(1));
      expect(find.text('95'), findsOneWidget);
      expect(find.text('mg/dL'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsAtLeastNWidgets(1));
    });

    testWidgets('hides Muat Lainnya when no more pages',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(
        stubListData: _makeResponse(totalPages: 1),
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Muat Lainnya'), findsNothing);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final pemantauanService = _MockPemantauanService(stubListData: _makeResponse());

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          service: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('ID remaja tidak ditemukan'), findsOneWidget);
    });
  });
}
