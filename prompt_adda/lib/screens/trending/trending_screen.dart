import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';
import '../../services/favorites_service.dart';
import '../prompt/prompt_details_screen.dart';
import '../../widgets/premium_badge.dart';
import '../../widgets/premium_prompt_dialog.dart';

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
      decoration: const BoxDecoration(
        gradient: AppColors.appBackgroundGradient,
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
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${trendingPrompts.length} popular ${trendingPrompts.length == 1 ? 'prompt' : 'prompts'}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textSecondary,
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

                      return _TrendingPromptCard(
                        prompt: prompt,
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
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingPromptCard extends StatelessWidget {
  const _TrendingPromptCard({required this.prompt, required this.onTap});

  final PromptModel prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.90)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
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
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    prompt.isPremium
                        ? Icons.workspace_premium_rounded
                        : Icons.local_fire_department_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              prompt.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (prompt.isPremium) ...[
                            const SizedBox(width: 8),
                            const PremiumBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        prompt.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E9FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          prompt.category,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6E3FD5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<Set<String>>(
                  valueListenable: FavoritesService.favoriteIdsNotifier,
                  builder: (context, favoriteIds, _) {
                    final isFavorite = favoriteIds.contains(prompt.id);

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          await FavoritesService.toggleFavorite(prompt.id);
                        },
                        child: Ink(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1E9FF),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: const Color(0xFF6E3FD5),
                            size: 21,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
