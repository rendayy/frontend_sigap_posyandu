import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/ibu_hamil/ibu_hamil_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/ibu_hamil/ibu_hamil_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockIbuHamilService extends IbuHamilService {
  IbuHamilBerandaData? stubData;
  bool stubThrowError = false;
  Object stubError = const NetworkException();

  _MockIbuHamilService({this.stubData}) : super();

  @override
  Future<IbuHamilBerandaData> getBeranda(String idIbuHamil) async {
    if (stubThrowError) throw stubError;
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }
}

IbuHamilBerandaData _beranda({String nama = 'Siti Aminah'}) =>
    IbuHamilBerandaData(
      nama: nama,
      inisial: nama.substring(0, 1).toUpperCase(),
      statusLabel: 'Ibu Hamil',
      kehamilan: const IbuHamilKehamilanInfo(
        usiaMinggu: 20,
        trimester: 2,
        hpl: '1 Januari 2027',
        totalMinggu: 40,
        progressPersen: 50,
        hariMenujuHpl: 190,
      ),
      vital: const IbuHamilVitalInfo(
        beratBadanKg: 58.5,
        beratBadanDeltaKg: 1.5,
        beratBadanStatus: 'Normal',
        tekananDarah: '110/75',
        tekananDarahTanggal: '20 Agustus 2026',
        tekananDarahStatus: 'Normal',
        lilaCm: 26.0,
        tinggiFundusCm: 22.0,
        kunjunganAnc: KunjunganAncInfo(selesai: 2),
      ),
      jadwal: const IbuHamilJadwalInfo(
        kunjunganKe: '3',
        tanggal: '3 September 2026',
        status: 'Akan Datang',
      ),
      edukasi: const IbuHamilEdukasiInfo(
        trimester: 2,
        konten: 'Trimester kedua adalah masa paling nyaman bagi ibu hamil.',
      ),
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

  testWidgets('shows skeleton then renders beranda data', (tester) async {
    final service = _MockIbuHamilService(stubData: _beranda());
    await tester.pumpWidget(_buildTestApp(
      IbuHamilPage(authService: _MockAuthService(stubModuleId: 'mod-001'), ibuHamilService: service),
    ));

    expect(find.text('Siti Aminah'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.text('Siti Aminah'), findsOneWidget);
    expect(find.text('Ibu Hamil'), findsOneWidget);
    expect(find.textContaining('Trimester 2 · 20 minggu lagi'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('58.5'), findsOneWidget);
    expect(find.text('110/75'), findsOneWidget);
    expect(find.text('26.0 cm'), findsOneWidget);
    expect(find.text('22.0 cm'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Jadwal Pemeriksaan Berikutnya'), findsOneWidget);
    expect(find.text('Akan Datang'), findsOneWidget);
    expect(find.text('Pemeriksaan ANC ke-3'), findsOneWidget);
  });

  testWidgets('shows error with retry when API fails and no cache', (tester) async {
    final service = _MockIbuHamilService()
      ..stubThrowError = true;
    await tester.pumpWidget(_buildTestApp(
      IbuHamilPage(authService: _MockAuthService(stubModuleId: 'mod-001'), ibuHamilService: service),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);

    service
      ..stubThrowError = false
      ..stubData = _beranda();

    await tester.tap(find.text('Coba Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Siti Aminah'), findsOneWidget);
  });

  testWidgets('shows cached data with offline banner when API fails and cache exists', (tester) async {
    SharedPreferences.setMockInitialValues({
      'ibu_hamil_cache_mod-001':
          '{"nama":"Cache Ibu","inisial":"C","statusLabel":"Ibu Hamil","kehamilan":{"usia_minggu":8,"trimester":1,"hpl":"-","total_minggu":40,"progress_persen":20,"hari_menuju_hpl":0}}',
    });
    final service = _MockIbuHamilService()..stubThrowError = true;

    await tester.pumpWidget(_buildTestApp(
      IbuHamilPage(authService: _MockAuthService(stubModuleId: 'mod-001'), ibuHamilService: service),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Cache Ibu'), findsOneWidget);
    expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
    expect(find.text('Hubungkan'), findsOneWidget);
    expect(find.text('Belum ada data'), findsWidgets);
  });

  testWidgets('bottom nav switches to placeholder tab', (tester) async {
    final service = _MockIbuHamilService(stubData: _beranda());
    await tester.pumpWidget(_buildTestApp(
      IbuHamilPage(authService: _MockAuthService(stubModuleId: 'mod-001'), ibuHamilService: service),
    ));

    await tester.pumpAndSettle();

    await tester.tap(find.text('Jadwal'));
    await tester.pumpAndSettle();

    expect(find.text('Jadwal\n(dalam pengembangan)'), findsOneWidget);
  });
}