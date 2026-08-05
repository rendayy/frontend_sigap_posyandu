import 'package:flutter/material.dart';
import 'package:frontend_posyandu/widgets/common/skeleton_widget.dart';

class GulaDarahChartSkeleton extends StatelessWidget {
  final bool embedded;

  const GulaDarahChartSkeleton({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Header card skeleton
        _buildHeaderCardSkeleton(),
        const SizedBox(height: 16),
        // Chart card skeleton
        _buildChartCardSkeleton(),
        const SizedBox(height: 16),
        // History section skeleton
        _buildHistorySectionSkeleton(),
      ],
    );
  }

  Widget _buildHeaderCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x14000000)),
      ),
      child: Row(
        children: [
          const SkeletonWidget(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonWidget(width: 80, height: 14),
                const SizedBox(height: 8),
                const SkeletonWidget(width: 100, height: 24),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const SkeletonWidget(width: 60, height: 22, borderRadius: 6),
          const SizedBox(width: 12),
          const SkeletonWidget(width: 40, height: 14),
        ],
      ),
    );
  }

  Widget _buildChartCardSkeleton() {
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
          const SkeletonWidget(width: 120, height: 20),
          const SizedBox(height: 4),
          const SkeletonWidget(width: 180, height: 14),
          const SizedBox(height: 16),
          const SkeletonWidget(width: double.infinity, height: 200),
          const SizedBox(height: 16),
          // Legend skeleton
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(3, (index) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SkeletonWidget(width: 12, height: 12, borderRadius: 2),
                  const SizedBox(width: 6),
                  const SkeletonWidget(width: 50, height: 12),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySectionSkeleton() {
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
          const SkeletonWidget(width: 140, height: 16),
          const SizedBox(height: 12),
          // 5 measurement items
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Expanded(
                    flex: 2,
                    child: SkeletonWidget(width: 80, height: 14),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SkeletonWidget(
                      width: 50,
                      height: 16,
                      borderRadius: 6,
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SkeletonWidget(width: 60, height: 14),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          // Pagination skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SkeletonWidget(width: 60, height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const SkeletonWidget(width: 40, height: 14),
              ),
              const SkeletonWidget(width: 60, height: 14),
            ],
          ),
        ],
      ),
    );
  }
}
