import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'user_tracking_service.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool _googleInitialized = false;

  static StreamSubscription<User?>? _userTrackingSubscription;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static User? get currentUser => _auth.currentUser;

  static void startUserTracking() {
    if (_userTrackingSubscription != null) {
      return;
    }

    _userTrackingSubscription = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        return;
      }

      try {
        await UserTrackingService.trackUser(user);
      } catch (error) {
        debugPrint('User tracking error: $error');
      }
    });
  }

  static Future<void> _initializeGoogleSignIn() async {
    if (_googleInitialized) return;

    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    await _initializeGoogleSignIn();

    final googleUser = await _googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    await _initializeGoogleSignIn();

    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
