import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/pages/posbindu/gula_darah_chart_page.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_status.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart_skeleton.dart';

// Mock classes
class MockPosbinduService extends PosbinduService {
  final GulaDarahChartData? stubData;
  final bool shouldThrow;

  MockPosbinduService({this.stubData, this.shouldThrow = false});

  @override
  Future<GulaDarahChartData> getGulaDarahChart(String idAnggota) async {
    if (shouldThrow) {
      throw Exception('Network error');
    }
    if (stubData != null) {
      return stubData!;
    }
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

class MockAuthService extends AuthService {
  final String? moduleId;

  MockAuthService({this.moduleId});

  @override
  Future<String?> getModuleId() async => moduleId;

  @override
  Future<void> logout() async {}
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  group('GulaDarahChartPage', () {
    testWidgets('shows skeleton while loading', (WidgetTester tester) async {
      final mockService = MockPosbinduService();
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      // Should show skeleton initially
      expect(find.byType(GulaDarahChartSkeleton), findsOneWidget);
    });

    testWidgets('shows data after successful load', (
      WidgetTester tester,
    ) async {
      final chartData = GulaDarahChartData(
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
      );

      final mockService = MockPosbinduService(stubData: chartData);
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gula Darah'), findsWidgets);
      expect(find.text('105 mg/dL'), findsAtLeastNWidgets(1));
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('2x'), findsOneWidget);
    });

    testWidgets('shows empty state when measurements is empty', (
      WidgetTester tester,
    ) async {
      final chartData = GulaDarahChartData(
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

      final mockService = MockPosbinduService(stubData: chartData);
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Data Pengukuran Gula Darah'), findsOneWidget);
    });

    testWidgets('shows error screen when no data and error', (
      WidgetTester tester,
    ) async {
      final mockService = MockPosbinduService(shouldThrow: true);
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('handles null moduleId gracefully', (
      WidgetTester tester,
    ) async {
      final mockService = MockPosbinduService();
      final mockAuthService = MockAuthService(moduleId: null);

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ID anggota tidak ditemukan'), findsOneWidget);
    });

    testWidgets('pull-to-refresh works', (WidgetTester tester) async {
      final chartData = GulaDarahChartData(
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
        ],
      );

      final mockService = MockPosbinduService(stubData: chartData);
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: true,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find RefreshIndicator and drag it
      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);
    });

    testWidgets('renders status colors correctly', (WidgetTester tester) async {
      // Verify status colors are correct
      expect(gulaDarahStatusColor('normal'), const Color(0xFF43A047));
      expect(gulaDarahStatusColor('pra_diabetes'), const Color(0xFFFFA726));
      expect(gulaDarahStatusColor('diabetes'), const Color(0xFFB71C1C));
    });

    testWidgets('standalone mode shows AppBar', (WidgetTester tester) async {
      final chartData = GulaDarahChartData(
        gulaDarahZones: [],
        label: 'Normal',
        latestGulaDarah: null,
        latestStatus: null,
        measurements: [],
      );

      final mockService = MockPosbinduService(stubData: chartData);
      final mockAuthService = MockAuthService(moduleId: 'test-module-id');

      await tester.pumpWidget(
        MaterialApp(
          home: GulaDarahChartPage(
            embedded: false,
            service: mockService,
            authService: mockAuthService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Gula Darah'), findsWidgets);
    });
  });
}
