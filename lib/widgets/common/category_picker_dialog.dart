import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend_posyandu/core/models/auth/user_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

class CategoryPickerDialog extends StatelessWidget {
  const CategoryPickerDialog({super.key});

  static Future<UserCategory?> show(BuildContext context) {
    return showDialog<UserCategory>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CategoryPickerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        title: Text(
          'Pilih Kategori Anda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Silakan pilih modul yang ingin Anda akses',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            for (final category in UserCategory.values)
              _CategoryTile(category: category, onTap: () {
                Navigator.of(context).pop(category);
              }),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final UserCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _icon(),
              const SizedBox(width: 12),
              Text(
                category.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    IconData icon;
    switch (category) {
      case UserCategory.balita:
        icon = Icons.child_care;
      case UserCategory.remaja:
        icon = Icons.people;
      case UserCategory.posbindu:
        icon = Icons.local_hospital;
      case UserCategory.lansia:
        icon = Icons.elderly;
      case UserCategory.ibuHamil:
        icon = Icons.pregnant_woman;
    }
    return Icon(icon, color: AppColors.primary, size: 24);
  }
}
