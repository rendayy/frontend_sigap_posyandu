import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/services/balita/pemantauan_balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/balita/riwayat_pemantauan_page.dart';
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
  final PemantauanListResponse? stubData;
  final bool stubThrowError;
  _MockPemantauanService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<PemantauanListResponse> getList({
    required String idBalita,
    int page = 1,
    int limit = 5,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }

  @override
  Future<PemantauanBalitaDetailResponse> getDetail({
    required String idBalita,
    required String idPantau,
  }) async {
    return PemantauanBalitaDetailResponse(
      idPantau: idPantau,
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
      imunisasi: 'BCG',
      vitaminA: 'ya',
      keluhan: 'test',
      saran: 'test',
    );
  }
}

PemantauanBalitaItem _makeItem({int no = 1, int usiaBulan = 34}) {
  return PemantauanBalitaItem(
    idPantau: 'p-00$no',
    idKader: 'k-001',
    namaKader: 'Zidan Kusuma',
    no: no,
    tanggalPantau: '2026-07-18',
    usiaBulan: usiaBulan,
    berat: 12.0,
    tinggi: 80.0,
    lingkarKepala: 48.0,
    lingkarLengan: null,
    statusGizi: 'gizi_kurang',
    imunisasi: null,
    vitaminA: 'ya',
  );
}

PemantauanListResponse _makeResponse({int totalPages = 3}) {
  return PemantauanListResponse(
    data: List.generate(5, (i) => _makeItem(no: i + 1)),
    pagination: PaginationMeta(page: 1, limit: 5, total: 14, totalPages: totalPages),
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
        stubData: _makeResponse(),
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.pumpAndSettle();

      expect(find.text('Riwayat Pemeriksaan'), findsOneWidget);
      expect(find.text('Pertumbuhan'), findsOneWidget);
      expect(find.text('Grafik'), findsOneWidget);
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
        'riwayat_pemantauan_cache_mod-001':
            '{"data":[{"id_pantau":"p-001","id_kader":"k-001","nama_kader":"Zidan Kusuma","no":1,"tanggal_pantau":"2026-07-18","usia_bulan":34,"berat":12.0,"tinggi":80.0,"lingkar_kepala":48.0,"lingkar_lengan":null,"status_gizi":"gizi_kurang","imunisasi":null,"vitamin_a":"ya"}],"pagination":{"page":1,"limit":5,"total":1,"total_pages":1},"success":true}',
      });

      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubThrowError: true);

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('18 Juli 2026'), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
      expect(find.text('Hubungkan'), findsOneWidget);
    });

    testWidgets('tab Grafik shows placeholder', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(stubData: _makeResponse());

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Halaman Grafik'), findsNothing);
    });

    testWidgets('hides Muat Lainnya when no more pages',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(
        stubData: _makeResponse(totalPages: 1),
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Muat Lainnya'), findsNothing);
    });

    testWidgets('shows error when moduleId is null', (tester) async {
      final authService = _MockAuthService(stubModuleId: null);
      final pemantauanService = _MockPemantauanService(stubData: _makeResponse());

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.textContaining('Data balita tidak ditemukan'), findsOneWidget);
    });

    testWidgets('tapping card navigates to BalitaDetailPage with idPantau',
        (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final pemantauanService = _MockPemantauanService(
        stubData: _makeResponse(totalPages: 1),
      );

      await tester.pumpWidget(_buildTestApp(
        RiwayatPemantauanPage(
          pemantauanService: pemantauanService,
          authService: authService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('18 Juli 2026'), findsNWidgets(5));
      expect(find.text('Detail pemeriksaan'), findsNothing);

      await tester.tap(find.text('18 Juli 2026').first);
      await tester.pumpAndSettle();

      expect(find.text('Detail pemeriksaan'), findsOneWidget);
      expect(find.text('12.8 kg'), findsOneWidget);
    });
  });
}