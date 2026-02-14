import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../data/models/category.dart';
import '../data/models/subscription.dart';
import '../data/providers/category_provider.dart';
import '../data/providers/subscription_providers.dart';

Future<bool?> showCreateSubscriptionBottomSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CreateSubscriptionSheet(),
  );
}

class CreateSubscriptionSheet extends ConsumerStatefulWidget {
  const CreateSubscriptionSheet({super.key});

  @override
  ConsumerState<CreateSubscriptionSheet> createState() =>
      _CreateSubscriptionSheetState();
}

class _CreateSubscriptionSheetState
    extends ConsumerState<CreateSubscriptionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _providerController = TextEditingController();
  final _amountController = TextEditingController();
  final _logoUrlController = TextEditingController();
  DateTime _nextBilling = DateTime.now().add(const Duration(days: 30));
  String? _categoryId;
  bool _submitting = false;

  @override
  void dispose() {
    _providerController.dispose();
    _amountController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final subscriptionsAsync = ref.watch(subscriptionsProvider);
    final providerSuggestions = subscriptionsAsync.maybeWhen(
      data: (subscriptions) {
        final seen = <String>{};
        final names = <String>[];
        for (final sub in subscriptions) {
          final name = sub.provider.trim();
          final key = name.toLowerCase();
          if (name.isEmpty || seen.contains(key)) continue;
          seen.add(key);
          names.add(name);
        }
        names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        final query = _providerController.text.trim().toLowerCase();
        if (query.isEmpty) return <String>[];
        return names
            .where((name) => name.toLowerCase().contains(query))
            .take(6)
            .toList();
      },
      orElse: () => <String>[],
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorderFor(context)),
              left: BorderSide(color: AppColors.glassBorderFor(context)),
              right: BorderSide(color: AppColors.glassBorderFor(context)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMutedFor(context),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Add Subscription',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _providerController,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(context, 'Provider name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Provider is required';
                        }
                        return null;
                      },
                    ),
                    if (providerSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackgroundFor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.glassBorderFor(context),
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: providerSuggestions.length,
                          itemBuilder: (context, index) {
                            final name = providerSuggestions[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                name,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              onTap: () {
                                setState(() {
                                  _providerController.text = name;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(context, 'Amount (USD)'),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _inputDecoration(context, 'Next billing'),
                        child: Row(
                          children: [
                            const Icon(Icons.event_note, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, yyyy').format(_nextBilling),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    categoriesAsync.when(
                      loading: () => const LinearProgressIndicator(
                        color: AppColors.active,
                        minHeight: 2,
                      ),
                      error: (_, __) => Text(
                        'Categories unavailable. You can continue without one.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      data: (categories) {
                        return Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _categoryId,
                              decoration: _inputDecoration(
                                context,
                                'Category (optional)',
                              ),
                              dropdownColor: AppColors.surfaceFor(context),
                              items: categories
                                  .map(
                                    (cat) => DropdownMenuItem(
                                      value: cat.id,
                                      child: Text(cat.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _categoryId = value),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 4,
                                children: [
                                  TextButton.icon(
                                    onPressed: _openCreateCategorySheet,
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      size: 16,
                                    ),
                                    label: const Text('New custom category'),
                                  ),
                                  TextButton.icon(
                                    onPressed: _openManageCategoriesSheet,
                                    icon: const Icon(Icons.settings, size: 16),
                                    label: const Text('Manage'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: _logoUrlController,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        context,
                        'Logo URL (optional)',
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: _submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.check),
                        label: Text(_submitting ? 'Saving...' : 'Create'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: Theme.of(context).textTheme.bodyMedium,
      filled: true,
      fillColor: AppColors.glassBackgroundFor(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorderFor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorderFor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.active),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _nextBilling,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() => _nextBilling = selected);
    }
  }

  Future<void> _openCreateCategorySheet() async {
    final category = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreateCategorySheet(),
    );

    if (category != null && mounted) {
      setState(() => _categoryId = category.id);
    }
  }

  Future<void> _openManageCategoriesSheet() async {
    final categoryId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ManageCategoriesSheet(),
    );

    if (categoryId != null && mounted) {
      setState(() => _categoryId = categoryId);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final amount = double.parse(_amountController.text.trim());
    final logoUrl = _logoUrlController.text.trim();

    try {
      await ref
          .read(subscriptionsProvider.notifier)
          .createSubscription(
            Subscription(
              id: '',
              provider: _providerController.text.trim(),
              amount: amount,
              nextBilling: _nextBilling,
              categoryId: _categoryId,
              logoUrl: logoUrl.isEmpty ? null : logoUrl,
            ),
          );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create subscription: $error'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _CreateCategorySheet extends ConsumerStatefulWidget {
  final Category? existingCategory;

  const _CreateCategorySheet({this.existingCategory});

  @override
  ConsumerState<_CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<_CreateCategorySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  late final TextEditingController _colorController;
  final _logoUrlController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCategory;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _iconController = TextEditingController(
      text: existing?.icon.isNotEmpty == true ? existing!.icon : 'category',
    );
    _colorController = TextEditingController(
      text: existing?.color.isNotEmpty == true ? existing!.color : '#00D4FF',
    );
    _logoUrlController.text = existing?.logoUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorderFor(context)),
              left: BorderSide(color: AppColors.glassBorderFor(context)),
              right: BorderSide(color: AppColors.glassBorderFor(context)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.existingCategory == null
                          ? 'New Custom Category'
                          : 'Edit Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(context, 'Name'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _iconController,
                      decoration: _inputDecoration(
                        context,
                        'Icon key (e.g. movie, music_note)',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Icon key is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _colorController,
                      decoration: _inputDecoration(
                        context,
                        'Hex color (#RRGGBB)',
                      ),
                      validator: (value) {
                        final input = (value ?? '').trim();
                        if (!RegExp(r'^#[A-Fa-f0-9]{6}$').hasMatch(input)) {
                          return 'Use format #RRGGBB';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _logoUrlController,
                      decoration: _inputDecoration(
                        context,
                        'Logo URL (optional)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.active,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _saving
                              ? (widget.existingCategory == null
                                    ? 'Creating...'
                                    : 'Saving...')
                              : (widget.existingCategory == null
                                    ? 'Create Category'
                                    : 'Save Category'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.glassBackgroundFor(context),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorderFor(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.glassBorderFor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.active),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final notifier = ref.read(categoriesProvider.notifier);
      final payload = Category(
        id: widget.existingCategory?.id ?? '',
        name: _nameController.text.trim(),
        icon: _iconController.text.trim(),
        color: _colorController.text.trim(),
        logoUrl: _logoUrlController.text.trim().isEmpty
            ? null
            : _logoUrlController.text.trim(),
      );

      final category = widget.existingCategory == null
          ? await notifier.createCategory(payload)
          : await notifier.updateCategory(widget.existingCategory!.id, payload);
      if (mounted) {
        Navigator.of(context).pop(category);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create category: $error'),
            backgroundColor: AppColors.alert,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _ManageCategoriesSheet extends ConsumerWidget {
  const _ManageCategoriesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceFor(context).withValues(alpha: 0.96),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorderFor(context)),
              left: BorderSide(color: AppColors.glassBorderFor(context)),
              right: BorderSide(color: AppColors.glassBorderFor(context)),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: categoriesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.active),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        'Failed to load categories: $error',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    data: (categories) => ListView.separated(
                      shrinkWrap: true,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: AppColors.glassBorderFor(context)),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(category.name),
                          subtitle: Text(
                            category.isDefault ? 'Default' : 'Custom',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          onTap: () => Navigator.of(context).pop(category.id),
                          trailing: category.isDefault
                              ? null
                              : Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      color: AppColors.scanLine,
                                      onPressed: () async {
                                        final updated =
                                            await showModalBottomSheet<
                                              Category
                                            >(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  _CreateCategorySheet(
                                                    existingCategory: category,
                                                  ),
                                            );
                                        if (updated != null &&
                                            context.mounted) {
                                          Navigator.of(context).pop(updated.id);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: AppColors.alert,
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Delete category?',
                                            ),
                                            content: Text(
                                              'Delete "${category.name}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.alert,
                                                  foregroundColor: Colors.white,
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true &&
                                            context.mounted) {
                                          try {
                                            await ref
                                                .read(
                                                  categoriesProvider.notifier,
                                                )
                                                .deleteCategory(category.id);
                                          } catch (error) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Delete failed: $error',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.alert,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
