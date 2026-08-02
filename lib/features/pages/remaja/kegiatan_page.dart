import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/pagination_meta.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_remaja_model.dart';
import 'package:frontend_posyandu/core/services/remaja/kegiatan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/features/pages/remaja/kegiatan_detail_page.dart';
import 'package:frontend_posyandu/widgets/remaja/kegiatan_remaja_card.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class KegiatanPage extends StatefulWidget {
  final bool embedded;
  final KegiatanRemajaService? service;

  const KegiatanPage({
    super.key,
    this.embedded = false,
    this.service,
  });

  @override
  State<KegiatanPage> createState() => _KegiatanPageState();
}

class _KegiatanPageState extends State<KegiatanPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;
  late final KegiatanRemajaService _service;
  final _cache = CacheManager<KegiatanRemajaListResponse>(
    prefix: 'remaja_kegiatan',
    fromJson: KegiatanRemajaListResponse.fromJson,
    toJson: (d) => d.toJson(),
  );
  static const _cacheKey = 'list';

  List<KegiatanRemajaItem> _items = [];
  PaginationMeta? _pagination;
  int _currentPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  DateTime? _lastFetchTime;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? KegiatanRemajaService();
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
    return DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 30);
  }

  Future<void> _silentRefreshIfStale() async {
    if (!_isStale || _items.isEmpty) return;
    await _loadData(silent: true);
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && !silent && !_isStale && _items.isNotEmpty) return;

    if (!silent) {
      setState(() {
        _loading = true;
        _isReconnecting = _isFromCache;
        _error = null;
        _currentPage = 1;
      });
    }

    try {
      final response = await _service.getList(page: 1, limit: 10);

      await _cache.save(_cacheKey, response);

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
        await _cache.clear(_cacheKey);
        await AuthService().logout();
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (silent) {
        if (context.mounted) {
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

      final cached = await _cache.load(_cacheKey);

      if (cached != null) {
        setState(() {
          _items = cached.data;
          _pagination = cached.pagination;
          _isFromCache = true;
          _isReconnecting = false;
          _loading = false;
          _error = null;
        });
        if (context.mounted) {
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

    setState(() => _loadingMore = true);

    try {
      final response = await _service.getList(
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
      if (context.mounted) {
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
    updateKeepAlive();

    if (widget.embedded) {
      return _buildBody();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Kegiatan Remaja',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items.isEmpty) {
      return _buildError();
    }

    if (_loading) {
      return _buildSkeletonList();
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
          ..._items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: KegiatanRemajaCard(
              item: item,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => KegiatanDetailPage(idKegiatan: item.idKegiatan),
                ),
              ),
            ),
          )),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 160, height: 14),
                const SizedBox(height: 8),
                const SkeletonWidget(width: 120, height: 12),
                const SizedBox(height: 4),
                const SkeletonWidget(width: 80, height: 12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SkeletonWidget(width: 50, height: 20, borderRadius: 6),
                    const SizedBox(width: 6),
                    const SkeletonWidget(width: 60, height: 20, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
          ),
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
            foregroundColor: AppColors.emerald,
            side: const BorderSide(color: AppColors.emerald),
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
                    color: AppColors.emerald,
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
              onPressed: () => _loadData(force: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
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
}
