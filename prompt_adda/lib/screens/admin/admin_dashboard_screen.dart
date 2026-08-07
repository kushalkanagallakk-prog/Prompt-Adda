import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../services/admin_auth_service.dart';
import 'prompt_editor_screen.dart';
import 'manage_prompts_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AdminAuthService.signOut();

    if (!context.mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text('$feature coming next'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final adminEmail = AdminAuthService.currentEmail ?? 'Admin';

    final actions = <_AdminAction>[
      _AdminAction(
        title: 'Add Prompt',
        subtitle: 'Create a new prompt',
        icon: Icons.add_circle_rounded,
        onTap: () => _openAddPrompt(context),
      ),
      _AdminAction(
        title: 'Manage Prompts',
        subtitle: 'Edit or delete prompts',
        icon: Icons.edit_note_rounded,
        onTap: () => _openManagePrompts(context),
      ),
      _AdminAction(
        title: 'Notifications',
        subtitle: 'Send updates to users',
        icon: Icons.notifications_active_rounded,
        onTap: () => _showComingSoon(context, 'Notifications'),
      ),
      _AdminAction(
        title: 'Categories',
        subtitle: 'Manage prompt categories',
        icon: Icons.grid_view_rounded,
        onTap: () => _showComingSoon(context, 'Categories'),
      ),
      _AdminAction(
        title: 'Analytics',
        subtitle: 'View app activity',
        icon: Icons.insights_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.24),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prompt Adda Admin',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              adminEmail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: () => _logout(context),
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: _AdminSummaryCard(
                    title: 'Admin Control Center',
                    subtitle:
                        'Manage prompts, images, premium access and notifications.',
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final action = actions[index];

                    return _AdminActionCard(action: action);
                  }, childCount: actions.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.02,
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

void _openAddPrompt(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const PromptEditorScreen()),
  );
}

class _AdminSummaryCard extends StatelessWidget {
  const _AdminSummaryCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -20,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 115,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.shield_rounded, color: Colors.white, size: 30),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openManagePrompts(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ManagePromptsScreen()),
  );
}

class _AdminActionCard extends StatelessWidget {
  const _AdminActionCard({required this.action});

  final _AdminAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(action.icon, color: AppColors.primary, size: 25),
              ),
              const Spacer(),
              Text(
                action.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminAction {
  const _AdminAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}
