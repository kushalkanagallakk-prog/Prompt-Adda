import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';
import '../prompt/prompt_details_screen.dart';
import '../../widgets/premium_prompt_dialog.dart';
import '../../widgets/prompt_card.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  void _openPrompt(BuildContext context, PromptModel prompt) {
    if (prompt.isPremium) {
      showPremiumPromptDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: Theme.of(context).brightness == Brightness.dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF171122),
                  Color(0xFF0E0C14),
                  Color(0xFF17101F),
                  Color(0xFF22151C),
                ],
                stops: [0, 0.38, 0.72, 1],
              )
            : AppColors.appBackgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: StreamBuilder<List<PromptModel>>(
          stream: PromptService.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return _TrendingMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Unable to load trending prompts',
                subtitle: 'Check your internet connection and try again.',
              );
            }

            final allPrompts = snapshot.data ?? <PromptModel>[];

            final trendingPrompts = allPrompts
                .where((prompt) => prompt.isTrending)
                .toList();

            if (trendingPrompts.isEmpty) {
              return const _TrendingMessage(
                icon: Icons.local_fire_department_rounded,
                title: 'No trending prompts yet',
                subtitle: 'Trending prompts will appear here.',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF9A5AF5), Color(0xFF5B2ACD)],
                          ),
                          borderRadius: BorderRadius.circular(19),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF7C3FE0,
                              ).withValues(alpha: 0.25),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 31,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Trending',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${trendingPrompts.length} popular ${trendingPrompts.length == 1 ? 'prompt' : 'prompts'}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ListView.separated(
                    itemCount: trendingPrompts.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, index) {
                      return const SizedBox(height: 18);
                    },
                    itemBuilder: (context, index) {
                      final prompt = trendingPrompts[index];

                      return PromptCard(
                        prompt: prompt,
                        footerLabel: 'Trending',
                        footerIcon: Icons.arrow_forward_rounded,
                        onTap: () {
                          _openPrompt(context, prompt);
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrendingMessage extends StatelessWidget {
  const _TrendingMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9A5AF5), Color(0xFF5B2ACD)],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
