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
import 'package:frontend_posyandu/features/pages/remaja/riwayat_pemantauan_page.dart';
import 'package:frontend_posyandu/widgets/common/home_sections.dart';
import 'package:frontend_posyandu/widgets/remaja/home_remaja_sections.dart';
import 'package:frontend_posyandu/widgets/balita/home_bottom_nav.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';
import 'package:frontend_posyandu/features/pages/remaja/kegiatan_page.dart';
import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';

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
          HomeBottomNav(
            currentIndex: _bottomNavIndex,
            onTap: _onNavTap,
            activeColor: AppColors.emerald,
            items: const [
              NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
              NavItem(label: 'Riwayat', icon: Icons.history_outlined, activeIcon: Icons.history),
              NavItem(label: 'Kegiatan', icon: Icons.event_outlined, activeIcon: Icons.event),
              NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
            ],
          ),
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

  Widget _buildContentWithSkeleton(RemajaDetailResponse? d) {
    final showSkeleton = _helper.showSkeleton;
    final nama = d?.nama ?? '';
    final initials = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    final bmiValue = _bmiData?.bmi?.toStringAsFixed(1) ?? '-';
    final lastCheckupDate = d?.updatedAt != null
        ? formatDate(d!.updatedAt!)
        : '-';

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
              isLoading: showSkeleton,
              moduleBadge: 'Remaja',
              badgeColor: AppColors.emerald,
              badgeBgColor: AppColors.greenLight,
              avatarGradient: const [AppColors.emerald, Color(0xFF26A69A)],
            ),
            const SizedBox(height: 16),
            // Section 2: BMI Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileSummaryCard(
                label: 'Indeks Massa Tubuh (BMI)',
                heroValue: bmiValue,
                heroUnit: 'kg/m²',
                icon: Icons.monitor_heart,
                gradient: const [
                  Color(0xFF43A047),
                  Color(0xFF2E9E5B),
                  Color(0xFF26A69A),
                ],
                labelColor: const Color(0xFFE8F5E9),
                statusRow: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE8F5E9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    StatusGiziBadge(status: _bmiData?.statusGizi ?? d?.statusGizi, compact: true),
                  ],
                ),
                footerValue: lastCheckupDate,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            // Section 3: Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickStatsGrid(
                items: [
                  QuickStatItem(
                    label: 'Usia',
                    value: d != null ? '${d.usia}' : '0',
                    unit: 'Tahun',
                    icon: Icons.cake_outlined,
                    iconColor: const Color(0xFF0EA5E9),
                  ),
                  QuickStatItem(
                    label: 'Tinggi',
                    value: d != null && d.tinggiBadan != null ? d.tinggiBadan!.toStringAsFixed(1) : '-',
                    unit: 'cm',
                    icon: Icons.height,
                    iconColor: const Color(0xFFAD46FF),
                  ),
                  QuickStatItem(
                    label: 'Berat',
                    value: d != null && d.beratBadan != null ? d.beratBadan!.toStringAsFixed(1) : '-',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFFFF2B4E),
                  ),
                ],
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
