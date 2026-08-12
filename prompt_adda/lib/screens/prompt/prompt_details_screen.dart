import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/prompt_model.dart';
import '../../services/favorites_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/prompt_service.dart';
import '../../widgets/discussion_section.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PromptDetailsScreen extends StatefulWidget {
  final PromptModel prompt;
  final String? heroTag;

  const PromptDetailsScreen({super.key, required this.prompt, this.heroTag});

  @override
  State<PromptDetailsScreen> createState() => _PromptDetailsScreenState();
}

class _BottomCompactAction extends StatelessWidget {
  const _BottomCompactAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.accentColor = const Color(0xFF7C4DFF),
    this.lightBackground = const Color(0xFFF1E8FF),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentColor;
  final Color lightBackground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? Colors.white.withValues(alpha: 0.06) : lightBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 68,
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: isDark
                    ? accentColor.withValues(alpha: 0.95)
                    : accentColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface
                      : accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromptDetailsScreenState extends State<PromptDetailsScreen> {
  bool _isFavorite = false;
  bool _isFavoriteLoading = true;
  int _currentImageIndex = 0;

  final ImagePicker _imagePicker = ImagePicker();

  PromptModel get prompt => widget.prompt;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    PromptService.incrementViewCount(prompt.id);
  }

  Future<void> _loadFavoriteStatus() async {
    final isFavorite = await FavoritesService.isFavorite(prompt.id);

    if (!mounted) return;

    setState(() {
      _isFavorite = isFavorite;
      _isFavoriteLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
  if (_isFavoriteLoading) return;

  if (FirebaseAuth.instance.currentUser == null) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Sign in with Google to save favorites.'),
        ),
      );

    return;
  }

  setState(() {
    _isFavoriteLoading = true;
  });

  final isFavorite = await FavoritesService.toggleFavorite(prompt.id);

  if (!mounted) return;

  setState(() {
    _isFavorite = isFavorite;
    _isFavoriteLoading = false;
  });

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          children: [
            Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              isFavorite
                  ? 'Added to favorites!'
                  : 'Removed from favorites',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
}

  Future<void> _copyPrompt(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: prompt.prompt));

    await PromptService.incrementCopyCount(prompt.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                'Prompt copied successfully!',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _sharePrompt() async {
    const playStoreLink =
        'https://play.google.com/store/apps/details?id=com.promptadda.app';

    await SharePlus.instance.share(
      ShareParams(
        text:
            '''
✨ ${prompt.title}

${prompt.description}

Prompt:

${prompt.prompt}

📲 Download Prompt Adda:
$playStoreLink
''',
      ),
    );

    await PromptService.incrementShareCount(prompt.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 130),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (prompt.imageUrls.isNotEmpty) ...[
                      _buildImageGallery(),
                      const SizedBox(height: 22),
                    ],
                    _buildDescriptionCard(),
                    const SizedBox(height: 22),
                    _buildPromptSection(),
                    const SizedBox(height: 30),
                    DiscussionSection(promptId: prompt.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Future<void> _useInChatGpt() async {
    await Clipboard.setData(ClipboardData(text: prompt.prompt));

    if (!mounted) return;

    await SharePlus.instance.share(
      ShareParams(text: prompt.prompt, subject: prompt.title),
    );
  }

  Widget _buildImageGallery() {
    final images = prompt.imageUrls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  physics: const PageScrollPhysics(),
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final imageWidget = CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(
                          color: const Color(0xFFF0EBFA),
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          color: const Color(0xFFF0EBFA),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            size: 48,
                            color: Color(0xFF8C79B8),
                          ),
                        );
                      },
                    );

                    if (index == 0 && widget.heroTag != null) {
                      return Hero(
                        tag: widget.heroTag!,
                        child: Material(
                          color: Colors.transparent,
                          child: imageWidget,
                        ),
                      );
                    }

                    return imageWidget;
                  },
                ),
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.35, 0.65, 1.0],
                        colors: [
                          Color(0x00000000),
                          Color(0x10000000),
                          Color(0x55000000),
                          Color(0xAA000000),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${_currentImageIndex + 1} / ${images.length}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (images.length > 1) ...[
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : Border.all(
                        color: const Color(0xFFE8E0F3).withValues(alpha: 0.65),
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(images.length, (index) {
                  final isActive = index == _currentImageIndex;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutQuart,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 22 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFF7042D8), Color(0xFFA65DE2)],
                            )
                          : null,
                      color: isActive
                          ? null
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.20)
                          : const Color(0xFFD8CEF0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showSelfieGuide() async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.camera_front_rounded,
                  size: 42,
                  color: Color(0xFF7C4DFF),
                ),
                const SizedBox(height: 16),
                Text(
                  'Selfie Reference',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Match the face angle in the prompt. A clear face is enough.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _takeSelfieAndCreate();
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _takeSelfieAndCreate() async {
    try {
      final XFile? selfie = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 90,
        maxWidth: 1600,
      );

      if (selfie == null) return;

      final fullPrompt =
          '''
Use the attached selfie as the identity reference.

Preserve the person's recognizable facial identity while matching the face angle, expression, pose, outfit, lighting, background, and composition described below.

${prompt.prompt}
''';

      await Clipboard.setData(ClipboardData(text: fullPrompt));

      final temporaryDirectory = await getTemporaryDirectory();

      final safePromptId = prompt.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      final promptFile = File(
        '${temporaryDirectory.path}/prompt_$safePromptId.txt',
      );

      await promptFile.writeAsString(fullPrompt, flush: true);

      if (!mounted) return;

      await SharePlus.instance.share(
        ShareParams(
          subject: prompt.title,
          text: 'Selfie and AI image prompt attached.',
          files: [
            XFile(selfie.path),
            XFile(
              promptFile.path,
              mimeType: 'text/plain',
              name: 'Prompt Adda - ${prompt.title}.txt',
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Text(
              'Unable to prepare the selfie and prompt.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        );
    }
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? const Color(0xFF18151E)
        : Colors.white.withValues(alpha: 0.94);

    Widget actionButton({
      required IconData icon,
      required VoidCallback onTap,
      Key? key,
    }) {
      return Material(
        key: key,
        color: surfaceColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(
              icon,
              size: 21,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              actionButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              actionButton(
                key: ValueKey(_isFavorite),
                icon: _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: _toggleFavorite,
              ),
              const SizedBox(width: 10),
              actionButton(icon: Icons.share_rounded, onTap: _sharePrompt),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF1E8FF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              prompt.category.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: isDark
                    ? const Color(0xFFD6BEFF)
                    : const Color(0xFF7042D8),
                fontSize: 10,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            prompt.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 26,
              height: 1.18,
              letterSpacing: -0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF18151E)
            : Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: isDark ? null : Border.all(color: const Color(0xFFE9E3F8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.045),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFFB45CFF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About this prompt',
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prompt.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    height: 1.65,
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

  Widget _buildPromptSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1E8FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.notes_rounded,
                size: 18,
                color: Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'PROMPT',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Material(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF4EEFF),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _copyPrompt(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: isDark
                        ? const Color(0xFFD6BEFF)
                        : const Color(0xFF7042D8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF18151E)
                : Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: isDark ? null : Border.all(color: const Color(0xFFE7DFFF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.045),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: SelectableText(
            prompt.prompt,
            style: GoogleFonts.poppins(
              fontSize: 14.5,
              height: 1.75,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${prompt.prompt.length} characters',
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF17131F)
              : Colors.white.withValues(alpha: 0.98),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.07),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            _BottomCompactAction(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () => _copyPrompt(context),
              isDark: isDark,
            ),
            const SizedBox(width: 10),
            _BottomCompactAction(
              icon: Icons.camera_front_rounded,
              label: 'Selfie',
              onTap: _showSelfieGuide,
              isDark: isDark,
              accentColor: const Color(0xFFD63384),
              lightBackground: const Color(0xFFFFEEF7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _useInChatGpt,
                  icon: const Icon(Icons.smart_toy_rounded, size: 20),
                  label: Text(
                    'Use in ChatGPT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF7C4DFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
