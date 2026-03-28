class IntegrationPreferences {
  final bool gmail;
  final bool sms;

  const IntegrationPreferences({this.gmail = false, this.sms = false});

  factory IntegrationPreferences.fromJson(Map<String, dynamic>? json) {
    return IntegrationPreferences(
      gmail: json?['gmail'] == true,
      sms: json?['sms'] == true,
    );
  }
}

class UserPreferences {
  final double budget;
  final String spendingAwareness;
  final String alertTiming;
  final bool onboardingComplete;
  final IntegrationPreferences integrations;

  const UserPreferences({
    this.budget = 0,
    this.spendingAwareness = 'unsure',
    this.alertTiming = '24h',
    this.onboardingComplete = false,
    this.integrations = const IntegrationPreferences(),
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      budget: (json['budget'] as num?)?.toDouble() ?? 0,
      spendingAwareness: json['spendingAwareness'] as String? ?? 'unsure',
      alertTiming: json['alertTiming'] as String? ?? '24h',
      onboardingComplete: json['onboardingComplete'] == true,
      integrations: IntegrationPreferences.fromJson(
        json['integrations'] as Map<String, dynamic>?,
      ),
    );
  }
}
