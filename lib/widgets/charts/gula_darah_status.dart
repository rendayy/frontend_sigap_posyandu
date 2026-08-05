import 'package:flutter/material.dart';
import 'package:frontend_posyandu/core/models/remaja/gula_darah_chart_model.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

/// Mengembalikan warna status berdasarkan status gula darah
Color gulaDarahStatusColor(String? status) {
  switch (status) {
    case 'normal':
      return const Color(0xFF43A047); // emerald
    case 'pra_diabetes':
      return const Color(0xFFFFA726); // amber
    case 'diabetes':
      return const Color(0xFFB71C1C); // dark red
    default:
      return AppColors.textSecondary;
  }
}

/// Mengembalikan label status yang ramah pengguna
String gulaDarahStatusLabel(String? status) {
  switch (status) {
    case 'normal':
      return 'Normal';
    case 'pra_diabetes':
      return 'Pra-diabetes';
    case 'diabetes':
      return 'Diabetes';
    default:
      return 'Belum ada data';
  }
}

/// Menentukan status gula darah berdasarkan nilai dan zona
GulaDarahZone? determineGulaDarahStatus(int value, List<GulaDarahZone> zones) {
  for (final zone in zones) {
    if (value >= zone.min && value <= zone.max) {
      return zone;
    }
  }
  return null;
}

/// Mengubah string warna hex menjadi Color
Color parseHexColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
