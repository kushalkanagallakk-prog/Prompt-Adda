import 'package:flutter/material.dart';

class PromptCollection {
  const PromptCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.promptIds,
    required this.icon,
    required this.gradient,
  });

  final String id;
  final String title;
  final String description;
  final List<String> promptIds;
  final IconData icon;
  final List<Color> gradient;
}
