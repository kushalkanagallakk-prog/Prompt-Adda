import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../data/dummy_prompts.dart';
import '../../models/prompt_model.dart';
import '../../services/favorites_service.dart';
import '../prompt/prompt_details_screen.dart';
import 'widgets/hero_carousel.dart';
import '../categories/category_prompts_screen.dart';
import 'widgets/featured_collections.dart';
import 'widgets/recently_added.dart';

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

  @override
  Widget build(BuildContext context) {
    final prompts = dummyPrompts.where((prompt) {
      final query = _searchQuery.trim().toLowerCase();

      return prompt.title.toLowerCase().contains(query) ||
          prompt.category.toLowerCase().contains(query) ||
          prompt.description.toLowerCase().contains(query) ||
          prompt.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();

    final isSearching = _searchQuery.trim().isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: Stack(
          children: [
            const _BackgroundBlobs(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 125),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _TopHeader(),
                    const SizedBox(height: 26),

                    _SearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onClear: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    ),

                    const SizedBox(height: 26),

                    if (!isSearching && dummyPrompts.isNotEmpty) ...[
                      HeroCarousel(prompts: dummyPrompts.take(4).toList()),
                      const SizedBox(height: 30),
                      _SectionHeader(
                        title: 'Categories',
                        actionText: 'See all',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      const _CategoriesGrid(),
                      const SizedBox(height: 30),

                      _SectionHeader(
                        title: 'Featured Collections',
                        actionText: 'Explore',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      const FeaturedCollections(),
                      const SizedBox(height: 30),

                      _SectionHeader(
                        title: 'Recently Added',
                        actionText: 'View all',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      const RecentlyAdded(),
                      const SizedBox(height: 30),
                    ],

                    _SectionHeader(
                      title: isSearching
                          ? 'Search Results (${prompts.length})'
                          : 'Trending Prompts',
                      actionText: isSearching ? 'Clear' : 'View all',
                      onTap: () {
                        if (isSearching) {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    if (prompts.isEmpty)
                      const _EmptySearchResult()
                    else
                      _TrendingList(prompts: prompts),
                  ],
                ),
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
                  color: AppColors.textSecondary,
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
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
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
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.88),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Search prompts, categories, tags...',
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) {
                  return const Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20,
                  );
                }

                return IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.primary,
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
              color: AppColors.textPrimary,
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

class _CategoriesGrid extends StatelessWidget {
  const _CategoriesGrid();

  static const List<List<Color>> _categoryGradients = [
    [Color(0xFF5B36C9), Color(0xFF8E5CE6)],
    [Color(0xFFC84C74), Color(0xFFEC7C9F)],
    [Color(0xFF176B87), Color(0xFF32A5B8)],
    [Color(0xFFB86C21), Color(0xFFE9A444)],
  ];

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'social media':
        return Icons.forum_rounded;

      case 'youtube':
        return Icons.play_circle_fill_rounded;

      case 'design':
        return Icons.palette_rounded;

      case 'coding':
        return Icons.code_rounded;

      case 'writing':
        return Icons.edit_note_rounded;

      case 'video':
        return Icons.movie_creation_rounded;

      default:
        return Icons.auto_awesome_rounded;
    }
  }

  void _openCategory(
    BuildContext context, {
    required String category,
    required List<PromptModel> prompts,
    required IconData icon,
    required List<Color> gradient,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPromptsScreen(
          category: category,
          prompts: prompts,
          icon: icon,
          gradient: gradient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = <String>[];

    for (final prompt in dummyPrompts) {
      if (!categoryNames.contains(prompt.category)) {
        categoryNames.add(prompt.category);
      }
    }

    return GridView.builder(
      itemCount: categoryNames.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        final category = categoryNames[index];

        final categoryPrompts = dummyPrompts
            .where((prompt) => prompt.category == category)
            .toList();

        final gradient = _categoryGradients[index % _categoryGradients.length];

        final icon = _categoryIcon(category);

        return _PremiumCategoryCard(
          category: category,
          promptCount: categoryPrompts.length,
          icon: icon,
          gradient: gradient,
          onTap: () {
            _openCategory(
              context,
              category: category,
              prompts: categoryPrompts,
              icon: icon,
              gradient: gradient,
            );
          },
        );
      },
    );
  }
}

class _PremiumCategoryCard extends StatelessWidget {
  const _PremiumCategoryCard({
    required this.category,
    required this.promptCount,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String category;
  final int promptCount;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  top: -35,
                  right: -30,
                  child: Container(
                    width: 115,
                    height: 115,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),

                Positioned(
                  right: -8,
                  bottom: -12,
                  child: Icon(
                    icon,
                    size: 82,
                    color: Colors.white.withValues(alpha: 0.13),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                              ),
                            ),
                            child: Icon(icon, color: Colors.white, size: 22),
                          ),

                          const Spacer(),

                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_outward_rounded,
                              size: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$promptCount ${promptCount == 1 ? 'prompt' : 'prompts'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  Future<void> _copyPrompt(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: prompt.prompt));

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Prompt copied successfully',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
  }

  Future<void> _sharePrompt() async {
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
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2B1F3D).withValues(alpha: 0.08),
              blurRadius: 26,
              offset: const Offset(0, 13),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
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
                                  fontSize: 17,
                                  height: 1.28,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.25,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(13),
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
                        fontSize: 12.5,
                        height: 1.55,
                        color: AppColors.textSecondary,
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
                      color: AppColors.textSecondary.withValues(alpha: 0.10),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PromptActionButton(
                            icon: Icons.copy_all_rounded,
                            label: 'Copy',
                            onTap: () => _copyPrompt(context),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: _PromptActionButton(
                            icon: Icons.ios_share_rounded,
                            label: 'Share',
                            onTap: _sharePrompt,
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
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          height: 43,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
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
    return Container(
      height: 142,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -48,
              right: -28,
              child: Container(
                width: 155,
                height: 155,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -55,
              left: -25,
              child: Container(
                width: 145,
                height: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.09),
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: -8,
              child: Transform.rotate(
                angle: -0.12,
                child: Icon(
                  prompt.icon,
                  size: 105,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  prompt.category.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.65,
                    color: gradient.first,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 14,
              right: 14,
              child: _AnimatedFavoriteButton(promptId: prompt.id),
            ),

            Positioned(
              left: 18,
              bottom: 17,
              child: Row(
                children: [
                  Container(
                    width: 41,
                    height: 41,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(prompt.icon, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    index == 0 ? 'Editor’s Pick' : 'Prompt Adda Choice',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
                        blurRadius: 14,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1FC),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
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
                color: AppColors.primaryDark,
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
