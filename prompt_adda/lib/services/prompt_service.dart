import '../data/dummy_prompts.dart';
import '../models/prompt_model.dart';

class PromptService {
  const PromptService._();

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
    final cleanQuery = query.trim().toLowerCase();

    if (cleanQuery.isEmpty) {
      return getTrending();
    }

    return dummyPrompts.where((prompt) {
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
