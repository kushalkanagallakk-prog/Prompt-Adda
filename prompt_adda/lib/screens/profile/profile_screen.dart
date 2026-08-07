import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/prompt_model.dart';
import '../../services/prompt_service.dart';
import '../../services/favorites_service.dart';
import '../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../admin/admin_login_screen.dart';
import '../../services/theme_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _adminTapCount = 0;
  DateTime? _lastAdminTap;
  Future<void> _shareApp() async {
    await SharePlus.instance.share(
      ShareParams(
        text: '''
🚀 Check out Prompt Adda!

Discover powerful AI prompts for ChatGPT, Gemini, Claude and more.

Download:
https://play.google.com/store/apps/details?id=com.example.prompt_adda
''',
      ),
    );
  }

  Future<void> _rateApp() async {
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.example.prompt_adda',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _contactUs() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _ContactUsSheet();
      },
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _PrivacyPolicyScreen()),
    );
  }

  void _openAbout() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _AboutPromptAddaSheet();
      },
    );
  }

  void _handleAdminTap() {
    final now = DateTime.now();

    if (_lastAdminTap == null ||
        now.difference(_lastAdminTap!) > const Duration(seconds: 3)) {
      _adminTapCount = 0;
    }

    _lastAdminTap = now;
    _adminTapCount++;

    if (_adminTapCount < 7) return;

    _adminTapCount = 0;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
    );
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 22),
                _buildProfileHeader(),
                const SizedBox(height: 32),
                Text(
                  'Your Stats',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                StreamBuilder<List<PromptModel>>(
                  stream: PromptService.watchAll(),
                  builder: (context, snapshot) {
                    final totalPrompts = snapshot.data?.length ?? 0;

                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: FavoritesService.favoriteIdsNotifier,
                      builder: (context, favoriteIds, child) {
                        return Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.auto_awesome_rounded,
                                title: totalPrompts.toString(),
                                subtitle: 'Total Prompts',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.favorite_rounded,
                                title: favoriteIds.length.toString(),
                                subtitle: 'Favorites',
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'General',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _SettingsCard(
                  onShareApp: _shareApp,
                  onRateApp: _rateApp,
                  onPrivacyPolicy: _openPrivacyPolicy,
                  onContactUs: _contactUs,
                  onAbout: _openAbout,
                ),
                const SizedBox(height: 28),

                Text(
                  'Appearance',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                const _AppearanceCard(),

                const SizedBox(height: 28),

                Center(
                  child: Column(
                    children: [
                      Text(
                        'Prompt Adda',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleAdminTap,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          child: Text(
                            'Version 0.6.0',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Crafted with ❤️ in India',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.textSecondary,
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

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF211D28)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.primary.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Prompt Adda',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Discover, save and use powerful AI prompts.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF221E2A)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.24
                  : 0.035,
            ),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 29,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.onShareApp,
    required this.onRateApp,
    required this.onPrivacyPolicy,
    required this.onContactUs,
    required this.onAbout,
  });

  final VoidCallback onShareApp;
  final VoidCallback onRateApp;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onContactUs;
  final VoidCallback onAbout;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF211D28)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? 0.24
                  : 0.035,
            ),
            blurRadius: 24,
            offset: const Offset(0, 11),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.share_rounded,
            title: 'Share App',
            onTap: onShareApp,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.star_rounded,
            title: 'Rate App',
            onTap: onRateApp,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            title: 'Privacy Policy',
            onTap: onPrivacyPolicy,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.mail_rounded,
            title: 'Contact Us',
            onTap: onContactUs,
          ),
          const _SettingsDivider(),
          _SettingsTile(
            icon: Icons.info_rounded,
            title: 'About Prompt Adda',
            onTap: onAbout,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title, this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, color: AppColors.primary, size: 21),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextPrimary
              : AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 15,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: AppColors.textSecondary.withValues(alpha: 0.10),
      ),
    );
  }
}

class _PrivacyPolicyScreen extends StatelessWidget {
  const _PrivacyPolicyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 20, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A171F)
                          : Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(24),
                      border: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.30)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PolicySection(
                          title: 'Introduction',
                          content:
                              'Prompt Adda provides curated AI prompts for educational, creative, and productivity purposes. This policy explains how the app handles user information.',
                        ),
                        _PolicySection(
                          title: 'Information We Collect',
                          content:
                              'Prompt Adda does not directly collect personal information such as your name, phone number, address, or passwords. Favorites and app preferences may be stored locally on your device.',
                        ),
                        _PolicySection(
                          title: 'Firebase Services',
                          content:
                              'The app uses Firebase Firestore to load prompt content. Firebase may process limited technical information required to deliver the service securely and reliably.',
                        ),
                        _PolicySection(
                          title: 'Third-Party Services',
                          content:
                              'The app may use third-party services such as Firebase, Google Play services, analytics, or advertising services in future versions. These services may operate under their own privacy policies.',
                        ),
                        _PolicySection(
                          title: 'Data Security',
                          content:
                              'Reasonable technical measures are used to protect app content and related services. However, no internet-based service can guarantee complete security.',
                        ),
                        _PolicySection(
                          title: 'Children’s Privacy',
                          content:
                              'Prompt Adda is not intended to knowingly collect personal data from children. Parents or guardians may contact us regarding any concerns.',
                        ),
                        _PolicySection(
                          title: 'Policy Updates',
                          content:
                              'This privacy policy may be updated when app features or third-party services change. The latest version will be available inside the app.',
                        ),
                        const _PolicySection(
                          title: 'Contact',
                          content:
                              'For privacy-related questions, contact us at promptadda.app@gmail.com.',
                          showDivider: false,
                        ),
                      ],
                    ),
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

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeModeNotifier,
      builder: (context, selectedMode, child) {
        return Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF221E2A)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.24
                      : 0.035,
                ),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _ThemeModeButton(
                  label: 'System',
                  icon: Icons.settings_suggest_rounded,
                  mode: ThemeMode.system,
                  selectedMode: selectedMode,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ThemeModeButton(
                  label: 'Light',
                  icon: Icons.light_mode_rounded,
                  mode: ThemeMode.light,
                  selectedMode: selectedMode,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _ThemeModeButton(
                  label: 'Dark',
                  icon: Icons.dark_mode_rounded,
                  mode: ThemeMode.dark,
                  selectedMode: selectedMode,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton({
    required this.label,
    required this.icon,
    required this.mode,
    required this.selectedMode,
  });

  final String label;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode selectedMode;

  @override
  Widget build(BuildContext context) {
    final selected = mode == selectedMode;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ThemeService.setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutQuart,
        height: 58,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.primaryGradient : null,
          color: selected
              ? null
              : Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.34),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 19,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({
    required this.title,
    required this.content,
    this.showDivider = true,
  });

  final String title;
  final String content;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 13,
            height: 1.65,
            color: AppColors.textSecondary,
          ),
        ),
        if (showDivider) ...[
          const SizedBox(height: 18),
          Divider(color: AppColors.textSecondary.withValues(alpha: 0.12)),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _AboutPromptAddaSheet extends StatelessWidget {
  const _AboutPromptAddaSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF141218)
              : const Color(0xFFF9F7FF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Prompt Adda',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Version 0.6.0',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Discover powerful AI prompts for creativity, productivity, coding, social media, design, writing, and more.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF1A171F)
                    : Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(18),
                border: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Border.all(color: AppColors.divider),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.30)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Crafted with ❤️ in India',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '© 2026 Prompt Adda',
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactUsSheet extends StatelessWidget {
  const _ContactUsSheet();

  static const String _email = 'promptadda.app@gmail.com';
  static const String _instagramUrl = 'https://www.instagram.com/prompt__adda/';

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _email));

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openGmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {'subject': 'Prompt Adda Support'},
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No email app found')));
    }
  }

  Future<void> _openInstagram(BuildContext context) async {
    final uri = Uri.parse(_instagramUrl);

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open Instagram')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF141218)
              : const Color(0xFFF9F7FF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Contact Us',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We are happy to help you',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.mail_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _email,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '@prompt__adda',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copyEmail(context),
                icon: const Icon(Icons.copy_rounded),
                label: Text(
                  'Copy Email',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openGmail(context),
                icon: const Icon(Icons.mail_outline_rounded),
                label: Text(
                  'Open Gmail',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openInstagram(context),
                icon: const Icon(Icons.camera_alt_rounded),
                label: Text(
                  'Open Instagram',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
