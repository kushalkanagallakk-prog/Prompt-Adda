import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/prompt_model.dart';
import '../services/favorites_service.dart';
import 'premium_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.prompt,
    required this.onTap,
    this.gradient = const [Color(0xFF9A5AF5), Color(0xFF5B2ACD)],
    this.footerLabel = 'View Prompt',
    this.footerIcon = Icons.arrow_forward_rounded,
    this.showFavorite = true,
    this.showPremiumBadge = true,
    this.showCategory = true,
    this.enableHero = true,
  });

  final PromptModel prompt;
  final VoidCallback onTap;
  final List<Color> gradient;

  final String footerLabel;
  final IconData footerIcon;

  final bool showFavorite;
  final bool showPremiumBadge;
  final bool showCategory;
  final bool enableHero;

  @override
  Widget build(BuildContext context) {
    final coverImage = prompt.coverImage;
    final imageCount = prompt.imageUrls.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageWidget = coverImage != null
        ? CachedNetworkImage(
            imageUrl: coverImage,
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return _buildLoadingPlaceholder();
            },
            errorWidget: (context, url, error) {
              return _buildImageFallback();
            },
          )
        : _buildImageFallback();

    final displayedImage = enableHero
        ? Hero(
            tag: 'prompt-image-${prompt.id}',
            child: Material(color: Colors.transparent, child: imageWidget),
          )
        : imageWidget;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1D1D23)
                : Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(26),
            border: isDark
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.03),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      displayedImage,

                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x14000000),
                              Color(0x00000000),
                              Color(0xA8000000),
                            ],
                            stops: [0, 0.58, 1],
                          ),
                        ),
                      ),

                      if (showCategory)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: _buildCategoryBadge(context),
                        ),

                      if (showFavorite)
                        Positioned(
                          top: 14,
                          right: 14,
                          child: _buildFavoriteButton(context),
                        ),

                      if (showPremiumBadge && prompt.isPremium)
                        const Positioned(
                          left: 16,
                          bottom: 16,
                          child: PremiumBadge(),
                        ),

                      if (imageCount > 1)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _buildImageCount(imageCount),
                        ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 17, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          height: 1.28,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (prompt.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          prompt.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: _buildFooterChip(context)),
                          const SizedBox(width: 12),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradient,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              footerIcon,
                              color: Colors.white,
                              size: 21,
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
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.55)
            : Colors.white.withValues(alpha: 0.93),
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
          letterSpacing: 0.55,
          color: isDark ? Colors.white : gradient.first,
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: FavoritesService.favoriteIdsNotifier,
      builder: (context, favoriteIds, child) {
        final isFavorite = favoriteIds.contains(prompt.id);

        return Material(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.92),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () async {
              await FavoritesService.toggleFavorite(prompt.id);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isDark ? Colors.white : gradient.first,
                size: 22,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageCount(int imageCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_rounded,
            color: Colors.white,
            size: 15,
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
    );
  }

  Widget _buildFooterChip(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : gradient.first.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(prompt.icon, size: 15, color: gradient.first),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              footerLabel.isEmpty ? prompt.category : footerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: gradient.first,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
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
  }

  Widget _buildImageFallback() {
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
