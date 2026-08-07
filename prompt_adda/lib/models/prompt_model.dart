import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromptModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String prompt;
  final List<String> tags;
  final IconData icon;
  final List<String> imageUrls;

  final bool isFeatured;
  final bool isTrending;
  final bool isPremium;
  final DateTime? createdAt;

  final int viewCount;
  final int copyCount;
  final int shareCount;
  final int favoriteCount;

  String? get coverImage {
    if (imageUrls.isEmpty) return null;
    return imageUrls.first;
  }

  const PromptModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.prompt,
    required this.tags,
    this.icon = Icons.auto_awesome_rounded,
    this.isFeatured = false,
    this.isTrending = false,
    this.isPremium = false,
    this.createdAt,
    this.imageUrls = const [],
    this.viewCount = 0,
    this.copyCount = 0,
    this.shareCount = 0,
    this.favoriteCount = 0,
  });

  factory PromptModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final rawTags = data['tags'];

    return PromptModel(
      id: document.id,
      title: data['title']?.toString() ?? 'Untitled Prompt',
      category: data['category']?.toString() ?? 'General',
      description: data['description']?.toString() ?? '',
      prompt: data['prompt']?.toString() ?? '',
      imageUrls: _parseImageUrls(data),
      tags: rawTags is List
          ? rawTags.map((tag) => tag.toString()).toList()
          : <String>[],
      icon: _getCategoryIcon(data['category']?.toString() ?? ''),
      isFeatured: data['isFeatured'] == true,
      isTrending: data['isTrending'] == true,
      isPremium: data['isPremium'] == true,
      createdAt: _parseDate(data['createdAt']),
      viewCount: _parseCount(data['viewCount']),
      copyCount: _parseCount(data['copyCount']),
      shareCount: _parseCount(data['shareCount']),
      favoriteCount: _parseCount(data['favoriteCount']),
    );
  }

  static List<String> _parseImageUrls(Map<String, dynamic> data) {
    final rawImageUrls = data['imageUrls'];

    if (rawImageUrls is List) {
      return rawImageUrls
          .map((url) => url.toString().trim())
          .where((url) => url.isNotEmpty)
          .toList();
    }

    final legacyImageUrl = data['imageUrl']?.toString().trim() ?? '';

    if (legacyImageUrl.isNotEmpty) {
      return [legacyImageUrl];
    }

    return <String>[];
  }

  static int _parseCount(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
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

  static IconData _getCategoryIcon(String category) {
    switch (category.trim().toLowerCase()) {
      case 'social media':
        return Icons.forum_rounded;

      case 'youtube':
        return Icons.play_circle_fill_rounded;

      case 'design':
        return Icons.palette_rounded;

      case 'career':
        return Icons.work_rounded;

      case 'coding':
        return Icons.code_rounded;

      case 'writing':
        return Icons.edit_note_rounded;

      default:
        return Icons.auto_awesome_rounded;
    }
  }
}
