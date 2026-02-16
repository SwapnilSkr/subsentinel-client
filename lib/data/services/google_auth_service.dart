import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initializes the Google Sign-In instance with the server client ID.
  /// This must be called before any other method.
  Future<void> init() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: AppConstants.serverClientId,
        // scopes: ['email'], // Scopes can be defined here if needed
      );
      debugPrint('✅ Google Sign-In Initialized');
    } catch (e) {
      debugPrint('❌ Google Sign-In Initialization Failed: $e');
    }
  }

  /// Initiates the Google Sign-In flow.
  /// Returns the [GoogleSignInAccount] if successful, or null if canceled/failed.
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // authenticate() triggers the interactive sign-in flow
      final account = await _googleSignIn.authenticate();
      // check if user cancelled? authenticate throws cancellation error usually or returns null depending on platform/version specifics,
      // but in 7.0+ it returns Future<GoogleSignInAccount?> on web, and usually throws on mobile if cancelled?
      // Actually authenticate returns Future<GoogleSignInAccount> and throws if cancelled/failed.
      return account;
    } catch (e) {
      debugPrint('❌ Google Sign-In Failed: $e');
      rethrow;
    }
  }

  /// Retrieves authentication tokens (idToken, accessToken) from a [GoogleSignInAccount].
  Future<GoogleSignInAuthentication> getAuthentication(
    GoogleSignInAccount account,
  ) async {
    return account.authentication;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      // disconnect() revokes access, signOut() just clears the local session.
      // Usually signOut() is what we want for "Logout".
      // specific logic might depend on requirements, but usually:
      await _googleSignIn.signOut();
      // await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint('❌ Google Sign-Out Failed: $e');
    }
  }
}
