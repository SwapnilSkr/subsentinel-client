import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/subscription.dart';
import '../../../data/providers/onboarding_provider.dart';
import '../../../data/providers/subscription_providers.dart';

class CompletionStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const CompletionStep({super.key, required this.onComplete});

  @override
  ConsumerState<CompletionStep> createState() => _CompletionStepState();
}

class _CompletionStepState extends ConsumerState<CompletionStep> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _saveOnboardingData();
  }

  Future<void> _saveOnboardingData() async {
    try {
      final onboardingNotifier = ref.read(onboardingProvider.notifier);
      final onboardingState = ref.read(onboardingProvider);

      await onboardingNotifier.savePreferences();

      for (final sub in onboardingState.data.subscriptions) {
        await ref
            .read(subscriptionsProvider.notifier)
            .createSubscription(
              Subscription(
                id: '',
                provider: sub['provider'],
                amount: (sub['amount'] as num).toDouble(),
                nextBilling: DateTime.parse(sub['next_billing']),
                categoryId: sub['categoryId'],
              ),
            );
      }

      await onboardingNotifier.completeOnboarding();
      await ref.read(subscriptionsProvider.notifier).refresh();
      await ref.read(dashboardSummaryProvider.notifier).refresh();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final totalSubs = state.data.subscriptions.length;
    final totalAmount = state.data.totalSubscriptionAmount;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          if (_isLoading) ...[
            const CircularProgressIndicator(color: AppColors.active),
            const SizedBox(height: 24),
            Text(
              'Setting up your dashboard...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ] else ...[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.active.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 60,
                color: AppColors.active,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "You're all set!",
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your personalized dashboard is ready.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    'Subscriptions added',
                    '$totalSubs',
                    Icons.subscriptions,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    'Monthly total',
                    '\$${totalAmount.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    'Alert timing',
                    _getAlertTimingLabel(state.data.alertTiming ?? '24h'),
                    Icons.notifications,
                  ),
                ],
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : widget.onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.active,
                foregroundColor: Colors.black,
                disabledBackgroundColor: AppColors.primaryCard,
                disabledForegroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Go to Dashboard',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getAlertTimingLabel(String timing) {
    switch (timing) {
      case '24h':
        return '24 hours';
      case '3d':
        return '3 days';
      case '1w':
        return '1 week';
      default:
        return '24 hours';
    }
  }
}
