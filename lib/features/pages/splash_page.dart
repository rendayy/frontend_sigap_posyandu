import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/services/auth/auth_service.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  static const _tag = 'SplashPage';

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;
  Timer? _deadlineTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    _timer = Timer(const Duration(seconds: 2), _navigateNext);
    _deadlineTimer = Timer(const Duration(seconds: 12), () {
      if (!mounted || _navigated) return;
      log('$_tag: hard-deadline tercapai -> paksa ke /login', name: _tag);
      _navigateReplacement('/login');
    });
  }

  Future<void> _navigateNext() async {
    if (_navigated) return;

    late final AuthService authService;
    try {
      authService = AuthService();
    } catch (e) {
      log('$_tag: AuthService gagal dikonstruksi ($e) -> /login', name: _tag);
      _navigateReplacement('/login');
      return;
    }

    final hasToken = await _safeRead(() => authService.isLoggedIn());
    if (!mounted || _navigated) return;
    log('$_tag: isLoggedIn=$hasToken', name: _tag);

    if (hasToken != true) {
      _navigateReplacement('/login');
      return;
    }

    // Sesi hanya valid bila data lengkap & konsisten.
    // Token parsial (sisa restore backup/crash) -> bersihkan & kembali ke login.
    final userInfo = await _safeRead(() => authService.getUserInfo());
    final category = await _safeRead(() => authService.getCategory());

    if (!mounted || _navigated) return;
    log(
      '$_tag: userInfo=${userInfo != null}, category=${category?.name ?? 'null'}',
      name: _tag,
    );

    if (userInfo == null || category == null) {
      try {
        await authService.logout().timeout(const Duration(seconds: 5));
      } catch (e) {
        log('$_tag: bersihkan sesi parsial gagal ($e)', name: _tag);
      }
      if (!mounted || _navigated) return;
      _navigateReplacement('/login');
      return;
    }

    _navigateReplacement(category.route);
  }

  Future<T?> _safeRead<T>(Future<T> Function() fn) async {
    try {
      return await fn().timeout(const Duration(seconds: 5));
    } catch (e) {
      log('$_tag: read gagal ($e)', name: _tag);
      return null;
    }
  }

  void _navigateReplacement(String route) {
    if (!mounted || _navigated) return;
    _navigated = true;
    log('$_tag: navigate -> $route', name: _tag);

    try {
      Navigator.pushReplacementNamed(context, route);
    } catch (e) {
      log('$_tag: navigasi ke $route gagal ($e) -> fallback /login', name: _tag);
      _navigated = false;
      if (!mounted) return;
      try {
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e2) {
        log('$_tag: fallback navigasi /login juga gagal: $e2', name: _tag);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _deadlineTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            Positioned(
              top: -64,
              right: -64,
              child: Container(
                width: 224,
                height: 224,
                decoration: const BoxDecoration(
                  color: AppColors.circleLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: -100,
              child: Container(
                width: 288,
                height: 288,
                decoration: const BoxDecoration(
                  color: AppColors.circleLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SIGAP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Posyandu Warga',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sistem Informasi Kesehatan\nWarga Posyandu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dot(true),
                      const SizedBox(width: 8),
                      _dot(false),
                      const SizedBox(width: 8),
                      _dot(false),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Dinas Kesehatan Kota',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.peach,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? AppColors.white : AppColors.white.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}
