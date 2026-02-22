import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/onboarding_provider.dart';

class CategoriesStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;

  const CategoriesStep({super.key, required this.onNext});

  @override
  ConsumerState<CategoriesStep> createState() => _CategoriesStepState();
}

class _CategoriesStepState extends ConsumerState<CategoriesStep> {
  final List<String> _selectedCategories = [];

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProviderForOnboarding);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'Which categories\ndo you use most?',
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
            child: categoriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.active),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load categories',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.alert),
                ),
              ),
              data: (categories) => GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategories.contains(category.id);
                  Color categoryColor;
                  try {
                    categoryColor = Color(
                      int.parse(category.color.replaceFirst('#', '0xFF')),
                    );
                  } catch (e) {
                    categoryColor = AppColors.active;
                  }
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected) {
                          _selectedCategories.remove(category.id);
                        } else {
                          _selectedCategories.add(category.id);
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? categoryColor.withValues(alpha: 0.2)
                            : AppColors.primaryCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? categoryColor
                              : AppColors.glassBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: categoryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconData(category.icon),
                              color: categoryColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: AppColors.textPrimary),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref
                    .read(onboardingProvider.notifier)
                    .updateCategories(_selectedCategories);
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

  IconData _getIconData(String iconName) {
    final iconMap = {
      'movie': Icons.movie,
      'music_note': Icons.music_note,
      'fitness_center': Icons.fitness_center,
      'work': Icons.work,
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'home': Icons.home,
      'school': Icons.school,
      'games': Icons.games,
      'category': Icons.category,
      'cloud': Icons.cloud,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
