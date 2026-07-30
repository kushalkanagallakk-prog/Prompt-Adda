import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_prompt_ids';

  static final ValueNotifier<Set<String>> favoriteIdsNotifier =
      ValueNotifier<Set<String>>(<String>{});

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    final favoriteIds = await getFavoriteIds();

    favoriteIdsNotifier.value = favoriteIds;
    _isInitialized = true;
  }

  static Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favoritesKey) ?? <String>[];

    return ids.toSet();
  }

  static bool isFavoriteSync(String promptId) {
    return favoriteIdsNotifier.value.contains(promptId);
  }

  static Future<bool> isFavorite(String promptId) async {
    await initialize();
    return favoriteIdsNotifier.value.contains(promptId);
  }

  static Future<void> addFavorite(String promptId) async {
    await initialize();

    final updatedIds = Set<String>.from(favoriteIdsNotifier.value)
      ..add(promptId);

    await _saveFavorites(updatedIds);
  }

  static Future<void> removeFavorite(String promptId) async {
    await initialize();

    final updatedIds = Set<String>.from(favoriteIdsNotifier.value)
      ..remove(promptId);

    await _saveFavorites(updatedIds);
  }

  static Future<bool> toggleFavorite(String promptId) async {
    await initialize();

    final updatedIds = Set<String>.from(favoriteIdsNotifier.value);

    final isNowFavorite = !updatedIds.contains(promptId);

    if (isNowFavorite) {
      updatedIds.add(promptId);
    } else {
      updatedIds.remove(promptId);
    }

    await _saveFavorites(updatedIds);

    return isNowFavorite;
  }

  static Future<void> clearFavorites() async {
    await initialize();
    await _saveFavorites(<String>{});
  }

  static Future<void> _saveFavorites(Set<String> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favoritesKey, favoriteIds.toList());

    favoriteIdsNotifier.value = Set<String>.from(favoriteIds);
  }
}
