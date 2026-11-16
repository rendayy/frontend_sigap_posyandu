import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/ibu_hamil/ibu_hamil_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/ibu_hamil/riwayat_pemeriksaan_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockInjectedService extends IbuHamilService {
  RiwayatPemeriksaanData? stubData;
  bool stubThrowError = false;
  Object stubError = const NetworkException();

  BeratBadanChartResponse? stubBbChart;
  TinggiFundusChartResponse? stubTfuChart;

  _MockInjectedService() : super();

  @override
  Future<RiwayatPemeriksaanData> getRiwayatPemeriksaan(
    String idIbuHamil, {
    int page = 1,
    int limit = 10,
  }) async {
    if (stubThrowError) throw stubError;
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }

  @override
  Future<BeratBadanChartResponse> getBeratBadanChart(String idIbuHamil) async {
    if (stubBbChart != null) return stubBbChart!;
    throw Exception('not mocked');
  }

  @override
  Future<TinggiFundusChartResponse> getTinggiFundusChart(String idIbuHamil) async {
    if (stubTfuChart != null) return stubTfuChart!;
    throw Exception('not mocked');
  }
}

PemeriksaanIbuHamilItem _item({
  String id = 'px-1',
  String? tanggal = '2026-08-20',
  double? bb = 58.5,
  int? sistol = 110,
  int? distol = 75,
  double? lila = 26.0,
  double? tfu = 22.0,
  int? usia = 20,
  String? keluhan,
}) =>
    PemeriksaanIbuHamilItem(
      idPeriksa: id,
      tanggalPeriksa: tanggal,
      usiaKehamilan: usia,
      beratBadan: bb,
      sistol: sistol,
      distol: distol,
      lingkarLengan: lila,
      tinggiFundus: tfu,
      keluhan: keluhan,
    );

RiwayatPemeriksaanData _data({List<PemeriksaanIbuHamilItem>? items, int total = 2}) =>
    RiwayatPemeriksaanData(
      items: items ?? [_item(), _item(id: 'px-2', tanggal: '2026-08-01', bb: 57.0, sistol: 105, distol: 70, tfu: 20.0)],
      pagination: PaginationMeta(page: 1, limit: 10, total: total, totalPages: 1),
      trimester: 2,
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

  testWidgets('renders list of pemeriksaan with count', (tester) async {
    final service = _MockInjectedService()..stubData = _data();
    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
    expect(find.text('2 kunjungan tercatat'), findsOneWidget);
    expect(find.textContaining('ANC ke-1'), findsOneWidget);
    expect(find.textContaining('ANC ke-2'), findsOneWidget);
    expect(find.text('Selesai'), findsNWidgets(2));
    expect(find.text('58.5 kg'), findsOneWidget);
    expect(find.text('110/75'), findsOneWidget);
    expect(find.text('22 cm'), findsOneWidget);
    expect(find.text('Muat lebih banyak'), findsNothing);
  });

  testWidgets('shows empty state when no pemeriksaan', (tester) async {
    final service = _MockInjectedService()
      ..stubData = RiwayatPemeriksaanData(
        items: const [],
        pagination: const PaginationMeta(page: 1, limit: 10, total: 0, totalPages: 0),
        trimester: 1,
      );
    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Belum ada riwayat pemeriksaan'), findsOneWidget);
  });

  testWidgets('shows error with retry when API fails', (tester) async {
    final service = _MockInjectedService()..stubThrowError = true;
    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);

    service
      ..stubThrowError = false
      ..stubData = _data();

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('2 kunjungan tercatat'), findsOneWidget);
  });

  testWidgets('redirects to login when session expired', (tester) async {
    final service = _MockInjectedService()
      ..stubThrowError = true
      ..stubError = const ServerException(statusCode: 401, message: 'expired');
    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Login Page'), findsOneWidget);
  });

  testWidgets('loads charts when switching to grafik tab', (tester) async {
    final service = _MockInjectedService()
      ..stubData = _data()
      ..stubBbChart = BeratBadanChartResponse(
        measurements: [
          ChartMeasurement(minggu: 16, nilai: 55.5),
          ChartMeasurement(minggu: 20, nilai: 57.0),
        ],
        batasAtas: [
          ChartReferencePoint(minggu: 16, nilai: 60.0),
          ChartReferencePoint(minggu: 20, nilai: 62.0),
        ],
        batasBawah: [
          ChartReferencePoint(minggu: 16, nilai: 48.0),
          ChartReferencePoint(minggu: 20, nilai: 50.0),
        ],
      )
      ..stubTfuChart = TinggiFundusChartResponse(
        measurements: [
          ChartMeasurement(minggu: 16, nilai: 20.0),
          ChartMeasurement(minggu: 20, nilai: 22.0),
        ],
        standar: [
          ChartReferencePoint(minggu: 16, nilai: 18.0),
          ChartReferencePoint(minggu: 20, nilai: 22.0),
        ],
      );

    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grafik'));
    await tester.pumpAndSettle();

    expect(find.text('Berat Badan (kg)'), findsOneWidget);
    expect(find.text('Minggu kehamilan'), findsOneWidget);

    await tester.tap(find.text('Tinggi Fundus'));
    await tester.pumpAndSettle();

    expect(find.text('Tinggi Fundus (cm)'), findsOneWidget);
  });

  testWidgets('shows insufficient data message when chart has < 2 measurements', (tester) async {
    final service = _MockInjectedService()
      ..stubData = _data()
      ..stubBbChart = BeratBadanChartResponse(measurements: [
        ChartMeasurement(minggu: 16, nilai: 55.5),
      ]);

    await tester.pumpWidget(_buildTestApp(
      RiwayatPemeriksaanPage(
        embedded: false,
        authService: _MockAuthService(stubModuleId: 'mod-001'),
        ibuHamilService: service,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grafik'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Data belum cukup untuk menampilkan grafik'), findsOneWidget);
  });
}