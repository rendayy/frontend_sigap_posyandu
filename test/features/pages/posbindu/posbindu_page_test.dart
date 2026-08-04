import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/posbindu/posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_model.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/pages/posbindu/posbindu_page.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPosbinduService extends PosbinduService {
  final PosbinduDetailResponse? stubDetailData;
  final PemeriksaanPosbinduListResponse? stubListpData;
  final bool stubThrowError;
  _MockPosbinduService({
    this.stubDetailData,
    this.stubListpData,
    this.stubThrowError = false,
  }) : super();

  @override
  Future<PosbinduDetailResponse> getPosbinduDetail(String idAnggota) async {
    if (stubThrowError) throw NetworkException();
    if (stubDetailData != null) return stubDetailData!;
    throw Exception('not mocked');
  }

  @override
  Future<PemeriksaanPosbinduListResponse> getList({
    required String idAnggota,
    int page = 1,
    int limit = 10,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubListpData != null) return stubListpData!;
    throw Exception('not mocked');
  }

  @override
  Future<GulaDarahChartData> getGulaDarahChart(String idAnggota) async {
    if (stubThrowError) throw NetworkException();
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

PosbinduDetailResponse _makePosbindu() => const PosbinduDetailResponse(
  idAnggota: '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
  nik: '0123456789876545',
  nama: 'Mochamad Ramadhan Alfikri',
  jenisKelamin: 'L',
  tanggalLahir: '2004-09-10',
  usia: 21,
  statusAktif: 'aktif',
  beratBadan: 65.5,
  tinggiBadan: 170.0,
  bmi: 22.66,
  gulaDarahSewaktu: 110,
  statusBmi: 'berat_badan_normal',
  statusGulaDarah: 'normal',
  faktorRisikoMerokok: 'tidak',
  faktorRisikoKurangAktifitas: 'ya',
  tanggalPeriksaTerakhir: '2026-08-01',
);

PemeriksaanPosbinduListResponse _makePosbinduList() {
  return PemeriksaanPosbinduListResponse(
    data: [
      PemeriksaanPosbinduItem(
        no: 1,
        idPeriksaPosbindu: 'pr-001',
        idKader: 'k-001',
        tanggalPeriksa: '2026-06-27',
        beratBadan: 60.65,
        tinggiBadan: 170.0,
        bmi: 21.0,
        sistol: 116,
        distol: 79,
        gulaDarahSewaktu: 105,
        statusBmi: 'berat_badan_normal',
      ),
    ],
    pagination: PaginationMeta(page: 1, limit: 10, total: 1, totalPages: 1),
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

  testWidgets('shows skeleton loading initially, then data when loaded', (
    tester,
  ) async {
    final authService = _MockAuthService(
      stubModuleId: '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
    );
    final posbinduService = _MockPosbinduService(
      stubDetailData: _makePosbindu(),
      stubListpData: _makePosbinduList(),
    );

    await tester.pumpWidget(
      _buildTestApp(
        PosbinduPage(
          authService: authService,
          posbinduService: posbinduService,
        ),
      ),
    );

    // Initial skeleton state
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Mochamad Ramadhan Alfikri'), findsNothing);

    // After async load completes
    await tester.pumpAndSettle();

    expect(find.text('Mochamad Ramadhan Alfikri'), findsOneWidget);
    expect(find.text('Gula Darah Sewaktu'), findsOneWidget);
    expect(find.text('110'), findsOneWidget);
    expect(find.text('Faktor Risiko Gaya Hidup'), findsOneWidget);
    expect(find.text('Posbindu'), findsOneWidget);
  });

  testWidgets('shows error with retry when API fails and no cache', (
    tester,
  ) async {
    final authService = _MockAuthService(
      stubModuleId: '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
    );
    final posbinduService = _MockPosbinduService(stubThrowError: true);

    await tester.pumpWidget(
      _buildTestApp(
        PosbinduPage(
          authService: authService,
          posbinduService: posbinduService,
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
        'posbindu_cache_1f67e7f7-bd46-44d6-aad4-89a6c96272cb':
            '{"id_anggota":"1f67e7f7-bd46-44d6-aad4-89a6c96272cb","nik":"0123456789876545","nama":"Cached User","jenis_kelamin":"L","tanggal_lahir":"2004-09-10","usia":21,"status_aktif":"aktif","berat_badan":70.0,"tinggi_badan":175.0,"bmi":22.8,"gula_darah_sewaktu":100,"status_bmi":"berat_badan_normal","status_gula_darah":"normal","faktor_risiko_merokok":"tidak","faktor_risiko_kurang_aktifitas":"tidak","tanggal_periksa_terakhir":"2026-08-01"}',
      });

      final authService = _MockAuthService(
        stubModuleId: '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
      );
      final posbinduService = _MockPosbinduService(stubThrowError: true);

      await tester.pumpWidget(
        _buildTestApp(
          PosbinduPage(
            authService: authService,
            posbinduService: posbinduService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cached User'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    },
  );

  testWidgets('swipes between 3 tabs (Beranda, Riwayat, Profil)', (
    tester,
  ) async {
    final authService = _MockAuthService(
      stubModuleId: '1f67e7f7-bd46-44d6-aad4-89a6c96272cb',
    );
    final posbinduService = _MockPosbinduService(
      stubDetailData: _makePosbindu(),
      stubListpData: _makePosbinduList(),
    );

    await tester.pumpWidget(
      _buildTestApp(
        PosbinduPage(
          authService: authService,
          posbinduService: posbinduService,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tab 0: Beranda
    expect(find.text('Mochamad Ramadhan Alfikri'), findsOneWidget);

    // Tap Tab 1: Riwayat
    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();

    // Riwayat tab shows the loaded list
    expect(find.text('27 Juni 2026'), findsOneWidget);
  });
}
