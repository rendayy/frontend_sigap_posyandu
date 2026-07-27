import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/remaja/remaja_model.dart';
import 'package:frontend_posyandu/core/models/remaja/bmi_status_model.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/remaja_service.dart';
import 'package:frontend_posyandu/core/services/remaja/kegiatan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_header.dart';
import 'package:frontend_posyandu/features/pages/remaja/riwayat_pemantauan_page.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_sections.dart';
import 'package:frontend_posyandu/widgets/remaja/home_bottom_nav_remaja.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/features/pages/remaja/kegiatan_page.dart';
import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';

class RemajaPage extends StatefulWidget {
  final RemajaService? remajaService;
  final AuthService? authService;

  const RemajaPage({super.key, this.remajaService, this.authService});

  @override
  State<RemajaPage> createState() => _RemajaPageState();
}

class _RemajaPageState extends State<RemajaPage> {
  late final RemajaService _remajaService;
  late final AuthService _authService;
  final _helper = ModulePageHelper<RemajaDetailResponse>();
  final _cache = CacheManager<RemajaDetailResponse>(
    prefix: 'remaja',
    fromJson: RemajaDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  BmiStatusResponse? _bmiData;
  final _bmiCache = CacheManager<BmiStatusResponse>(
    prefix: 'remaja_bmi',
    fromJson: BmiStatusResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  late final KegiatanRemajaService _kegiatanService;
  List<KegiatanRemajaItem>? _kegiatanItems;
  final _kegiatanCache = CacheManager<KegiatanRemajaListResponse>(
    prefix: 'remaja_kegiatan_home',
    fromJson: KegiatanRemajaListResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  int _bottomNavIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    _remajaService = widget.remajaService ?? RemajaService();
    _kegiatanService = KegiatanRemajaService();
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
    String? moduleId;
    await loadModuleData(
      helper: _helper,
      getModuleId: () => _authService.getModuleId(),
      fetchFromApi: (id) => _remajaService.getRemajaById(id),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
      staleAfter: force ? null : const Duration(seconds: 30),
    );

    // Load BMI status after main data
    if (_helper.data != null) {
      moduleId = _helper.data!.idRemaja;
      try {
        final bmiFetched = await _remajaService.getBmiStatus(moduleId);
        _bmiData = bmiFetched;
        await _bmiCache.save(moduleId, bmiFetched);
      } catch (e) {
        final cachedBmi = await _bmiCache.load(moduleId);
        if (cachedBmi != null) {
          _bmiData = cachedBmi;
        }
      }
      setState(() {});
    }

    // Load kegiatan data for home section
    try {
      final kegiatanResponse = await _kegiatanService.getList(page: 1, limit: 2);
      _kegiatanItems = kegiatanResponse.data;
      await _kegiatanCache.save('list', kegiatanResponse);
    } catch (e) {
      final cachedKegiatan = await _kegiatanCache.load('list');
      if (cachedKegiatan != null) {
        _kegiatanItems = cachedKegiatan.data;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(top: false, bottom: false, child: _buildBody()),
          ),
          HomeBottomNavRemaja(currentIndex: _bottomNavIndex, onTap: _onNavTap),
        ],
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
        RiwayatPemantauanPage(embedded: true, idRemaja: _helper.data?.idRemaja),
        const KegiatanPage(embedded: true),
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildContentWithSkeleton(RemajaDetailResponse? d) {
    final showSkeleton = _helper.showSkeleton;
    final nama = d?.nama ?? '';
    final initials = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

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
            const SizedBox(height: 12),
            GreetingSection(
              name: nama,
              initials: initials,
              moduleName: 'Remaja',
              isLoading: showSkeleton,
            ),
            const SizedBox(height: 16),
            // Section 2: BMI Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileSummaryCard(
                bmi: _bmiData?.bmi,
                statusGizi: _bmiData?.statusGizi ?? d?.statusGizi,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            // Section 3: Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickStatsGrid(
                usia: d?.usia ?? 0,
                tinggiBadan: d != null && d.tinggiBadan != null
                    ? d.tinggiBadan!.toStringAsFixed(1)
                    : '-',
                beratBadan: d != null && d.beratBadan != null
                    ? d.beratBadan!.toStringAsFixed(1)
                    : '-',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            // Dedicated Section: Riwayat Anemia
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AnemiaCard(
                riwayatAnemia: d?.riwayatAnemia ?? 'tidak',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            // Section: Info Akademik & Hobi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InfoSectionCard(
                sekolah: d?.sekolah,
                kelas: d?.kelas,
                hobi: d?.hobi,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            // Section: Kegiatan Terdekat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: KegiatanHomeCard(
                items: _kegiatanItems,
                isLoading: showSkeleton,
                onLihatSemua: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Section 5: Footer
            FooterSection(
              lastCheckupDate: d?.updatedAt != null
                  ? _formatDate(d!.updatedAt!)
                  : '-',
              isLoading: showSkeleton,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
