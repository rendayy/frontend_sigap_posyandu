import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
      _NavItem(label: 'Riwayat', icon: Icons.history_outlined, activeIcon: Icons.history),
      _NavItem(label: 'Jadwal', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
      _NavItem(label: 'Notifikasi', icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
      _NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
    ];

    return Container(
      height: 63,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: Color(0x14000000), width: 0.5),
        ),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Container(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 20,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 16,
                        height: 2,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
