import 'package:flutter/material.dart';

import '../models/prompt_model.dart';

final List<PromptModel> dummyPrompts = [
  const PromptModel(
    id: '1',
    title: 'Instagram Viral Reel',
    category: 'Social Media',
    description: 'Create high-engagement Instagram reel scripts.',
    prompt:
        'Generate a viral Instagram reel script with a powerful opening hook, relatable storytelling, pattern interrupts, engaging captions, and a clear call to action. Keep the language natural and optimized for audience retention.',
    tags: ['Instagram', 'Reels', 'Marketing'],
    icon: Icons.smartphone_rounded,
  ),
  const PromptModel(
    id: '2',
    title: 'YouTube Video Script',
    category: 'YouTube',
    description: 'Create a structured long-form video script.',
    prompt:
        'Write a detailed YouTube video script with a curiosity-driven hook, short introduction, well-structured main content, examples, smooth transitions, audience engagement questions, and a memorable conclusion with a call to action.',
    tags: ['YouTube', 'Script', 'Video'],
    icon: Icons.play_circle_fill_rounded,
  ),
  const PromptModel(
    id: '3',
    title: 'Premium Logo Design',
    category: 'Design',
    description: 'Generate a modern professional logo concept.',
    prompt:
        'Create a premium minimalist logo concept using clean geometry, balanced negative space, modern typography, subtle gradients, and a memorable brand symbol. The result should feel professional, scalable, and suitable for digital and print use.',
    tags: ['Logo', 'Design', 'Branding'],
    icon: Icons.palette_rounded,
  ),
  const PromptModel(
    id: '4',
    title: 'Instagram Growth Strategy',
    category: 'Social Media',
    description: 'Build a practical 30-day Instagram growth plan.',
    prompt:
        'Create a detailed 30-day Instagram growth strategy for my niche. Include daily content ideas, reel hooks, carousel topics, story engagement methods, posting frequency, audience interaction tasks, and weekly performance checkpoints.',
    tags: ['Instagram', 'Growth', 'Strategy'],
    icon: Icons.trending_up_rounded,
  ),
  const PromptModel(
    id: '5',
    title: 'Professional Resume Writer',
    category: 'Career',
    description: 'Turn work experience into a strong resume.',
    prompt:
        'Create a professional ATS-friendly resume from the information I provide. Use powerful action verbs, measurable achievements, concise bullet points, a strong profile summary, relevant skills, and clean section organization.',
    tags: ['Resume', 'Career', 'Jobs'],
    icon: Icons.description_rounded,
  ),
  const PromptModel(
    id: '6',
    title: 'Flutter Feature Builder',
    category: 'Coding',
    description: 'Generate clean production-ready Flutter code.',
    prompt:
        'Act as a senior Flutter developer. Build the requested feature using clean architecture, reusable widgets, null safety, proper state management, responsive layouts, meaningful naming, error handling, and production-quality Dart code.',
    tags: ['Flutter', 'Dart', 'Coding'],
    icon: Icons.code_rounded,
  ),
  const PromptModel(
    id: '7',
    title: 'YouTube Shorts Ideas',
    category: 'YouTube',
    description: 'Generate engaging short-video content ideas.',
    prompt:
        'Generate 20 YouTube Shorts ideas for my niche. For each idea, provide a strong first-three-second hook, the core concept, suggested visuals, a short caption, and a clear engagement call to action.',
    tags: ['YouTube', 'Shorts', 'Ideas'],
    icon: Icons.video_library_rounded,
  ),
  const PromptModel(
    id: '8',
    title: 'Product Description Writer',
    category: 'Writing',
    description: 'Write persuasive product descriptions.',
    prompt:
        'Write a persuasive product description that highlights the customer problem, key benefits, important features, emotional value, trust-building details, and a clear purchase call to action. Keep it concise and natural.',
    tags: ['Writing', 'Product', 'Sales'],
    icon: Icons.edit_note_rounded,
  ),
  const PromptModel(
    id: '9',
    title: 'Cinematic Portrait Prompt',
    category: 'Design',
    description: 'Create detailed AI portrait photography prompts.',
    prompt:
        'Write an ultra-realistic cinematic portrait prompt with detailed subject styling, natural proportions, camera angle, professional lighting, lens settings, background atmosphere, realistic skin texture, depth of field, and premium editorial composition.',
    tags: ['Portrait', 'Photography', 'AI Image'],
    icon: Icons.camera_alt_rounded,
  ),
  const PromptModel(
    id: '10',
    title: 'Job Interview Preparation',
    category: 'Career',
    description: 'Prepare confident answers for interviews.',
    prompt:
        'Act as an experienced interview coach. Create likely interview questions for the target role, strong sample answers using the STAR method, technical preparation topics, common mistakes to avoid, and thoughtful questions to ask the interviewer.',
    tags: ['Interview', 'Career', 'Preparation'],
    icon: Icons.work_rounded,
  ),
];
