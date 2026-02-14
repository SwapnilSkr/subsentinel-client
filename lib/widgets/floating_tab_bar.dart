import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';

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
    final surfaceColor = AppColors.surfaceFor(context);
    final borderColor = AppColors.glassBorderFor(context);
    final inactiveColor = AppColors.textMutedFor(context);

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
              color: surfaceColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: borderColor, width: 1),
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
                Expanded(
                  child: _TabItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Command',
                    isSelected: currentIndex == 0,
                    inactiveColor: inactiveColor,
                    onTap: () => _handleTap(0),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.lock_rounded,
                    label: 'Vault',
                    isSelected: currentIndex == 1,
                    inactiveColor: inactiveColor,
                    onTap: () => _handleTap(1),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.camera_alt_rounded,
                    label: 'Lens',
                    isSelected: currentIndex == 2,
                    inactiveColor: inactiveColor,
                    onTap: () => _handleTap(2),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.insights_rounded,
                    label: 'Strategy',
                    isSelected: currentIndex == 3,
                    inactiveColor: inactiveColor,
                    onTap: () => _handleTap(3),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.person_rounded,
                    label: 'Account',
                    isSelected: currentIndex == 4,
                    inactiveColor: inactiveColor,
                    onTap: () => _handleTap(4),
                  ),
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
  final Color inactiveColor;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.active.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.08 : 1,
              child: Icon(
                icon,
                color: isSelected ? AppColors.active : inactiveColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.active : inactiveColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
