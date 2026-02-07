import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';

/// Repository for API calls to the ElysiaJS backend
class SubscriptionRepository {
  // Use 10.0.2.2 for Android emulator, localhost for iOS simulator, or your actual IP
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  final http.Client _client;

  SubscriptionRepository({http.Client? client})
    : _client = client ?? http.Client();

  /// Fetch all subscriptions
  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Subscription.fromJson(e)).toList();
      }
      throw HttpException(
        'Failed to load subscriptions: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch dashboard summary
  Future<DashboardSummary> fetchSummary() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/subscriptions/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DashboardSummary.fromJson(data);
      }
      throw HttpException('Failed to load summary: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new subscription
  Future<Subscription> createSubscription(Subscription subscription) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(subscription.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Subscription.fromJson(jsonDecode(response.body));
      }
      throw HttpException(
        'Failed to create subscription: ${response.statusCode}',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update subscription status (pause/resume/cancel)
  Future<Subscription?> updateStatus(String id, String status) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/subscriptions/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? Subscription.fromJson(data) : null;
      }
      throw HttpException('Failed to update status: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a subscription
  Future<bool> deleteSubscription(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Register device for push notifications
  Future<bool> registerDevice(
    String token,
    String platform, {
    String? userId,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register-device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'platform': platform,
          if (userId != null) 'userId': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Get checkout URL for Dodo payments
  Future<String?> createCheckoutSession({
    required String productId,
    required String email,
    required String name,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': productId,
          'email': email,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
