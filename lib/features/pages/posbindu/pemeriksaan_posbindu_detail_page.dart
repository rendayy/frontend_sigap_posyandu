import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/posbindu/pemeriksaan_posbindu_detail_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/widgets/common/error_state_widget.dart';
import 'package:frontend_posyandu/widgets/posbindu/posbindu_detail_sections.dart';

class PemeriksaanPosbinduDetailPage extends StatefulWidget {
  final String idPeriksa;
  final String? idAnggota;
  final PosbinduService? service;
  final AuthService? authService;

  const PemeriksaanPosbinduDetailPage({
    super.key,
    required this.idPeriksa,
    this.idAnggota,
    this.service,
    this.authService,
  });

  @override
  State<PemeriksaanPosbinduDetailPage> createState() =>
      _PemeriksaanPosbinduDetailPageState();
}

class _PemeriksaanPosbinduDetailPageState
    extends State<PemeriksaanPosbinduDetailPage>
    with WidgetsBindingObserver {
  PemeriksaanPosbinduDetailResponse? _data;
  bool _loading = true;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  DateTime? _lastFetchTime;

  late final PosbinduService _service;
  late final AuthService _authService;
  final _cache = CacheManager<PemeriksaanPosbinduDetailResponse>(
    prefix: 'posbindu_pemeriksaan_detail',
    fromJson: PemeriksaanPosbinduDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PosbinduService();
    _authService = widget.authService ?? AuthService();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _silentRefreshIfStale();
    }
  }

  bool get _isStale {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >
        const Duration(seconds: 30);
  }

  Future<void> _silentRefreshIfStale() async {
    if (!_isStale || _data == null) return;
    await _loadData(force: false);
  }

  Future<String?> _getIdAnggota() async {
    if (widget.idAnggota != null) return widget.idAnggota;
    return _authService.getModuleId();
  }

  Future<String?> _getCacheKey() async {
    final idAnggota = await _getIdAnggota();
    if (idAnggota == null || idAnggota.isEmpty) return null;
    return '${idAnggota}_${widget.idPeriksa}';
  }

  Future<DateTime?> _getCacheTimestamp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString('${_cache.prefix}_ts_$key');
    if (ts == null) return null;
    return DateTime.tryParse(ts);
  }

  Future<void> _setCacheTimestamp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_cache.prefix}_ts_$key',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> _initializeData() async {
    final cacheKey = await _getCacheKey();

    if (cacheKey != null) {
      final cached = await _cache.load(cacheKey);
      final cachedTs = await _getCacheTimestamp(cacheKey);

      if (cached != null && cachedTs != null) {
        final elapsed = DateTime.now().difference(cachedTs);
        final isFresh = elapsed <= const Duration(seconds: 30);

        if (isFresh) {
          if (mounted) {
            setState(() {
              _data = cached;
              _lastFetchTime = cachedTs;
              _loading = false;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _data = cached;
            _lastFetchTime = cachedTs;
            _loading = false;
            _isFromCache = true;
          });
        }

        try {
          final idAnggota = await _getIdAnggota();
          if (idAnggota != null) {
            final response = await _service.getDetail(
              idAnggota: idAnggota,
              idPeriksaPosbindu: widget.idPeriksa,
            );
            await _cache.save(cacheKey, response);
            await _setCacheTimestamp(cacheKey);
            if (mounted) {
              setState(() {
                _data = response;
                _lastFetchTime = DateTime.now();
                _isFromCache = false;
              });
            }
          }
        } catch (e) {
          if (!isSessionExpired(e) && mounted) {
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
        return;
      }
    }

    await _loadData(force: true);
  }

  Future<void> _loadData({bool force = false}) async {
    if (!force && !_isStale && _data != null) return;

    final isSilent = !force && _data != null;

    if (!isSilent) {
      setState(() {
        _loading = true;
        _isReconnecting = _isFromCache;
        _error = null;
      });
    }

    try {
      final idAnggota = await _getIdAnggota();
      if (idAnggota == null || idAnggota.isEmpty) {
        throw const ServerException(message: 'ID anggota tidak ditemukan');
      }

      final response = await _service.getDetail(
        idAnggota: idAnggota,
        idPeriksaPosbindu: widget.idPeriksa,
      );

      final cacheKey = '${idAnggota}_${widget.idPeriksa}';
      await _cache.save(cacheKey, response);
      await _setCacheTimestamp(cacheKey);

      setState(() {
        _data = response;
        _lastFetchTime = DateTime.now();
        _isFromCache = false;
        _isReconnecting = false;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        final idAnggota = await _getIdAnggota();
        if (idAnggota != null) {
          await _cache.clear('${idAnggota}_${widget.idPeriksa}');
        }
        await _authService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      if (isSilent) {
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

      final cacheKey = await _getCacheKey();
      final cached = cacheKey != null ? await _cache.load(cacheKey) : null;

      if (cached != null) {
        setState(() {
          _data = cached;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Detail Pemeriksaan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
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
    if (_error != null && _data == null) {
      return _buildError();
    }

    if (_loading && _data == null) {
      return _buildSkeleton();
    }

    final d = _data!;
    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: () => _loadData(force: true),
            ),
          if (_isFromCache) const SizedBox(height: 12),
          PemeriksaanHeaderCard(data: d),
          const SizedBox(height: 16),
          PemeriksaanDetailCard(data: d),
          const SizedBox(height: 16),
          LabDetailCard(data: d),
          const SizedBox(height: 16),
          StatusDetailCard(data: d),
          const SizedBox(height: 16),
          FaktorRisikoDetailCard(data: d),
          const SizedBox(height: 16),
          CatatanPetugasDetailCard(data: d),
          const SizedBox(height: 24),
          _buildReadOnlyNote(),
        ],
      ),
    );
  }

  Widget _buildReadOnlyNote() {
    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Text(
        'Data bersifat read-only. Semua perubahan harus dilakukan melalui aplikasi kader.',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF94A3B8),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const SkeletonWidget(
          width: double.infinity,
          height: 80,
          borderRadius: 16,
        ),
        const SizedBox(height: 16),
        const SkeletonWidget(
          width: double.infinity,
          height: 200,
          borderRadius: 16,
        ),
        const SizedBox(height: 16),
        const SkeletonWidget(
          width: double.infinity,
          height: 150,
          borderRadius: 16,
        ),
        const SizedBox(height: 16),
        const SkeletonWidget(
          width: double.infinity,
          height: 120,
          borderRadius: 16,
        ),
        const SizedBox(height: 24),
        const SkeletonWidget(
          width: double.infinity,
          height: 60,
          borderRadius: 8,
        ),
      ],
    );
  }

  Widget _buildError() {
    return ErrorStateWidget(
      message: _error ?? 'Terjadi kesalahan',
      onRetry: () => _loadData(force: true),
    );
  }
}
