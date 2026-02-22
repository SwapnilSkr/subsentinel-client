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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final complete = await ref
          .read(onboardingProvider.notifier)
          .checkOnboardingStatus();
      state = state.copyWith(isLoading: false, isComplete: complete);
    } catch (e) {
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
