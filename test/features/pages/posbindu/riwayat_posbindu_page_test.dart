import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/posbindu/riwayat_posbindu_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPosbinduService extends PosbinduService {
  final PemeriksaanPosbinduListResponse? stubListData;
  final GulaDarahChartData? stubGulaDarahChartData;
  final bool stubThrowError;
  _MockPosbinduService({
    this.stubListData,
    this.stubGulaDarahChartData,
    this.stubThrowError = false,
  }) : super();

  @override
  Future<PemeriksaanPosbinduListResponse> getList({
    required String idAnggota,
    int page = 1,
    int limit = 10,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubListData != null) return stubListData!;
    throw Exception('not mocked');
  }

  @override
  Future<GulaDarahChartData> getGulaDarahChart(String idAnggota) async {
    if (stubThrowError) throw NetworkException();
    if (stubGulaDarahChartData != null) return stubGulaDarahChartData!;
    return GulaDarahChartData(
      gulaDarahZones: [
        GulaDarahZone(
          status: 'normal',
          label: 'Normal',
          min: 0,
          max: 126,
          color: '#43A047',
        ),
      ],
      label: 'Normal',
      latestGulaDarah: null,
      latestStatus: null,
      measurements: [],
    );
  }
}

PemeriksaanPosbinduItem _makeItem({int no = 1}) {
  return PemeriksaanPosbinduItem(
    no: no,
    idPeriksaPosbindu: 'pr-00$no',
    idKader: 'k-001',
    tanggalPeriksa: '2026-06-27',
    beratBadan: 60.65,
    tinggiBadan: 170.0,
    bmi: 21.0,
    sistol: 116,
    distol: 79,
    gulaDarahSewaktu: 105,
    statusBmi: 'berat_badan_normal',
  );
}

PemeriksaanPosbinduListResponse _makeResponse({int totalPages = 3}) {
  return PemeriksaanPosbinduListResponse(
    data: List.generate(5, (i) => _makeItem(no: i + 1)),
    pagination: PaginationMeta(
      page: 1,
      limit: 10,
      total: 14,
      totalPages: totalPages,
    ),
    success: true,
  );
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
    routes: {'/login': (_) => const Scaffold(body: Text('Login Page'))},
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('RiwayatPosbinduPage', () {
    testWidgets('shows skeleton loading initially, then data when loaded', (
      tester,
    ) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubListData: _makeResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Pemantauan'), findsOneWidget);
      expect(find.text('Gula Darah'), findsOneWidget);
      expect(find.text('27 Juni 2026'), findsNWidgets(5));
      await tester.scrollUntilVisible(find.text('Muat Lainnya'), 100);
      expect(find.text('Muat Lainnya'), findsOneWidget);
    });

    testWidgets('shows error with retry when API fails and no cache', (
      tester,
    ) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(stubThrowError: true);

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    });

    testWidgets(
      'shows cached data with offline banner when API fails and cache exists',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'posbindu_pemeriksaan_cache_mod-001':
              '{"data":[{"no":1,"id_periksa_posbindu":"pr-001","id_kader":"k-001","tanggal_periksa":"2026-06-27","berat_badan":60.65,"tinggi_badan":170.0,"bmi":21.0,"sistol":116,"distol":79,"gula_darah_sewaktu":105,"status_bmi":"berat_badan_normal"}],"pagination":{"page":1,"limit":10,"total":1,"total_pages":1},"success":true}',
        });

        final authService = _MockAuthService(stubModuleId: 'mod-001');
        final posbinduService = _MockPosbinduService(stubThrowError: true);

        await tester.pumpWidget(
          _buildTestApp(
            RiwayatPosbinduPage(
              service: posbinduService,
              authService: authService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('27 Juni 2026'), findsOneWidget);
        expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
        expect(find.text('Hubungkan'), findsOneWidget);
      },
    );

    testWidgets('tab Gula Darah shows chart page with data', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubListData: _makeResponse(),
        stubGulaDarahChartData: GulaDarahChartData(
          gulaDarahZones: [
            GulaDarahZone(
              status: 'normal',
              label: 'Normal',
              min: 0,
              max: 126,
              color: '#43A047',
            ),
          ],
          label: 'Normal',
          latestGulaDarah: 105,
          latestStatus: 'normal',
          measurements: [
            GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
            GulaDarahMeasurement(gulaDarah: 105, tanggalPeriksa: '2026-06-27'),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Gula Darah'));
      await tester.pumpAndSettle();

      expect(find.text('Gula Darah'), findsWidgets);
      expect(find.text('105 mg/dL'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('hides Muat Lainnya when no more pages', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubListData: _makeResponse(totalPages: 1),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Muat Lainnya'), findsNothing);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final posbinduService = _MockPosbinduService(
        stubListData: _makeResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('ID anggota tidak ditemukan'), findsOneWidget);
    });

    testWidgets('shows empty state when list is empty', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubListData: PemeriksaanPosbinduListResponse(
          data: [],
          pagination: PaginationMeta(
            page: 1,
            limit: 10,
            total: 0,
            totalPages: 0,
          ),
          success: true,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Data Pemeriksaan'), findsOneWidget);
    });

    testWidgets('tab switching works correctly', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubListData: _makeResponse(),
        stubGulaDarahChartData: GulaDarahChartData(
          gulaDarahZones: [
            GulaDarahZone(
              status: 'normal',
              label: 'Normal',
              min: 0,
              max: 126,
              color: '#43A047',
            ),
          ],
          label: 'Normal',
          latestGulaDarah: 105,
          latestStatus: 'normal',
          measurements: [
            GulaDarahMeasurement(gulaDarah: 96, tanggalPeriksa: '2025-09-30'),
            GulaDarahMeasurement(gulaDarah: 105, tanggalPeriksa: '2026-06-27'),
          ],
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          RiwayatPosbinduPage(
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('27 Juni 2026'), findsNWidgets(5));

      await tester.tap(find.text('Gula Darah'));
      await tester.pumpAndSettle();

      expect(find.text('105 mg/dL'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsWidgets);

      await tester.tap(find.text('Pemantauan'));
      await tester.pumpAndSettle();

      expect(find.text('27 Juni 2026'), findsNWidgets(5));
    });
  });
}
