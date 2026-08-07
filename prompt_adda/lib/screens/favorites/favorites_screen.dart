import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/prompt_service.dart';
import '../../models/prompt_model.dart';
import '../../services/favorites_service.dart';
import '../prompt/prompt_details_screen.dart';
import '../../widgets/premium_prompt_dialog.dart';
import '../../widgets/prompt_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final Future<void> _initializeFavoritesFuture;

  @override
  void initState() {
    super.initState();
    _initializeFavoritesFuture = FavoritesService.initialize();
  }

  Future<void> _openPromptDetails(PromptModel prompt) async {
    if (prompt.isPremium) {
      showPremiumPromptDialog(context);
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PromptDetailsScreen(prompt: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
          child: FutureBuilder<void>(
            future: _initializeFavoritesFuture,
            builder: (context, initializationSnapshot) {
              if (initializationSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              return ValueListenableBuilder<Set<String>>(
                valueListenable: FavoritesService.favoriteIdsNotifier,
                builder: (context, favoriteIds, child) {
                  return StreamBuilder<List<PromptModel>>(
                    stream: PromptService.watchAll(),
                    builder: (context, promptsSnapshot) {
                      if (promptsSnapshot.connectionState ==
                              ConnectionState.waiting &&
                          !promptsSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      if (promptsSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Text(
                              'Unable to load favorite prompts.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        );
                      }

                      final allPrompts =
                          promptsSnapshot.data ?? <PromptModel>[];

                      final favoritePrompts = allPrompts.where((prompt) {
                        return favoriteIds.contains(prompt.id);
                      }).toList();

                      return CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                            sliver: SliverToBoxAdapter(
                              child: _FavoritesHeader(
                                favoritesCount: favoritePrompts.length,
                              ),
                            ),
                          ),
                          if (favoritePrompts.isEmpty)
                            const SliverFillRemaining(
                              hasScrollBody: false,
                              child: _EmptyFavorites(),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                4,
                                20,
                                120,
                              ),
                              sliver: SliverList.separated(
                                itemCount: favoritePrompts.length,
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 14);
                                },
                                itemBuilder: (context, index) {
                                  final prompt = favoritePrompts[index];

                                  return PromptCard(
                                    prompt: prompt,
                                    footerLabel: 'Favorite',
                                    footerIcon: Icons.arrow_forward_rounded,
                                    onTap: () {
                                      _openPromptDetails(prompt);
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final int favoritesCount;

  const _FavoritesHeader({required this.favoritesCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorites',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                favoritesCount == 1
                    ? '1 saved prompt'
                    : '$favoritesCount saved prompts',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2141)
                    : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No favorites yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Save prompts you like and they will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
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
