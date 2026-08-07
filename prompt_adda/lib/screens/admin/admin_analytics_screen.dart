import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'Prompt Analytics',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<List<PromptModel>>(
        stream: PromptService.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load analytics.',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }

          final prompts = snapshot.data ?? <PromptModel>[];

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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.25,
                children: [
                  _AnalyticsSummaryCard(
                    title: 'Total Views',
                    value: totalViews,
                    icon: Icons.visibility_rounded,
                  ),
                  _AnalyticsSummaryCard(
                    title: 'Total Copies',
                    value: totalCopies,
                    icon: Icons.copy_rounded,
                  ),
                  _AnalyticsSummaryCard(
                    title: 'Total Shares',
                    value: totalShares,
                    icon: Icons.share_rounded,
                  ),
                  _AnalyticsSummaryCard(
                    title: 'Total Favorites',
                    value: totalFavorites,
                    icon: Icons.favorite_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Top Performing Prompts',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              if (topPrompts.isEmpty)
                _buildEmptyState()
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'No analytics data available yet.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(color: AppColors.textSecondary),
      ),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E3F8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          Text(
            _formatCount(value),
            style: GoogleFonts.poppins(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
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

class _TopPromptCard extends StatelessWidget {
  const _TopPromptCard({required this.prompt});

  final PromptModel prompt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9E3F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prompt.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            prompt.category,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.visibility_rounded,
                value: prompt.viewCount,
              ),
              _MetricChip(icon: Icons.copy_rounded, value: prompt.copyCount),
              _MetricChip(icon: Icons.share_rounded, value: prompt.shareCount),
              _MetricChip(
                icon: Icons.favorite_rounded,
                value: prompt.favoriteCount,
              ),
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
