import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/comment_model.dart';

class CommentService {
  CommentService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> _comments(String promptId) {
    return _firestore
        .collection('prompts')
        .doc(promptId)
        .collection('comments');
  }

  static Stream<List<CommentModel>> watchComments(String promptId) {
    return _comments(
      promptId,
    ).where('isVisible', isEqualTo: true).snapshots().map((snapshot) {
      final comments = snapshot.docs.map(CommentModel.fromFirestore).toList();

      comments.sort((first, second) {
        final firstDate =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        final secondDate =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

      return comments;
    });
  }

  static Future<void> addComment({
    required String promptId,
    required String text,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Sign in required');
    }

    final cleanText = text.trim();

    if (cleanText.isEmpty) {
      throw ArgumentError('Comment cannot be empty');
    }

    if (cleanText.length > 500) {
      throw ArgumentError('Comment is too long');
    }

    final emailName = user.email?.split('@').first.trim();

    final fallbackName = emailName != null && emailName.isNotEmpty
        ? emailName
        : 'User';

    final displayName = user.displayName?.trim();

    await _comments(promptId).add({
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

  static Future<void> deleteComment({
    required String promptId,
    required String commentId,
  }) async {
    await _comments(promptId).doc(commentId).delete();
  }
}
