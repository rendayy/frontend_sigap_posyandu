import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:frontend_posyandu/widgets/common/home_sections.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';
import 'package:frontend_posyandu/features/themes/app_colors.dart';

void main() {
  group('GreetingSection Tests', () {
    testWidgets('renders name, initials, and badge correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GreetingSection(
              name: 'Andi Pratama',
              initials: 'AP',
              moduleBadge: 'Balita',
              badgeColor: AppColors.pinkVivid,
              badgeBgColor: AppColors.pinkLight,
            ),
          ),
        ),
      );

      expect(find.text('Andi Pratama'), findsOneWidget);
      expect(find.text('AP'), findsOneWidget);
      expect(find.text('Balita'), findsOneWidget);
    });

    testWidgets('shows skeleton when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GreetingSection(
              name: '',
              initials: '',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });

  group('ProfileSummaryCard Tests', () {
    testWidgets('renders values, gradient, and statusRow correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSummaryCard(
              label: 'Usia Balita',
              heroValue: '24',
              heroUnit: 'Bulan',
              icon: Icons.child_care,
              gradient: [AppColors.gold, AppColors.orange, AppColors.goldDark],
              labelColor: AppColors.pinkLight,
              statusRow: Row(
                children: [
                  Text('Imunisasi: '),
                  Text('Lengkap'),
                ],
              ),
              footerValue: '1 Agustus 2026',
            ),
          ),
        ),
      );

      expect(find.text('Usia Balita'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Bulan'), findsOneWidget);
      expect(find.text('Imunisasi: '), findsOneWidget);
      expect(find.text('Lengkap'), findsOneWidget);
      expect(find.text('1 Agustus 2026'), findsOneWidget);
    });

    testWidgets('shows skeleton when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileSummaryCard(
              label: '',
              heroValue: '',
              heroUnit: '',
              icon: Icons.child_care,
              gradient: [AppColors.gold, AppColors.orange, AppColors.goldDark],
              labelColor: AppColors.pinkLight,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });

  group('QuickStatsGrid Tests', () {
    testWidgets('renders all items correctly', (tester) async {
      final items = [
        const QuickStatItem(
          label: 'Tinggi Badan',
          value: '95',
          unit: 'cm',
          icon: Icons.height,
          iconColor: Colors.purple,
        ),
        const QuickStatItem(
          label: 'Berat Badan',
          value: '14',
          unit: 'kg',
          icon: Icons.monitor_weight_outlined,
          iconColor: Colors.red,
        ),
        const QuickStatItem(
          label: 'Lingkar Kepala',
          value: '48',
          unit: 'cm',
          icon: Icons.adjust,
          iconColor: Colors.green,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickStatsGrid(items: items),
          ),
        ),
      );

      expect(find.text('Tinggi Badan'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
      expect(find.text('Berat Badan'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('Lingkar Kepala'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
    });

    testWidgets('shows skeleton when loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QuickStatsGrid(items: [], isLoading: true),
          ),
        ),
      );

      expect(find.byType(SkeletonWidget), findsWidgets);
    });
  });
}
