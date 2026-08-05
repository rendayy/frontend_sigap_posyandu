import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_detail_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/posbindu/pemeriksaan_posbindu_detail_page.dart';

class _MockAuthService extends AuthService {
  final String? stubModuleId;
  _MockAuthService({this.stubModuleId}) : super();

  @override
  Future<String?> getModuleId() async => stubModuleId;

  @override
  Future<void> logout() async {}
}

class _MockPosbinduService extends PosbinduService {
  final PemeriksaanPosbinduDetailResponse? stubDetailData;
  final bool stubThrowError;
  _MockPosbinduService({this.stubDetailData, this.stubThrowError = false})
    : super();

  @override
  Future<PemeriksaanPosbinduDetailResponse> getDetail({
    required String idAnggota,
    required String idPeriksaPosbindu,
  }) async {
    if (stubThrowError) throw NetworkException();
    if (stubDetailData != null) return stubDetailData!;
    throw Exception('not mocked');
  }
}

PemeriksaanPosbinduDetailResponse _makeDetailResponse() {
  return PemeriksaanPosbinduDetailResponse(
    idPeriksaPosbindu: '961a6b2e-1234-5678-9abc-def012345678',
    idAnggota: '1bee01e5-abcd-ef12-3456-789abcdef012',
    idKader: '49568e7c-abcd-ef12-3456-789abcdef012',
    idCabang: '0bb10b9e-abcd-ef12-3456-789abcdef012',
    tanggalPeriksa: '2026-06-27',
    beratBadan: 60.65,
    tinggiBadan: 170.0,
    bmi: 21.0,
    lingkarPerut: 73.2,
    sistol: 116,
    distol: 79,
    gulaDarahSewaktu: 105,
    kolesterolTotal: 165,
    asamUrat: 4.2,
    statusBmi: 'berat_badan_normal',
    statusGulaDarah: 'normal',
    statusRujukan: 'tidak',
    faktorRisikoMerokok: 'tidak',
    faktorRisikoKurangAktifitas: 'tidak',
    keluhan: 'Tidak ada keluhan.',
    saran: 'Pertahankan gaya hidup sehat.',
    catatan: 'Pemeriksaan rutin bulan ke-10. Kondisi sangat baik.',
    riwayatPenyakitKeluarga: 'Tidak ada riwayat penyakit serius.',
    createdAt: '2026-07-27T16:29:46',
    updatedAt: '2026-07-27T16:29:46',
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

  group('PemeriksaanPosbinduDetailPage', () {
    testWidgets('shows skeleton loading initially, then data when loaded', (
      tester,
    ) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: '961a6b2e-1234-5678-9abc-def012345678',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Detail Pemeriksaan'), findsOneWidget);
      expect(find.text('Data Pengukuran'), findsOneWidget);
      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('60.65 kg'), findsOneWidget);
      expect(find.text('Tinggi Badan'), findsOneWidget);
      expect(find.text('170.0 cm'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);
      expect(find.text('21.0 kg/m²'), findsOneWidget);
    });

    testWidgets('shows all measurement sections', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lab'), findsOneWidget);
      expect(find.text('Gula Darah Sewaktu'), findsOneWidget);
      expect(find.text('105 mg/dL'), findsOneWidget);
      expect(find.text('Kolesterol Total'), findsOneWidget);
      expect(find.text('165 mg/dL'), findsOneWidget);
      expect(find.text('Asam Urat'), findsOneWidget);
      expect(find.text('4.2 mg/dL'), findsOneWidget);
    });

    testWidgets('shows status section', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Status'), 200);

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Tekanan Darah'), findsOneWidget);
      expect(find.text('Sistol'), findsOneWidget);
      expect(find.text('116 mmHg'), findsOneWidget);
      expect(find.text('Distol'), findsOneWidget);
      expect(find.text('79 mmHg'), findsOneWidget);
      expect(find.text('Status Gula Darah'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);
      expect(find.text('Status Rujukan'), findsOneWidget);
      expect(find.text('Tidak'), findsOneWidget);
    });

    testWidgets('shows faktor risiko section when present', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Faktor Risiko'), 200);

      expect(find.text('Faktor Risiko'), findsOneWidget);
    });

    testWidgets('shows catatan petugas section when present', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(find.text('Catatan Petugas'), 200);

      expect(find.text('Catatan Petugas'), findsOneWidget);
      expect(find.text('Keluhan'), findsOneWidget);
      expect(find.text('Saran'), findsOneWidget);
      expect(find.text('Catatan'), findsOneWidget);
      expect(find.text('Riwayat Penyakit Keluarga'), findsOneWidget);
    });

    testWidgets('shows error with retry when API fails and no cache', (
      tester,
    ) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(stubThrowError: true);

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
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
          'posbindu_pemeriksaan_detail_cache_mod-001_test-id_ts': DateTime.now()
              .toIso8601String(),
          'posbindu_pemeriksaan_detail_cache_mod-001_test-id':
              '{"id_periksa_posbindu":"test-id","id_anggota":"mod-001","id_kader":"k-001","id_cabang":"c-001","tanggal_periksa":"2026-06-27","berat_badan":60.65,"tinggi_badan":170.0,"bmi":21.0,"lingkar_perut":73.2,"sistol":116,"distol":79,"gula_darah_sewaktu":105,"kolesterol_total":165,"asam_urat":4.2,"status_bmi":"berat_badan_normal","status_gula_darah":"normal","status_rujukan":"tidak","faktor_risiko_merokok":"tidak","faktor_risiko_kurang_aktifitas":"tidak","keluhan":null,"saran":null,"catatan":null,"riwayat_penyakit_keluarga":null,"created_at":null,"updated_at":null}',
        });

        final authService = _MockAuthService(stubModuleId: 'mod-001');
        final posbinduService = _MockPosbinduService(stubThrowError: true);

        await tester.pumpWidget(
          _buildTestApp(
            PemeriksaanPosbinduDetailPage(
              idPeriksa: 'test-id',
              service: posbinduService,
              authService: authService,
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('60.65 kg'), findsOneWidget);
        expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
        expect(find.text('Hubungkan'), findsOneWidget);
      },
    );

    testWidgets('shows read-only note at bottom', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.textContaining('Data bersifat read-only'),
        200,
      );

      expect(find.textContaining('Data bersifat read-only'), findsOneWidget);
    });

    testWidgets('handles null values gracefully', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: PemeriksaanPosbinduDetailResponse(
          idPeriksaPosbindu: 'test-id',
          idAnggota: 'mod-001',
          idKader: 'k-001',
          idCabang: 'c-001',
          tanggalPeriksa: '2026-06-27',
          beratBadan: null,
          tinggiBadan: null,
          bmi: null,
          lingkarPerut: null,
          sistol: null,
          distol: null,
          gulaDarahSewaktu: null,
          kolesterolTotal: null,
          asamUrat: null,
          statusBmi: null,
          statusGulaDarah: null,
          statusRujukan: null,
          faktorRisikoMerokok: null,
          faktorRisikoKurangAktifitas: null,
          keluhan: null,
          saran: null,
          catatan: null,
          riwayatPenyakitKeluarga: null,
          createdAt: null,
          updatedAt: null,
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Data Pengukuran'), findsOneWidget);
      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('- kg'), findsOneWidget);
      expect(find.text('Tinggi Badan'), findsOneWidget);
      expect(find.text('- cm'), findsOneWidget);
    });

    testWidgets('pull-to-refresh works', (tester) async {
      final authService = _MockAuthService(stubModuleId: 'mod-001');
      final posbinduService = _MockPosbinduService(
        stubDetailData: _makeDetailResponse(),
      );

      await tester.pumpWidget(
        _buildTestApp(
          PemeriksaanPosbinduDetailPage(
            idPeriksa: 'test-id',
            service: posbinduService,
            authService: authService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      expect(find.text('Detail Pemeriksaan'), findsOneWidget);
    });
  });
}
