import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reply_model.dart';

class ReplyService {
  ReplyService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _replies({
    required String promptId,
    required String commentId,
  }) {
    return _firestore
        .collection('prompts')
        .doc(promptId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');
  }

  static Stream<List<ReplyModel>> watchReplies({
    required String promptId,
    required String commentId,
  }) {
    return _replies(
      promptId: promptId,
      commentId: commentId,
    ).where('isVisible', isEqualTo: true).snapshots().map((snapshot) {
      final replies = snapshot.docs.map(ReplyModel.fromFirestore).toList();

      replies.sort((first, second) {
        final firstDate =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final secondDate =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return firstDate.compareTo(secondDate);
      });

      return replies;
    });
  }

  static Future<void> addReply({
    required String promptId,
    required String commentId,
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Sign in required');
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      throw ArgumentError('Reply cannot be empty');
    }

    if (cleanText.length > 500) {
      throw ArgumentError('Reply is too long');
    }

    final emailName = user.email?.split('@').first.trim();

    final fallbackName = emailName != null && emailName.isNotEmpty
        ? emailName
        : 'User';

    final displayName = user.displayName?.trim();

    await _replies(promptId: promptId, commentId: commentId).add({
      'userId': user.uid,
      'userName': displayName != null && displayName.isNotEmpty
          ? displayName
          : fallbackName,
      'userPhoto': user.photoURL,
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
      'isVisible': true,
    });
  }

  static Future<void> deleteReply({
    required String promptId,
    required String commentId,
    required String replyId,
  }) async {
    await _replies(
      promptId: promptId,
      commentId: commentId,
    ).doc(replyId).delete();
  }
}
