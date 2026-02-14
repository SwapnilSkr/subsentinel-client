import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/providers/subscription_providers.dart';
import '../data/models/subscription.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_glow.dart';

/// Screen B: "The Vault" (Subscription Management)
/// Tactile Modules with swipe actions for pause/cancel
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  late ConfettiController _confettiController;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);

    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'The Vault',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your subscriptions',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                  ],
                ),
              ),

              // Total Monthly
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: subscriptionsAsync.when(
                  loading: () => _buildLoadingTotal(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (subscriptions) => _buildTotalCard(subscriptions),
                ),
              ),

              const SizedBox(height: 16),

              // Swipe Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SwipeHint(
                      icon: Icons.chevron_right,
                      label: 'Pause',
                      color: AppColors.paused,
                    ),
                    const SizedBox(width: 24),
                    _SwipeHint(
                      icon: Icons.chevron_left,
                      label: 'Cancel',
                      color: AppColors.alert,
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ),

              const SizedBox(height: 16),

              // Subscription List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(subscriptionsProvider.notifier).refresh(),
                  color: AppColors.active,
                  backgroundColor: AppColors.surfaceFor(context),
                  child: subscriptionsAsync.when(
                    loading: () => _buildLoadingState(),
                    error: (error, stack) => _buildErrorWidget(error),
                    data: (subscriptions) =>
                        _buildSubscriptionList(subscriptions),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.active,
              AppColors.paused,
              AppColors.scanLine,
            ],
            createParticlePath: _drawEmojiPath,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingTotal() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonGlow(width: 80, height: 16),
              SizedBox(height: 8),
              SkeletonGlow(width: 100, height: 28),
            ],
          ),
          const SkeletonGlow(width: 80, height: 32),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTotalCard(List<Subscription> subscriptions) {
    final activeSubscriptions = subscriptions
        .where((s) => s.status == SubscriptionStatus.active)
        .toList();
    final total = activeSubscriptions.fold(0.0, (sum, s) => sum + s.amount);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Monthly',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: AppTheme.getBurnRateFontWeight(total),
                  color: AppColors.active,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.active.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${activeSubscriptions.length} Active',
              style: const TextStyle(
                color: AppColors.active,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: const SkeletonSubscriptionCard().animate().fadeIn(
            delay: Duration(milliseconds: 100 * index),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.alert, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load subscriptions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(subscriptionsProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.active),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionList(List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: AppColors.textMutedFor(context),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No subscriptions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first subscription to get started',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        final isExpanded = _expandedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child:
              Dismissible(
                    key: Key(sub.id),
                    background: _buildSwipeBackground(
                      color: AppColors.paused,
                      icon: Icons.pause_circle_outline,
                      label: sub.isPaused ? 'Resume' : 'Pause',
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
                        await _handlePause(sub);
                      } else {
                        await _handleCancel(context, sub);
                      }
                      return false;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: GlassCard(
                        accentColor: sub.isPaused
                            ? AppColors.paused
                            : (sub.isRenewingSoon ? AppColors.alert : null),
                        enableGlow: sub.isRenewingSoon || sub.isPaused,
                        onTap: () => _toggleExpand(index),
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            // Main content
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Logo placeholder
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.glassBackgroundFor(
                                        context,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        sub.provider.isNotEmpty
                                            ? sub.provider[0].toUpperCase()
                                            : '?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: sub.isPaused
                                                  ? AppColors.paused
                                                  : AppColors.active,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Name and Price
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                sub.provider,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (sub.isPaused) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.paused
                                                      .withValues(alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Text(
                                                  'PAUSED',
                                                  style: TextStyle(
                                                    color: AppColors.paused,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              '\$${sub.amount.toStringAsFixed(2)}/mo',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                            ),
                                            if (sub.category != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _parseColor(sub.category!.color)
                                                      .withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      _mapCategoryIcon(sub.category!.icon),
                                                      size: 10,
                                                      color: _parseColor(sub.category!.color),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      sub.category!.name,
                                                      style: TextStyle(
                                                        color: _parseColor(sub.category!.color),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Days Left Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: sub.isRenewingSoon
                                          ? AppColors.alert.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppColors.glassBackgroundFor(
                                              context,
                                            ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: sub.isRenewingSoon
                                          ? Border.all(
                                              color: AppColors.alert.withValues(
                                                alpha: 0.5,
                                              ),
                                            )
                                          : null,
                                    ),
                                    child: Text(
                                      '${sub.daysLeft}d',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: sub.isRenewingSoon
                                                ? AppColors.alert
                                                : AppColors.textSecondaryFor(
                                                    context,
                                                  ),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: AppColors.textMutedFor(context),
                                  ),
                                ],
                              ),
                            ),

                            // Expanded content
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: _buildExpandedContent(sub),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 300),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 50 * index),
                    duration: 400.ms,
                  )
                  .slideY(begin: 0.1),
        );
      },
    );
  }

  Widget _buildExpandedContent(Subscription sub) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: AppColors.glassBorderFor(context)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Billing',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                DateFormat('MMM d, yyyy').format(sub.nextBilling),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status', style: Theme.of(context).textTheme.labelLarge),
              Text(
                sub.status.value.toUpperCase(),
                style: TextStyle(
                  color: sub.isPaused ? AppColors.paused : AppColors.active,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (sub.category != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category', style: Theme.of(context).textTheme.labelLarge),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _parseColor(sub.category!.color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _mapCategoryIcon(sub.category!.icon),
                        size: 14,
                        color: _parseColor(sub.category!.color),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sub.category!.name,
                        style: TextStyle(
                          color: _parseColor(sub.category!.color),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          // Kill Switch Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCancelConfirmation(context, sub),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alert,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.power_settings_new),
              label: const Text(
                'Cancel Subscription',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
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

  void _toggleExpand(int index) {
    AppHaptics.navigation();
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  Future<void> _handlePause(Subscription sub) async {
    AppHaptics.success();
    try {
      await ref.read(subscriptionsProvider.notifier).toggleStatus(sub.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              sub.isPaused
                  ? '${sub.provider} resumed'
                  : '${sub.provider} paused',
            ),
            backgroundColor: AppColors.surfaceFor(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }

  Future<void> _handleCancel(BuildContext context, Subscription sub) async {
    await _showCancelConfirmation(context, sub);
  }

  Future<void> _showCancelConfirmation(
    BuildContext context,
    Subscription sub,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CancelConfirmationSheet(
        subscriptionName: sub.provider,
        price: sub.amount,
      ),
    );

    if (result == true && mounted) {
      AppHaptics.success();
      _confettiController.play();
      try {
        await ref
            .read(subscriptionsProvider.notifier)
            .cancelSubscription(sub.id);
      } catch (e) {
        // ignore error - subscription was already removed from UI
      }
    }
  }

  Color _parseColor(String hex) {
    final hexStr = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hexStr', radix: 16));
  }

  IconData _mapCategoryIcon(String icon) {
    const iconMap = {
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'work': Icons.work,
      'cloud': Icons.cloud,
      'sports_esports': Icons.sports_esports,
      'newspaper': Icons.newspaper,
      'school': Icons.school,
      'fitness_center': Icons.fitness_center,
      'account_balance': Icons.account_balance,
      'chat': Icons.chat,
      'shopping_bag': Icons.shopping_bag,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'build': Icons.build,
    };
    return iconMap[icon] ?? Icons.category;
  }

  Path _drawEmojiPath(Size size) {
    final path = Path();
    final center = size.width / 2;
    path.moveTo(center, 0);
    path.lineTo(center * 1.3, center * 0.7);
    path.lineTo(size.width, center);
    path.lineTo(center * 1.3, center * 1.3);
    path.lineTo(center, size.height);
    path.lineTo(center * 0.7, center * 1.3);
    path.lineTo(0, center);
    path.lineTo(center * 0.7, center * 0.7);
    path.close();
    return path;
  }
}

class _SwipeHint extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SwipeHint({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CancelConfirmationSheet extends StatelessWidget {
  final String subscriptionName;
  final double price;

  const _CancelConfirmationSheet({
    required this.subscriptionName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorderFor(context)),
              left: BorderSide(color: AppColors.glassBorderFor(context)),
              right: BorderSide(color: AppColors.glassBorderFor(context)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMutedFor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.alert,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Cancel $subscriptionName?',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ll save \$${price.toStringAsFixed(2)}/month',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.active),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.glassBorderFor(context),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Keep It'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alert,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel 💸',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
