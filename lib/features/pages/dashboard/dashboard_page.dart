import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';
import 'package:frontend_posyandu/services/fcm_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _fcmStatus;

  @override
  void initState() {
    super.initState();
    _checkFcmStatus();
  }

  Future<void> _checkFcmStatus() async {
    final token = await FCMService().getToken();
    setState(() {
      _fcmStatus = token != null
          ? '${token.substring(0, 20)}...'
          : 'Belum terdaftar';
    });
  }

  Future<void> _registerFcm() async {
    final token = await FCMService().getToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mendapatkan FCM token')),
      );
      return;
    }

    final authService = AuthService();
    final accessToken = await authService.getAccessToken();
    if (accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada token akses')),
      );
      return;
    }

    FCMService().setJwtToken(accessToken);
    final ok = await FCMService().registerCurrentToken();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'FCM token berhasil didaftarkan'
            : 'Gagal mendaftarkan FCM token (cek backend)'),
      ),
    );
    _checkFcmStatus();
  }

  Future<void> _logout() async {
    await FCMService().clearFcmToken();
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('SIGAP Posyandu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'SIGAP Posyandu Warga',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Status FCM'),
                    const SizedBox(height: 8),
                    Text(
                      _fcmStatus ?? 'Memuat...',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _registerFcm,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Daftarkan Ulang FCM'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
