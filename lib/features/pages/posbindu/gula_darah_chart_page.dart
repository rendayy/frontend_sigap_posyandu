import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/posbindu/posbindu_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_header_card.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart_card.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_history_section.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart_skeleton.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/empty_state_widget.dart';
import 'package:frontend_posyandu/widgets/common/error_state_widget.dart';

class GulaDarahChartPage extends StatefulWidget {
  final bool embedded;
  final PosbinduService? service;
  final AuthService? authService;
  final String? idAnggota;

  const GulaDarahChartPage({
    super.key,
    this.embedded = false,
    this.service,
    this.authService,
    this.idAnggota,
  });

  @override
  State<GulaDarahChartPage> createState() => _GulaDarahChartPageState();
}

class _GulaDarahChartPageState extends State<GulaDarahChartPage>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const _posbinduBlue = Color(0xFF162DF9);

  late final PosbinduService _service;
  late final AuthService _authService;
  final _cache = CacheManager<GulaDarahChartData>(
    prefix: 'posbindu_gula_darah_chart',
    fromJson: GulaDarahChartData.fromJson,
    toJson: (d) => d.toJson(),
  );

  GulaDarahChartData? _data;
  bool _loading = true;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  int _currentPage = 1;
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
    if (!_isStale || _data == null) return;
    await _loadData(silent: true);
  }

  Future<String?> _getIdAnggota() async {
    if (widget.idAnggota != null) return widget.idAnggota;
    return _authService.getModuleId();
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && !silent && !_isStale && _data != null) return;

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
      final response = await _service.getGulaDarahChart(idAnggota);

      await _cache.save(idAnggota, response);

      setState(() {
        _data = response;
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
          _data = cached;
          _currentPage = 1;
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

  List<GulaDarahMeasurement> get _currentMeasurements {
    if (_data == null) return [];
    final allMeasurements = _data!.measurements;
    final pageSize = 5;
    final startIndex = (_currentPage - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    if (startIndex >= allMeasurements.length) return [];
    return allMeasurements.sublist(
      startIndex,
      endIndex > allMeasurements.length ? allMeasurements.length : endIndex,
    );
  }

  int get _totalPages {
    if (_data == null) return 0;
    final len = _data!.measurements.length;
    if (len == 0) return 0;
    return ((len) / 5).ceil();
  }

  void _onPrev() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _onNext() {
    if (_currentPage < _totalPages) {
      setState(() => _currentPage++);
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
          'Gula Darah',
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
        if (_error != null && _data == null)
          Expanded(child: _buildError())
        else if (_loading && _data == null)
          const Expanded(child: GulaDarahChartSkeleton())
        else if (_data == null)
          Expanded(child: _buildError())
        else
          Expanded(
            child: RefreshIndicator(
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
                  GulaDarahHeaderCard(data: _data!, accent: _posbinduBlue),
                  const SizedBox(height: 16),
                  GulaDarahChartCard(
                    data: _data!,
                    currentMeasurements: _currentMeasurements,
                  ),
                  const SizedBox(height: 16),
                  _data!.measurements.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.monitor_heart_outlined,
                          title: 'Belum Ada Data Pengukuran Gula Darah',
                        )
                      : GulaDarahHistorySection(
                          measurements: _data!.measurements,
                          zones: _data!.gulaDarahZones,
                          currentPage: _currentPage,
                          totalPages: _totalPages,
                          onPrev: _onPrev,
                          onNext: _onNext,
                          accent: _posbinduBlue,
                        ),
                ],
              ),
            ),
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
