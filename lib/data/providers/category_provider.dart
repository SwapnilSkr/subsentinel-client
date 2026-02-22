import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'subscription_providers.dart';

/// Categories provider
final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<Category>>(
      CategoriesNotifier.new,
    );

class CategoriesNotifier extends AsyncNotifier<List<Category>> {
  @override
  Future<List<Category>> build() => _fetchCategories();

  Future<List<Category>> _fetchCategories() async {
    final repository = ref.read(subscriptionRepositoryProvider);
    return await repository.fetchCategories();
  }

  /// Refresh the categories list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchCategories);
  }

  /// Create a custom category
  Future<Category> createCategory(Category category) async {
    final repository = ref.read(subscriptionRepositoryProvider);
    final created = await repository.createCategory(category);

    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, created]);

    return created;
  }

  /// Update a custom category
  Future<Category> updateCategory(String id, Category category) async {
    final repository = ref.read(subscriptionRepositoryProvider);
    final updated = await repository.updateCategory(id, category);
    if (updated == null) {
      throw Exception('Failed to update category');
    }

    final currentList = state.value ?? [];
    state = AsyncValue.data(
      currentList.map((c) => c.id == id ? updated : c).toList(),
    );

    return updated;
  }

  /// Delete a custom category
  Future<bool> deleteCategory(String id) async {
    final currentList = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data(currentList.where((c) => c.id != id).toList());

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      return await repository.deleteCategory(id);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }
}
