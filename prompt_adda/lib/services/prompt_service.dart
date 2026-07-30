import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/dummy_prompts.dart';
import '../models/prompt_model.dart';

class PromptService {
  const PromptService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _promptsCollection {
    return _firestore.collection('prompts');
  }

  // Existing screens break avvakunda dummy-data methods.
  static List<PromptModel> getAll() {
    return List.unmodifiable(dummyPrompts);
  }

  static List<PromptModel> getTrending({int limit = 10}) {
    return dummyPrompts.take(limit).toList();
  }

  static List<PromptModel> getRecent({int limit = 5}) {
    return dummyPrompts.reversed.take(limit).toList();
  }

  static List<PromptModel> search(String query) {
    return _searchList(dummyPrompts, query);
  }

  // Firestore nundi one-time data fetch.
  static Future<List<PromptModel>> fetchAll() async {
    try {
      final snapshot = await _promptsCollection.get();

      final prompts = snapshot.docs.map(PromptModel.fromFirestore).toList();

      if (prompts.isEmpty) {
        return getAll();
      }

      return prompts;
    } catch (_) {
      return getAll();
    }
  }

  static Future<List<PromptModel>> fetchFeatured({int limit = 10}) async {
    final prompts = await fetchAll();

    final featured = prompts
        .where((prompt) => prompt.isFeatured)
        .take(limit)
        .toList();

    return featured.isNotEmpty ? featured : prompts.take(limit).toList();
  }

  static Future<List<PromptModel>> fetchTrending({int limit = 10}) async {
    final prompts = await fetchAll();

    final trending = prompts
        .where((prompt) => prompt.isTrending)
        .take(limit)
        .toList();

    return trending.isNotEmpty ? trending : prompts.take(limit).toList();
  }

  static Future<List<PromptModel>> fetchRecent({int limit = 5}) async {
    final prompts = await fetchAll();

    final sortedPrompts = List<PromptModel>.from(prompts)
      ..sort((first, second) {
        final firstDate =
            first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        final secondDate =
            second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return secondDate.compareTo(firstDate);
      });

    return sortedPrompts.take(limit).toList();
  }

  static Future<List<PromptModel>> searchFirestore(String query) async {
    final prompts = await fetchAll();

    return _searchList(prompts, query);
  }

  // Firestore changes app ki live ga receive avvadaniki.
  static Stream<List<PromptModel>> watchAll() {
    return _promptsCollection.snapshots().map((snapshot) {
      final prompts = snapshot.docs.map(PromptModel.fromFirestore).toList();

      if (prompts.isEmpty) {
        return getAll();
      }

      return prompts;
    });
  }

  static List<PromptModel> _searchList(
    List<PromptModel> prompts,
    String query,
  ) {
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return prompts;
    }

    return prompts.where((prompt) {
      final matchesTitle = prompt.title.toLowerCase().contains(cleanQuery);

      final matchesCategory = prompt.category.toLowerCase().contains(
        cleanQuery,
      );

      final matchesDescription = prompt.description.toLowerCase().contains(
        cleanQuery,
      );

      final matchesTags = prompt.tags.any(
        (tag) => tag.toLowerCase().contains(cleanQuery),
      );

      return matchesTitle ||
          matchesCategory ||
          matchesDescription ||
          matchesTags;
    }).toList();
  }
}
