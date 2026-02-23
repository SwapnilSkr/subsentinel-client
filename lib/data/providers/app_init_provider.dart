import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_provider.dart';
import 'onboarding_provider.dart';

class AppInitState {
  final AppUser? user;
  final bool onboardingComplete;
  final bool isLoading;
  final String? error;

  const AppInitState({
    this.user,
    this.onboardingComplete = false,
    this.isLoading = true,
    this.error,
  });

  AppInitState copyWith({
    AppUser? user,
    bool? onboardingComplete,
    bool? isLoading,
    String? error,
  }) {
    return AppInitState(
      user: user ?? this.user,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final appInitProvider = FutureProvider<AppInitState>((ref) async {
  final authState = ref.watch(authProvider);

  if (authState.isLoading) {
    return const AppInitState(isLoading: true);
  }

  if (authState.user == null) {
    return AppInitState(isLoading: false, user: null);
  }

  final user = authState.user!;
  bool isComplete = false;

  try {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('AppInit: SharedPreferences error: $e');
    }

    if (prefs != null) {
      final cached = prefs.getBool('onboarding_complete_${user.id}');
      if (cached == true) {
        isComplete = true;
      }
    }

    final repo = ref.read(onboardingRepositoryProvider);
    final serverComplete = await repo.checkOnboardingStatus();
    isComplete = serverComplete;

    if (prefs != null) {
      await prefs.setBool('onboarding_complete_${user.id}', isComplete);
    }
  } catch (e) {
    debugPrint('AppInit: Error checking onboarding status: $e');
  }

  return AppInitState(
    user: user,
    onboardingComplete: isComplete,
    isLoading: false,
  );
});

void refreshAppInit(WidgetRef ref) {
  ref.invalidate(appInitProvider);
}
