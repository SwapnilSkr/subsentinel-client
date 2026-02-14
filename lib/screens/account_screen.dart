import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_mode_provider.dart';
import '../data/models/user_model.dart';
import '../data/providers/auth_provider.dart';
import '../widgets/glass_card.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.headlineLarge,
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
            const SizedBox(height: 8),
            Text(
              'Profile and appearance',
              style: Theme.of(context).textTheme.bodyMedium,
            ).animate().fadeIn(delay: 120.ms, duration: 350.ms),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.active.withValues(
                        alpha: isDark ? 0.2 : 0.16,
                      ),
                      border: Border.all(
                        color: AppColors.active.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _initials(user),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.active,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(user),
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _secondaryLabel(user),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
            const SizedBox(height: 14),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _ThemeModeSelector(
                    mode: themeMode,
                    onChanged: (mode) async {
                      HapticFeedback.selectionClick();
                      await ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(mode);
                    },
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      isDark
                          ? 'Dark mode is active on this device'
                          : 'Light mode is active on this device',
                      key: ValueKey(themeMode),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.08),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await ref.read(authProvider.notifier).logout();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.alert,
                  side: BorderSide(
                    color: AppColors.alert.withValues(alpha: 0.45),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = mode == ThemeMode.dark;
    final borderColor = isDark
        ? AppColors.scanLine.withValues(alpha: 0.3)
        : AppColors.lightScanLine.withValues(alpha: 0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        color: AppColors.glassBackgroundFor(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ThemeSegment(
              selected: isDark,
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              activeColor: AppColors.scanLine,
              onTap: () => onChanged(ThemeMode.dark),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ThemeSegment(
              selected: !isDark,
              icon: Icons.light_mode_rounded,
              label: 'Light',
              activeColor: AppColors.lightScanLine,
              onTap: () => onChanged(ThemeMode.light),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  const _ThemeSegment({
    required this.selected,
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.textMutedFor(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 340),
              turns: selected ? 0 : -0.04,
              curve: Curves.easeOutCubic,
              child: Icon(
                icon,
                size: 18,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

String _displayName(AppUser? user) {
  if (user == null) {
    return 'SubSentinel User';
  }
  final displayName = user.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }
  final email = user.email?.trim();
  if (email != null && email.isNotEmpty) {
    return email;
  }
  final phone = user.phone?.trim();
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return 'SubSentinel User';
}

String _secondaryLabel(AppUser? user) {
  if (user == null) {
    return 'Signed in';
  }
  final phone = user.phone?.trim();
  final email = user.email?.trim();
  if (email != null && email.isNotEmpty && phone != null && phone.isNotEmpty) {
    return '$email • $phone';
  }
  if (email != null && email.isNotEmpty) {
    return email;
  }
  if (phone != null && phone.isNotEmpty) {
    return phone;
  }
  return 'Signed in';
}

String _initials(AppUser? user) {
  final source = _displayName(user).trim();
  if (source.isEmpty) {
    return 'SS';
  }
  final parts = source
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  final first = parts.first.substring(0, 1);
  final second = parts[1].substring(0, 1);
  return (first + second).toUpperCase();
}
