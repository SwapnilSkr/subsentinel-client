import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Glassmorphism Card following SubSentinel SOP
///
/// The Glassmorphism Recipe:
/// - Background: #121212
/// - Border: 1px Solid rgba(255, 255, 255, 0.1)
/// - BackdropFilter: blur(15.0)
/// - Shadow: BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 20)
class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool enableGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.enableGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = accentColor ?? AppColors.active;
    final surfaceColor = AppColors.surfaceFor(context);
    final borderColor = AppColors.glassBorderFor(context);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: enableGlow
            ? [
                BoxShadow(
                  color: glowColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subscription Card with swipe actions for The Vault screen
class SwipeableSubscriptionCard extends StatefulWidget {
  final String name;
  final String logoUrl;
  final double price;
  final int daysLeft;
  final bool isRenewingSoon;
  final VoidCallback? onPause;
  final VoidCallback? onCancel;
  final VoidCallback? onTap;

  const SwipeableSubscriptionCard({
    super.key,
    required this.name,
    required this.logoUrl,
    required this.price,
    required this.daysLeft,
    this.isRenewingSoon = false,
    this.onPause,
    this.onCancel,
    this.onTap,
  });

  @override
  State<SwipeableSubscriptionCard> createState() =>
      _SwipeableSubscriptionCardState();
}

class _SwipeableSubscriptionCardState extends State<SwipeableSubscriptionCard> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.name),
      background: _buildSwipeBackground(
        color: AppColors.paused,
        icon: Icons.pause_circle_outline,
        label: 'Pause',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: AppColors.alert,
        icon: Icons.cancel_outlined,
        label: 'Cancel',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onPause?.call();
        } else {
          widget.onCancel?.call();
        }
        return false; // Don't actually dismiss
      },
      child: GlassCard(
        accentColor: widget.isRenewingSoon ? AppColors.alert : null,
        enableGlow: widget.isRenewingSoon,
        onTap: widget.onTap,
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.glassBackgroundFor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  widget.name.substring(0, 1).toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.active),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Name and Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}/mo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            // Days Left Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isRenewingSoon
                    ? AppColors.alert.withValues(alpha: 0.2)
                    : AppColors.glassBackgroundFor(context),
                borderRadius: BorderRadius.circular(20),
                border: widget.isRenewingSoon
                    ? Border.all(color: AppColors.alert.withValues(alpha: 0.5))
                    : null,
              ),
              child: Text(
                '${widget.daysLeft}d',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: widget.isRenewingSoon
                      ? AppColors.alert
                      : AppColors.textSecondaryFor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: alignment == Alignment.centerLeft
            ? [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ]
            : [
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: color),
              ],
      ),
    );
  }
}
