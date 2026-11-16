import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/core/services/ibu_hamil/ibu_hamil_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/greeting_ibu_hamil.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/hero_kehamilan_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/stat_row_2_widget.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/stat_row_3_widget.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/jadwal_berikutnya_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/banner_edukasi_card.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/ibu_hamil_header.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/bottom_nav_ibu_hamil.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/features/pages/ibu_hamil/riwayat_pemeriksaan_page.dart';
import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';

class IbuHamilPage extends StatefulWidget {
  final IbuHamilService? ibuHamilService;
  final AuthService? authService;

  const IbuHamilPage({super.key, this.ibuHamilService, this.authService});

  @override
  State<IbuHamilPage> createState() => _IbuHamilPageState();
}

class _IbuHamilPageState extends State<IbuHamilPage> {
  late final IbuHamilService _service;
  late final AuthService _authService;
  final _helper = ModulePageHelper<IbuHamilBerandaData>();
  final _cache = CacheManager<IbuHamilBerandaData>(
    prefix: 'ibu_hamil',
    fromJson: (json) => IbuHamilBerandaData(
      nama: json['nama'] as String? ?? '',
      inisial: json['inisial'] as String? ?? '?',
      statusLabel: json['statusLabel'] as String? ?? 'Ibu Hamil',
      kehamilan: IbuHamilKehamilanInfo(
        usiaMinggu: json['kehamilan']?['usia_minggu'] as int? ?? 0,
        trimester: json['kehamilan']?['trimester'] as int? ?? 1,
        hpl: json['kehamilan']?['hpl'] as String? ?? '-',
        totalMinggu: json['kehamilan']?['total_minggu'] as int? ?? 40,
        progressPersen: json['kehamilan']?['progress_persen'] as int? ?? 0,
        hariMenujuHpl: json['kehamilan']?['hari_menuju_hpl'] as int? ?? 0,
      ),
      vital: IbuHamilVitalInfo(
        kunjunganAnc: KunjunganAncInfo(selesai: 0),
      ),
      jadwal: const IbuHamilJadwalInfo(),
      edukasi: const IbuHamilEdukasiInfo(trimester: 1, konten: ''),
    ),
    toJson: (d) => {
      'nama': d.nama,
      'inisial': d.inisial,
      'statusLabel': d.statusLabel,
      'kehamilan': {
        'usia_minggu': d.kehamilan.usiaMinggu,
        'trimester': d.kehamilan.trimester,
        'hpl': d.kehamilan.hpl,
        'total_minggu': d.kehamilan.totalMinggu,
        'progress_persen': d.kehamilan.progressPersen,
        'hari_menuju_hpl': d.kehamilan.hariMenujuHpl,
      },
    },
  );
  int _bottomNavIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    _service = widget.ibuHamilService ?? IbuHamilService();
    _authService = widget.authService ?? AuthService();
    _pageController = PageController(initialPage: 0);
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool force = false}) async {
    await loadModuleData(
      helper: _helper,
      getModuleId: () => _authService.getModuleId(),
      fetchFromApi: (id) => _service.getBeranda(id),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
      staleAfter: force ? null : const Duration(seconds: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const IbuHamilHeader(),
            Expanded(child: _buildBody()),
            BottomNavIbuHamil(
              currentIndex: _bottomNavIndex,
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildBody() {
    return PageView(
      controller: _pageController,
      physics: const AlwaysScrollableScrollPhysics(),
      onPageChanged: (index) {
        setState(() => _bottomNavIndex = index);
      },
      children: [
        _buildHomeContent(),
        const RiwayatPemeriksaanPage(embedded: true),
        _buildPlaceholderTab('Jadwal'),
        _buildPlaceholderTab('Notifikasi'),
        const ProfilePage(),
      ],
    );
  }

  Widget _buildHomeContent() {
    if (_helper.error != null && _helper.data == null) {
      return buildModuleError(_helper.error!, () => _loadData(force: true));
    }

    final d = _helper.data;
    if (d == null) {
      return _buildContentWithSkeleton(null);
    }

    return _buildContentWithSkeleton(d);
  }

  Widget _buildContentWithSkeleton(IbuHamilBerandaData? d) {
    final showSkeleton = _helper.showSkeleton;

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (_helper.isFromCache)
              OfflineBanner(
                isReconnecting: _helper.isReconnecting,
                onTap: () => _loadData(force: true),
              ),
            const SizedBox(height: 16),
            GreetingIbuHamil(
              name: d?.nama ?? '',
              initials: d?.inisial ?? '?',
              isLoading: showSkeleton,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HeroKehamilanCard(
                usiaMinggu: d?.kehamilan.usiaMinggu ?? 0,
                trimester: d?.kehamilan.trimester ?? 1,
                progressPersen: d?.kehamilan.progressPersen ?? 0,
                hpl: d?.kehamilan.hpl ?? '-',
                hariMenujuHpl: d?.kehamilan.hariMenujuHpl ?? 0,
                totalMinggu: d?.kehamilan.totalMinggu ?? 40,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StatRow2Widget(
                beratBadanKg: d?.vital.beratBadanKg,
                deltaKg: d?.vital.beratBadanDeltaKg,
                beratBadanStatus: d?.vital.beratBadanStatus ?? 'Normal',
                tekananDarah: d?.vital.tekananDarah,
                tekananDarahTanggal: d?.vital.tekananDarahTanggal,
                tekananDarahStatus: d?.vital.tekananDarahStatus ?? 'Normal',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StatRow3Widget(
                lilaCm: d?.vital.lilaCm,
                tinggiFundusCm: d?.vital.tinggiFundusCm,
                kunjunganSelesai: d?.vital.kunjunganAnc.selesai ?? 0,
                kunjunganTarget: d?.vital.kunjunganAnc.target ?? 9,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: JadwalBerikutnyaCard(
                kunjunganKe: d?.jadwal.kunjunganKe,
                tanggal: d?.jadwal.tanggal,
                lokasi: d?.jadwal.lokasi,
                status: d?.jadwal.status ?? 'Belum Ada Pemeriksaan',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BannerEdukasiCard(
                trimester: d?.edukasi.trimester ?? 1,
                konten: d?.edukasi.konten ?? '',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(String title) {
    return Center(
      child: Text(
        '$title\n(dalam pengembangan)',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}