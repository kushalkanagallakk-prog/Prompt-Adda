import 'package:cloud_firestore/cloud_firestore.dart';

class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.providerIds,
    this.firstSeenAt,
    this.lastSignInAt,
    this.lastSeenAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;
  final List<String> providerIds;

  final DateTime? firstSeenAt;
  final DateTime? lastSignInAt;
  final DateTime? lastSeenAt;

  factory AppUserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return AppUserModel(
      uid: data['uid']?.toString() ?? document.id,
      displayName: data['displayName']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      providerIds: data['providerIds'] is List
          ? (data['providerIds'] as List)
                .map((provider) => provider.toString())
                .toList()
          : <String>[],
      firstSeenAt: _parseDate(data['firstSeenAt']),
      lastSignInAt: _parseDate(data['lastSignInAt']),
      lastSeenAt: _parseDate(data['lastSeenAt']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
