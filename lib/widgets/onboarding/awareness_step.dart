import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class AwarenessStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const AwarenessStep({super.key, required this.onNext});

  @override
  ConsumerState<AwarenessStep> createState() => _AwarenessStepState();
}

class _AwarenessStepState extends ConsumerState<AwarenessStep> {
  String? _selectedAwareness;

  final List<Map<String, dynamic>> _options = [
    {
      'value': 'know',
      'title': 'I know exactly',
      'description': 'I track my spending regularly',
      'icon': Icons.check_circle_outline,
    },
    {
      'value': 'unsure',
      'title': "I'm not sure",
      'description': 'I have a rough idea',
      'icon': Icons.help_outline,
    },
    {
      'value': 'no_idea',
      'title': 'No idea',
      'description': "I've never tracked it",
      'icon': Icons.remove_circle_outline,
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
            'How well do you know\nyour spending habits?',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us tailor our recommendations.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = _selectedAwareness == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedAwareness = option['value'];
                      });
                      ref
                          .read(onboardingProvider.notifier)
                          .updateSpendingAwareness(option['value']);
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
              onPressed: _selectedAwareness != null ? widget.onNext : null,
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
