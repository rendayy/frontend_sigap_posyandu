import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/balita/balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/balita/home_balita_header.dart';
import 'package:frontend_posyandu/widgets/balita/home_balita_sections.dart';
import 'package:frontend_posyandu/widgets/balita/home_bottom_nav.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/core/services/fcm/fcm_service.dart';

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

  @override
  void initState() {
    _balitaService = widget.balitaService ?? BalitaService();
    _authService = widget.authService ?? AuthService();
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await loadModuleData(
      helper: _helper,
      getModuleId: () => _authService.getModuleId(),
      fetchFromApi: (id) => _balitaService.getBalitaById(id),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
    );
  }

  Future<void> _logout() async {
    await FCMService().clearFcmToken();
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          HomeBalitaHeader(title: 'SIGAP Posyandu', onLogout: _logout),
          Expanded(child: _buildBody()),
          HomeBottomNav(
            currentIndex: _bottomNavIndex,
            onTap: (i) {
              setState(() => _bottomNavIndex = i);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_helper.error != null && _helper.data == null) {
      return buildModuleError(_helper.error!, _loadData);
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            if (_helper.isFromCache)
              OfflineBanner(
                isReconnecting: _helper.isReconnecting,
                onTap: _loadData,
              ),
            const SizedBox(height: 12),
            GreetingSection(name: nama, initials: initials, isLoading: showSkeleton),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileSummaryCard(
                usia: d?.usia ?? 0,
                imunisasiStatus: d?.imunisasiDasar == 'lengkap' ? 'Lengkap' : 'Tidak Lengkap',
                lastCheckupDate: d?.updatedAt != null
                    ? _formatDate(d!.updatedAt!)
                    : d?.tanggalLahir ?? '-',
                isLoading: showSkeleton,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickStatsGrid(
                tinggiBadan: d != null ? d.panjangLahir.toStringAsFixed(1) : '0',
                beratBadan: d != null ? d.beratLahir.toStringAsFixed(1) : '0',
                lingkarKepala: '-',
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }
}
