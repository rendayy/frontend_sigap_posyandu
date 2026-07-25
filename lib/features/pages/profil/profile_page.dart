import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/citizen/citizen_model.dart';
import 'package:frontend_posyandu/core/services/citizen/citizen_service.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/core/services/fcm/fcm_service.dart';
import 'package:frontend_posyandu/core/utils/cache_manager.dart';
import 'package:frontend_posyandu/core/utils/module_page_mixin.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/widgets/common/offline_banner.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class ProfilePage extends StatefulWidget {
  final CitizenService? citizenService;
  final AuthService? authService;

  const ProfilePage({super.key, this.citizenService, this.authService});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with WidgetsBindingObserver {
  late final CitizenService _citizenService;
  late final AuthService _authService;
  final _helper = ModulePageHelper<ProfileResponse>();
  final _cache = CacheManager<ProfileResponse>(
    prefix: 'profile',
    fromJson: ProfileResponse.fromJson,
    toJson: (d) => d.toJson(),
  );

  @override
  void initState() {
    super.initState();
    _citizenService = widget.citizenService ?? CitizenService();
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

  void _silentRefreshIfStale() {
    if (_helper.isStale(const Duration(seconds: 30))) {
      _loadData();
    }
  }

  Future<void> _loadData({bool force = false}) async {
    await loadModuleData(
      helper: _helper,
      getModuleId: () => _authService.getModuleId(),
      fetchFromApi: (_) => _citizenService.getMyProfile(),
      cacheManager: _cache,
      setState: () => setState(() {}),
      context: context,
      staleAfter: force ? null : const Duration(seconds: 30),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FCMService().clearFcmToken();
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_helper.error != null && _helper.data == null) {
      return buildModuleError(_helper.error!, () => _loadData(force: true));
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_helper.isFromCache)
              OfflineBanner(
                isReconnecting: _helper.isReconnecting,
                onTap: () => _loadData(force: true),
              ),
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildInfoSection('Info Pribadi', Icons.badge_outlined, AppColors.primary, _buildPersonalInfo()),
            const SizedBox(height: 16),
            if (_helper.data?.keluarga != null) ...[
              _buildInfoSection('Info Keluarga', Icons.people_outline_rounded, AppColors.orange, _buildFamilyInfo()),
              const SizedBox(height: 16),
            ],
            _buildMenuSection(),
            const SizedBox(height: 24),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    final data = _helper.data;
    final isLoading = _helper.showSkeleton;

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const SkeletonWidget(width: 80, height: 80, borderRadius: 40),
            const SizedBox(height: 12),
            const SkeletonWidget(width: 180, height: 20),
            const SizedBox(height: 8),
            const SkeletonWidget(width: 160, height: 14),
            const SizedBox(height: 8),
            const SkeletonWidget(width: 120, height: 14),
          ],
        ),
      );
    }

    final inisial = (data?.nama ?? 'U').isNotEmpty
        ? (data!.nama).substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.06),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 3),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                inisial,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data?.nama ?? '-',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NIK: ${data?.nik ?? '-'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (data?.kategoriAnggota != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatKategori(data!.kategoriAnggota!, data.tanggalLahir).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, Color iconColor, Widget content) {
    return Card(
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final data = _helper.data;
    if (_helper.showSkeleton) {
      return _buildSkeletonInfoRows(7);
    }
    if (data == null) return const SizedBox.shrink();

    return Column(
      children: [
        _infoRow('Tempat Lahir', data.tempatLahir ?? '-'),
        _infoRow('Tanggal Lahir', _formatTanggal(data.tanggalLahir)),
        _infoRow('Jenis Kelamin', _formatJenisKelamin(data.jenisKelamin)),
        _infoRow('Golongan Darah', data.golonganDarah ?? '-'),
        _infoRow('Hubungan Keluarga', _formatHubungan(data.hubunganKeluarga)),
        _infoRow('No. Telepon', data.noHp?.isNotEmpty == true ? data.noHp! : '-'),
        _infoRow('Kategori Anggota', _formatKategoriLabel(data.kategoriAnggota)),
      ],
    );
  }

  Widget _buildFamilyInfo() {
    final keluarga = _helper.data?.keluarga;
    if (_helper.showSkeleton) {
      return _buildSkeletonInfoRows(6);
    }
    if (keluarga == null) return const SizedBox.shrink();

    return Column(
      children: [
        _infoRow('No. KK', keluarga.noKk),
        _infoRow('Alamat', keluarga.alamat.isNotEmpty ? keluarga.alamat : '-'),
        _infoRow('RT', keluarga.rt.isNotEmpty ? keluarga.rt : '-'),
        _infoRow('RW', keluarga.rw.isNotEmpty ? keluarga.rw : '-'),
        _infoRow('Dusun', keluarga.dusun.isNotEmpty ? keluarga.dusun : '-'),
        _infoRow('Cabang', keluarga.cabang?.namaPosyandu ?? '-'),
      ],
    );
  }

  Widget _buildSkeletonInfoRows(int count) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              const SkeletonWidget(width: 100, height: 14),
              const SizedBox(width: 12),
              const Expanded(child: SkeletonWidget(width: double.infinity, height: 14)),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildMenuSection() {
    return Card(
      color: AppColors.white,
      child: Column(
        children: [
          _menuItem(
            icon: Icons.edit_outlined,
            iconColor: AppColors.primary,
            label: 'Edit Profil',
            onTap: () async {
              await Navigator.pushNamed(context, '/edit-profile');
              _loadData(force: true);
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _menuItem(
            icon: Icons.logout,
            iconColor: AppColors.error,
            textColor: AppColors.error,
            label: 'Keluar',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: iconColor ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'SIGAP Posyandu Warga v1.0.0',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  static const _bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatTanggal(String? tanggal) {
    if (tanggal == null || tanggal.isEmpty) return '-';
    try {
      final date = DateTime.parse(tanggal);
      return '${date.day} ${_bulan[date.month - 1]} ${date.year}';
    } catch (_) {
      return tanggal;
    }
  }

  String _formatJenisKelamin(String? jk) {
    if (jk == null) return '-';
    if (jk == 'L') return 'Laki-laki';
    if (jk == 'P') return 'Perempuan';
    return jk;
  }

  String _formatHubungan(String? hubungan) {
    if (hubungan == null) return '-';
    switch (hubungan) {
      case 'kepala': return 'Kepala Keluarga';
      case 'istri': return 'Istri';
      case 'anak': return 'Anak';
      case 'lainnya': return 'Lainnya';
      default: return hubungan;
    }
  }

  String _formatKategoriLabel(String? kategori) {
    if (kategori == null) return '-';
    switch (kategori) {
      case 'balita': return 'Balita';
      case 'remaja': return 'Remaja';
      case 'ibu_hamil': return 'Ibu Hamil';
      case 'lansia': return 'Lansia';
      case 'umum': return 'Umum';
      default: return kategori;
    }
  }

  String _formatKategori(String kategori, String? tanggalLahir) {
    final label = _formatKategoriLabel(kategori);
    if (tanggalLahir == null || tanggalLahir.isEmpty) return label;
    try {
      final birth = DateTime.parse(tanggalLahir);
      final now = DateTime.now();
      if (kategori == 'balita') {
        final months = (now.year - birth.year) * 12 + (now.month - birth.month);
        return '$label - $months Bulan';
      }
      int age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return '$label - $age Tahun';
    } catch (_) {
      return label;
    }
  }
}
