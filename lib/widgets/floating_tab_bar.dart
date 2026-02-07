import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

/// Floating Tab Bar - Pill-shaped frosted glass navigation
/// Sits 20px above the bottom of the screen
class FloatingTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryCard.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.glassBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppColors.active.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _TabItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Command',
                  isSelected: currentIndex == 0,
                  onTap: () => _handleTap(0),
                ),
                _TabItem(
                  icon: Icons.lock_rounded,
                  label: 'Vault',
                  isSelected: currentIndex == 1,
                  onTap: () => _handleTap(1),
                ),
                _TabItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Lens',
                  isSelected: currentIndex == 2,
                  onTap: () => _handleTap(2),
                ),
                _TabItem(
                  icon: Icons.insights_rounded,
                  label: 'Strategy',
                  isSelected: currentIndex == 3,
                  onTap: () => _handleTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    HapticFeedback.selectionClick();
    onTap(index);
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.active.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.active : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.active : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
