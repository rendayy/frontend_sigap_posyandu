import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend_posyandu/core/models/balita/pemantauan_balita_detail_model.dart';
import 'package:frontend_posyandu/core/services/balita/pemantauan_balita_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/status_gizi_badge.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/core/utils/errors.dart';

class BalitaDetailPage extends StatefulWidget {
  final String idPantau;
  final PemantauanBalitaService? pemantauanService;
  final AuthService? authService;

  const BalitaDetailPage({
    super.key,
    required this.idPantau,
    this.pemantauanService,
    this.authService,
  });

  @override
  State<BalitaDetailPage> createState() => _BalitaDetailPageState();
}

class _BalitaDetailPageState extends State<BalitaDetailPage> {
  late final PemantauanBalitaService _service;
  late final AuthService _authService;
  final _cache = CacheManager<PemantauanBalitaDetailResponse>(
    prefix: 'detail_pemantauan',
    fromJson: PemantauanBalitaDetailResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  PemantauanBalitaDetailResponse? _data;
  bool _loading = true;
  bool _isFromCache = false;
  bool _isReconnecting = false;
  String? _error;

  @override
  void initState() {
    _service = widget.pemantauanService ?? PemantauanBalitaService();
    _authService = widget.authService ?? AuthService();
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
      _isFromCache = false;
    });

    try {
      final moduleId = await _authService.getModuleId();
      if (moduleId == null || moduleId.isEmpty) {
        setState(() {
          _error = 'Data balita tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final data = await _service.getDetail(
        idBalita: moduleId,
        idPantau: widget.idPantau,
      );

      await _cache.save('${moduleId}_${widget.idPantau}', data);

      setState(() {
        _data = data;
        _loading = false;
        _isFromCache = false;
      });
    } catch (e) {
      if (isSessionExpired(e)) {
        await _cache.clear('');
        await _authService.logout();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (_data != null) {
        setState(() => _isReconnecting = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: const Color(0xFFFFA726),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      final moduleId = await _authService.getModuleId();
      final cached = await _cache.load('${moduleId}_${widget.idPantau}');
      if (cached != null) {
        setState(() {
          _data = cached;
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detail pemeriksaan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w800,
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
      onRefresh: _loadData,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_isFromCache)
            OfflineBanner(
              isReconnecting: _isReconnecting,
              onTap: _loadData,
            ),
          if (_loading && _data != null)
            _buildLoadingShimmer()
          else ...[
            _buildPemeriksaanCard(),
            const SizedBox(height: 16),
            _buildCatatanPetugasCard(),
            const SizedBox(height: 16),
            _buildInfoKaderCard(),
            const SizedBox(height: 16),
            _buildReadOnlyNote(),
          ],
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: const Color(0x14000000),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
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
          Row(
            children: [
              Text(
                _formatDate(d.tanggalPantau),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              StatusGiziBadge(status: d.statusGizi, compact: true),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${d.usiaBulan} bulan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            _beratIcon,
            'Berat Badan',
            '${d.berat.toStringAsFixed(1)} kg',
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            _tinggiIcon,
            'Tinggi Badan',
            '${d.tinggi.toStringAsFixed(1)} cm',
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            _lingkarKepalaIcon,
            'Lingkar Kepala',
            d.lingkarKepala != null
                ? '${d.lingkarKepala!.toStringAsFixed(1)} cm'
                : '-',
          ),
          _buildSeparator(),
          _buildAntropometriRow(
            _lingkarLenganIcon,
            'Lingkar Lengan',
            d.lingkarLengan != null
                ? '${d.lingkarLengan!.toStringAsFixed(1)} cm'
                : '-',
          ),
          _buildInfoRow('Imunisasi', d.imunisasi ?? '-'),
          const SizedBox(height: 8),
          _buildInfoRow('Vitamin A', d.vitaminA ?? '-'),
        ],
      ),
    );
  }

  Widget _buildAntropometriRow(String assetPath, String label, String value) {
    return Row(
      children: [
        SvgPicture.asset(assetPath, width: 14, height: 14),
        const SizedBox(width: 8),
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
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
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
          Text(
            'Catatan Petugas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          if (hasKeluhan) ...[
            Text(
              'Keluhan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              d.keluhan!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E293B),
              ),
            ),
            if (hasSaran) const SizedBox(height: 12),
          ],
          if (hasSaran) ...[
            Text(
              'Saran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              d.saran!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF1E293B),
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
          Text(
            'Info Kader & Posyandu',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Kader', d.namaKader),
          const SizedBox(height: 8),
          _buildInfoRow('Posyandu', d.namaPosyandu),
          if (d.updatedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Diperbarui', _formatDate(d.updatedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildReadOnlyNote() {
    return Center(
      child: Text(
        'Data ini bersifat read-only.\nHubungi bidan untuk koreksi.',
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF64748B),
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

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSkeletonCard(200),
        const SizedBox(height: 16),
        _buildSkeletonCard(120),
        const SizedBox(height: 16),
        _buildSkeletonCard(100),
      ],
    );
  }

  Widget _buildSkeletonCard(double height) {
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
            width: 140,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            (height / 24).floor(),
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  static const _beratIcon = 'static/svg/ic_berat_badan.svg';
  static const _tinggiIcon = 'static/svg/ic_lingkar_kepala.svg';
  static const _lingkarKepalaIcon = 'static/svg/ic_tinggi_badan.svg';
  static const _lingkarLenganIcon = 'static/svg/ic_lingkar_lengan.svg';
}
