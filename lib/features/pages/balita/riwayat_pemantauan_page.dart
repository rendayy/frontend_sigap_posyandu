import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/core/services/balita/pemantauan_balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/features/pages/balita/balita_detail_page.dart';
import 'package:frontend_posyandu/features/pages/balita/growth_chart_page.dart';
import 'package:frontend_posyandu/widgets/common/pemantauan_item_card.dart';
import 'package:frontend_posyandu/widgets/common/error_state_widget.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/balita/home_bottom_nav.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/empty_state_widget.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class RiwayatPemantauanPage extends StatefulWidget {
  final PemantauanBalitaService? pemantauanService;
  final BalitaService? balitaService;
  final AuthService? authService;
  final bool embedded;

  const RiwayatPemantauanPage({
    super.key,
    this.pemantauanService,
    this.balitaService,
    this.authService,
    this.embedded = false,
  });

  @override
  State<RiwayatPemantauanPage> createState() => _RiwayatPemantauanPageState();
}

class _RiwayatPemantauanPageState extends State<RiwayatPemantauanPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final PemantauanBalitaService _service;
  late final AuthService _authService;
  final _cache = CacheManager<PemantauanListResponse>(
    prefix: 'riwayat_pemantauan',
    fromJson: PemantauanListResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  static const _staleAfter = Duration(seconds: 30);

  List<PemantauanBalitaItem> _items = [];
  PaginationMeta? _pagination;
  int _currentPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _isFromCache = false;
  final bool _isReconnecting = false;
  String? _error;
  int _selectedTab = 0;
  int _navIndex = 1;
  DateTime? _lastFetchTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _service = widget.pemantauanService ?? PemantauanBalitaService();
    _authService = widget.authService ?? AuthService();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.embedded) {
      _silentRefreshIfStale();
    }
  }

  void _silentRefreshIfStale() {
    if (_items.isEmpty) return;
    if (_lastFetchTime == null) return;
    if (DateTime.now().difference(_lastFetchTime!) < _staleAfter) return;
    _loadData(silent: true);
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent && _items.isNotEmpty && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _staleAfter) {
      return;
    }

    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
        _isFromCache = false;
        _currentPage = 1;
      });
    }

    try {
      final moduleId = await _authService.getModuleId();
      if (moduleId == null || moduleId.isEmpty) {
        if (!silent) {
          setState(() {
            _error = 'Data balita tidak ditemukan';
            _loading = false;
          });
        }
        return;
      }

      final response = await _service.getList(
        idBalita: moduleId,
        page: 1,
        limit: 5,
      );

      await _cache.save(moduleId, response);

      setState(() {
        _items = response.data;
        _pagination = response.pagination;
        _currentPage = 1;
        _loading = false;
        _isFromCache = false;
        _lastFetchTime = DateTime.now();
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        await _cache.clear('');
        await _authService.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (silent) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final cached = await _cache.load(await _authService.getModuleId() ?? '');
      if (cached != null) {
        setState(() {
          _items = cached.data;
          _pagination = cached.pagination;
          _currentPage = 1;
          _isFromCache = true;
          _loading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      } else {
        setState(() {
          _error = friendlyError(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _pagination == null || !_pagination!.hasMore) return;

    setState(() => _loadingMore = true);

    try {
      final moduleId = await _authService.getModuleId();
      if (moduleId == null || moduleId.isEmpty) return;

      final nextPage = _currentPage + 1;
      final response = await _service.getList(
        idBalita: moduleId,
        page: nextPage,
        limit: 5,
      );

      setState(() {
        _items.addAll(response.data);
        _pagination = response.pagination;
        _currentPage = nextPage;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyError(e))),
      );
    }
  }

  void _onTapCard(PemantauanBalitaItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BalitaDetailPage(
          idPantau: item.idPantau,
          pemantauanService: _service,
          authService: _authService,
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _navIndex = index);
    if (index == 0) {
      Navigator.pop(context);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.embedded) {
      return Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildPertumbuhanTab(),
                _buildGrafikTab(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Riwayat Pemeriksaan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _buildPertumbuhanTab(),
                _buildGrafikTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Pertumbuhan', 'Grafik'];
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x14000000)),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _selectedTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isActive ? const Color(0xFFF97316) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? const Color(0xFFF97316)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGrafikTab() {
    return GrowthChartPage(
      embedded: true,
      balitaService: widget.balitaService,
      authService: _authService,
    );
  }

  Widget _buildPertumbuhanTab() {
    if (_error != null && _items.isEmpty) {
      return _buildError();
    }

    if (!_loading && _items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadData(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            EmptyStateWidget(
              icon: Icons.child_care_outlined,
              title: 'Belum Ada Data Pertumbuhan',
              subtitle: 'Riwayat pertumbuhan balita akan muncul setelah kader melakukan pencatatan.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: _loadData,
            ),
          if (_loading && _items.isEmpty)
            ..._buildSkeletons()
          else ...[
            ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PemantauanItemCard(
                date: formatDate(item.tanggalPantau),
                status: item.statusGizi,
                avatarMain: '${item.usiaBulan}',
                avatarSub: 'bln',
                avatarFg: const Color(0xFFF97316),
                avatarBg: const Color(0xFFFFF7ED),
                metrics: [
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_berat_badan.svg',
                    text: '${item.berat.toStringAsFixed(1)} kg',
                  ),
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_tinggi_badan.svg',
                    text: '${item.tinggi.toStringAsFixed(1)} cm',
                  ),
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_lingkar_kepala.svg',
                    text: item.lingkarKepala != null
                        ? '${item.lingkarKepala!.toStringAsFixed(1)} cm'
                        : '- cm',
                  ),
                ],
                onTap: () => _onTapCard(item),
              ),
            )),
            if (_pagination != null && _pagination!.hasMore)
              _buildLoadMoreButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return ErrorStateWidget(
      message: _error ?? 'Terjadi kesalahan',
      onRetry: _loadData,
    );
  }

  List<Widget> _buildSkeletons() {
    return List.generate(
      3,
      (_) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _skeletonBox(50, 10),
                    const SizedBox(width: 16),
                    _skeletonBox(50, 10),
                    const SizedBox(width: 16),
                    _skeletonBox(50, 10),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: _loadMore,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.orange,
            side: const BorderSide(color: AppColors.orange),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: _loadingMore
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.orange,
                  ),
                )
              : Text(
                  'Muat Lainnya',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}