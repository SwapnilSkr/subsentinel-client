/// Subscription model matching the backend schema
class Subscription {
  final String id;
  final String provider;
  final double amount;
  final String currency;
  final DateTime nextBilling;
  final SubscriptionStatus status;
  final String? category;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subscription({
    required this.id,
    required this.provider,
    required this.amount,
    this.currency = 'USD',
    required this.nextBilling,
    this.status = SubscriptionStatus.active,
    this.category,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  /// Days until next billing
  int get daysLeft {
    final now = DateTime.now();
    final difference = nextBilling.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  /// Check if renewing soon (within 3 days)
  bool get isRenewingSoon => daysLeft <= 3;

  /// Check if paused
  bool get isPaused => status == SubscriptionStatus.paused;

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      provider: json['provider'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      nextBilling: json['next_billing'] != null
          ? DateTime.parse(json['next_billing'])
          : DateTime.now(),
      status: SubscriptionStatus.fromString(json['status'] ?? 'active'),
      category: json['category'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'amount': amount,
      'currency': currency,
      'next_billing': nextBilling.toIso8601String(),
      'status': status.value,
      if (category != null) 'category': category,
      if (userId != null) 'userId': userId,
    };
  }

  Subscription copyWith({
    String? id,
    String? provider,
    double? amount,
    String? currency,
    DateTime? nextBilling,
    SubscriptionStatus? status,
    String? category,
    String? userId,
  }) {
    return Subscription(
      id: id ?? this.id,
      provider: provider ?? this.provider,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      nextBilling: nextBilling ?? this.nextBilling,
      status: status ?? this.status,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

enum SubscriptionStatus {
  active('active'),
  paused('paused'),
  cancelled('cancelled');

  final String value;
  const SubscriptionStatus(this.value);

  static SubscriptionStatus fromString(String value) {
    return SubscriptionStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SubscriptionStatus.active,
    );
  }
}

/// Dashboard summary model
class DashboardSummary {
  final double totalBurn;
  final int activeCount;
  final int totalCount;
  final List<RenewingSoon> renewingSoon;
  final String currency;

  DashboardSummary({
    required this.totalBurn,
    required this.activeCount,
    required this.totalCount,
    required this.renewingSoon,
    this.currency = 'USD',
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBurn: (json['totalBurn'] as num?)?.toDouble() ?? 0.0,
      activeCount: json['activeCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      renewingSoon:
          (json['renewingSoon'] as List?)
              ?.map((e) => RenewingSoon.fromJson(e))
              .toList() ??
          [],
      currency: json['currency'] ?? 'USD',
    );
  }
}

class RenewingSoon {
  final String id;
  final String name;
  final double amount;
  final int daysLeft;

  RenewingSoon({
    required this.id,
    required this.name,
    required this.amount,
    required this.daysLeft,
  });

  factory RenewingSoon.fromJson(Map<String, dynamic> json) {
    return RenewingSoon(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      daysLeft: json['daysLeft'] ?? 0,
    );
  }
}
