import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/auth_session_storage.dart';
import '../../data/services/google_auth_service.dart';
import '../../data/services/twilio_auth_service.dart';

// --- State ---
class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// --- Provider ---
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  final AuthRepository _repo = AuthRepository();
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final TwilioAuthService _twilioAuthService = TwilioAuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  AuthState build() {
    // Initial state is loading until we verify session
    _init(); // Fire and forget init
    return AuthState(isLoading: true);
  }

  Future<void> _init() async {
    // Initialize Google Sign-In
    await _googleAuthService.init();

    // 1. Listen to Firebase Auth (Google Sign-In)
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) async {
      try {
        if (firebaseUser == null) {
          // If no Firebase user, check if we have a locally saved "Twilio" session
          await _checkLocalSession();
        } else {
          // If Firebase user exists, ensure backend session exists too
          final userData = await _sessionStorage.readUserData();
          final authToken = await _sessionStorage.readAuthToken();

          if (userData != null && authToken != null && authToken.isNotEmpty) {
            // We have local data, use it for speed
            state = AuthState(
              user: AppUser.fromJson(jsonDecode(userData)),
              isLoading: false,
            );
          } else {
            await _restoreGoogleBackendSession(firebaseUser);
          }
        }
      } catch (e) {
        state = AuthState(error: e.toString(), isLoading: false);
      }
    });
  }

  Future<void> _checkLocalSession() async {
    try {
      final userData = await _sessionStorage.readUserData();
      final authToken = await _sessionStorage.readAuthToken();
      if (userData != null && authToken != null && authToken.isNotEmpty) {
        // We found a session (likely Twilio/Phone or stale Google)
        state = AuthState(
          user: AppUser.fromJson(jsonDecode(userData)),
          isLoading: false,
        );
      } else {
        await _sessionStorage.clearSession();
        // Really logged out
        state = AuthState(user: null, isLoading: false);
      }
    } catch (e) {
      state = AuthState(user: null, error: e.toString(), isLoading: false);
    }
  }

  Future<void> _restoreGoogleBackendSession(User firebaseUser) async {
    final idToken = await firebaseUser.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Missing Firebase ID token');
    }
    final result = await _repo.googleLogin(idToken);
    final user = result['user'] as AppUser;
    await _sessionStorage.saveSession(
      user: user,
      token: result['token'] as String,
    );
    state = AuthState(user: user, isLoading: false);
  }

  // Send OTP (Twilio Logic)
  // Note: isLoading is NOT set here — screens manage their own loading UI.
  // Setting isLoading on auth state would cause AuthWrapper to swap out the
  // current screen with a loading spinner, unmounting the widget mid-call.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(clearError: true);
    try {
      await _twilioAuthService.sendOtp(phone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Verify OTP (Twilio Logic)
  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(clearError: true);
    try {
      final result = await _twilioAuthService.verifyOtp(phone, code);
      final user = result['user'] as AppUser;
      await _sessionStorage.saveSession(
        user: user,
        token: result['token'] as String,
      );

      // We manually update state because this flow is outside Firebase
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Google Login with Firebase
  Future<void> signInWithGoogle() async {
    state = state.copyWith(clearError: true);
    try {
      // 1. Trigger Google Sign In flow
      // This step is now handled by our GoogleAuthService
      final GoogleSignInAccount? googleUser = await _googleAuthService.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth = await _googleAuthService
          .getAuthentication(googleUser);

      // 3. Create credential
      // Note: accessToken is nullable on some platforms/web, but usually present for OAuth
      // idToken is required for OpenID Connect
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      // This triggers the authStateChanges listener in _init
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 5. Get ID Token to send to Backend
        final idToken = await firebaseUser.getIdToken();
        if (idToken == null || idToken.isEmpty) {
          throw Exception('Missing Firebase ID token');
        }

        // 6. Verify with Backend (and create/update user in DB)
        // We proactively do this to ensure backend has the user and we get the backend session token
        final result = await _repo.googleLogin(idToken);
        final user = result['user'] as AppUser;

        // 7. Save Session
        await _sessionStorage.saveSession(
          user: user,
          token: result['token'] as String,
        );

        // Listener will eventually update state, but we can fast-track updates here
        state = AuthState(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _sessionStorage.clearSession();
    await _googleAuthService.signOut();
    await _firebaseAuth.signOut();
    state = AuthState(user: null);
  }
}
