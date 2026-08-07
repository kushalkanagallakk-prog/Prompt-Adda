import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  AdminAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static bool get isSignedIn => currentUser != null;

  static String? get currentUid => currentUser?.uid;

  static String? get currentEmail => currentUser?.email;

  static Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<void> signOut() {
    return _auth.signOut();
  }

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
