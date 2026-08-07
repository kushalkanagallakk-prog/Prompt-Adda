import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../services/prompt_service.dart';
import '../../models/prompt_model.dart';
import '../../services/favorites_service.dart';
import '../prompt/prompt_details_screen.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/featured_collections.dart';
import 'widgets/recently_added.dart';
import '../../widgets/premium_badge.dart';
import '../../widgets/premium_prompt_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Stack(
          children: [
            const _BackgroundBlobs(),
            SafeArea(
              child: StreamBuilder<List<PromptModel>>(
                stream: PromptService.watchAll(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Unable to load prompts',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Check your internet connection and try again.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allPrompts = snapshot.data ?? <PromptModel>[];

                  final cleanQuery = _searchQuery.trim().toLowerCase();
                  final isSearching = cleanQuery.isNotEmpty;

                  final searchResults = allPrompts.where((prompt) {
                    final matchesTitle = prompt.title.toLowerCase().contains(
                      cleanQuery,
                    );

                    final matchesCategory = prompt.category
                        .toLowerCase()
                        .contains(cleanQuery);

                    final matchesDescription = prompt.description
                        .toLowerCase()
                        .contains(cleanQuery);

                    final matchesPrompt = prompt.prompt.toLowerCase().contains(
                      cleanQuery,
                    );

                    final matchesTags = prompt.tags.any(
                      (tag) => tag.toLowerCase().contains(cleanQuery),
                    );

                    return matchesTitle ||
                        matchesCategory ||
                        matchesDescription ||
                        matchesPrompt ||
                        matchesTags;
                  }).toList();

                  const hiddenTrendingTitles = {
                    'youtube shorts hook',
                    'instagram viral reel',
                  };

                  final trendingPrompts = allPrompts
                      .where(
                        (prompt) =>
                            prompt.isTrending &&
                            !hiddenTrendingTitles.contains(
                              prompt.title.trim().toLowerCase(),
                            ),
                      )
                      .toList();

                  final featuredPrompts =
                      allPrompts
                          .where(
                            (prompt) =>
                                prompt.isFeatured &&
                                prompt.title.trim().toLowerCase() !=
                                    'instagram viral reel',
                          )
                          .toList()
                        ..sort((first, second) {
                          final firstDate =
                              first.createdAt ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final secondDate =
                              second.createdAt ??
                              DateTime.fromMillisecondsSinceEpoch(0);

                          return secondDate.compareTo(firstDate);
                        });

                  final displayedPrompts = isSearching
                      ? searchResults
                      : trendingPrompts;

                  return RefreshIndicator(
  color: AppColors.primary,
  onRefresh: () async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {});
    }
  },
  child: SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 125),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _TopHeader(),
                        const SizedBox(height: 22),

                        _SearchBar(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          onClear: _clearSearch,
                        ),

                        const SizedBox(height: 36),

                        if (!isSearching && allPrompts.isNotEmpty) ...[
                          if (featuredPrompts.isNotEmpty) ...[
                            HeroCarousel(prompts: featuredPrompts),
                            const SizedBox(height: 30),
                          ],

                          _SectionHeader(
                            title: 'Recently Added',
                            actionText: 'View all',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          const RecentlyAdded(),
                          const SizedBox(height: 30),

                          _SectionHeader(
                            title: 'Featured Collections',
                            actionText: 'Explore',
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          const FeaturedCollections(),
                          const SizedBox(height: 30),
                        ],

                        _SectionHeader(
                          title: isSearching
                              ? 'Search Results (${displayedPrompts.length})'
                              : 'Trending Prompts',
                          actionText: isSearching ? 'Clear' : 'View all',
                          onTap: () {
                            if (isSearching) {
                              _clearSearch();
                            }
                          },
                        ),

                        const SizedBox(height: 18),

                        if (displayedPrompts.isEmpty)
                          const _EmptySearchResult()
                        else
                          _TrendingList(prompts: displayedPrompts),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
        ? 'Good Afternoon'
        : 'Good Evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find your next\nperfect prompt',
                style: GoogleFonts.poppins(
                  fontSize: 29,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1A181F)
                : Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.30
                      : 0.08,
                ),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF18171F)
            : const Color(0xFFF2ECFF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.18
                  : 0.025,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              size: 22,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search prompts...',
                  filled: false,
                  fillColor: Colors.transparent,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.68),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  tooltip: 'Clear search',
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  final String title;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingList extends StatelessWidget {
  const _TrendingList({required this.prompts});

  final List<PromptModel> prompts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(prompts.length, (index) {
        final prompt = prompts[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: _PremiumPromptCard(prompt: prompt, index: index),
        );
      }),
    );
  }
}

class _PremiumPromptCard extends StatelessWidget {
  const _PremiumPromptCard({required this.prompt, required this.index});

  final PromptModel prompt;
  final int index;

  static const List<List<Color>> _cardGradients = [
    [Color(0xFF5B36C9), Color(0xFF8E5CE6)],
    [Color(0xFF176B87), Color(0xFF32A5B8)],
    [Color(0xFFC84C74), Color(0xFFEC7C9F)],
    [Color(0xFFB86C21), Color(0xFFE9A444)],
  ];

  List<Color> get _gradient {
    return _cardGradients[index % _cardGradients.length];
  }

  void _openPrompt(BuildContext context) {
    if (prompt.isPremium) {
      showPremiumPromptDialog(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  Future<void> _sharePrompt(BuildContext context) async {
    if (prompt.isPremium) {
      showPremiumPromptDialog(context);
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        subject: prompt.title,
        text:
            '''
${prompt.title}

${prompt.prompt}

Shared from Prompt Adda
''',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(28),
          border: null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.20
                    : 0.025,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _openPrompt(context),
                child: _PromptVisualHeader(
                  prompt: prompt,
                  gradient: _gradient,
                  index: index,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 17, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => _openPrompt(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                prompt.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  height: 1.22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.25,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (prompt.isPremium) ...[
                              const SizedBox(width: 8),
                              const PremiumBadge(),
                            ],
                            const SizedBox(width: 12),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF33234E)
                                    : AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.arrow_outward_rounded,
                                size: 19,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      prompt.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.6,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        _PromptInfoChip(
                          icon: Icons.local_fire_department_rounded,
                          label: index.isEven ? 'Trending' : 'Popular',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _PromptInfoChip(
                              icon: Icons.auto_awesome_rounded,
                              label: prompt.category,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.25),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PromptActionButton(
                            icon: Icons.copy_all_rounded,
                            label: 'Copy',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: prompt.prompt),
                              );
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PromptActionButton(
                            icon: Icons.ios_share_rounded,
                            label: 'Share',
                            onTap: () => _sharePrompt(context),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PromptActionButton(
                            icon: Icons.visibility_rounded,
                            label: 'View',
                            isPrimary: true,
                            onTap: () => _openPrompt(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptActionButton extends StatelessWidget {
  const _PromptActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary
          ? AppColors.primary
          : AppColors.primarySoft.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 46,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptVisualHeader extends StatelessWidget {
  const _PromptVisualHeader({
    required this.prompt,
    required this.gradient,
    required this.index,
  });

  final PromptModel prompt;
  final List<Color> gradient;
  final int index;

  @override
  Widget build(BuildContext context) {
    final coverImage = prompt.coverImage;
    final imageCount = prompt.imageUrls.length;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverImage != null)
              CachedNetworkImage(
                imageUrl: coverImage,
                fit: BoxFit.cover,
                placeholder: (context, url) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradient,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  return _buildFallback();
                },
              )
            else
              _buildFallback(),

            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x08000000),
                    Color(0x22000000),
                    Color(0x72000000),
                    Color(0xD0000000),
                  ],
                  stops: [0.0, 0.35, 0.72, 1.0],
                ),
              ),
            ),

            Positioned(
              top: 15,
              left: 15,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 190),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  prompt.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.65,
                    color: Colors.white.withValues(alpha: 0.96),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 14,
              right: 14,
              child: _AnimatedFavoriteButton(promptId: prompt.id),
            ),

            if (imageCount > 1)
              Positioned(
                right: 15,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$imageCount',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Positioned(
              left: 16,
              right: imageCount > 1 ? 76 : 16,
              bottom: 15,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: Icon(
                      index == 0
                          ? Icons.workspace_premium_rounded
                          : Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      index == 0 ? 'Editor’s Pick' : 'Prompt Adda Choice',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        prompt.icon,
        size: 80,
        color: Colors.white.withValues(alpha: 0.32),
      ),
    );
  }
}

class _AnimatedFavoriteButton extends StatefulWidget {
  const _AnimatedFavoriteButton({required this.promptId});

  final String promptId;

  @override
  State<_AnimatedFavoriteButton> createState() =>
      _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.28,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.28,
          end: 1,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
    ]).animate(_animationController);

    _loadFavoriteState();
  }

  @override
  void didUpdateWidget(covariant _AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.promptId != widget.promptId) {
      _loadFavoriteState();
    }
  }

  Future<void> _loadFavoriteState() async {
    final isFavorite = await FavoritesService.isFavorite(widget.promptId);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing || _isLoading) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final newFavoriteState = await FavoritesService.toggleFavorite(
      widget.promptId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = newFavoriteState;
      _isProcessing = false;
    });

    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleFavorite,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _isFavorite
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: _isFavorite
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.26),
              ),
              boxShadow: _isFavorite
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: _isLoading || _isProcessing
                ? Padding(
                    padding: const EdgeInsets.all(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _isFavorite
                          ? const Color(0xFF7042D8)
                          : Colors.white,
                    ),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey<bool>(_isFavorite),
                      size: 22,
                      color: _isFavorite
                          ? const Color(0xFF7042D8)
                          : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PromptInfoChip extends StatelessWidget {
  const _PromptInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2433) : const Color(0xFFF6F1FC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 75),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 46,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'No prompts found',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching with another keyword.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -130,
            bottom: 100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFC8AF).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 250,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
