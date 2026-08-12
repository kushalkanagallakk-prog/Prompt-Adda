import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'prompt_service.dart';

class FavoritesService {
  FavoritesService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final ValueNotifier<Set<String>> favoriteIdsNotifier =
      ValueNotifier<Set<String>>(<String>{});

  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _favoritesSubscription;

  static bool _isInitialized = false;
  static String? _activeUid;

  static bool get isSignedIn => _auth.currentUser != null;

  static CollectionReference<Map<String, dynamic>> _favoritesCollection(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('favorites');
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    _isInitialized = true;

    await _switchUser(_auth.currentUser);

    _auth.authStateChanges().listen((user) {
      unawaited(_switchUser(user));
    });
  }

  static Future<void> _switchUser(User? user) async {
    await _favoritesSubscription?.cancel();
    _favoritesSubscription = null;

    _activeUid = user?.uid;

    // Guest / logout = no visible favorites.
    favoriteIdsNotifier.value = <String>{};

    if (user == null) {
      return;
    }

    final uid = user.uid;

    _favoritesSubscription = _favoritesCollection(uid).snapshots().listen(
      (snapshot) {
        if (_activeUid != uid) return;

        favoriteIdsNotifier.value = snapshot.docs
            .map((document) => document.id)
            .toSet();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Favorites stream error: $error');

        if (_activeUid == uid) {
          favoriteIdsNotifier.value = <String>{};
        }
      },
    );
  }

  static Future<Set<String>> getFavoriteIds() async {
    await initialize();

    if (_auth.currentUser == null) {
      return <String>{};
    }

    return Set<String>.from(favoriteIdsNotifier.value);
  }

  static bool isFavoriteSync(String promptId) {
    if (_auth.currentUser == null) {
      return false;
    }

    return favoriteIdsNotifier.value.contains(promptId);
  }

  static Future<bool> isFavorite(String promptId) async {
    await initialize();

    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final document = await _favoritesCollection(user.uid).doc(promptId).get();

      return document.exists;
    } catch (error) {
      debugPrint('Check favorite error: $error');
      return favoriteIdsNotifier.value.contains(promptId);
    }
  }

  static Future<void> addFavorite(String promptId) async {
    await initialize();

    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final reference = _favoritesCollection(user.uid).doc(promptId);

    try {
      final existing = await reference.get();

      if (existing.exists) {
        return;
      }

      await reference.set({
        'promptId': promptId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final updatedIds = Set<String>.from(favoriteIdsNotifier.value)
        ..add(promptId);

      favoriteIdsNotifier.value = updatedIds;

      await PromptService.incrementFavoriteCount(promptId, isAdding: true);
    } catch (error) {
      debugPrint('Add favorite error: $error');
    }
  }

  static Future<void> removeFavorite(String promptId) async {
    await initialize();

    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    final reference = _favoritesCollection(user.uid).doc(promptId);

    try {
      final existing = await reference.get();

      if (!existing.exists) {
        return;
      }

      await reference.delete();

      final updatedIds = Set<String>.from(favoriteIdsNotifier.value)
        ..remove(promptId);

      favoriteIdsNotifier.value = updatedIds;

      await PromptService.incrementFavoriteCount(promptId, isAdding: false);
    } catch (error) {
      debugPrint('Remove favorite error: $error');
    }
  }

  static Future<bool> toggleFavorite(String promptId) async {
    await initialize();

    final user = _auth.currentUser;

    // Guest cannot favorite.
    if (user == null) {
      return false;
    }

    final reference = _favoritesCollection(user.uid).doc(promptId);

    try {
      final existing = await reference.get();
      final isNowFavorite = !existing.exists;

      if (isNowFavorite) {
        await reference.set({
          'promptId': promptId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await reference.delete();
      }

      final updatedIds = Set<String>.from(favoriteIdsNotifier.value);

      if (isNowFavorite) {
        updatedIds.add(promptId);
      } else {
        updatedIds.remove(promptId);
      }

      favoriteIdsNotifier.value = updatedIds;

      await PromptService.incrementFavoriteCount(
        promptId,
        isAdding: isNowFavorite,
      );

      return isNowFavorite;
    } catch (error) {
      debugPrint('Toggle favorite error: $error');

      return favoriteIdsNotifier.value.contains(promptId);
    }
  }

  static Future<void> clearFavorites() async {
    await initialize();

    final user = _auth.currentUser;

    if (user == null) {
      favoriteIdsNotifier.value = <String>{};
      return;
    }

    try {
      final snapshot = await _favoritesCollection(user.uid).get();

      for (final document in snapshot.docs) {
        await document.reference.delete();
      }

      favoriteIdsNotifier.value = <String>{};
    } catch (error) {
      debugPrint('Clear favorites error: $error');
    }
  }
}
