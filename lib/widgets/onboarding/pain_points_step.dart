import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class PainPointsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const PainPointsStep({super.key, required this.onNext});

  @override
  ConsumerState<PainPointsStep> createState() => _PainPointsStepState();
}

class _PainPointsStepState extends ConsumerState<PainPointsStep> {
  final List<String> _selectedPainPoints = [];

  final List<Map<String, dynamic>> _painPointsOptions = [
    {
      'value': 'forgotten_renewals',
      'title': 'Forgotten renewals',
      'icon': Icons.refresh,
    },
    {
      'value': 'hidden_fees',
      'title': 'Hidden fees',
      'icon': Icons.attach_money,
    },
    {'value': 'hard_to_cancel', 'title': 'Hard to cancel', 'icon': Icons.block},
    {
      'value': 'duplicate_subs',
      'title': 'Duplicate subs',
      'icon': Icons.content_copy,
    },
    {
      'value': 'unused_services',
      'title': 'Unused services',
      'icon': Icons.delete_outline,
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
            'What frustrates you\nmost about subscriptions?',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Select all that apply.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _painPointsOptions.length,
              itemBuilder: (context, index) {
                final option = _painPointsOptions[index];
                final isSelected = _selectedPainPoints.contains(
                  option['value'],
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected) {
                          _selectedPainPoints.remove(option['value']);
                        } else {
                          _selectedPainPoints.add(option['value']);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.alert.withValues(alpha: 0.1)
                            : AppColors.primaryCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.alert
                              : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: isSelected
                                ? AppColors.alert
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option['title'],
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.alert,
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
              onPressed: () {
                ref
                    .read(onboardingProvider.notifier)
                    .updatePainPoints(_selectedPainPoints);
                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.active,
                foregroundColor: Colors.black,
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
