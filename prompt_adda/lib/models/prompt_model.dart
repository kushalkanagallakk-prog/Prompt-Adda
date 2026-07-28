import 'package:flutter/material.dart';

class PromptModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String prompt;
  final List<String> tags;
  final IconData icon;

  const PromptModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.prompt,
    required this.tags,
    this.icon = Icons.auto_awesome_rounded,
  });
}