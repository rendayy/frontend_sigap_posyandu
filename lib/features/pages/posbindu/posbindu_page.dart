import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/posbindu/posbindu_model.dart';
import 'package:frontend_posyandu/core/models/posbindu/posbindu_bmi_status_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/features/pages/posbindu/riwayat_posbindu_page.dart';
import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';
import 'package:frontend_posyandu/widgets/balita/home_bottom_nav.dart';
import 'package:frontend_posyandu/widgets/common/home_sections.dart';
import 'package:frontend_posyandu/widgets/posbindu/home_posbindu_sections.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';
import 'package:google_fonts/google_fonts.dart';

class PosbinduPage extends StatefulWidget {
  final PosbinduService? posbinduService;
  final AuthService? authService;
  final CitizenService? citizenService;

  const PosbinduPage({
    super.key,
    this.posbinduService,
    this.authService,
    this.citizenService,
  });

  @override
  State<PosbinduPage> createState() => _PosbinduPageState();
}

class _PosbinduPageState extends State<PosbinduPage> {
  late final PosbinduService _posbinduService;
  late final AuthService _authService;
  final _helper = ModulePageHelper<PosbinduDetailResponse>();
  final _cache = CacheManager<PosbinduDetailResponse>(
    prefix: 'posbindu',
    fromJson: PosbinduDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  PosbinduBmiStatusResponse? _bmiData;
  final _bmiCache = CacheManager<PosbinduBmiStatusResponse>(
    prefix: 'posbindu_bmi',
    fromJson: PosbinduBmiStatusResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  int _bottomNavIndex = 0;
  late final PageController _pageController;

  static const _posbinduBlue = Color(0xFF162DF9);
  static const _bmiGradient = [
    Color(0xFF001BC9),
    Color(0xFF003CBC),
    Color(0xFF370096),
  ];

  @override
  void initState() {
    _posbinduService = widget.posbinduService ?? PosbinduService();
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
    String? idAnggota;
    await loadModuleData(
      helper: _helper,
      getModuleId: () async {
        final id = await _authService.getModuleId();
        if (id != null && id.isNotEmpty) return id;
        final userInfo = await _authService.getUserInfo();
        return userInfo?.idAnggota ?? '';
      },
      fetchFromApi: (id) => _posbinduService.getPosbinduDetail(id),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
      staleAfter: force ? null : const Duration(seconds: 30),
    );

    if (_helper.data != null) {
      idAnggota = _helper.data!.idAnggota;
      try {
        final bmiFetched = await _posbinduService.getBmiStatus(idAnggota);
        _bmiData = bmiFetched;
        await _bmiCache.save(idAnggota, bmiFetched);
      } catch (e) {
        final cachedBmi = await _bmiCache.load(idAnggota);
        if (cachedBmi != null) {
          _bmiData = cachedBmi;
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(top: true, bottom: false, child: _buildBody()),
          ),
          HomeBottomNav(
            currentIndex: _bottomNavIndex,
            onTap: _onNavTap,
            activeColor: _posbinduBlue,
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
        RiwayatPosbinduPage(
          embedded: true,
          service: _posbinduService,
          authService: _authService,
        ),
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

  Widget _buildContentWithSkeleton(PosbinduDetailResponse? d) {
    final showSkeleton = _helper.showSkeleton;
    final nama = d?.nama ?? '';
    final initials = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    final rawBmi = _bmiData?.bmi ?? d?.bmi;
    final bmiValue = rawBmi?.toStringAsFixed(1) ?? '-';
    final lastCheckup = d?.tanggalPeriksaTerakhir != null
        ? formatDate(d!.tanggalPeriksaTerakhir!)
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
              moduleBadge: 'Posbindu',
              badgeColor: AppColors.primary,
              badgeBgColor: AppColors.blueLight,
              avatarGradient: const [Color(0xFF3A33FF), Color(0xFF6353F5)],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileSummaryCard(
                label: 'Indeks Massa Tubuh (BMI)',
                heroValue: bmiValue,
                heroUnit: 'kg/m²',
                icon: Icons.monitor_heart,
                gradient: _bmiGradient,
                labelColor: const Color(0xFFDBE4FF),
                statusRow: Row(
                  children: [
                    Text(
                      'Status: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFDBE4FF),
                      ),
                    ),
                    const SizedBox(width: 4),
                    StatusGiziBadge(
                      status: _bmiData?.statusBmi ?? d?.statusBmi,
                      compact: true,
                    ),
                  ],
                ),
                footerValue: lastCheckup,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
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
                    value: d != null && d.tinggiBadan != null
                        ? d.tinggiBadan!.toStringAsFixed(1)
                        : '-',
                    unit: 'cm',
                    icon: Icons.height,
                    iconColor: const Color(0xFFAD46FF),
                  ),
                  QuickStatItem(
                    label: 'Berat',
                    value: d != null && d.beratBadan != null
                        ? d.beratBadan!.toStringAsFixed(1)
                        : '-',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFFFF2B4E),
                  ),
                ],
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GulaDarahCard(
                gulaDarahSewaktu: d?.gulaDarahSewaktu,
                statusGulaDarah: d?.statusGulaDarah,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FaktorRisikoCard(
                faktorRisikoMerokok: d?.faktorRisikoMerokok,
                faktorRisikoKurangAktifitas: d?.faktorRisikoKurangAktifitas,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
