import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

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
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  AuthState build() {
    // Initial state is loading until we verify session
    _init(); // Fire and forget init
    return AuthState(isLoading: true);
  }

  Future<void> _init() async {
    // Initialize Google Sign-In (Required for v7.0+)
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      // Log initialization error (non-fatal for app start, but fatal for google auth)
      debugPrint('GoogleSignIn initialize failed: $e');
    }

    // 1. Listen to Firebase Auth (Google Sign-In)
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) async {
      try {
        if (firebaseUser == null) {
          // If no Firebase user, check if we have a locally saved "Twilio" session
          await _checkLocalSession();
        } else {
          // If Firebase user exists, trust it, but try to sync with backend model
          final prefs = await SharedPreferences.getInstance();
          final userData = prefs.getString('user_data');

          if (userData != null) {
            // We have local data, use it for speed
            state = AuthState(
              user: AppUser.fromJson(jsonDecode(userData)),
              isLoading: false,
            );
          } else {
            // Fallback: If we have firebase user but no local data, create a temporary AppUser
            // In a real app, we should fetch the profile from API using the backend token
            state = AuthState(
              user: AppUser(
                id: firebaseUser.uid,
                email: firebaseUser.email,
                displayName: firebaseUser.displayName,
                photoUrl: firebaseUser.photoURL,
                phone: firebaseUser.phoneNumber,
              ),
              isLoading: false,
            );
          }
        }
      } catch (e) {
        state = AuthState(error: e.toString(), isLoading: false);
      }
    });
  }

  Future<void> _checkLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        // We found a session (likely Twilio/Phone or stale Google)
        state = AuthState(
          user: AppUser.fromJson(jsonDecode(userData)),
          isLoading: false,
        );
      } else {
        // Really logged out
        state = AuthState(user: null, isLoading: false);
      }
    } catch (e) {
      state = AuthState(user: null, error: e.toString(), isLoading: false);
    }
  }

  // Send OTP (Twilio Logic)
  // Note: isLoading is NOT set here — screens manage their own loading UI.
  // Setting isLoading on auth state would cause AuthWrapper to swap out the
  // current screen with a loading spinner, unmounting the widget mid-call.
  Future<void> sendOtp(String phone) async {
    state = state.copyWith(clearError: true);
    try {
      await _repo.sendOtp(phone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Verify OTP (Twilio Logic)
  Future<void> verifyOtp(String phone, String code) async {
    state = state.copyWith(clearError: true);
    try {
      final result = await _repo.verifyOtp(phone, code);
      final user = result['user'] as AppUser;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user.toJson()));
      await prefs.setString('auth_token', result['token']);

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
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

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

        // 6. Verify with Backend (and create/update user in DB)
        // We proactively do this to ensure backend has the user and we get the backend session token
        final result = await _repo.googleLogin(idToken!);
        final user = result['user'] as AppUser;

        // 7. Save Session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(user.toJson()));
        await prefs.setString('auth_token', result['token']);

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    state = AuthState(user: null);
  }
}
