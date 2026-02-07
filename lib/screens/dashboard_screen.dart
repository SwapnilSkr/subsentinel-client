import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../data/providers/subscription_providers.dart';
import '../data/models/subscription.dart';
import '../widgets/glass_card.dart';
import '../widgets/skeleton_glow.dart';

/// Screen A: "Command Center" (Dashboard)
/// Dynamic Bento Grid that looks like a cockpit
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Budget threshold
  final double _budget = 150.0;
  final double _dayOfMonth = DateTime.now().day.toDouble();
  late final double _daysInMonth;

  @override
  void initState() {
    super.initState();
    _daysInMonth = DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0,
    ).day.toDouble();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => ref.read(dashboardSummaryProvider.notifier).refresh(),
        color: AppColors.active,
        backgroundColor: AppColors.primaryCard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Command Center',
                style: Theme.of(context).textTheme.headlineLarge,
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'Your subscription cockpit',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 24),

              // Hero Widget with Burn Gauge
              summaryAsync.when(
                loading: () => _buildLoadingHero(),
                error: (error, stack) => _buildErrorWidget(error),
                data: (summary) => _buildHeroWidget(summary),
              ),

              const SizedBox(height: 24),

              // Pulse Strip - Horizontal scroll of service icons
              Text(
                'Upcoming Renewals',
                style: Theme.of(context).textTheme.titleMedium,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              summaryAsync.when(
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.active),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _buildPulseStrip(summary.renewingSoon),
              ),

              const SizedBox(height: 24),

              // Quick Stats Grid
              summaryAsync.when(
                loading: () => _buildLoadingStats(),
                error: (_, __) => const SizedBox.shrink(),
                data: (summary) => _buildQuickStatsGrid(summary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingHero() {
    return const GlassCard(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          SkeletonGlow(width: 100, height: 20),
          SizedBox(height: 8),
          SkeletonGlow(width: 180, height: 56),
          SizedBox(height: 32),
          SkeletonGlow(width: 160, height: 80),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonGlow(width: 60, height: 16),
              SkeletonGlow(width: 80, height: 16),
              SkeletonGlow(width: 60, height: 16),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 500.ms);
  }

  Widget _buildLoadingStats() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonGlow(width: 24, height: 24),
                SizedBox(height: 8),
                SkeletonGlow(width: 40, height: 20),
                SizedBox(height: 4),
                SkeletonGlow(width: 60, height: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonGlow(width: 24, height: 24),
                SizedBox(height: 8),
                SkeletonGlow(width: 40, height: 20),
                SizedBox(height: 4),
                SkeletonGlow(width: 60, height: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SkeletonGlow(width: 24, height: 24),
                SizedBox(height: 8),
                SkeletonGlow(width: 40, height: 20),
                SizedBox(height: 4),
                SkeletonGlow(width: 60, height: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Object error) {
    return GlassCard(
      accentColor: AppColors.alert,
      padding: const EdgeInsets.all(24),
      child: Column(
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
            onPressed: () =>
                ref.read(dashboardSummaryProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.active),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroWidget(DashboardSummary summary) {
    final monthlyTotal = summary.totalBurn;
    final isOverBudget = monthlyTotal > _budget;
    final burnProgress = _dayOfMonth / _daysInMonth;
    final fontWeight = AppTheme.getBurnRateFontWeight(monthlyTotal);

    // Start pulse animation if over budget
    if (isOverBudget && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isOverBudget && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    return GlassCard(
          accentColor: isOverBudget ? AppColors.alert : AppColors.active,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: isOverBudget ? _pulseAnimation.value : 1.0,
                    child: child,
                  );
                },
                child: Column(
                  children: [
                    Text(
                      'Monthly Total',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: isOverBudget
                            ? [AppColors.alert, AppColors.paused]
                            : [AppColors.active, AppColors.scanLine],
                      ).createShader(bounds),
                      child: Text(
                        '\$${monthlyTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: fontWeight,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                    ),
                    if (isOverBudget)
                      Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.alert.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.alert.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              '\$${(monthlyTotal - _budget).toStringAsFixed(2)} over budget',
                              style: const TextStyle(
                                color: AppColors.alert,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                          .shimmer(
                            duration: 1500.ms,
                            color: AppColors.alert.withValues(alpha: 0.3),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildBurnGauge(burnProgress),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Month Start',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    'Day ${_dayOfMonth.toInt()} of ${_daysInMonth.toInt()}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(
                    'Month End',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildBurnGauge(double progress) {
    Color progressColor;
    if (progress < 0.5) {
      progressColor = Color.lerp(
        AppColors.burnStart,
        AppColors.burnMid,
        progress * 2,
      )!;
    } else {
      progressColor = Color.lerp(
        AppColors.burnMid,
        AppColors.burnEnd,
        (progress - 0.5) * 2,
      )!;
    }

    return CircularPercentIndicator(
      radius: 80,
      lineWidth: 12,
      percent: progress.clamp(0, 1),
      startAngle: 180,
      arcType: ArcType.HALF,
      arcBackgroundColor: AppColors.glassBackground,
      progressColor: progressColor,
      backgroundColor: Colors.transparent,
      circularStrokeCap: CircularStrokeCap.round,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            progress > 0.8 ? Icons.local_fire_department : Icons.trending_up,
            color: progressColor,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: progressColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseStrip(List<RenewingSoon> renewingSoon) {
    if (renewingSoon.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'No renewals in the next 7 days 🎉',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: renewingSoon.length,
        itemBuilder: (context, index) {
          final sub = renewingSoon[index];
          final isUrgent = sub.daysLeft <= 1;

          return Container(
            margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
            child: Column(
              children: [
                Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryCard,
                        border: Border.all(
                          color: isUrgent
                              ? AppColors.alert
                              : AppColors.glassBorder,
                          width: isUrgent ? 2 : 1,
                        ),
                        boxShadow: isUrgent
                            ? [
                                BoxShadow(
                                  color: AppColors.alert.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          sub.name.isNotEmpty ? sub.name[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isUrgent
                                ? AppColors.alert
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: isUrgent
                          ? (controller) => controller.repeat(reverse: true)
                          : null,
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: isUrgent
                          ? const Offset(1.05, 1.05)
                          : const Offset(1, 1),
                      duration: 1000.ms,
                    ),
                const SizedBox(height: 6),
                Text(
                  '${sub.daysLeft}d',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? AppColors.alert : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildQuickStatsGrid(DashboardSummary summary) {
    final isOverBudget = summary.totalBurn > _budget;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Active Subs',
            value: '${summary.activeCount}',
            icon: Icons.subscriptions,
            color: AppColors.active,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'This Month',
            value: '\$${summary.totalBurn.toStringAsFixed(0)}',
            icon: Icons.payments,
            color: isOverBudget ? AppColors.alert : AppColors.active,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Budget Left',
            value:
                '\$${(_budget - summary.totalBurn).abs().toStringAsFixed(0)}',
            icon: isOverBudget ? Icons.warning : Icons.savings,
            color: isOverBudget ? AppColors.alert : AppColors.paused,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      accentColor: color,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
