import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_prompt_ids';

  static Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_favoritesKey) ?? <String>[];

    return ids.toSet();
  }

  static Future<bool> isFavorite(String promptId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(promptId);
  }

  static Future<void> addFavorite(String promptId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();

    favoriteIds.add(promptId);

    await prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  static Future<void> removeFavorite(String promptId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteIds();

    favoriteIds.remove(promptId);

    await prefs.setStringList(_favoritesKey, favoriteIds.toList());
  }

  static Future<bool> toggleFavorite(String promptId) async {
    final favoriteIds = await getFavoriteIds();

    if (favoriteIds.contains(promptId)) {
      await removeFavorite(promptId);
      return false;
    }

    await addFavorite(promptId);
    return true;
  }
}
