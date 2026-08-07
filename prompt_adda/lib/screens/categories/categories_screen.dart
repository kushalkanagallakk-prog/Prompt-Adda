import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'category_prompts_screen.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      title: 'Image AI',
      subtitle: 'Portraits, posters and visual concepts',
      icon: Icons.image_rounded,
      gradient: [Color(0xFF7547D8), Color(0xFFA776FF)],
    ),
    _CategoryItem(
      title: 'Video AI',
      subtitle: 'Reels, cinematic scenes and video ideas',
      icon: Icons.movie_creation_rounded,
      gradient: [Color(0xFF176B87), Color(0xFF32A5B8)],
    ),
    _CategoryItem(
      title: 'Social Media',
      subtitle: 'Posts, captions and viral content',
      icon: Icons.campaign_rounded,
      gradient: [Color(0xFFC84C74), Color(0xFFEC7C9F)],
    ),
    _CategoryItem(
      title: 'YouTube',
      subtitle: 'Titles, hooks and content planning',
      icon: Icons.play_circle_fill_rounded,
      gradient: [Color(0xFFE45858), Color(0xFFFF8A65)],
    ),
    _CategoryItem(
      title: 'Design',
      subtitle: 'Branding, layouts and creative direction',
      icon: Icons.palette_rounded,
      gradient: [Color(0xFF7E57C2), Color(0xFFBA68C8)],
    ),
    _CategoryItem(
      title: 'Coding',
      subtitle: 'Development, debugging and automation',
      icon: Icons.code_rounded,
      gradient: [Color(0xFF355C7D), Color(0xFF6C8EBF)],
    ),
    _CategoryItem(
      title: 'Writing',
      subtitle: 'Stories, scripts and professional writing',
      icon: Icons.edit_note_rounded,
      gradient: [Color(0xFFB86C21), Color(0xFFE9A444)],
    ),
    _CategoryItem(
      title: 'Marketing',
      subtitle: 'Campaigns, copy and growth ideas',
      icon: Icons.trending_up_rounded,
      gradient: [Color(0xFF2E8B57), Color(0xFF68C98B)],
    ),
    _CategoryItem(
      title: 'Business',
      subtitle: 'Strategy, planning and productivity',
      icon: Icons.business_center_rounded,
      gradient: [Color(0xFF5C6BC0), Color(0xFF7986CB)],
    ),
    _CategoryItem(
      title: 'Career',
      subtitle: 'Resume, interview and job prompts',
      icon: Icons.work_rounded,
      gradient: [Color(0xFF8D6E63), Color(0xFFBCAAA4)],
    ),
    _CategoryItem(
      title: 'Education',
      subtitle: 'Learning, study and teaching prompts',
      icon: Icons.school_rounded,
      gradient: [Color(0xFF00897B), Color(0xFF4DB6AC)],
    ),
    _CategoryItem(
      title: 'Other',
      subtitle: 'More useful AI prompt collections',
      icon: Icons.auto_awesome_rounded,
      gradient: [Color(0xFF607D8B), Color(0xFF90A4AE)],
    ),
  ];

  void _openCategory(
    BuildContext context,
    _CategoryItem category,
    List<PromptModel> prompts,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPromptsScreen(
          category: category.title,
          prompts: prompts,
          icon: category.icon,
          gradient: category.gradient,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF100D16),
                    Color(0xFF15111C),
                    Color(0xFF0D0B12),
                  ],
                )
              : AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: StreamBuilder<List<PromptModel>>(
            stream: PromptService.watchAll(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Unable to load categories.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final allPrompts = snapshot.data ?? <PromptModel>[];

              final categoryEntries =
                  _categories
                      .map((category) {
                        final categoryPrompts = allPrompts.where((prompt) {
                          return prompt.category.trim().toLowerCase() ==
                              category.title.trim().toLowerCase();
                        }).toList();

                        categoryPrompts.sort((first, second) {
                          final firstDate =
                              first.createdAt ??
                              DateTime.fromMillisecondsSinceEpoch(0);
                          final secondDate =
                              second.createdAt ??
                              DateTime.fromMillisecondsSinceEpoch(0);

                          return secondDate.compareTo(firstDate);
                        });

                        return _CategoryEntry(
                          category: category,
                          prompts: categoryPrompts,
                        );
                      })
                      .where((entry) => entry.prompts.isNotEmpty)
                      .toList()
                    ..sort(
                      (first, second) =>
                          second.prompts.length.compareTo(first.prompts.length),
                    );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 125),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: isDark
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${categoryEntries.length} categories available',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (categoryEntries.isEmpty)
                      _buildEmptyState(context)
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryEntries.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.92,
                            ),
                        itemBuilder: (context, index) {
                          final entry = categoryEntries[index];
                          final category = entry.category;
                          final promptCount = entry.prompts.length;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                _openCategory(context, category, entry.prompts);
                              },
                              borderRadius: BorderRadius.circular(24),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1B1821)
                                      : Colors.white.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: isDark
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.035,
                                            ),
                                            blurRadius: 22,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: category.gradient,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Icon(
                                          category.icon,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        category.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '$promptCount '
                                        '${promptCount == 1 ? 'prompt' : 'prompts'}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: category.gradient.first,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        category.subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11.5,
                                          height: 1.4,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 19,
                                          color: category.gradient.first,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B1821)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.grid_view_rounded,
            size: 46,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Categories will appear after prompts are published.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              height: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
}

class _CategoryEntry {
  const _CategoryEntry({required this.category, required this.prompts});

  final _CategoryItem category;
  final List<PromptModel> prompts;
}
