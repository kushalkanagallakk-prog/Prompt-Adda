import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyModel {
  const ReplyModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
    this.userPhoto,
    this.isVisible = true,
  });

  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String text;
  final DateTime? createdAt;
  final bool isVisible;

  factory ReplyModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];

    return ReplyModel(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? 'User',
      userPhoto: data['userPhoto']?.toString(),
      text: data['text']?.toString() ?? '',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      isVisible: data['isVisible'] != false,
    );
  }
}
