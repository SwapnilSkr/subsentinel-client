import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/subscription_repository.dart';
import '../repositories/auth_session_storage.dart';

enum OnboardingStep {
  welcome,
  budget,
  awareness,
  categories,
  addSubscriptions,
  painPoints,
  goals,
  alerts,
  completion,
}

class OnboardingData {
  final double? budget;
  final String? spendingAwareness;
  final List<String> categories;
  final List<Map<String, dynamic>> subscriptions;
  final List<String> painPoints;
  final List<String> goals;
  final String? alertTiming;

  const OnboardingData({
    this.budget,
    this.spendingAwareness,
    this.categories = const [],
    this.subscriptions = const [],
    this.painPoints = const [],
    this.goals = const [],
    this.alertTiming,
  });

  OnboardingData copyWith({
    double? budget,
    String? spendingAwareness,
    List<String>? categories,
    List<Map<String, dynamic>>? subscriptions,
    List<String>? painPoints,
    List<String>? goals,
    String? alertTiming,
  }) {
    return OnboardingData(
      budget: budget ?? this.budget,
      spendingAwareness: spendingAwareness ?? this.spendingAwareness,
      categories: categories ?? this.categories,
      subscriptions: subscriptions ?? this.subscriptions,
      painPoints: painPoints ?? this.painPoints,
      goals: goals ?? this.goals,
      alertTiming: alertTiming ?? this.alertTiming,
    );
  }

  double get totalSubscriptionAmount {
    return subscriptions.fold(
      0.0,
      (sum, sub) => sum + (sub['amount'] as num).toDouble(),
    );
  }
}

class OnboardingState {
  final OnboardingStep currentStep;
  final OnboardingData data;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.data = const OnboardingData(),
    this.isLoading = false,
    this.error,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    OnboardingData? data,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return const OnboardingState();
  }

  void nextStep() {
    final nextIndex = OnboardingStep.values.indexOf(state.currentStep) + 1;
    if (nextIndex < OnboardingStep.values.length) {
      state = state.copyWith(currentStep: OnboardingStep.values[nextIndex]);
    }
  }

  void previousStep() {
    final prevIndex = OnboardingStep.values.indexOf(state.currentStep) - 1;
    if (prevIndex >= 0) {
      state = state.copyWith(currentStep: OnboardingStep.values[prevIndex]);
    }
  }

  void goToStep(OnboardingStep step) {
    state = state.copyWith(currentStep: step);
  }

  void updateBudget(double budget) {
    state = state.copyWith(data: state.data.copyWith(budget: budget));
  }

  void updateSpendingAwareness(String awareness) {
    state = state.copyWith(
      data: state.data.copyWith(spendingAwareness: awareness),
    );
  }

  void updateCategories(List<String> categories) {
    state = state.copyWith(data: state.data.copyWith(categories: categories));
  }

  void addSubscription(Map<String, dynamic> subscription) {
    final newSubscriptions = [...state.data.subscriptions, subscription];
    state = state.copyWith(
      data: state.data.copyWith(subscriptions: newSubscriptions),
    );
  }

  void removeSubscription(int index) {
    final newSubscriptions = [...state.data.subscriptions];
    newSubscriptions.removeAt(index);
    state = state.copyWith(
      data: state.data.copyWith(subscriptions: newSubscriptions),
    );
  }

  void updatePainPoints(List<String> painPoints) {
    state = state.copyWith(data: state.data.copyWith(painPoints: painPoints));
  }

  void updateGoals(List<String> goals) {
    state = state.copyWith(data: state.data.copyWith(goals: goals));
  }

  void updateAlertTiming(String timing) {
    state = state.copyWith(data: state.data.copyWith(alertTiming: timing));
  }

  Future<void> savePreferences() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      final authStorage = ref.read(onboardingAuthStorageProvider);
      final token = await authStorage.readAuthToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      await repository.savePreferences({
        'budget': state.data.budget ?? 0,
        'spendingAwareness': state.data.spendingAwareness ?? 'unsure',
        'categories': state.data.categories,
        'painPoints': state.data.painPoints,
        'goals': state.data.goals,
        'alertTiming': state.data.alertTiming ?? '24h',
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      await repository.completeOnboarding();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<bool> checkOnboardingStatus() async {
    try {
      final repository = ref.read(onboardingRepositoryProvider);
      return await repository.checkOnboardingStatus();
    } catch (e) {
      return false;
    }
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final onboardingAuthStorageProvider = Provider<AuthSessionStorage>((ref) {
  return AuthSessionStorage();
});

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

final categoriesProviderForOnboarding = FutureProvider<List<Category>>((
  ref,
) async {
  final repository = ref.watch(onboardingRepositoryProvider);
  return await repository.fetchCategories();
});
