import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_colors.dart';

/// Skeleton Glow Loading Widget
/// Uses dark cards with a sweeping neon gradient shimmer
/// instead of generic gray boxes
class SkeletonGlow extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? accentColor;

  const SkeletonGlow({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerColor = accentColor ?? AppColors.active;

    return Shimmer(
      gradient: LinearGradient(
        colors: [
          AppColors.shimmerBase,
          shimmerColor.withValues(alpha: 0.3),
          AppColors.shimmerBase,
        ],
        stops: const [0.0, 0.5, 1.0],
        begin: const Alignment(-1.5, -0.5),
        end: const Alignment(1.5, 0.5),
      ),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryCard,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
      ),
    );
  }
}

/// Skeleton Card for subscription loading states
class SkeletonSubscriptionCard extends StatelessWidget {
  const SkeletonSubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.active.withValues(alpha: 0.3),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero Widget Skeleton for Dashboard
class SkeletonHeroWidget extends StatelessWidget {
  const SkeletonHeroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.active.withValues(alpha: 0.3),
      child: Column(
        children: [
          Container(
            width: 200,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
