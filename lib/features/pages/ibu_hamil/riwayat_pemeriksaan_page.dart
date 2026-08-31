import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/ibu_hamil/ibu_hamil_model.dart';
import 'package:frontend_posyandu/core/services/ibu_hamil/ibu_hamil_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/card_riwayat_kunjungan.dart';
import 'package:frontend_posyandu/widgets/ibu_hamil/grafik_card.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class RiwayatPemeriksaanPage extends StatefulWidget {
  final IbuHamilService? ibuHamilService;
  final AuthService? authService;
  final bool embedded;

  const RiwayatPemeriksaanPage({
    super.key,
    this.ibuHamilService,
    this.authService,
    this.embedded = true,
  });

  @override
  State<RiwayatPemeriksaanPage> createState() => _RiwayatPemeriksaanPageState();
}

class _RiwayatPemeriksaanPageState extends State<RiwayatPemeriksaanPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final IbuHamilService _service;
  late final AuthService _authService;
  final _cache = CacheManager<RiwayatPemeriksaanData>(
    prefix: 'riwayat_periksa',
    fromJson: RiwayatPemeriksaanData.fromJson,
    toJson: (d) => d.toJson(),
  );
  static const _staleAfter = Duration(seconds: 30);

  List<PemeriksaanIbuHamilItem> _items = [];
  PaginationMeta? _pagination;
  int _currentPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _isFromCache = false;
  String? _error;
  int _mainTab = 0;
  int _grafikSubTab = 0;
  DateTime? _lastFetchTime;

  int _trimester = 1;

  BeratBadanChartResponse? _bbChart;
  TinggiFundusChartResponse? _tfuChart;
  bool _chartLoading = false;
  String? _chartError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _service = widget.ibuHamilService ?? IbuHamilService();
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
            _error = 'Data ibu hamil tidak ditemukan';
            _loading = false;
          });
        }
        return;
      }

      final data = await _service.getRiwayatPemeriksaan(moduleId, page: 1, limit: 10);
      await _cache.save(moduleId, data);

      setState(() {
        _items = data.items;
        _sortAndRenumber();
        _pagination = data.pagination;
        _trimester = data.trimester;
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

      final moduleId = await _authService.getModuleId();
      final cached = moduleId != null ? await _cache.load(moduleId) : null;
      if (cached != null) {
        setState(() {
          _items = cached.items;
          _sortAndRenumber();
          _pagination = cached.pagination;
          _trimester = cached.trimester;
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
      final data = await _service.getRiwayatPemeriksaan(moduleId, page: nextPage, limit: 10);

      setState(() {
        _items.addAll(data.items);
        _sortAndRenumber();
        _pagination = data.pagination;
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

  void _sortAndRenumber() {
    _items.sort((a, b) {
      final aDate = a.tanggalPeriksa ?? '';
      final bDate = b.tanggalPeriksa ?? '';
      return aDate.compareTo(bDate);
    });
    for (int i = 0; i < _items.length; i++) {
      _items[i].no = i + 1;
    }
  }

  Future<void> _loadChart(int indicator) async {
    setState(() {
      _chartLoading = true;
      _chartError = null;
    });

    try {
      final moduleId = await _authService.getModuleId();
      if (moduleId == null || moduleId.isEmpty) return;

      switch (indicator) {
        case 1:
          _tfuChart = await _service.getTinggiFundusChart(moduleId);
        default:
          _bbChart = await _service.getBeratBadanChart(moduleId);
      }

      setState(() => _chartLoading = false);
    } catch (e) {
      if (isSessionExpired(e)) {
        await _authService.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        _chartError = friendlyError(e);
        _chartLoading = false;
      });
    }
  }

  void _onTapCard(PemeriksaanIbuHamilItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Detail pemeriksaan (dalam pengembangan)'),
        backgroundColor: const Color(0xFFFFA726),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    updateKeepAlive();

    if (widget.embedded) {
      return Column(
        children: [
          _buildMainTabBar(),
          Expanded(
            child: IndexedStack(
              index: _mainTab,
              children: [
                _buildKunjunganTab(),
                _buildGrafikTab(),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildMainTabBar(),
            Expanded(
              child: IndexedStack(
                index: _mainTab,
                children: [
                  _buildKunjunganTab(),
                  _buildGrafikTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(color: AppColors.white),
      child: Text(
        'Riwayat Pemeriksaan',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMainTabBar() {
    const tabs = ['Kunjungan ANC', 'Grafik'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x14000000)),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.tabTrackBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isActive = _mainTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _mainTab = i);
                  if (i == 1) {
                    _loadChart(_grafikSubTab);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.tabActiveBg : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive ? AppColors.white : AppColors.tabInactiveText,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildKunjunganTab() {
    if (_error != null && _items.isEmpty) {
      return _buildError();
    }

    if (!_loading && _items.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: false,
              onTap: _loadData,
            ),
          if (_loading && _items.isEmpty)
            ..._buildSkeletons()
          else ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '${_pagination?.total ?? _items.length} kunjungan tercatat',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ..._items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardRiwayatKunjungan(
                item: item,
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

  Widget _buildGrafikTab() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildSubTabBar(),
        const SizedBox(height: 12),
        if (_chartLoading)
          _buildChartSkeleton()
        else if (_chartError != null)
          _buildChartError()
        else if (_bbChart == null && _tfuChart == null)
          _buildChartSkeleton()
        else
          GrafikCard(
            selectedIndicator: _grafikSubTab,
            trimester: _trimester,
            bbData: _bbChart,
            tfuData: _tfuChart,
          ),
      ],
    );
  }

  Widget _buildSubTabBar() {
    const tabs = ['Berat Badan', 'Tinggi Fundus'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.tabTrackBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _grafikSubTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _grafikSubTab = i);
                _loadChart(i);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.tabActiveBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive ? AppColors.white : AppColors.tabInactiveText,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: ListView(
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(Icons.history, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat pemeriksaan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabActiveBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36, color: Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(
              _chartError ?? 'Gagal memuat grafik',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadChart(_grafikSubTab),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tabActiveBg,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkeletons() {
    return List.generate(3, (_) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildSkeletonCard(),
    ));
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(140, 12),
                const SizedBox(height: 8),
                _skeletonBox(100, 10),
                const SizedBox(height: 10),
                Row(children: [
                  _skeletonBox(50, 10),
                  const SizedBox(width: 16),
                  _skeletonBox(50, 10),
                  const SizedBox(width: 16),
                  _skeletonBox(50, 10),
                ]),
                const SizedBox(height: 4),
                _skeletonBox(50, 10),
                const SizedBox(height: 6),
                _skeletonBox(160, 10),
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

  Widget _buildChartSkeleton() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(120, 14),
          const SizedBox(height: 4),
          _skeletonBox(180, 10),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: const Color(0xFFE2E8F0)),
                  left: BorderSide(color: const Color(0xFFE2E8F0)),
                ),
              ),
              child: CustomPaint(
                painter: _DashedLinePainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: _loadingMore
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : GestureDetector(
                onTap: _loadMore,
                child: Text(
                  'Muat lebih banyak',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.tabActiveBg,
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width, startY),
        paint,
      );
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
