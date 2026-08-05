import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? activeColor;
  final List<NavItem>? items;

  const HomeBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onTap,
    this.activeColor,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.orange;
    final navItems = items ?? const [
      NavItem(label: 'Beranda', icon: Icons.home_outlined, activeIcon: Icons.home),
      NavItem(label: 'Riwayat', icon: Icons.history_outlined, activeIcon: Icons.history),
      NavItem(label: 'Profil', icon: Icons.person_outline, activeIcon: Icons.person),
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
        children: List.generate(navItems.length, (i) {
          final item = navItems[i];
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
                        color: isActive ? effectiveActiveColor : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isActive ? effectiveActiveColor : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (isActive)
                      Container(
                        width: 16,
                        height: 2,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: effectiveActiveColor,
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
