import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class BudgetStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const BudgetStep({super.key, required this.onNext});

  @override
  ConsumerState<BudgetStep> createState() => _BudgetStepState();
}

class _BudgetStepState extends ConsumerState<BudgetStep> {
  final _budgetController = TextEditingController();
  String _selectedPreset = '';

  final List<Map<String, dynamic>> _presets = [
    {'label': '\$25', 'value': 25},
    {'label': '\$50', 'value': 50},
    {'label': '\$100', 'value': 100},
    {'label': '\$150', 'value': 150},
    {'label': '\$200', 'value': 200},
    {'label': '\$500', 'value': 500},
  ];

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final budget = state.data.budget;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            "What's your monthly\nsubscription budget?",
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'This helps us warn you when you\'re\napproaching your limit.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presets.map((preset) {
              final isSelected = _selectedPreset == preset['value'];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedPreset = preset['value'];
                    _budgetController.text = preset['value'].toString();
                  });
                  ref
                      .read(onboardingProvider.notifier)
                      .updateBudget((preset['value'] as num).toDouble());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.active
                        : AppColors.primaryCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.active
                          : AppColors.glassBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    preset['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _budgetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              hintText: 'Custom amount',
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.primaryCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.glassBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.active, width: 2),
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                ref.read(onboardingProvider.notifier).updateBudget(parsed);
                setState(() {
                  _selectedPreset = '';
                });
              }
            },
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: budget != null && budget > 0 ? widget.onNext : null,
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
