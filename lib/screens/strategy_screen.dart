import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/providers/subscription_providers.dart';
import '../data/models/subscription.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_glow.dart';

/// Screen D: "Strategy & Churn" (Analysis)
class StrategyScreen extends ConsumerStatefulWidget {
  const StrategyScreen({super.key});

  @override
  ConsumerState<StrategyScreen> createState() => _StrategyScreenState();
}

class _StrategyScreenState extends ConsumerState<StrategyScreen> {
  bool _showInsight = true;

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Stack(
      children: [
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Strategy & Churn',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const SizedBox(height: 8),
                    Text(
                      'Your renewal timeline',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: 100.ms),
                  ],
                ),
              ),
              // Month spending overview
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: summaryAsync.when(
                  loading: () => _buildLoadingStats(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (summary) => _buildStatsCard(summary),
                ),
              ),
              const SizedBox(height: 24),
              // Churn Calendar header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Churn Calendar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              // Timeline
              Expanded(
                child: subscriptionsAsync.when(
                  loading: () => _buildLoadingList(),
                  error: (error, _) => _buildErrorWidget(error),
                  data: (subscriptions) => _buildChurnCalendar(subscriptions),
                ),
              ),
            ],
          ),
        ),
        // AI Insight Toast
        if (_showInsight)
          subscriptionsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (subscriptions) {
              // Find a paused subscription to suggest cancelling
              final pausedSub = subscriptions.where((s) => s.isPaused).toList();
              if (pausedSub.isNotEmpty) {
                return _buildAIInsightToast(pausedSub.first);
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _buildLoadingStats() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                SkeletonGlow(width: 50, height: 18),
                SizedBox(height: 4),
                SkeletonGlow(width: 70, height: 14),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorderFor(context),
          ),
          Expanded(
            child: Column(
              children: [
                SkeletonGlow(width: 50, height: 18),
                SizedBox(height: 4),
                SkeletonGlow(width: 70, height: 14),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorderFor(context),
          ),
          Expanded(
            child: Column(
              children: [
                SkeletonGlow(width: 50, height: 18),
                SizedBox(height: 4),
                SkeletonGlow(width: 70, height: 14),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    const SkeletonGlow(width: 12, height: 12),
                    if (index < 4)
                      Container(
                        width: 2,
                        height: 60,
                        color: AppColors.glassBorderFor(context),
                      ),
                  ],
                ),
              ),
              const Expanded(
                child: GlassCard(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SkeletonGlow(width: 40, height: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonGlow(width: 100, height: 16),
                            SizedBox(height: 4),
                            SkeletonGlow(width: 80, height: 14),
                          ],
                        ),
                      ),
                      SkeletonGlow(width: 50, height: 16),
                    ],
                  ),
                ),
              ),
            ],
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
            'Failed to load data',
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

  Widget _buildStatsCard(DashboardSummary summary) {
    // Calculate next month (simple estimation)
    final nextMonthEstimate = summary.totalBurn * 1.1; // 10% buffer
    final potentialSave =
        summary.totalBurn * 0.15; // Estimate potential savings

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              title: 'This Month',
              value: '\$${summary.totalBurn.toStringAsFixed(2)}',
              color: AppColors.active,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorderFor(context),
          ),
          Expanded(
            child: _StatItem(
              title: 'Next Month',
              value: '\$${nextMonthEstimate.toStringAsFixed(2)}',
              color: AppColors.paused,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.glassBorderFor(context),
          ),
          Expanded(
            child: _StatItem(
              title: 'Potential Save',
              value: '\$${potentialSave.toStringAsFixed(2)}',
              color: AppColors.alert,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildChurnCalendar(List<Subscription> subscriptions) {
    if (subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              color: AppColors.textMutedFor(context),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No subscriptions to display',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add subscriptions to see your renewal timeline',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Sort by next billing date
    final sortedSubscriptions = List<Subscription>.from(subscriptions)
      ..sort((a, b) => a.nextBilling.compareTo(b.nextBilling));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
      itemCount: sortedSubscriptions.length,
      itemBuilder: (context, index) {
        final sub = sortedSubscriptions[index];
        final isPast = sub.nextBilling.isBefore(DateTime.now());
        final isToday = DateUtils.isSameDay(sub.nextBilling, DateTime.now());

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPast
                          ? AppColors.textMutedFor(context)
                          : (isToday ? AppColors.alert : AppColors.active),
                      boxShadow: !isPast
                          ? [
                              BoxShadow(
                                color:
                                    (isToday
                                            ? AppColors.alert
                                            : AppColors.active)
                                        .withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  if (index < sortedSubscriptions.length - 1)
                    Container(
                      width: 2,
                      height: 60,
                      color: AppColors.glassBorderFor(context),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child:
                    Opacity(
                          opacity: isPast ? 0.5 : 1.0,
                          child: GlassCard(
                            accentColor: sub.isPaused
                                ? AppColors.paused
                                : (isPast ? null : AppColors.active),
                            enableGlow: !isPast,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.glassBackgroundFor(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      sub.provider.isNotEmpty
                                          ? sub.provider[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: isPast
                                            ? AppColors.textMutedFor(context)
                                            : AppColors.active,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
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
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.paused
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'PAUSED',
                                                style: TextStyle(
                                                  color: AppColors.paused,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        DateFormat(
                                          'MMM d, yyyy',
                                        ).format(sub.nextBilling),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${sub.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: isPast
                                        ? AppColors.textMutedFor(context)
                                        : AppColors.active,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 50 * index))
                        .slideX(begin: 0.1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAIInsightToast(Subscription pausedSub) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 110,
      child: GestureDetector(
        onVerticalDragEnd: (_) => setState(() => _showInsight = false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.surfaceFor(context).withValues(alpha: 0.95),
                    AppColors.surfaceFor(context).withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.paused.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.paused.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.paused.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: AppColors.paused,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI Insight',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.paused,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _showInsight = false),
                        child: Icon(
                          Icons.close,
                          color: AppColors.textMutedFor(context),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        const TextSpan(text: 'Hey, '),
                        TextSpan(
                          text: pausedSub.provider,
                          style: const TextStyle(
                            color: AppColors.paused,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' is currently '),
                        const TextSpan(
                          text: 'paused',
                          style: TextStyle(
                            color: AppColors.alert,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: '. Consider cancelling to save '),
                        TextSpan(
                          text: '\$${pausedSub.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: AppColors.active,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: '/month?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _showInsight = false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.glassBorderFor(context),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Maybe Later'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await ref
                                .read(subscriptionsProvider.notifier)
                                .cancelSubscription(pausedSub.id);
                            setState(() => _showInsight = false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.active,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel ${pausedSub.provider} 💸',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
