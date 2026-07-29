import 'package:flutter/material.dart';

import '../models/prompt_collection.dart';

const List<PromptCollection> dummyCollections = [
  PromptCollection(
    id: 'instagram-growth',
    title: 'Instagram Growth',
    description: 'Reels, strategy and audience growth prompts.',
    promptIds: ['1', '4'],
    icon: Icons.auto_graph_rounded,
    gradient: [Color(0xFFC84C74), Color(0xFFEC7C9F)],
  ),
  PromptCollection(
    id: 'creator-toolkit',
    title: 'Creator Toolkit',
    description: 'Essential prompts for videos and content.',
    promptIds: ['1', '2', '7', '8'],
    icon: Icons.video_collection_rounded,
    gradient: [Color(0xFF5B36C9), Color(0xFF8E5CE6)],
  ),
  PromptCollection(
    id: 'career-booster',
    title: 'Career Booster',
    description: 'Resume and interview preparation prompts.',
    promptIds: ['5', '10'],
    icon: Icons.rocket_launch_rounded,
    gradient: [Color(0xFF176B87), Color(0xFF32A5B8)],
  ),
  PromptCollection(
    id: 'design-studio',
    title: 'Design Studio',
    description: 'Branding and cinematic visual prompts.',
    promptIds: ['3', '9'],
    icon: Icons.brush_rounded,
    gradient: [Color(0xFFB86C21), Color(0xFFE9A444)],
  ),
  PromptCollection(
    id: 'developer-pack',
    title: 'Developer Pack',
    description: 'Prompts for cleaner and faster coding.',
    promptIds: ['6'],
    icon: Icons.terminal_rounded,
    gradient: [Color(0xFF3267C8), Color(0xFF6595EF)],
  ),
];
