import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/app_user_model.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';
import '../../services/user_tracking_service.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.surface
          : const Color(0xFFF7F5FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: Text(
          'Live Analytics',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<PromptModel>>(
        stream: PromptService.watchAll(),
        builder: (context, promptSnapshot) {
          if (promptSnapshot.connectionState == ConnectionState.waiting &&
              !promptSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (promptSnapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load prompt analytics.',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final prompts = promptSnapshot.data ?? <PromptModel>[];

          return StreamBuilder<List<AppUserModel>>(
            stream: UserTrackingService.watchUsers(),
            builder: (context, userSnapshot) {
              final users = userSnapshot.data ?? <AppUserModel>[];

              final totalViews = prompts.fold<int>(
                0,
                (total, prompt) => total + prompt.viewCount,
              );

              final totalCopies = prompts.fold<int>(
                0,
                (total, prompt) => total + prompt.copyCount,
              );

              final totalShares = prompts.fold<int>(
                0,
                (total, prompt) => total + prompt.shareCount,
              );

              final totalFavorites = prompts.fold<int>(
                0,
                (total, prompt) => total + prompt.favoriteCount,
              );

              final topPrompts = List<PromptModel>.from(prompts)
                ..sort((first, second) {
                  final firstScore =
                      first.viewCount +
                      first.copyCount +
                      first.shareCount +
                      first.favoriteCount;

                  final secondScore =
                      second.viewCount +
                      second.copyCount +
                      second.shareCount +
                      second.favoriteCount;

                  return secondScore.compareTo(firstScore);
                });

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF35C76F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Live Firestore data',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.60),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.28,
                    children: [
                      _AnalyticsSummaryCard(
                        title: 'Total Views',
                        value: totalViews,
                        icon: Icons.visibility_rounded,
                      ),
                      _AnalyticsSummaryCard(
                        title: 'Favorites',
                        value: totalFavorites,
                        icon: Icons.favorite_rounded,
                      ),
                      _AnalyticsSummaryCard(
                        title: 'Total Shares',
                        value: totalShares,
                        icon: Icons.share_rounded,
                      ),
                      _AnalyticsSummaryCard(
                        title: 'Total Copies',
                        value: totalCopies,
                        icon: Icons.copy_rounded,
                      ),
                      _AnalyticsSummaryCard(
                        title: 'Signed-in Users',
                        value: users.length,
                        icon: Icons.people_alt_rounded,
                      ),
                      _AnalyticsSummaryCard(
                        title: 'Total Prompts',
                        value: prompts.length,
                        icon: Icons.auto_awesome_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  _SectionTitle(
                    icon: Icons.people_alt_rounded,
                    title: 'Signed-in Users',
                    subtitle: '${users.length} registered app users',
                  ),

                  const SizedBox(height: 14),

                  if (userSnapshot.hasError)
                    _InfoCard(
                      message:
                          'Unable to load user activity. Check Firestore rules.',
                    )
                  else if (userSnapshot.connectionState ==
                          ConnectionState.waiting &&
                      !userSnapshot.hasData)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (users.isEmpty)
                    const _InfoCard(
                      message:
                          'No tracked sign-ins yet. Users will appear here after opening or signing into the updated app.',
                    )
                  else
                    ...users
                        .take(50)
                        .map(
                          (user) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _UserActivityCard(user: user),
                          ),
                        ),

                  const SizedBox(height: 28),

                  const _SectionTitle(
                    icon: Icons.trending_up_rounded,
                    title: 'Top Performing Prompts',
                    subtitle: 'Based on views, copies, shares and favorites',
                  ),

                  const SizedBox(height: 14),

                  if (topPrompts.isEmpty)
                    const _InfoCard(message: 'No analytics data available yet.')
                  else
                    ...topPrompts
                        .take(10)
                        .map(
                          (prompt) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _TopPromptCard(prompt: prompt),
                          ),
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E7FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsSummaryCard extends StatelessWidget {
  const _AnalyticsSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.055) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE9E3F8),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary, size: 21),
          ),
          Text(
            _formatCount(value),
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10.8,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.60),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}

class _UserActivityCard extends StatelessWidget {
  const _UserActivityCard({required this.user});

  final AppUserModel user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = user.displayName.trim().isNotEmpty
        ? user.displayName.trim()
        : 'Prompt Adda User';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.045) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE9E3F8),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: const Color(0xFFEDE5FF),
            backgroundImage: user.photoUrl.trim().isNotEmpty
                ? NetworkImage(user.photoUrl)
                : null,
            child: user.photoUrl.trim().isEmpty
                ? Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (user.email.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.8,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                const SizedBox(height: 5),
                Text(
                  'Last sign-in: ${_formatDate(user.lastSignInAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 9.8,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.46),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.verified_user_rounded,
            size: 18,
            color: Color(0xFF35A965),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Unknown';
    }

    final difference = DateTime.now().difference(dateTime);

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }
}

class _TopPromptCard extends StatelessWidget {
  const _TopPromptCard({required this.prompt});

  final PromptModel prompt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.045) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : const Color(0xFFE9E3F8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prompt.category,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.visibility_rounded,
                value: prompt.viewCount,
              ),
              _MetricChip(
                icon: Icons.favorite_rounded,
                value: prompt.favoriteCount,
              ),
              _MetricChip(icon: Icons.share_rounded, value: prompt.shareCount),
              _MetricChip(icon: Icons.copy_rounded, value: prompt.copyCount),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.value});

  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Text(
            value.toString(),
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
      ),
    );
  }
}
