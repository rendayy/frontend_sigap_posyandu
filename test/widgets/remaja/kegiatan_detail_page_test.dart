import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:frontend_posyandu/core/api/api_client.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_detail_model.dart';
import 'package:frontend_posyandu/core/services/remaja/kegiatan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/pages/remaja/kegiatan_detail_page.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';

class _MockKegiatanRemajaService extends KegiatanRemajaService {
  final Future<KegiatanDetailResponse> Function(String) mockGetDetail;

  _MockKegiatanRemajaService({required this.mockGetDetail})
      : super(apiClient: ApiClient(customDio: Dio()));

  @override
  Future<KegiatanDetailResponse> getDetail(String idKegiatan) =>
      mockGetDetail(idKegiatan);
}

class _MockAuthService extends AuthService {
  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

const _testId = '0ec11841-bd2b-411b-8ad8-f95beddde51f';

final _sampleData = KegiatanDetailResponse(
  idKegiatan: _testId,
  judulKegiatan: 'Abogoboga',
  jenisKegiatan: 'edukasi',
  tanggal: '2026-07-31',
  waktu: '21:00:00',
  tempat: 'Aula Posyandu Melati',
  status: 'dibatalkan',
  pesertaTarget: 2,
  totalKehadiran: 0,
  persentaseKehadiran: 0,
  narasumber: 'Dr. Siti Rahayu',
  materi: null,
  createdAt: '2026-07-21T02:00:38',
  updatedAt: null,
);

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    home: child,
    routes: {
      '/login': (context) => const Scaffold(body: Text('Login Page')),
    },
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('KegiatanDetailPage', () {
    testWidgets('renders loading skeleton when loading', (tester) async {
      final completer = Completer<KegiatanDetailResponse>();
      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) => completer.future,
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));

      expect(find.byType(ListView), findsOneWidget);

      completer.complete(_sampleData);
      await tester.pumpAndSettle();
    });

    testWidgets('renders error screen when error and no cache', (tester) async {
      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) => throw const ServerException(statusCode: 404, message: 'Data tidak ditemukan.'),
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Data tidak ditemukan.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('renders offline banner when from cache', (tester) async {
      SharedPreferences.setMockInitialValues({
        'kegiatan_detail_cache_$_testId': jsonEncode(_sampleData.toJson()),
      });

      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) => throw const ServerException(statusCode: 500, message: 'Server error'),
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(find.text('Menampilkan data tersimpan'), findsOneWidget);
    });

    testWidgets('renders detail content when data loaded', (tester) async {
      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) => Future.value(_sampleData),
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Detail Kegiatan'), findsOneWidget);
      expect(find.text('Detail Informasi'), findsOneWidget);
      expect(find.text('Narasumber & Materi'), findsOneWidget);
      expect(find.text('Abogoboga'), findsOneWidget);
      expect(find.text('Edukasi'), findsOneWidget);
      expect(find.text('Dibatalkan'), findsOneWidget);
      expect(find.textContaining('31 Juli 2026'), findsOneWidget);
      expect(find.textContaining('21:00'), findsOneWidget);
      expect(find.textContaining('Aula Posyandu Melati'), findsOneWidget);
      expect(find.textContaining('Peserta Target'), findsOneWidget);
      expect(find.textContaining('2 orang'), findsOneWidget);
      expect(find.textContaining('Dr. Siti Rahayu'), findsOneWidget);
    });

    testWidgets('pull-to-refresh triggers reload', (tester) async {
      int reloadCount = 0;

      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) {
          reloadCount++;
          return Future.value(_sampleData);
        },
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));
      await tester.pumpAndSettle();

      expect(reloadCount, 1);

      await tester.fling(
        find.byType(RefreshIndicator).last,
        const Offset(0, 200),
        1000,
      );
      await tester.pumpAndSettle();

      expect(reloadCount, 2);
    });

    testWidgets('shows snackbar on refresh error', (tester) async {
      bool firstLoad = true;

      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) {
          if (firstLoad) {
            firstLoad = false;
            return Future.value(_sampleData);
          }
          throw const ServerException(statusCode: 500, message: 'Terjadi gangguan pada server. Silakan coba lagi nanti.');
        },
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(idKegiatan: _testId, service: service),
      ));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(RefreshIndicator).last,
        const Offset(0, 200),
        1000,
      );
      await tester.pumpAndSettle();

      expect(find.text('Terjadi gangguan pada server. Silakan coba lagi nanti.'), findsOneWidget);
    });

    testWidgets('navigates to login on 401', (tester) async {
      final mockAuth = _MockAuthService();
      final service = _MockKegiatanRemajaService(
        mockGetDetail: (_) => throw const ServerException(
          statusCode: 401,
          message: 'Sesi Anda telah habis. Silakan login kembali.',
        ),
      );

      await tester.pumpWidget(_buildTestApp(
        KegiatanDetailPage(
          idKegiatan: _testId,
          service: service,
          authService: mockAuth,
        ),
      ));
      await tester.pumpAndSettle();

      expect(mockAuth.logoutCalled, true);
      expect(find.text('Login Page'), findsOneWidget);
    });
  });
}
