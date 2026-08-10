import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthService {
  AdminAuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static const Set<String> _adminUids = {'7EWRjJM9PFgXOlLBvystv5IL4q83'};

  static User? get currentUser => _auth.currentUser;

  static String? get currentUid => currentUser?.uid;

  static String? get currentEmail => currentUser?.email;

  static bool get isSignedIn => currentUser != null;

  static bool get isCurrentUserAdmin {
    final uid = currentUid;

    if (uid == null) {
      return false;
    }

    return _adminUids.contains(uid);
  }

  static bool isAdminUid(String uid) {
    return _adminUids.contains(uid);
  }

  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
