import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_posyandu/core/models/remaja/pemantauan_remaja_detail_model.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/widgets/common/error_state_widget.dart';
import 'package:frontend_posyandu/core/utils/date_util.dart';

class PemantauanDetailPage extends StatefulWidget {
  final String idPantau;
  final String? idRemaja;
  final PemantauanRemajaService? service;
  final AuthService? authService;

  const PemantauanDetailPage({
    super.key,
    required this.idPantau,
    this.idRemaja,
    this.service,
    this.authService,
  });

  @override
  State<PemantauanDetailPage> createState() => _PemantauanDetailPageState();
}

class _PemantauanDetailPageState extends State<PemantauanDetailPage>
    with WidgetsBindingObserver {
  PemantauanRemajaDetailResponse? _data;
  bool _loading = true;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  DateTime? _lastFetchTime;

  late final PemantauanRemajaService _service;
  late final AuthService _authService;
  final _cache = CacheManager<PemantauanRemajaDetailResponse>(
    prefix: 'remaja_pemantauan_detail',
    fromJson: PemantauanRemajaDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PemantauanRemajaService();
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
    return DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 30);
  }

  Future<void> _silentRefreshIfStale() async {
    if (!_isStale || _data == null) return;
    await _loadData(force: false);
  }

  Future<String?> _getIdRemaja() async {
    if (widget.idRemaja != null) return widget.idRemaja;
    return _authService.getModuleId();
  }

  Future<String?> _getCacheKey() async {
    final idRemaja = await _getIdRemaja();
    if (idRemaja == null || idRemaja.isEmpty) return null;
    return '${idRemaja}_${widget.idPantau}';
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
          final idRemaja = await _getIdRemaja();
          if (idRemaja != null) {
            final response = await _service.getDetail(
              idRemaja: idRemaja,
              idPantau: widget.idPantau,
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
      final idRemaja = await _getIdRemaja();
      if (idRemaja == null || idRemaja.isEmpty) {
        throw const ServerException(message: 'Data remaja tidak ditemukan');
      }

      final response = await _service.getDetail(
        idRemaja: idRemaja,
        idPantau: widget.idPantau,
      );

      final cacheKey = '${idRemaja}_${widget.idPantau}';
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
        final idRemaja = await _getIdRemaja();
        if (idRemaja != null) {
          await _cache.clear('${idRemaja}_${widget.idPantau}');
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



  String _formatNum(dynamic value, {int digits = 1}) {
    if (value == null) return '-';
    if (value is double) return value.toStringAsFixed(digits);
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Detail Pemantauan',
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
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildPemeriksaanCard(),
          const SizedBox(height: 16),
          _buildCatatanPetugasCard(),
          const SizedBox(height: 16),
          _buildInfoKaderCard(),
          const SizedBox(height: 24),
          _buildReadOnlyNote(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'static/svg/ic_chart.svg',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemantauan ${formatDate(_data!.tanggalPeriksa, short: true)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _data!.bmi != null
                      ? 'BMI ${_formatNum(_data!.bmi)} · ${_statusLabel(_data!.statusGizi)}'
                      : _statusLabel(_data!.statusGizi),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emerald,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPemeriksaanCard() {
    final d = _data!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Pemeriksaan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionHeader('Data Pengukuran'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF475569)),
                const SizedBox(width: 10),
                Text(
                  'Tanggal Periksa',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF475569),
                  ),
                ),
                const Spacer(),
                Text(
                  formatDate(d.tanggalPeriksa),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            'static/svg/ic_berat_badan.svg',
            'Berat Badan',
            '${_formatNum(d.beratBadan)} kg',
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            'static/svg/ic_tinggi_badan.svg',
            'Tinggi Badan',
            '${_formatNum(d.tinggiBadan)} cm',
          ),
          if (d.bmi != null) ...[
            _buildSeparator(),
            _buildAntropometriRow(
              'static/svg/ic_chart.svg',
              'BMI',
              '${_formatNum(d.bmi)} kg/m²',
            ),
          ],
          _buildSeparator(),
          _buildStatusGiziRow(),
          const SizedBox(height: 12),
          _buildSectionHeader('Tekanan Darah & Gula Darah'),
          const SizedBox(height: 8),
          ..._buildTekananGulaSection(d),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald,
        letterSpacing: 0.5,
      ),
    );
  }

  List<Widget> _buildTekananGulaSection(dynamic d) {
    final items = <Widget>[];
    if (d.sistol != null) {
      items.add(_buildAntropometriRow(
        'static/svg/ic_tekanan_darah.svg',
        'Sistol',
        '${d.sistol} mmHg',
      ));
    }
    if (d.distol != null) {
      items.add(_buildAntropometriRow(
        'static/svg/ic_tekanan_darah.svg',
        'Distol',
        '${d.distol} mmHg',
      ));
    }
    if (d.gulaDarah != null) {
      items.add(_buildAntropometriRow(
        'static/svg/ic_gula_darah.svg',
        'Gula Darah',
        '${d.gulaDarah} mg/dL',
      ));
    }
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) result.add(_buildSeparator());
      result.add(items[i]);
    }
    return result;
  }

  Widget _buildAntropometriRow(String assetPath, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(assetPath, width: 16, height: 16),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGiziRow() {
    final d = _data!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.monitor_heart_outlined, size: 16, color: Color(0xFF475569)),
          const SizedBox(width: 10),
          Text(
            'Status Gizi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
            ),
          ),
          const Spacer(),
          StatusGiziBadge(status: d.statusGizi),
        ],
      ),
    );
  }

  Widget _buildCatatanPetugasCard() {
    final d = _data!;
    final hasKeluhan = d.keluhan != null && d.keluhan!.isNotEmpty;
    final hasSaran = d.saran != null && d.saran!.isNotEmpty;

    if (!hasKeluhan && !hasSaran) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_outlined, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Catatan Petugas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasKeluhan) ...[
            Text(
              'Keluhan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                d.keluhan!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (hasSaran) const SizedBox(height: 12),
          ],
          if (hasSaran) ...[
            Text(
              'Saran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                d.saran!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoKaderCard() {
    final d = _data!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Info Kader & Posyandu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, 'Kader', d.namaKader),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Posyandu', d.namaPosyandu),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF475569),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: const Color(0x14000000),
      ),
    );
  }

  Widget _buildReadOnlyNote() {
    return Center(
      key: const Key('read_only_note'),
      child: Text(
        'Data bersifat read-only.\nHubungi petugas untuk koreksi.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildSkeletonHeader(),
        const SizedBox(height: 16),
        _buildSkeletonCard(280),
        const SizedBox(height: 16),
        _buildSkeletonCard(120),
        const SizedBox(height: 16),
        _buildSkeletonCard(100),
      ],
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(width: 180, height: 14),
                SizedBox(height: 8),
                SkeletonWidget(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(double contentHeight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(width: 140, height: 14),
          const SizedBox(height: 16),
          ...List.generate(
            (contentHeight / 40).ceil(),
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SkeletonWidget(width: 16, height: 16, borderRadius: 4),
                  SizedBox(width: 10),
                  Expanded(child: SkeletonWidget(width: double.infinity, height: 12)),
                  SizedBox(width: 16),
                  SkeletonWidget(width: 60, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return ErrorStateWidget(
      message: _error ?? 'Terjadi kesalahan',
      onRetry: () => _loadData(force: true),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'berat_badan_kurang':
        return 'Kurang';
      case 'berat_badan_normal':
        return 'Normal';
      case 'berat_badan_berlebih':
        return 'Berlebih';
      case 'obesitas_1':
        return 'Obesitas 1';
      case 'obesitas_2':
        return 'Obesitas 2';
      default:
        return status;
    }
  }
}
