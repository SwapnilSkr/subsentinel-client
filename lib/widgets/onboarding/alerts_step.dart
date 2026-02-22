import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class AlertsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const AlertsStep({super.key, required this.onNext});

  @override
  ConsumerState<AlertsStep> createState() => _AlertsStepState();
}

class _AlertsStepState extends ConsumerState<AlertsStep> {
  String _selectedTiming = '24h';

  final List<Map<String, dynamic>> _timingOptions = [
    {
      'value': '24h',
      'title': '24 hours before',
      'description': 'Get reminded one day in advance',
      'icon': Icons.today,
    },
    {
      'value': '3d',
      'title': '3 days before',
      'description': 'More time to prepare',
      'icon': Icons.calendar_view_week,
    },
    {
      'value': '1w',
      'title': '1 week before',
      'description': 'Maximum lead time',
      'icon': Icons.date_range,
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
            'When should we\nnotify you?',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose when to get renewal reminders.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.builder(
              itemCount: _timingOptions.length,
              itemBuilder: (context, index) {
                final option = _timingOptions[index];
                final isSelected = _selectedTiming == option['value'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedTiming = option['value']);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.scanLine.withValues(alpha: 0.1)
                            : AppColors.primaryCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.scanLine
                              : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            option['icon'] as IconData,
                            color: isSelected
                                ? AppColors.scanLine
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
                              color: AppColors.scanLine,
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
                    .updateAlertTiming(_selectedTiming);
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
