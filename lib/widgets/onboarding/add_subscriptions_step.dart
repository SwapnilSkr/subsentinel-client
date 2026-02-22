import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class AddSubscriptionsStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const AddSubscriptionsStep({super.key, required this.onNext});

  @override
  ConsumerState<AddSubscriptionsStep> createState() =>
      _AddSubscriptionsStepState();
}

class _AddSubscriptionsStepState extends ConsumerState<AddSubscriptionsStep> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _nextBilling = DateTime.now().add(const Duration(days: 30));
  String? _categoryId;
  bool _showCustomForm = false;

  final List<Map<String, dynamic>> _popularServices = [
    {'provider': 'Netflix', 'amount': 15.99},
    {'provider': 'Spotify', 'amount': 10.99},
    {'provider': 'YouTube Premium', 'amount': 13.99},
    {'provider': 'Disney+', 'amount': 13.99},
    {'provider': 'Amazon Prime', 'amount': 14.99},
    {'provider': 'HBO Max', 'amount': 15.99},
  ];

  @override
  void dispose() {
    _providerController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final subscriptions = state.data.subscriptions;
    final budget = state.data.budget ?? 0;
    final totalAmount = subscriptions.fold(
      0.0,
      (sum, sub) => sum + (sub['amount'] as num).toDouble(),
    );
    final isOverBudget = totalAmount > budget && budget > 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Add your\nsubscriptions',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Add the services you currently use.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOverBudget
                  ? AppColors.alert.withValues(alpha: 0.1)
                  : AppColors.primaryCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOverBudget ? AppColors.alert : AppColors.glassBorder,
                width: isOverBudget ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total: \$${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isOverBudget
                            ? AppColors.alert
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (budget > 0)
                      Text(
                        'Budget: \$${budget.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
                if (isOverBudget)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.alert,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Over Budget!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (subscriptions.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final sub = subscriptions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${sub['provider']} - \$${(sub['amount'] as num).toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      backgroundColor: AppColors.primaryCard,
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => ref
                          .read(onboardingProvider.notifier)
                          .removeSubscription(index),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _showCustomForm
                ? Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _providerController,
                            decoration: InputDecoration(
                              labelText: 'Provider name',
                              filled: true,
                              fillColor: AppColors.glassBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.active,
                                ),
                              ),
                            ),
                            validator: (v) =>
                                v?.trim().isEmpty == true ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Amount (USD)',
                              filled: true,
                              fillColor: AppColors.glassBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.active,
                                ),
                              ),
                            ),
                            validator: (v) => double.tryParse(v ?? '') == null
                                ? 'Invalid'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _nextBilling,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 3650),
                                ),
                              );
                              if (picked != null) {
                                setState(() => _nextBilling = picked);
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Next billing',
                                filled: true,
                                fillColor: AppColors.glassBackground,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.glassBorder,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.event_note, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(_nextBilling),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      setState(() => _showCustomForm = false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: const BorderSide(
                                      color: AppColors.glassBorder,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _addCustomSubscription,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.active,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Popular Services',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _popularServices.map((service) {
                            return ActionChip(
                              label: Text(
                                service['provider'],
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              backgroundColor: AppColors.primaryCard,
                              side: const BorderSide(
                                color: AppColors.glassBorder,
                              ),
                              onPressed: () {
                                ref
                                    .read(onboardingProvider.notifier)
                                    .addSubscription({
                                      'provider': service['provider'],
                                      'amount': service['amount'],
                                      'next_billing': DateTime.now()
                                          .add(const Duration(days: 30))
                                          .toIso8601String(),
                                    });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                setState(() => _showCustomForm = true),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Custom'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.active,
                              side: const BorderSide(color: AppColors.active),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
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

  void _addCustomSubscription() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(onboardingProvider.notifier).addSubscription({
      'provider': _providerController.text.trim(),
      'amount': double.parse(_amountController.text.trim()),
      'next_billing': _nextBilling.toIso8601String(),
      'categoryId': _categoryId,
    });
    setState(() {
      _showCustomForm = false;
      _providerController.clear();
      _amountController.clear();
      _nextBilling = DateTime.now().add(const Duration(days: 30));
    });
  }
}
