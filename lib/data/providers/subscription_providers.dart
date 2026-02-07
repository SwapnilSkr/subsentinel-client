import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/subscription_repository.dart';
import '../models/subscription.dart';

/// Repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

// ==================== DASHBOARD SUMMARY ====================

/// Dashboard summary provider
final dashboardSummaryProvider =
    AsyncNotifierProvider<DashboardSummaryNotifier, DashboardSummary>(
      DashboardSummaryNotifier.new,
    );

class DashboardSummaryNotifier extends AsyncNotifier<DashboardSummary> {
  @override
  Future<DashboardSummary> build() => _fetchSummary();

  Future<DashboardSummary> _fetchSummary() async {
    final repository = ref.read(subscriptionRepositoryProvider);
    return await repository.fetchSummary();
  }

  /// Refresh the summary data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSummary);
  }
}

// ==================== SUBSCRIPTIONS LIST ====================

/// Subscriptions list provider
final subscriptionsProvider =
    AsyncNotifierProvider<SubscriptionsNotifier, List<Subscription>>(
      SubscriptionsNotifier.new,
    );

class SubscriptionsNotifier extends AsyncNotifier<List<Subscription>> {
  @override
  Future<List<Subscription>> build() => _fetchSubscriptions();

  Future<List<Subscription>> _fetchSubscriptions() async {
    final repository = ref.read(subscriptionRepositoryProvider);
    return await repository.fetchSubscriptions();
  }

  /// Refresh the subscriptions list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchSubscriptions);
  }

  /// Toggle subscription status (active <-> paused)
  Future<void> toggleStatus(String id) async {
    final currentList = state.value ?? [];
    final subscription = currentList.firstWhere((s) => s.id == id);

    // Optimistic update
    final newStatus = subscription.isPaused
        ? SubscriptionStatus.active
        : SubscriptionStatus.paused;

    state = AsyncValue.data(
      currentList
          .map((s) => s.id == id ? s.copyWith(status: newStatus) : s)
          .toList(),
    );

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      await repository.updateStatus(id, newStatus.value);
      // Refresh dashboard after status change
      ref.invalidate(dashboardSummaryProvider);
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  /// Cancel/delete a subscription
  Future<bool> cancelSubscription(String id) async {
    final currentList = state.value ?? [];

    // Optimistic update
    state = AsyncValue.data(currentList.where((s) => s.id != id).toList());

    try {
      final repository = ref.read(subscriptionRepositoryProvider);
      final success = await repository.deleteSubscription(id);
      if (success) {
        // Refresh dashboard after deletion
        ref.invalidate(dashboardSummaryProvider);
      }
      return success;
    } catch (e) {
      // Revert on error
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  /// Create a new subscription
  Future<Subscription> createSubscription(Subscription subscription) async {
    final repository = ref.read(subscriptionRepositoryProvider);
    final created = await repository.createSubscription(subscription);

    // Add to local list
    final currentList = state.value ?? [];
    state = AsyncValue.data([...currentList, created]);

    // Refresh dashboard
    ref.invalidate(dashboardSummaryProvider);

    return created;
  }
}
