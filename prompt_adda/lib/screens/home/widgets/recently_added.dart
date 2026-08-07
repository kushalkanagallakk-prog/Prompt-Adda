import 'package:flutter/material.dart';

import '../../../models/prompt_model.dart';
import '../../../services/prompt_service.dart';
import '../../prompt/prompt_details_screen.dart';
import '../../../widgets/prompt_card.dart';

class RecentlyAdded extends StatefulWidget {
  const RecentlyAdded({super.key});

  @override
  State<RecentlyAdded> createState() => _RecentlyAddedState();
}

class _RecentlyAddedState extends State<RecentlyAdded> {
  void _openPrompt(BuildContext context, PromptModel prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<PromptModel>>(
      stream: PromptService.watchAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 470,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox(
            height: 470,
            child: Center(child: Text('Unable to load recent prompts')),
          );
        }

        final allPrompts = List<PromptModel>.from(
          snapshot.data ?? <PromptModel>[],
        );

        allPrompts.sort((first, second) {
          final firstDate =
              first.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final secondDate =
              second.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

          return secondDate.compareTo(firstDate);
        });

        final prompts = allPrompts.take(5).toList();

        if (prompts.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 470,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: prompts.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 14);
            },
            itemBuilder: (context, index) {
              final prompt = prompts[index];

              return SizedBox(
                width: 250,
                child: PromptCard(
                  prompt: prompt,
                  footerLabel: 'Recently Added',
                  footerIcon: Icons.arrow_forward_rounded,
                  enableHero: false,
                  onTap: () {
                    _openPrompt(context, prompt);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
