import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:frontend_posyandu/core/models/balita/growth_chart_model.dart';
import 'package:frontend_posyandu/core/services/balita/balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/charts/growth_chart.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';

class GrowthChartPage extends StatefulWidget {
  final GrowthChartResponse? data;
  final String? idBalita;
  final bool embedded;
  final BalitaService? balitaService;
  final AuthService? authService;

  const GrowthChartPage({
    super.key,
    this.data,
    this.idBalita,
    this.embedded = false,
    this.balitaService,
    this.authService,
  });

  @override
  State<GrowthChartPage> createState() => _GrowthChartPageState();
}

class _GrowthChartPageState extends State<GrowthChartPage> {
  final _ranges = [0, 20, 40];
  int _rangeIndex = 0;
  GrowthChartResponse? _data;
  bool _loading = false;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  bool _isDownloading = false;
  String? _error;
  DateTime? _lastFetchTime;
  static const _staleAfter = Duration(seconds: 30);

  int _currentPage = 1;
  static const _limit = 5;

  int get _totalPages {
    final total = _data?.measurements.length ?? 0;
    if (total == 0) return 1;
    return (total / _limit).ceil();
  }

  List<GrowthMeasurement> get _currentMeasurements {
    final all = _data?.measurements ?? [];
    return all.reversed.skip((_currentPage - 1) * _limit).take(_limit).toList();
  }

  late final BalitaService _balitaService;
  late final AuthService _authService;
  late final CacheManager<GrowthChartResponse> _cache;

  int get _rangeStart => _ranges[_rangeIndex];
  int get _rangeEnd => _rangeStart + 20;
  bool get _hasPrev => _rangeIndex > 0;
  bool get _hasNext => _rangeIndex < _ranges.length - 1;
  String get _rangeLabel => '$_rangeStart - $_rangeEnd Bulan';

  @override
  void initState() {
    _balitaService = widget.balitaService ?? BalitaService();
    _authService = widget.authService ?? AuthService();
    _cache = CacheManager<GrowthChartResponse>(
      prefix: 'growth_chart',
      fromJson: GrowthChartResponse.fromJson,
      toJson: (d) => d.toJson(),
    );

    if (widget.data != null) {
      _data = widget.data;
    } else {
      _loadData();
    }
    super.initState();
  }

  void _silentRefreshIfStale() {
    if (_data == null) return;
    if (_lastFetchTime == null) return;
    if (DateTime.now().difference(_lastFetchTime!) < _staleAfter) return;
    _loadData(silent: true);
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && _data != null && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _staleAfter) {
      return;
    }

    if (silent && _data != null) {
      try {
        final idBalita = widget.idBalita ?? await _authService.getModuleId();
        if (idBalita == null || idBalita.isEmpty) return;

        final response = await _balitaService.getGrowthChart(idBalita);
        await _cache.save(idBalita, response);

        if (!mounted) return;
        setState(() {
          _data = response;
          _lastFetchTime = DateTime.now();
          _isFromCache = false;
          _loading = false;
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
      final idBalita = widget.idBalita ?? await _authService.getModuleId();
      if (idBalita == null || idBalita.isEmpty) {
        setState(() {
          _error = 'Data balita tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final response = await _balitaService.getGrowthChart(idBalita);
      await _cache.save(idBalita, response);

      setState(() {
        _data = response;
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

      final idBalita = widget.idBalita ?? await _authService.getModuleId();
      final cached = idBalita != null ? await _cache.load(idBalita) : null;
      if (cached != null) {
        setState(() {
          _data = cached;
          _isFromCache = true;
          _loading = false;
          _lastFetchTime = DateTime.now();
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

  void _goPrev() {
    if (_hasPrev) setState(() => _rangeIndex--);
  }

  void _goNext() {
    if (_hasNext) setState(() => _rangeIndex++);
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
    final ageRange = [_rangeStart, _rangeEnd];

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
          _buildChartCard(d, ageRange),
          const SizedBox(height: 12),
          _buildMeasurementHistory(d),
          const SizedBox(height: 12),
          _buildPagination(),
          const SizedBox(height: 24),
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
          'Grafik Pertumbuhan',
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

  Widget _buildStatusSummary(GrowthChartResponse d) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _statusLabel(d.latestStatus),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(d.latestStatus),
                  ),
                ),
                const Spacer(),
                Text(
                  '${d.measurements.length}x pengukuran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_chartTypeLabel(d.chartType)} — ${d.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (d.standardSource.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                d.standardSource,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _downloadKms() async {
    final idBalita = widget.idBalita ?? await _authService.getModuleId();
    if (idBalita == null || idBalita.isEmpty) return;
    setState(() => _isDownloading = true);
    try {
      final file = await _balitaService.downloadKms(idBalita);
      await OpenFilex.open(file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka file KMS')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isDownloading = false);
    }
  }

  Widget _buildChartCard(GrowthChartResponse d, List<int> ageRange) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kartu Menuju Sehat (KMS)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${_chartTypeLabel(d.chartType)} vs standar WHO anak ${d.jenisKelamin == 'L' ? 'laki-laki' : 'perempuan'} ($_rangeLabel)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_hasPrev)
                  _buildNavButton(Icons.chevron_left, 'Sebelumnya', _goPrev)
                else
                  const SizedBox(width: 100),
                Text(
                  _rangeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_hasNext)
                  _buildNavButton(Icons.chevron_right, 'Selanjutnya', _goNext)
                else
                  const SizedBox(width: 100),
              ],
            ),
            const SizedBox(height: 8),
            GrowthChart(
              data: d,
              ageRange: ageRange,
            ),
            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: _isDownloading ? null : _downloadKms,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isDownloading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Download KMS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFF97316)),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneDescription(GrowthChartResponse d) {
    final statusLabel = _statusLabel(d.latestStatus);
    final zoneLabel = d.zoneLabels['-2SD'] ?? 'Gizi Kurang';
    final zoneLabelUpper = d.zoneLabels['+2SD'] ?? 'Kelebihan Berat Badan';
    final gender = d.jenisKelamin == 'L' ? 'laki-laki' : 'perempuan';
    final chartLabel = _chartTypeLabel(d.chartType);

    String description;
    switch (d.latestStatus) {
      case 'gizi_baik':
        description = 'berada dalam zona normal WHO (antara -2SD dan +2SD)';
        break;
      case 'gizi_kurang':
        description = 'berada di bawah -2SD (zona $zoneLabel)';
        break;
      case 'gizi_buruk':
        description = 'berada di bawah -3SD (zona $zoneLabel)';
        break;
      case 'stunting':
        description = 'berada di bawah standar tinggi badan (zona $zoneLabel)';
        break;
      default:
        description = 'berada dalam zona $zoneLabel';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: _statusColor(d.latestStatus),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $statusLabel',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(d.latestStatus),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$chartLabel $gender $description.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementHistory(GrowthChartResponse d) {
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
          ...items.map(
            (m) {
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
                          color: AppColors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.monitor_weight_outlined,
                          size: 20,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Usia ${m.usiaBulan} bulan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(m.tanggalPantau),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${m.berat}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orange,
                            ),
                          ),
                          Text(
                            'kg',
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
                onPressed: _loadData,
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
          'Grafik Pertumbuhan',
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
                onPressed: _loadData,
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
        _buildSkeletonCard(),
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
          'Grafik Pertumbuhan',
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

  Widget _buildSkeletonCard() {
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
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 200,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
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
            Container(
              width: 140,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
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
                        const SizedBox(height: 6),
                        Container(
                          width: 140,
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
                    width: 40,
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

  String _chartTypeLabel(String type) {
    switch (type) {
      case 'BB/U': return 'Berat Badan';
      case 'TB/U': return 'Tinggi Badan';
      case 'BB/TB': return 'Berat Badan / Tinggi Badan';
      default: return type;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'gizi_baik': return 'Gizi Baik';
      case 'gizi_kurang': return 'Gizi Kurang';
      case 'gizi_buruk': return 'Gizi Buruk';
      case 'stunting': return 'Stunting';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'gizi_baik': return const Color(0xFF43A047);
      case 'gizi_kurang': return const Color(0xFFFFA726);
      case 'gizi_buruk': return const Color(0xFFEF5350);
      case 'stunting': return const Color(0xFFB71C1C);
      default: return AppColors.textSecondary;
    }
  }

  Color _measurementStatusColor(String status) {
    switch (status) {
      case 'gizi_baik': return const Color(0xFF43A047);
      case 'gizi_kurang': return const Color(0xFFFFA726);
      case 'gizi_buruk': return const Color(0xFFEF5350);
      case 'stunting': return const Color(0xFFB71C1C);
      default: return AppColors.textSecondary;
    }
  }

  String _measurementStatusLabel(String status) {
    switch (status) {
      case 'gizi_baik': return 'Baik';
      case 'gizi_kurang': return 'Kurang';
      case 'gizi_buruk': return 'Buruk';
      case 'stunting': return 'Stunting';
      default: return status;
    }
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
