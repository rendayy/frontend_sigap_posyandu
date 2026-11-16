import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/banner_edukasi_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/bottom_nav_ibu_hamil.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/card_riwayat_kunjungan.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_berat_badan.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_tinggi_fundus.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/greeting_ibu_hamil.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/hero_kehamilan_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/ibu_hamil_header.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/info_box_edukasi_grafik.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/jadwal_berikutnya_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/stat_row_2_widget.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/stat_row_3_widget.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('GreetingIbuHamil', () {
    testWidgets('renders name, initials and chip', (tester) async {
      await tester.pumpWidget(_host(
        const GreetingIbuHamil(name: 'Siti Aminah', initials: 'SA'),
      ));

      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('SA'), findsOneWidget);
      expect(find.text('Ibu Hamil'), findsOneWidget);
      expect(find.byType(SkeletonWidget), findsNothing);
    });

    testWidgets('renders skeleton while loading', (tester) async {
      await tester.pumpWidget(_host(
        const GreetingIbuHamil(name: '', initials: '', isLoading: true),
      ));

      expect(find.byType(SkeletonWidget), findsWidgets);
      expect(find.text('Ibu Hamil'), findsNothing);
    });
  });

  group('HeroKehamilanCard', () {
    testWidgets('renders usia, trimester, progress and hpl', (tester) async {
      await tester.pumpWidget(_host(
        const HeroKehamilanCard(
          usiaMinggu: 20,
          trimester: 2,
          progressPersen: 50,
          hpl: '1 Januari 2027',
          hariMenujuHpl: 190,
        ),
      ));

      expect(find.text('Usia Kehamilan'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('minggu'), findsOneWidget);
      expect(find.text('Trimester 2 · 20 minggu lagi'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Minggu 1'), findsOneWidget);
      expect(find.text('Minggu 40'), findsOneWidget);
      expect(find.text('1 Januari 2027'), findsOneWidget);
      expect(find.text('190'), findsOneWidget);
      expect(find.text('hari lagi'), findsOneWidget);
    });

    testWidgets('renders skeleton while loading', (tester) async {
      await tester.pumpWidget(_host(
        const HeroKehamilanCard(
          usiaMinggu: 0,
          trimester: 1,
          progressPersen: 0,
          hpl: '-',
          hariMenujuHpl: 0,
          isLoading: true,
        ),
      ));

      expect(find.byType(SkeletonWidget), findsWidgets);
      expect(find.text('Usia Kehamilan'), findsNothing);
    });
  });

  group('StatRow2Widget', () {
    testWidgets('renders berat badan, delta and tekanan darah', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow2Widget(
          beratBadanKg: 58.5,
          deltaKg: 1.5,
          beratBadanStatus: 'Normal',
          tekananDarah: '110/75',
          tekananDarahTanggal: '20 Agustus 2026',
          tekananDarahStatus: 'Normal',
        ),
      ));

      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('58.5'), findsOneWidget);
      expect(find.text('kg'), findsOneWidget);
      expect(find.text('+1.5 kg dari pemeriksaan lalu'), findsOneWidget);
      expect(find.text('Tekanan Darah'), findsOneWidget);
      expect(find.text('110/75'), findsOneWidget);
      expect(find.text('mmHg · 20 Agustus 2026'), findsOneWidget);
      expect(find.text('Normal'), findsNWidgets(2));
      expect(find.text('Belum ada data'), findsNothing);
    });

    testWidgets('renders placeholders when no data', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow2Widget(),
      ));

      expect(find.text('--'), findsOneWidget);
      expect(find.text('--/--'), findsOneWidget);
      expect(find.text('Belum ada data'), findsNWidgets(2));
      expect(find.text('Normal'), findsNWidgets(2));
    });

    testWidgets('renders waspada status', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow2Widget(
          beratBadanKg: 41.0,
          tekananDarah: '150/95',
          tekananDarahStatus: 'Waspada',
        ),
      ));

      expect(find.text('Waspada'), findsOneWidget);
      expect(find.text('150/95'), findsOneWidget);
    });
  });

  group('StatRow3Widget', () {
    testWidgets('renders lila, fundus and kunjungan', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow3Widget(
          lilaCm: 26.0,
          tinggiFundusCm: 22.0,
          kunjunganSelesai: 2,
        ),
      ));

      expect(find.text('LILA'), findsOneWidget);
      expect(find.text('26.0 cm'), findsOneWidget);
      expect(find.text('Tinggi Fundus'), findsOneWidget);
      expect(find.text('22.0 cm'), findsOneWidget);
      expect(find.text('Kunjungan ANC'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows Lengkap label when kunjungan >= 6', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow3Widget(kunjunganSelesai: 7),
      ));

      expect(find.text('7 Lengkap'), findsOneWidget);
    });

    testWidgets('shows dash when lila/fundus absent', (tester) async {
      await tester.pumpWidget(_host(
        const StatRow3Widget(),
      ));

      expect(find.text('-'), findsNWidgets(2));
    });
  });

  group('JadwalBerikutnyaCard', () {
    testWidgets('renders upcoming schedule', (tester) async {
      await tester.pumpWidget(_host(
        const JadwalBerikutnyaCard(
          kunjunganKe: '3',
          tanggal: '3 September 2026',
          lokasi: 'Posyandu Mawar',
          status: 'Akan Datang',
          hariLagi: 3,
        ),
      ));

      expect(find.text('Jadwal Pemeriksaan Berikutnya'), findsOneWidget);
      expect(find.text('Pemeriksaan ANC ke-3'), findsOneWidget);
      expect(find.text('3 September 2026'), findsOneWidget);
      expect(find.text('Posyandu Mawar'), findsOneWidget);
      expect(find.text('Akan Datang'), findsOneWidget);
      expect(find.text('3 hari lagi'), findsOneWidget);
    });

    testWidgets('renders empty state when belum ada pemeriksaan', (tester) async {
      await tester.pumpWidget(_host(
        const JadwalBerikutnyaCard(status: 'Belum Ada Pemeriksaan'),
      ));

      expect(find.text('Belum Ada Pemeriksaan'), findsOneWidget);
      expect(find.textContaining('ANC ke-'), findsNothing);
      expect(find.textContaining('hari lagi'), findsNothing);
    });

    testWidgets('renders skeleton while loading', (tester) async {
      await tester.pumpWidget(_host(
        const JadwalBerikutnyaCard(isLoading: true),
      ));

      expect(find.byType(SkeletonWidget), findsWidgets);
      expect(find.text('Jadwal Pemeriksaan Berikutnya'), findsNothing);
    });
  });

  group('BannerEdukasiCard', () {
    testWidgets('renders trimester and konten', (tester) async {
      await tester.pumpWidget(_host(
        const BannerEdukasiCard(
          trimester: 2,
          konten: 'Trimester kedua adalah masa paling nyaman.',
        ),
      ));

      expect(find.text('Trimester 2'), findsOneWidget);
      expect(find.text('Trimester kedua adalah masa paling nyaman.'), findsOneWidget);
    });

    testWidgets('renders skeleton while loading', (tester) async {
      await tester.pumpWidget(_host(
        const BannerEdukasiCard(trimester: 1, konten: '', isLoading: true),
      ));

      expect(find.byType(SkeletonWidget), findsWidgets);
      expect(find.text('Trimester 1'), findsNothing);
    });
  });

  group('CardRiwayatKunjungan', () {
    testWidgets('renders item fields', (tester) async {
      final item = PemeriksaanIbuHamilItem(
        idPeriksa: 'px-1',
        tanggalPeriksa: '2026-08-20',
        usiaKehamilan: 20,
        beratBadan: 58.5,
        sistol: 110,
        distol: 75,
        lingkarLengan: 26.0,
        tinggiFundus: 22.0,
        keluhan: 'Mual ringan',
        no: 2,
      );

      await tester.pumpWidget(_host(CardRiwayatKunjungan(item: item)));

      expect(find.text('20'), findsOneWidget);
      expect(find.text('Agu'), findsOneWidget);
      expect(find.text('ANC ke-2'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
      expect(find.text('Usia 20 minggu · 20 Agu 2026'), findsOneWidget);
      expect(find.text('58.5 kg'), findsOneWidget);
      expect(find.text('110/75'), findsOneWidget);
      expect(find.text('22 cm'), findsOneWidget);
      expect(find.text('26.0 cm'), findsOneWidget);
      expect(find.text('Keluhan: Mual ringan'), findsOneWidget);
    });

    testWidgets('falls back when tanggal is missing', (tester) async {
      final item = PemeriksaanIbuHamilItem(idPeriksa: 'px-2', no: 1);

      await tester.pumpWidget(_host(CardRiwayatKunjungan(item: item)));

      expect(find.text('ANC ke-1'), findsOneWidget);
      expect(find.text('Keluhan: Tidak ada keluhan.'), findsOneWidget);
      expect(find.text('- kg'), findsOneWidget);
      expect(find.text('-/-'), findsOneWidget);
    });

    testWidgets('fires onTap callback', (tester) async {
      var tapped = false;
      final item = PemeriksaanIbuHamilItem(idPeriksa: 'px-1');

      await tester.pumpWidget(_host(
        CardRiwayatKunjungan(item: item, onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(CardRiwayatKunjungan));
      expect(tapped, true);
    });
  });

  group('GrafikCard', () {
    testWidgets('renders berat badan chart on default indicator', (tester) async {
      await tester.pumpWidget(_host(
        GrafikCard(
          selectedIndicator: 0,
          trimester: 2,
          bbData: BeratBadanChartResponse(
            measurements: [
              ChartMeasurement(minggu: 16, nilai: 55.5),
              ChartMeasurement(minggu: 20, nilai: 57.0),
            ],
          ),
        ),
      ));

      expect(find.text('Berat Badan (kg)'), findsOneWidget);
      expect(find.text('per kunjungan'), findsOneWidget);
      expect(find.text('Penambahan BB ideal: 0.4–0.6 kg/minggu di trimester 2'), findsOneWidget);
      expect(find.text('BB'), findsOneWidget);
      expect(find.text('Batas Atas'), findsOneWidget);
      expect(find.text('Batas Bawah'), findsOneWidget);
      expect(find.textContaining('Kenaikan berat badan selama kehamilan'), findsOneWidget);
    });

    testWidgets('renders tinggi fundus chart on indicator 1', (tester) async {
      await tester.pumpWidget(_host(
        GrafikCard(
          selectedIndicator: 1,
          tfuData: TinggiFundusChartResponse(
            measurements: [
              ChartMeasurement(minggu: 16, nilai: 20.0),
              ChartMeasurement(minggu: 20, nilai: 22.0),
            ],
          ),
        ),
      ));

      expect(find.text('Tinggi Fundus (cm)'), findsOneWidget);
      expect(find.text('TFU normal ≈ usia kehamilan (minggu) ± 2 cm'), findsOneWidget);
      expect(find.text('TFU'), findsOneWidget);
      expect(find.text('Standar'), findsOneWidget);
    });

    testWidgets('shows loading fallback when chart data is null', (tester) async {
      await tester.pumpWidget(_host(
        const GrafikCard(selectedIndicator: 0),
      ));

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(_host(
        const GrafikCard(selectedIndicator: 1),
      ));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('GrafikBeratBadan', () {
    testWidgets('renders chart summary and legend', (tester) async {
      await tester.pumpWidget(_host(
        GrafikBeratBadan(
          data: BeratBadanChartResponse(
            measurements: [
              ChartMeasurement(minggu: 16, nilai: 55.5),
              ChartMeasurement(minggu: 20, nilai: 57.0),
            ],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Minggu kehamilan'), findsOneWidget);
      expect(find.text('BB'), findsOneWidget);
      expect(find.text('Batas Atas'), findsOneWidget);
      expect(find.text('Batas Bawah'), findsOneWidget);
      expect(find.text('Awal'), findsOneWidget);
      expect(find.text('55.5 kg'), findsOneWidget);
      expect(find.text('Terakhir'), findsOneWidget);
      expect(find.text('57.0 kg'), findsOneWidget);
      expect(find.text('+1.5 kg'), findsOneWidget);
    });

    testWidgets('shows insufficient data message with < 2 measurements', (tester) async {
      await tester.pumpWidget(_host(
        GrafikBeratBadan(
          data: BeratBadanChartResponse(
            measurements: [ChartMeasurement(minggu: 16, nilai: 55.5)],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Data belum cukup untuk menampilkan grafik'), findsOneWidget);
    });
  });

  group('GrafikTinggiFundus', () {
    testWidgets('renders chart summary and legend', (tester) async {
      await tester.pumpWidget(_host(
        GrafikTinggiFundus(
          data: TinggiFundusChartResponse(
            measurements: [
              ChartMeasurement(minggu: 16, nilai: 20.0),
              ChartMeasurement(minggu: 20, nilai: 22.0),
            ],
            standar: [
              ChartReferencePoint(minggu: 16, nilai: 18.0),
              ChartReferencePoint(minggu: 20, nilai: 22.0),
            ],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('TFU'), findsOneWidget);
      expect(find.text('Standar'), findsOneWidget);
      expect(find.text('20.0 cm'), findsOneWidget);
      expect(find.text('22.0 cm'), findsOneWidget);
    });

    testWidgets('shows insufficient data message with < 2 measurements', (tester) async {
      await tester.pumpWidget(_host(
        GrafikTinggiFundus(
          data: TinggiFundusChartResponse(
            measurements: [ChartMeasurement(minggu: 16, nilai: 20.0)],
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('Data belum cukup untuk menampilkan grafik'), findsOneWidget);
    });
  });

  group('InfoBoxEdukasiGrafik', () {
    testWidgets('renders konten', (tester) async {
      await tester.pumpWidget(_host(
        const InfoBoxEdukasiGrafik(konten: 'Pantau terus setiap kunjungan.'),
      ));

      expect(find.text('Pantau terus setiap kunjungan.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('IbuHamilHeader', () {
    testWidgets('renders brand and fires notif tap', (tester) async {
      var tapped = 0;
      await tester.pumpWidget(_host(
        IbuHamilHeader(onNotifTap: () => tapped++),
      ));

      expect(find.text('SIGAP Posyandu'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      expect(tapped, 1);
    });
  });

  group('BottomNavIbuHamil', () {
    testWidgets('renders five nav items and reports index', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(_host(
        BottomNavIbuHamil(onTap: (i) => tappedIndex = i),
      ));

      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Jadwal'), findsOneWidget);
      expect(find.text('Notifikasi'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      await tester.tap(find.text('Riwayat'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Profil'));
      expect(tappedIndex, 4);
    });
  });
}