import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class _MockAuthService extends AuthService {
  _MockAuthService() : super();

  @override
  Future<String?> getModuleId() async => 'test-module';

  @override
  Future<void> logout() async {}

  @override
  Future<UserInfo?> getUserInfo() async => null;
}

class _MockCitizenService extends CitizenService {
  final ProfileResponse? stubData;
  final bool stubThrowError;
  _MockCitizenService({this.stubData, this.stubThrowError = false}) : super();

  @override
  Future<ProfileResponse> getMyProfile() async {
    if (stubThrowError) throw NetworkException();
    if (stubData != null) return stubData!;
    throw Exception('not mocked');
  }
}

ProfileResponse _makeProfile() {
  return ProfileResponse(
    idAnggota: '2d4ecbfe-b33e-404e-b580-339d7ee8fe54',
    nik: '0821433725931236',
    nama: 'Emma Elizabeth Myers',
    noHp: '089876543210',
    tempatLahir: 'Sidoarjo',
    tanggalLahir: '2002-04-02',
    jenisKelamin: 'P',
    golonganDarah: 'A',
    hubunganKeluarga: 'istri',
    kategoriAnggota: 'remaja',
    statusAktif: 'aktif',
    statusKesehatan: 'sehat',
    roles: const ['user'],
    keluarga: const KeluargaInfo(
      idKeluarga: '35483e13-b4d2-4556-b19a-69a5fdbafed5',
      noKk: '0821433725931234',
      alamat: 'JL. Raya',
      rt: '1',
      rw: '1',
      dusun: 'Ngaban',
    ),
  );
}

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
    routes: {
      '/login': (_) => const Scaffold(body: Text('Login Page')),
      '/edit-profile': (_) => const Scaffold(body: Text('Edit Profile Page')),
    },
  );
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows skeleton loading initially, then data when loaded',
      (tester) async {
    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubData: _makeProfile());

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    // Initial skeleton state — skeleton widgets should be visible
    expect(find.byType(SkeletonWidget), findsWidgets);
    expect(find.text('Emma Elizabeth Myers'), findsNothing);

    // After async load completes
    await tester.pumpAndSettle();
    await tester.pump(); // extra pump

    // Debug: print what's in the helper
    print('--- DEBUG: data is null? ${authService.getModuleId()}');
    print('--- DEBUG: pumpAndSettle done');

    // Find all Text widgets and print their data
    final allTexts = find.byType(Text);
    print('--- Total Text widgets: ${allTexts.evaluate().length}');
    for (final element in allTexts.evaluate()) {
      final text = element.widget as Text;
      print('  Text: "${text.data}"');
    }

    // Debug helper state using pumpAndSettle callback
    final profile = find.byType(ProfilePage);
    print('--- ProfilePage found? ${profile.evaluate().isNotEmpty}');
    await tester.pump(const Duration(milliseconds: 100));
    final allTexts2 = find.byType(Text);
    print('--- Total Text widgets after extra pump: ${allTexts2.evaluate().length}');
    for (final element in allTexts2.evaluate()) {
      final text = element.widget as Text;
      print('  Text2: "${text.data}"');
    }

    expect(find.text('Emma Elizabeth Myers'), findsOneWidget);
    expect(find.text('NIK: 0821433725931236'), findsOneWidget);
    expect(find.text('Sidoarjo'), findsOneWidget);
    expect(find.text('0821433725931234'), findsOneWidget);
    expect(find.text('Edit Profil'), findsOneWidget);
  });

  testWidgets('shows error with retry when API fails and no cache',
      (tester) async {
    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubThrowError: true);

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.textContaining('Tidak dapat terhubung'), findsOneWidget);
  });

  testWidgets('shows cached data with offline banner when API fails and cache exists',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'profile_cache_test-module': '{"id_anggota":"2d4ecbfe-b33e-404e-b580-339d7ee8fe54","nik":"0821433725931236","nama":"Cached Emma","no_hp":"089876543210","tempat_lahir":"Sidoarjo","tanggal_lahir":"2002-04-02","jenis_kelamin":"P","golongan_darah":"A","hubungan_keluarga":"istri","kategori_anggota":"remaja","status_aktif":"aktif","status_kesehatan":null,"roles":["user"],"keluarga":{"id_keluarga":"35483e13-b4d2-4556-b19a-69a5fdbafed5","no_kk":"0821433725931234","alamat":"JL. Raya","rt":"1","rw":"1","dusun":"Ngaban","cabang":null},"created_at":null,"updated_at":null}',
    });

    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubThrowError: true);

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Cached Emma'), findsOneWidget);
    expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
    expect(find.text('Hubungkan'), findsOneWidget);
  });

  testWidgets('renders menu items: Edit Profil and Keluar', (tester) async {
    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubData: _makeProfile());

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Edit Profil'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
  });

  testWidgets('shows logout confirmation dialog when Keluar is tapped',
      (tester) async {
    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubData: _makeProfile());

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    await tester.pumpAndSettle();

    final keluarFinder = find.text('Keluar');
    await tester.ensureVisible(keluarFinder);
    await tester.tap(keluarFinder);
    await tester.pump();

    expect(find.text('Apakah Anda yakin ingin keluar?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Ya, Keluar'), findsOneWidget);
  });

  testWidgets('shows footer version text', (tester) async {
    final authService = _MockAuthService();
    final citizenService = _MockCitizenService(stubData: _makeProfile());

    await tester.pumpWidget(_buildTestApp(
      ProfilePage(authService: authService, citizenService: citizenService),
    ));

    await tester.pumpAndSettle();

    expect(find.text('SIGAP Posyandu Warga v1.0.0'), findsOneWidget);
  });
}
