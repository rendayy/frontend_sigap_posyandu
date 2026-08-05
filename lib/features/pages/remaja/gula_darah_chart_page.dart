import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/core/services/remaja/pemantauan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/charts/gula_darah_chart.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

import 'package:frontend_posyandu/widgets/common/empty_state_widget.dart';

class GulaDarahChartPage extends StatefulWidget {
  final GulaDarahChartData? data;
  final String? idRemaja;
  final bool embedded;
  final PemantauanRemajaService? service;
  final AuthService? authService;

  const GulaDarahChartPage({
    super.key,
    this.data,
    this.idRemaja,
    this.embedded = false,
    this.service,
    this.authService,
  });

  @override
  State<GulaDarahChartPage> createState() => _GulaDarahChartPageState();
}

class _GulaDarahChartPageState extends State<GulaDarahChartPage> {
  GulaDarahChartData? _data;
  bool _loading = false;
  bool _isFromCache = false;
  final bool _isReconnecting = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const _staleAfter = Duration(seconds: 30);

  int _currentPage = 1;
  static const _limit = 5;

  late final PemantauanRemajaService _service;
  late final AuthService _authService;
  late final CacheManager<GulaDarahChartData> _cache;

  int get _totalPages {
    final total = _data?.measurements.length ?? 0;
    if (total == 0) return 1;
    return (total / _limit).ceil();
  }

  List<GulaDarahMeasurement> get _currentMeasurements {
    final all = _data?.measurements ?? [];
    final start = (_currentPage - 1) * _limit;
    return all.skip(start).take(_limit).toList();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? PemantauanRemajaService();
    _authService = widget.authService ?? AuthService();
    _cache = CacheManager<GulaDarahChartData>(
      prefix: 'gula_darah_chart',
      fromJson: GulaDarahChartData.fromJson,
      toJson: (d) => d.toJson(),
    );

    if (widget.data != null) {
      _data = widget.data;
    } else {
      _loadData();
    }
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && _data != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _staleAfter) {
      return;
    }

    if (silent && _data != null) {
      try {
        final idRemaja = widget.idRemaja ?? await _authService.getModuleId();
        if (idRemaja == null || idRemaja.isEmpty) return;

        final response = await _service.getGulaDarahChart(idRemaja);
        await _cache.save(idRemaja, response);

        if (!mounted) return;
        setState(() {
          _data = response;
          _lastFetchTime = DateTime.now();
          _isFromCache = false;
          _loading = false;
          _currentPage = 1;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
      return;
    }

    if (!silent) {
      setState(() {
        _loading = _data == null;
        _error = null;
        _isFromCache = false;
      });
    }

    try {
      final idRemaja = widget.idRemaja ?? await _authService.getModuleId();
      if (idRemaja == null || idRemaja.isEmpty) {
        setState(() {
          _error = 'Data remaja tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final response = await _service.getGulaDarahChart(idRemaja);
      await _cache.save(idRemaja, response);

      setState(() {
        _data = response;
        _loading = false;
        _isFromCache = false;
        _lastFetchTime = DateTime.now();
        _currentPage = 1;
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        final idRemaja = widget.idRemaja ?? await _authService.getModuleId();
        if (idRemaja != null) await _cache.clear(idRemaja);
        await _authService.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final idRemaja = widget.idRemaja ?? await _authService.getModuleId();
      final cached = idRemaja != null ? await _cache.load(idRemaja) : null;
      if (cached != null) {
        setState(() {
          _data = cached;
          _isFromCache = true;
          _loading = false;
          _lastFetchTime = DateTime.now();
          _currentPage = 1;
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

  @override
  Widget build(BuildContext context) {
    if (_error != null && _data == null) {
      return _buildError();
    }

    if (_loading && _data == null) {
      return _buildSkeleton();
    }

    final d = _data!;

    Widget content = RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, widget.embedded ? 12 : 16, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: () => _loadData(force: true),
            ),
          _buildHeaderCard(d),
          const SizedBox(height: 12),
          _buildChartCard(d),
          const SizedBox(height: 12),
          if (d.measurements.isEmpty)
            const EmptyStateWidget(
              icon: Icons.monitor_heart_outlined,
              title: 'Belum Ada Data Pengukuran Gula Darah',
              subtitle: 'Riwayat akan muncul setelah pemeriksaan gula darah dilakukan.',
            )
          else ...[
            _buildMeasurementHistory(d),
            const SizedBox(height: 16),
            _buildPagination(),
          ],
        ],
      ),
    );

    if (widget.embedded) return content;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Grafik Gula Darah',
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
      body: content,
    );
  }

  Widget _buildHeaderCard(GulaDarahChartData d) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              color: _statusColor(d.latestStatus).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monitor_heart_outlined,
              color: _statusColor(d.latestStatus),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gula Darah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      d.latestGulaDarah != null ? '${d.latestGulaDarah}' : '—',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'mg/dL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor(d.latestStatus).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _statusLabel(d.latestStatus),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(d.latestStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${d.measurements.length}x',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(GulaDarahChartData d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 18, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  'Grafik Gula Darah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Gula darah (mg/dL) vs zona status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(height: 12),
          GulaDarahChart(
            data: d,
            currentMeasurements: _currentMeasurements,
          ),
          const SizedBox(height: 12),
          _buildZoneLegend(d),
        ],
      ),
    );
  }

  Widget _buildZoneLegend(GulaDarahChartData d) {
    final sorted = List<GulaDarahZone>.from(d.gulaDarahZones)
      ..sort((a, b) => a.min.compareTo(b.min));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: sorted.map((zone) {
          final color = _parseColor(zone.color);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  zone.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMeasurementHistory(GulaDarahChartData d) {
    final items = _currentMeasurements;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 18, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                'Riwayat Pengukuran',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.reversed.map(
            (m) {
              final status = _determineStatus(m.gulaDarah, d.gulaDarahZones);
              final statusColor = _statusColor(status);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.monitor_heart_outlined,
                          size: 20,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(m.tanggalPeriksa),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _statusLabel(status),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${m.gulaDarah}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                          Text(
                            'mg/dL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    final total = _totalPages;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 1)
          TextButton(
            onPressed: () => setState(() => _currentPage--),
            child: Text(
              'Sebelumnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF97316),
              ),
            ),
          ),
        const SizedBox(width: 16),
        Text(
          '$_currentPage / $total',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        if (_currentPage < total)
          TextButton(
            onPressed: () => setState(() => _currentPage++),
            child: Text(
              'Selanjutnya',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF97316),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError() {
    if (widget.embedded) {
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
                  backgroundColor: const Color(0xFFF97316),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Grafik Gula Darah',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: Center(
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
                  backgroundColor: const Color(0xFFF97316),
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
      ),
    );
  }

  Widget _buildSkeleton() {
    final skeleton = ListView(
      padding: EdgeInsets.fromLTRB(16, widget.embedded ? 12 : 16, 16, 24),
      children: [
        _buildSkeletonHeader(),
        const SizedBox(height: 12),
        _buildSkeletonChart(),
        const SizedBox(height: 12),
        _buildSkeletonRiwayat(),
      ],
    );

    if (widget.embedded) return skeleton;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Grafik Gula Darah',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: skeleton,
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          const SkeletonWidget(width: 48, height: 48, borderRadius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 80, height: 12),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SkeletonWidget(width: 60, height: 20),
                    const SizedBox(width: 8),
                    const SkeletonWidget(width: 50, height: 14),
                    const SizedBox(width: 8),
                    const SkeletonWidget(width: 60, height: 22, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
          const SkeletonWidget(width: 30, height: 14),
        ],
      ),
    );
  }

  Widget _buildSkeletonChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonWidget(width: 120, height: 14),
          const SizedBox(height: 4),
          const SkeletonWidget(width: 180, height: 12),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image_outlined,
              size: 64,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonRiwayat() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 60,
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    if (status == null) return AppColors.textSecondary;
    switch (status) {
      case 'normal':
        return const Color(0xFF43A047);
      case 'pra_diabetes':
        return const Color(0xFFFFA726);
      case 'diabetes':
        return const Color(0xFFB71C1C);
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusLabel(String? status) {
    if (status == null) return 'Belum ada data';
    switch (status) {
      case 'normal':
        return 'Normal';
      case 'pra_diabetes':
        return 'Pra-diabetes';
      case 'diabetes':
        return 'Diabetes';
      default:
        return status;
    }
  }

  String _determineStatus(int value, List<GulaDarahZone> zones) {
    for (final zone in zones) {
      if (value >= zone.min && value <= zone.max) {
        return zone.status;
      }
    }
    return 'unknown';
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final monthIdx = int.tryParse(parts[1]) ?? 1;
      final month = monthIdx >= 1 && monthIdx <= 12 ? months[monthIdx - 1] : parts[1];
      return '${parts[2]} $month ${parts[0]}';
    } catch (_) {
      return dateStr;
    }
  }
}
