import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/features/pages/balita/growth_chart_page.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class _MockBalitaService extends BalitaService {
  final GrowthChartResponse? stubData;
  final bool stubThrowError;
  _MockBalitaService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<GrowthChartResponse> getGrowthChart(String idBalita) async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }

  @override
  Future<File> downloadKms(String idBalita) async {
    if (stubThrowError) throw NetworkException();
    return File('${Directory.systemTemp.path}/test_kms.pdf');
  }
}

GrowthChartResponse _makeResponse() => GrowthChartResponse(
  chartType: 'BB/U',
  idAnggota: 'a-001',
  jenisKelamin: 'L',
  latestStatus: 'gizi_baik',
  measurements: [
    GrowthMeasurement(berat: 12.5, statusGizi: 'gizi_baik', tanggalPantau: '2026-06-12', usiaBulan: 1),
    GrowthMeasurement(berat: 12.8, statusGizi: 'gizi_kurang', tanggalPantau: '2026-06-15', usiaBulan: 5),
  ],
  standardCurves: {
    'median': [StandardCurvePoint(nilai: 9.6, usia: 12)],
    '-2SD': [StandardCurvePoint(nilai: 7.7, usia: 12)],
    '+2SD': [StandardCurvePoint(nilai: 12.0, usia: 12)],
  },
  zoneLabels: {'-2SD': 'Gizi Kurang', '+2SD': 'Kelebihan Berat Badan', 'median': 'Normal'},
  standardSource: 'WHO Child Growth Standards 2006',
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

  group('GrowthChartPage standalone', () {
    testWidgets('shows data when provided via constructor', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(data: _makeResponse()),
      ));

      expect(find.text('Kartu Menuju Sehat (KMS)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Riwayat Pengukuran'), 200);
      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
      expect(find.text('Usia 5 bulan'), findsOneWidget);
      expect(find.textContaining('12.8 kg'), findsOneWidget);
    });

    testWidgets('shows skeleton then data when loaded from service', (tester) async {
      final balitaService = _MockBalitaService(stubData: _makeResponse());

      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(
          idBalita: 'mod-001',
          balitaService: balitaService,
        ),
      ));

      expect(find.text('Kartu Menuju Sehat (KMS)'), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Kartu Menuju Sehat (KMS)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Riwayat Pengukuran'), 200);
      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
    });

    testWidgets('shows error when service fails', (tester) async {
      final balitaService = _MockBalitaService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(
          idBalita: 'mod-001',
          balitaService: balitaService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Coba Lagi'), findsOneWidget);
      expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
    });

    testWidgets('navigates range with prev/next buttons', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(data: _makeResponse()),
      ));

      expect(find.text('0 - 20 Bulan'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsNothing);
      expect(find.text('Selanjutnya'), findsOneWidget);

      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('20 - 40 Bulan'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsOneWidget);

      await tester.tap(find.text('Selanjutnya'));
      await tester.pumpAndSettle();

      expect(find.text('40 - 60 Bulan'), findsOneWidget);
      expect(find.text('Sebelumnya'), findsOneWidget);
      expect(find.text('Selanjutnya'), findsNothing);
    });

    testWidgets('shows measurement history', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(data: _makeResponse()),
      ));

      await tester.scrollUntilVisible(find.text('Riwayat Pengukuran'), 200);
      expect(find.text('Riwayat Pengukuran'), findsOneWidget);
      expect(find.text('Usia 5 bulan'), findsOneWidget);
      expect(find.text('Usia 1 bulan'), findsOneWidget);
    });
  });

  group('GrowthChartPage embedded', () {
    testWidgets('renders without AppBar', (tester) async {
      await tester.pumpWidget(_buildTestApp(
        GrowthChartPage(embedded: true, data: _makeResponse()),
      ));

      expect(find.text('Kartu Menuju Sehat (KMS)'), findsOneWidget);
      expect(find.text('Grafik Pertumbuhan'), findsNothing);
    });
  });
}
