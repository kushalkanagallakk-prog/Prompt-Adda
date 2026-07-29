import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/prompt_service.dart';
import '../../../models/prompt_model.dart';
import '../../prompt/prompt_details_screen.dart';

class RecentlyAdded extends StatelessWidget {
  const RecentlyAdded({super.key});

  List<PromptModel> get _recentPrompts {
    return PromptService.getRecent(limit: 5);
  }

  void _openPrompt(BuildContext context, PromptModel prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prompts = _recentPrompts;

    if (prompts.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 182,
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

          return _RecentPromptCard(
            prompt: prompt,
            index: index,
            onTap: () {
              _openPrompt(context, prompt);
            },
          );
        },
      ),
    );
  }
}

class _RecentPromptCard extends StatelessWidget {
  const _RecentPromptCard({
    required this.prompt,
    required this.index,
    required this.onTap,
  });

  final PromptModel prompt;
  final int index;
  final VoidCallback onTap;

  static const List<List<Color>> _gradients = [
    [Color(0xFF5B36C9), Color(0xFF8E5CE6)],
    [Color(0xFFC84C74), Color(0xFFEC7C9F)],
    [Color(0xFF176B87), Color(0xFF32A5B8)],
    [Color(0xFFB86C21), Color(0xFFE9A444)],
    [Color(0xFF3267C8), Color(0xFF6595EF)],
  ];

  List<Color> get _gradient {
    return _gradients[index % _gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradient,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: _gradient.first.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 11),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    top: -48,
                    right: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -8,
                    bottom: -17,
                    child: Icon(
                      prompt.icon,
                      size: 98,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'NEW',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.65,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.16),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            prompt.icon,
                            color: Colors.white,
                            size: 23,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          prompt.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.25,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prompt.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
