import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/subscription.dart';
import '../models/category.dart';
import 'auth_session_storage.dart';

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
  final AuthSessionStorage _sessionStorage;

  SubscriptionRepository({
    http.Client? client,
    AuthSessionStorage? sessionStorage,
  }) : _client = client ?? http.Client(),
       _sessionStorage = sessionStorage ?? AuthSessionStorage();

  Future<Map<String, String>> _authHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await _sessionStorage.readAuthToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// Fetch all subscriptions
  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: await _authHeaders(),
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
        headers: await _authHeaders(),
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
      final payload = Map<String, dynamic>.from(subscription.toJson())
        ..remove('userId');
      final response = await _client.post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: await _authHeaders(),
        body: jsonEncode(payload),
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
        headers: await _authHeaders(),
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
        headers: await _authHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== CATEGORIES ====================

  /// Fetch all categories (defaults + user's custom)
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/categories'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Category.fromJson(e)).toList();
      }
      throw HttpException('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a custom category
  Future<Category> createCategory(Category category) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/categories'),
        headers: await _authHeaders(),
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Category.fromJson(jsonDecode(response.body));
      }
      throw HttpException('Failed to create category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update a custom category
  Future<Category> updateCategory(String id, Category category) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/categories/$id'),
        headers: await _authHeaders(),
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200) {
        return Category.fromJson(jsonDecode(response.body));
      }
      throw HttpException('Failed to update category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a custom category
  Future<bool> deleteCategory(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/categories/$id'),
        headers: await _authHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Register device for push notifications
  Future<bool> registerDevice(String token, String platform) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register-device'),
        headers: await _authHeaders(),
        body: jsonEncode({'token': token, 'platform': platform}),
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
        headers: await _authHeaders(),
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
