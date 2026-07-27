import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/remaja/kegiatan_detail_model.dart';
import 'package:frontend_posyandu/core/services/remaja/kegiatan_remaja_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class KegiatanDetailPage extends StatefulWidget {
  final String idKegiatan;
  final KegiatanRemajaService? service;
  final AuthService? authService;

  const KegiatanDetailPage({
    super.key,
    required this.idKegiatan,
    this.service,
    this.authService,
  });

  @override
  State<KegiatanDetailPage> createState() => _KegiatanDetailPageState();
}

class _KegiatanDetailPageState extends State<KegiatanDetailPage>
    with WidgetsBindingObserver {
  late final KegiatanRemajaService _service;
  late final AuthService _authService;
  final _cache = CacheManager<KegiatanDetailResponse>(
    prefix: 'kegiatan_detail',
    fromJson: KegiatanDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  KegiatanDetailResponse? _data;
  bool _loading = true;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;
  DateTime? _lastFetchTime;

  static const Map<String, Color> _jenisColors = {
    'edukasi': Color(0xFF3B82F6),
    'skrining': Color(0xFF10B981),
    'konseling': Color(0xFF8B5CF6),
    'olahraga': Color(0xFFF59E0B),
  };

  static const Map<String, List<Color>> _bannerGradients = {
    'edukasi': [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'skrining': [Color(0xFF10B981), Color(0xFF34D399)],
    'konseling': [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    'olahraga': [Color(0xFFF59E0B), Color(0xFFFBBF24)],
  };

  static const Map<String, Color> _statusColors = {
    'rencana': Color(0xFF64748B),
    'selesai': Color(0xFF10B981),
    'dibatalkan': Color(0xFFEF4444),
  };

  static const Map<String, String> _jenisLabels = {
    'edukasi': 'Edukasi',
    'skrining': 'Skrining',
    'konseling': 'Konseling',
    'olahraga': 'Olahraga',
  };

  static const Map<String, String> _statusLabels = {
    'rencana': 'Rencana',
    'selesai': 'Selesai',
    'dibatalkan': 'Dibatalkan',
  };

  static const Map<String, IconData> _jenisIcons = {
    'edukasi': Icons.menu_book,
    'skrining': Icons.health_and_safety,
    'konseling': Icons.chat_bubble_outline,
    'olahraga': Icons.directions_run,
  };

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? KegiatanRemajaService();
    _authService = widget.authService ?? AuthService();
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
    await _loadData(silent: true);
  }

  Color _getJenisColor(String key) => _jenisColors[key] ?? const Color(0xFF64748B);
  List<Color> _getBannerGradient(String key) => _bannerGradients[key] ?? [const Color(0xFF64748B), const Color(0xFF94A3B8)];
  Color _getStatusColor(String key) => _statusColors[key] ?? const Color(0xFF64748B);
  String _getJenisLabel(String key) => _jenisLabels[key] ?? key;
  String _getStatusLabel(String key) => _statusLabels[key] ?? key;
  IconData _getJenisIcon(String key) => _jenisIcons[key] ?? Icons.event;

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatTime(String time) {
    try {
      final t = time.substring(0, 5);
      return '$t WIB';
    } catch (_) {
      return time;
    }
  }

  Future<void> _loadData({bool force = false, bool silent = false}) async {
    if (!force && !silent && !_isStale && _data != null) return;

    if (!silent) {
      setState(() {
        _loading = true;
        _isReconnecting = _isFromCache;
        _error = null;
      });
    }

    try {
      final data = await _service.getDetail(widget.idKegiatan);

      await _cache.save(widget.idKegiatan, data);

      setState(() {
        _data = data;
        _lastFetchTime = DateTime.now();
        _isFromCache = false;
        _isReconnecting = false;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        await _cache.clear(widget.idKegiatan);
        await _authService.logout();
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

      final cached = await _cache.load(widget.idKegiatan);

      if (cached != null) {
        setState(() {
          _data = cached;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail Kegiatan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E293B),
          ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: () => _loadData(force: true),
            ),
          if (_isFromCache) const SizedBox(height: 8),
          if (_loading && _data != null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (_data != null) ...[
            _buildBannerSection(),
            const SizedBox(height: 12),
            _buildDetailInfoCard(),
            const SizedBox(height: 12),
            if (_data!.narasumber != null || _data!.materi != null)
              _buildNarasumberCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    final d = _data!;
    final gradientColors = _getBannerGradient(d.jenisKegiatan);
    final icon = _getJenisIcon(d.jenisKegiatan);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          stops: const [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.judulKegiatan,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(d.tanggal)} • ${_formatTime(d.waktu)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfoCard() {
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Informasi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildJenisRow(d.jenisKegiatan),
          if (d.jenisKegiatan != d.status) _buildDivider(),
          _buildStatusRow(d.status),
          _buildDivider(),
          _buildInfoRow(Icons.location_on_outlined, 'Tempat', d.tempat),
          _buildDivider(),
          _buildInfoRow(Icons.people_outline, 'Peserta Target', '${d.pesertaTarget} orang'),
        ],
      ),
    );
  }

  Widget _buildNarasumberCard() {
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Narasumber & Materi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (d.narasumber != null) ...[
            _buildInfoRow(Icons.person_outline, 'Narasumber', d.narasumber!),
            _buildDivider(),
          ],
          if (d.materi != null)
            _buildInfoRow(Icons.description_outlined, 'Materi', d.materi!),
          if (d.materi == null && d.narasumber != null)
            _buildInfoRow(Icons.description_outlined, 'Materi', '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: const Color(0x14000000),
    );
  }

  Widget _buildStatusBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildJenisRow(String jenis) {
    final jenisColor = _getJenisColor(jenis);
    final jenisLabel = _getJenisLabel(jenis);
    final icon = _getJenisIcon(jenis);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: jenisColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              'Jenis Kegiatan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              jenisLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: jenisColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, size: 14, color: Color(0xFF94A3B8)),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              'Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildStatusBadge(label: statusLabel, color: statusColor),
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
              onPressed: () => _loadData(force: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
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

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSkeletonBanner(),
        const SizedBox(height: 12),
        _buildSkeletonCard(4),
        const SizedBox(height: 12),
        _buildSkeletonCard(2),
      ],
    );
  }

  Widget _buildSkeletonBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        children: [
          const SkeletonWidget(width: 48, height: 48, borderRadius: 16),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(width: 180, height: 14),
                SizedBox(height: 8),
                SkeletonWidget(width: 100, height: 12),
                SizedBox(height: 8),
                SkeletonWidget(width: 70, height: 18, borderRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(int rows) {
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
          const SizedBox(height: 12),
          ...List.generate(rows, (i) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SkeletonWidget(width: 14, height: 14, borderRadius: 4),
                SizedBox(width: 8),
                SkeletonWidget(width: 60, height: 12),
                SizedBox(width: 8),
                Expanded(child: SkeletonWidget(width: 100, height: 12)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
