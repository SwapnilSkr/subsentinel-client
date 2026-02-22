import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class GoalsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const GoalsStep({super.key, required this.onNext});

  @override
  ConsumerState<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends ConsumerState<GoalsStep> {
  String? _selectedGoal;

  final List<Map<String, dynamic>> _goalsOptions = [
    {
      'value': 'save_money',
      'title': 'Save money',
      'description': 'Cut unnecessary expenses',
      'icon': Icons.savings,
    },
    {
      'value': 'track_spending',
      'title': 'Track spending',
      'description': 'Know where my money goes',
      'icon': Icons.analytics,
    },
    {
      'value': 'avoid_surprises',
      'title': 'Avoid surprises',
      'description': 'No unexpected renewals',
      'icon': Icons.notifications_active,
    },
    {
      'value': 'simplify',
      'title': 'Simplify',
      'description': 'Reduce subscription clutter',
      'icon': Icons.cleaning_services,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "What's your primary\nfinancial goal?",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us prioritize features for you.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _goalsOptions.length,
              itemBuilder: (context, index) {
                final option = _goalsOptions[index];
                final isSelected = _selectedGoal == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedGoal = option['value']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.active.withValues(alpha: 0.1)
                            : AppColors.primaryCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.active
                              : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: isSelected
                                ? AppColors.active
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  option['title'],
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                ),
                                Text(
                                  option['description'],
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.active,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedGoal != null
                  ? () {
                      ref.read(onboardingProvider.notifier).updateGoals([
                        _selectedGoal!,
                      ]);
                      widget.onNext();
                    }
                  : null,
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
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
