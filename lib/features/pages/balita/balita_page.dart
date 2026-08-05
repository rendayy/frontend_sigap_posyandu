import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/features/pages/balita/riwayat_pemantauan_page.dart';
import 'package:frontend_posyandu/widgets/common/home_sections.dart';
import 'package:frontend_posyandu/widgets/balita/home_bottom_nav.dart';
import 'package:frontend_posyandu/widgets/balita/home_balita_sections.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';

import 'package:frontend_posyandu/features/pages/profil/profile_page.dart';

class BalitaPage extends StatefulWidget {
  final BalitaService? balitaService;
  final AuthService? authService;

  const BalitaPage({super.key, this.balitaService, this.authService});

  @override
  State<BalitaPage> createState() => _BalitaPageState();
}

class _BalitaPageState extends State<BalitaPage> {
  late final BalitaService _balitaService;
  late final AuthService _authService;
  final _helper = ModulePageHelper<BalitaDetailResponse>();
  final _cache = CacheManager<BalitaDetailResponse>(
    prefix: 'balita',
    fromJson: BalitaDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  int _bottomNavIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    _balitaService = widget.balitaService ?? BalitaService();
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
      fetchFromApi: (id) => _balitaService.getBalitaById(id),
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              top: true,
              bottom: false,
              child: _buildBody(),
            ),
          ),
          HomeBottomNav(
            currentIndex: _bottomNavIndex,
            onTap: _onNavTap,
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
        const RiwayatPemantauanPage(embedded: true),
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

  Widget _buildContentWithSkeleton(BalitaDetailResponse? d) {
    final showSkeleton = _helper.showSkeleton;
    final nama = d?.nama ?? '';
    final initials = nama.isNotEmpty ? nama[0].toUpperCase() : '?';

    final isLengkap = d?.imunisasiDasar == 'lengkap';
    final lastCheckupDate = d?.updatedAt != null
        ? formatDate(d!.updatedAt!)
        : d?.tanggalLahir ?? '-';

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
              moduleBadge: 'Balita',
              badgeColor: AppColors.pinkVivid,
              badgeBgColor: AppColors.pinkLight,
              avatarGradient: const [AppColors.orange, AppColors.beige],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileSummaryCard(
                label: 'Usia Balita',
                heroValue: d != null ? '${d.usia}' : '0',
                heroUnit: 'Bulan',
                icon: Icons.child_care,
                gradient: const [AppColors.gold, AppColors.orange, AppColors.goldDark],
                labelColor: AppColors.pinkLight,
                statusRow: Row(
                  children: [
                    Text(
                      'Imunisasi: ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.pinkLight,
                      ),
                    ),
                    Text(
                      isLengkap ? 'Lengkap' : 'Tidak Lengkap',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                footerValue: lastCheckupDate,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickStatsGrid(
                items: [
                  QuickStatItem(
                    label: 'Tinggi Badan',
                    value: d != null ? d.panjangLahir.toStringAsFixed(1) : '0',
                    unit: 'cm',
                    icon: Icons.height,
                    iconColor: const Color(0xFFAD46FF),
                  ),
                  QuickStatItem(
                    label: 'Berat Badan',
                    value: d != null ? d.beratLahir.toStringAsFixed(1) : '0',
                    unit: 'kg',
                    icon: Icons.monitor_weight_outlined,
                    iconColor: const Color(0xFFFF2B4E),
                  ),
                  const QuickStatItem(
                    label: 'Lingkar Kepala',
                    value: '-',
                    unit: 'cm',
                    icon: Icons.adjust,
                    iconColor: Color(0xFF00C950),
                  ),
                ],
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatusGiziInfoCard(
                statusGizi: d?.statusGizi,
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ImunisasiCard(
                imunisasiStatus: d?.imunisasiDasar ?? '',
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