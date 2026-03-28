import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_preferences.dart';
import '../repositories/subscription_repository.dart';

final _userPreferencesRepositoryProvider = Provider<SubscriptionRepository>((
  ref,
) {
  return SubscriptionRepository();
});

final userPreferencesProvider =
    AsyncNotifierProvider<UserPreferencesNotifier, UserPreferences?>(
      UserPreferencesNotifier.new,
    );

class UserPreferencesNotifier extends AsyncNotifier<UserPreferences?> {
  @override
  Future<UserPreferences?> build() => _fetchPreferences();

  Future<UserPreferences?> _fetchPreferences() async {
    final repository = ref.read(_userPreferencesRepositoryProvider);
    final data = await repository.getPreferences();
    if (data == null || data.isEmpty) {
      return null;
    }
    return UserPreferences.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchPreferences);
  }
}
