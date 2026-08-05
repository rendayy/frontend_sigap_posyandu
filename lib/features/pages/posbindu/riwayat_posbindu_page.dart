import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/features/pages/posbindu/pemeriksaan_posbindu_detail_page.dart';
import 'package:frontend_posyandu/features/pages/posbindu/gula_darah_chart_page.dart';
import 'package:frontend_posyandu/widgets/common/pemantauan_item_card.dart';
import 'package:frontend_posyandu/widgets/common/error_state_widget.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/widgets/common/empty_state_widget.dart';

class RiwayatPosbinduPage extends StatefulWidget {
  final bool embedded;
  final PosbinduService? service;
  final AuthService? authService;

  const RiwayatPosbinduPage({
    super.key,
    this.embedded = false,
    this.service,
    this.authService,
  });

  @override
  State<RiwayatPosbinduPage> createState() => _RiwayatPosbinduPageState();
}

class _RiwayatPosbinduPageState extends State<RiwayatPosbinduPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const _posbinduBlue = Color(0xFF162DF9);

  late final PosbinduService _service;
  late final AuthService _authService;
  final _cache = CacheManager<PemeriksaanPosbinduListResponse>(
    prefix: 'posbindu_pemeriksaan',
    fromJson: PemeriksaanPosbinduListResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  List<PemeriksaanPosbinduItem> _items = [];
  PaginationMeta? _pagination;
  int _currentPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  int _selectedTab = 0;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PosbinduService();
    _authService = widget.authService ?? AuthService();
    if (!widget.embedded) {
      WidgetsBinding.instance.addObserver(this);
    }
    _loadData();
  }

  @override
  void dispose() {
    if (!widget.embedded) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !widget.embedded) {
      _silentRefreshIfStale();
    }
  }

  bool get _isStale {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >
        const Duration(seconds: 30);
  }

  Future<void> _silentRefreshIfStale() async {
    if (!_isStale || _items.isEmpty) return;
    await _loadData(silent: true);
  }

  Future<String?> _getIdAnggota() async {
    if (widget.embedded) {
      return _authService.getModuleId();
    }
    return _authService.getModuleId();
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && !silent && !_isStale && _items.isNotEmpty) return;

    final idAnggota = await _getIdAnggota();
    if (idAnggota == null || idAnggota.isEmpty) {
      if (!silent) {
        setState(() {
          _error = 'ID anggota tidak ditemukan';
          _loading = false;
        });
      }
      return;
    }

    if (!silent) {
      setState(() {
        _loading = true;
        _isReconnecting = _isFromCache;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final response = await _service.getList(
        idAnggota: idAnggota,
        page: 1,
        limit: 10,
      );

      await _cache.save(idAnggota, response);

      setState(() {
        _items = response.data;
        _pagination = response.pagination;
        _currentPage = 1;
        _lastFetchTime = DateTime.now();
        _isFromCache = false;
        _isReconnecting = false;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        await _cache.clear(idAnggota);
        await AuthService().logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (silent) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(friendlyError(e)),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final cached = await _cache.load(idAnggota);

      if (cached != null) {
        setState(() {
          _items = cached.data;
          _pagination = cached.pagination;
          _isFromCache = true;
          _isReconnecting = false;
          _loading = false;
          _error = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(friendlyError(e)),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _error = friendlyError(e);
          _loading = false;
          _isReconnecting = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _pagination == null || !_pagination!.hasMore) return;

    final idAnggota = await _getIdAnggota();
    if (idAnggota == null || idAnggota.isEmpty) return;

    setState(() => _loadingMore = true);

    try {
      final response = await _service.getList(
        idAnggota: idAnggota,
        page: _currentPage + 1,
        limit: 10,
      );

      setState(() {
        _items.addAll(response.data);
        _pagination = response.pagination;
        _currentPage++;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.embedded) {
      return _buildBody();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Pemeriksaan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [_buildPemantauanTab(), _buildGulaDarahTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem('Pemantauan', 0),
          _buildTabItem('Gula Darah', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? _posbinduBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive ? _posbinduBlue : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPemantauanTab() {
    if (_error != null && _items.isEmpty) {
      return _buildError();
    }

    if (_loading && _items.isEmpty) {
      return _buildSkeletonList();
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadData(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 60),
            EmptyStateWidget(
              icon: Icons.monitor_heart_outlined,
              title: 'Belum Ada Data Pemeriksaan',
              subtitle:
                  'Data riwayat pemeriksaan Posbindu Anda akan muncul di sini setelah dilakukan pemeriksaan oleh kader.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: () => _loadData(force: true),
            ),
          if (_isFromCache) const SizedBox(height: 8),
          ..._items.map((item) {
            String month = '-';
            String year = '-';
            try {
              final date = DateTime.parse(item.tanggalPeriksa);
              month = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'Mei',
                'Jun',
                'Jul',
                'Agu',
                'Sep',
                'Okt',
                'Nov',
                'Des',
              ][date.month - 1];
              year = date.year.toString();
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PemantauanItemCard(
                date: formatDate(item.tanggalPeriksa),
                status: item.statusBmi,
                avatarMain: month,
                avatarSub: year,
                avatarFg: _posbinduBlue,
                avatarBg: _posbinduBlue.withValues(alpha: 0.1),
                metrics: [
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_berat_badan.svg',
                    text: item.beratBadan != null
                        ? '${item.beratBadan} kg'
                        : '- kg',
                  ),
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_tinggi_badan.svg',
                    text: item.tinggiBadan != null
                        ? '${item.tinggiBadan} cm'
                        : '- cm',
                  ),
                  PemantauanMetric(
                    iconAsset: 'static/svg/ic_gula_darah.svg',
                    text: item.gulaDarahSewaktu != null
                        ? '${item.gulaDarahSewaktu} mg/dl'
                        : '- mg/dl',
                  ),
                ],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PemeriksaanPosbinduDetailPage(
                        idPeriksa: item.idPeriksaPosbindu,
                        service: _service,
                        authService: _authService,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          if (_pagination != null && _pagination!.hasMore)
            _buildLoadMoreButton(),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: List.generate(3, (_) => _buildSkeletonCard()),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonWidget(width: 100, height: 14),
                    const Spacer(),
                    const SkeletonWidget(
                      width: 60,
                      height: 22,
                      borderRadius: 6,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SkeletonWidget(width: 50, height: 14),
                    const SizedBox(width: 16),
                    const SkeletonWidget(width: 50, height: 14),
                    const SizedBox(width: 16),
                    const SkeletonWidget(width: 60, height: 14),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
        ],
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
            foregroundColor: _posbinduBlue,
            side: BorderSide(color: _posbinduBlue),
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
                    color: _posbinduBlue,
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

  Widget _buildGulaDarahTab() {
    return GulaDarahChartPage(
      embedded: true,
      service: _service,
      authService: _authService,
    );
  }

  Widget _buildError() {
    return ErrorStateWidget(
      message: _error ?? 'Terjadi kesalahan',
      onRetry: () => _loadData(force: true),
    );
  }
}
