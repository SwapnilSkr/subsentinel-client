import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'onboarding_provider.dart';

class OnboardingCheckState {
  final bool isLoading;
  final bool isComplete;
  final String? error;

  OnboardingCheckState({
    this.isLoading = false,
    this.isComplete = false,
    this.error,
  });

  OnboardingCheckState copyWith({
    bool? isLoading,
    bool? isComplete,
    String? error,
  }) {
    return OnboardingCheckState(
      isLoading: isLoading ?? this.isLoading,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

class OnboardingCheckNotifier extends Notifier<OnboardingCheckState> {
  @override
  OnboardingCheckState build() {
    return OnboardingCheckState();
  }

  Future<void> checkStatus() async {
    print('🔄 [ONBOARDING_CHECK] checkStatus called');
    state = state.copyWith(isLoading: true, error: null);
    try {
      print(
        '📤 [ONBOARDING_CHECK] Calling onboardingProvider.checkOnboardingStatus...',
      );
      final complete = await ref
          .read(onboardingProvider.notifier)
          .checkOnboardingStatus();
      print('✅ [ONBOARDING_CHECK] Onboarding status: $complete');
      state = state.copyWith(isLoading: false, isComplete: complete);
    } catch (e) {
      print('❌ [ONBOARDING_CHECK] Error: $e');
      print(
        '❌ [ONBOARDING_CHECK] Defaulting to isComplete=false (safe default)',
      );
      state = state.copyWith(
        isLoading: false,
        isComplete: false,
        error: e.toString(),
      );
    }
  }
}

final onboardingCheckProvider =
    NotifierProvider<OnboardingCheckNotifier, OnboardingCheckState>(
      OnboardingCheckNotifier.new,
    );
