import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/subscription.dart';
import '../models/category.dart';
import 'auth_session_storage.dart';

/// Repository for API calls to ElysiaJS backend
class SubscriptionRepository {
  static String get baseUrl => AppConstants.apiBaseUrl;

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

  /// Safely decode JSON response, handling backend MongoDB ObjectId format issues
  dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      debugPrint(
        '⚠️ [REPO] JSON decode failed (backend returning non-JSON format): $e',
      );
      debugPrint(
        '⚠️ [REPO] Response body preview: ${body.substring(0, body.length > 200 ? 200 : body.length)}...',
      );
      return null;
    }
  }

  // ==================== SUBSCRIPTIONS ====================

  /// Fetch all subscriptions
  Future<List<Subscription>> fetchSubscriptions() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data != null && data is List) {
          return data.map((e) => Subscription.fromJson(e)).toList();
        }
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
        final data = _safeJsonDecode(response.body);
        if (data != null) {
          return DashboardSummary.fromJson(data);
        }
      }
      throw HttpException('Failed to load summary: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a new subscription
  Future<Subscription> createSubscription(Subscription subscription) async {
    try {
      final payload = Map<String, dynamic>.from(subscription.toJson());
      final response = await _client.post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: await _authHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeJsonDecode(response.body);
        if (data != null) {
          return Subscription.fromJson(data);
        }
        return subscription;
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
        final data = _safeJsonDecode(response.body);
        if (data != null) {
          return data != null ? Subscription.fromJson(data) : null;
        }
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

  /// Fetch all categories
  Future<List<Category>> fetchCategories() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/categories'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data != null && data is List) {
          return data.map((e) => Category.fromJson(e)).toList();
        }
      }
      throw HttpException('Failed to load categories: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Create a custom category
  Future<Category> createCategory(Category category) async {
    try {
      final payload = Map<String, dynamic>.from(category.toJson());
      final response = await _client.post(
        Uri.parse('$baseUrl/categories'),
        headers: await _authHeaders(),
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeJsonDecode(response.body);
        if (data != null) {
          return Category.fromJson(data);
        }
      }
      throw HttpException('Failed to create category: ${response.statusCode}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Update a custom category
  Future<Category?> updateCategory(String id, Category category) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/categories/$id'),
        headers: await _authHeaders(),
        body: jsonEncode(category.toJson()),
      );

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data != null) {
          return data != null ? Category.fromJson(data) : null;
        }
      }
      return null;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Delete a category
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

  // ==================== USER PREFERENCES ====================

  /// Save user preferences
  Future<Map<String, dynamic>> savePreferences(
    Map<String, dynamic> preferences,
  ) async {
    try {
      debugPrint('📤 [REPO] POST $baseUrl/preferences');
      debugPrint('📦 [REPO] Request body: ${jsonEncode(preferences)}');

      final headers = await _authHeaders();
      debugPrint(
        '🔑 [REPO] Auth header: ${headers['Authorization'] != null ? "Bearer ***" : "null"}',
      );

      final response = await _client.post(
        Uri.parse('$baseUrl/preferences'),
        headers: headers,
        body: jsonEncode(preferences),
      );

      debugPrint('📥 [REPO] Response status: ${response.statusCode}');
      debugPrint('📥 [REPO] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ [REPO] Preferences saved successfully');
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint(
            '⚠️ [REPO] Failed to parse response body (backend may be returning non-JSON format): $e',
          );
          return {};
        }
      }
      debugPrint('❌ [REPO] Failed to save preferences: ${response.statusCode}');
      throw HttpException('Failed to save preferences: ${response.statusCode}');
    } catch (e) {
      debugPrint('❌ [REPO] savePreferences error: $e');
      debugPrint('❌ [REPO] Error type: ${e.runtimeType}');
      throw Exception('Network error: $e');
    }
  }

  /// Get user preferences
  Future<Map<String, dynamic>?> getPreferences() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/preferences'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        return _safeJsonDecode(response.body);
      }
      return null;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Check if onboarding is complete
  Future<bool> checkOnboardingStatus() async {
    try {
      debugPrint('📤 [REPO] GET $baseUrl/preferences/status');

      final headers = await _authHeaders();
      debugPrint(
        '🔑 [REPO] Auth header: ${headers['Authorization'] != null ? "Bearer ***" : "null"}',
      );

      final response = await _client.get(
        Uri.parse('$baseUrl/preferences/status'),
        headers: headers,
      );

      debugPrint('📥 [REPO] Response status: ${response.statusCode}');
      debugPrint('📥 [REPO] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = _safeJsonDecode(response.body);
        if (data != null && data is Map) {
          return data['onboardingComplete'] ?? false;
        }
      }
      debugPrint(
        '❌ [REPO] Failed to check onboarding status: ${response.statusCode}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ [REPO] checkOnboardingStatus error: $e');
      debugPrint('❌ [REPO] Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Complete onboarding
  Future<bool> completeOnboarding() async {
    try {
      debugPrint('📤 [REPO] PATCH $baseUrl/preferences/complete');

      final headers = await _authHeaders();
      debugPrint(
        '🔑 [REPO] Auth header: ${headers['Authorization'] != null ? "Bearer ***" : "null"}',
      );

      final response = await _client.patch(
        Uri.parse('$baseUrl/preferences/complete'),
        headers: headers,
      );

      debugPrint('📥 [REPO] Response status: ${response.statusCode}');
      debugPrint('📥 [REPO] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeJsonDecode(response.body);
        if (data != null && data is Map) {
          return data['success'] ?? false;
        }
      }
      debugPrint(
        '❌ [REPO] Failed to complete onboarding: ${response.statusCode}',
      );
      return false;
    } catch (e) {
      debugPrint('❌ [REPO] completeOnboarding error: $e');
      debugPrint('❌ [REPO] Error type: ${e.runtimeType}');
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
