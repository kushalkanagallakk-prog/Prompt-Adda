import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';

class UserTrackingService {
  UserTrackingService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  static Future<void> trackUser(User user) async {
    final userRef = _users.doc(user.uid);

    final existingDocument = await userRef.get();

    final providerIds = user.providerData
        .map((provider) => provider.providerId.trim())
        .where((providerId) => providerId.isNotEmpty)
        .toSet()
        .toList();

    final lastSignInTime = user.metadata.lastSignInTime;
    final creationTime = user.metadata.creationTime;

    final data = <String, dynamic>{
      'uid': user.uid,
      'displayName': user.displayName?.trim() ?? '',
      'email': user.email?.trim() ?? '',
      'photoUrl': user.photoURL?.trim() ?? '',
      'providerIds': providerIds,
      'lastSignInAt': lastSignInTime != null
          ? Timestamp.fromDate(lastSignInTime)
          : FieldValue.serverTimestamp(),
      'lastSeenAt': FieldValue.serverTimestamp(),
    };

    if (!existingDocument.exists) {
      data['firstSeenAt'] = creationTime != null
          ? Timestamp.fromDate(creationTime)
          : FieldValue.serverTimestamp();
    }

    await userRef.set(data, SetOptions(merge: true));
  }

  static Stream<List<AppUserModel>> watchUsers() {
    return _users.orderBy('lastSignInAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map(AppUserModel.fromFirestore).toList();
    });
  }
}
