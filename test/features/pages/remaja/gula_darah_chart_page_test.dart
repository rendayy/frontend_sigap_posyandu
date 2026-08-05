import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/remaja/gula_darah_chart_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPemantauanService extends PemantauanRemajaService {
  final GulaDarahChartData? stubData;
  final bool stubThrowError;
  _MockPemantauanService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<GulaDarahChartData> getGulaDarahChart(String idRemaja) async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }
}

GulaDarahChartData _makeChartData({int measurementCount = 4}) {
  return GulaDarahChartData(
    gulaDarahZones: [
      const GulaDarahZone(
        status: 'normal', label: 'Normal', min: 0, max: 126, color: '#43A047',
      ),
      const GulaDarahZone(
        status: 'pra_diabetes', label: 'Pra-diabetes', min: 126, max: 200, color: '#FFA726',
      ),
      const GulaDarahZone(
        status: 'diabetes', label: 'Diabetes', min: 200, max: 999, color: '#B71C1C',
      ),
    ],
    label: 'Normal',
    latestGulaDarah: 95,
    latestStatus: 'normal',
    measurements: List.generate(measurementCount, (i) {
      return GulaDarahMeasurement(
        gulaDarah: 90 + i,
        tanggalPeriksa: '2026-07-${(22 - i).toString().padLeft(2, '0')}',
      );
    }),
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

  group('GulaDarahChartPage', () {
    testWidgets('shows skeleton loading initially, then chart when loaded',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final service = _MockPemantauanService(
        stubData: _makeChartData(),
      );

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
          authService: authService,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Gula Darah'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
      expect(find.text('mg/dL'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsAtLeastNWidgets(1));
      expect(find.text('4x'), findsOneWidget);
      expect(find.text('Grafik Gula Darah'), findsAtLeastNWidgets(1));
    });

    testWidgets('shows error with retry when API fails and no cache',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final service = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
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
        'gula_darah_chart_cache_mod-001':
            '{"gula_darah_zones":[{"color":"#43A047","label":"Normal","max":126,"min":0,"status":"normal"},{"color":"#FFA726","label":"Pra-diabetes","max":200,"min":126,"status":"pra_diabetes"},{"color":"#B71C1C","label":"Diabetes","max":999,"min":200,"status":"diabetes"}],"label":"Normal","latest_gula_darah":95,"latest_status":"normal","measurements":[{"gula_darah":94,"tanggal_periksa":"2026-07-04"},{"gula_darah":89,"tanggal_periksa":"2026-07-11"}]}',
      });

      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final service = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('95'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    });

    testWidgets('renders measurement history', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final service = _MockPemantauanService(
        stubData: _makeChartData(measurementCount: 3),
      );

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Riwayat Pengukuran'), 200);
      await tester.pumpAndSettle();

      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('91'), findsOneWidget);
      expect(find.text('92'), findsOneWidget);
    });

    testWidgets('shows pagination with more than 5 measurements',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final service = _MockPemantauanService(
        stubData: _makeChartData(measurementCount: 12),
      );

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('1 / 3'), 200);
      await tester.pumpAndSettle();

      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsNothing);

      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsOneWidget);

      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsNothing);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final service = _MockPemantauanService(stubData: _makeChartData());

      await tester.pumpWidget(_buildTestApp(
        GulaDarahChartPage(
          service: service,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Data remaja tidak ditemukan'), findsOneWidget);
    });

    testWidgets('shows status colors based on latestStatus', (tester) async {
      for (final status in ['normal', 'pra_diabetes', 'diabetes']) {
        final authService = _MockAuthService(stubModuleId: 'mod-001');
        final data = _makeChartData();
        final modifiedData = GulaDarahChartData(
          gulaDarahZones: data.gulaDarahZones,
          label: data.label,
          latestGulaDarah: data.latestGulaDarah,
          latestStatus: status,
          measurements: data.measurements,
        );
        final service = _MockPemantauanService(stubData: modifiedData);

        await tester.pumpWidget(_buildTestApp(
          GulaDarahChartPage(
            service: service,
            authService: authService,
          ),
        ));

        await tester.pumpAndSettle();

        if (status == 'normal') {
          expect(find.text('Normal'), findsAtLeastNWidgets(1));
        } else if (status == 'pra_diabetes') {
          expect(find.text('Pra-diabetes'), findsAtLeastNWidgets(1));
        } else if (status == 'diabetes') {
          expect(find.text('Diabetes'), findsAtLeastNWidgets(1));
        }
      }
    });
  });
}
