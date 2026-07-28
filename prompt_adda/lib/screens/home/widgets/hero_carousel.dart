import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/prompt_model.dart';
import '../../prompt/prompt_details_screen.dart';

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key, required this.prompts});

  final List<PromptModel> prompts;

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;

  Timer? _autoScrollTimer;
  int _currentPage = 0;

  static const List<String> _featuredImages = [
    'assets/images/featured/featured_social.jpg',
    'assets/images/featured/featured_image_ai.jpg',
    'assets/images/featured/featured_coding.jpg',
    'assets/images/featured/featured_writing.jpg',
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(viewportFraction: 0.92);

    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant HeroCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.prompts.length != widget.prompts.length) {
      _currentPage = 0;

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }

      _restartAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    if (widget.prompts.length <= 1) {
      return;
    }

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % widget.prompts.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _restartAutoScroll() {
    _pauseAutoScroll();
    _startAutoScroll();
  }

  void _openPrompt(PromptModel prompt) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PromptDetailsScreen(prompt: prompt)),
    );
  }

  String _getImagePath(int index) {
    return _featuredImages[index % _featuredImages.length];
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prompts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Featured for you',
              style: GoogleFonts.poppins(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: const Color(0xFF241B35),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0E8FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: Color(0xFF7042D8),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Top picks',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7042D8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: Listener(
            onPointerDown: (_) => _pauseAutoScroll(),
            onPointerUp: (_) => _restartAutoScroll(),
            onPointerCancel: (_) => _restartAutoScroll(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.prompts.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final prompt = widget.prompts[index];

                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double pageValue = _currentPage.toDouble();

                    if (_pageController.hasClients &&
                        _pageController.position.haveDimensions) {
                      pageValue =
                          _pageController.page ?? _currentPage.toDouble();
                    }

                    final distance = (pageValue - index).abs();
                    final scale = (1 - (distance * 0.045)).clamp(0.94, 1.0);
                    final verticalOffset = (distance * 10).clamp(0.0, 10.0);

                    return Transform.translate(
                      offset: Offset(0, verticalOffset),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.center,
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == widget.prompts.length - 1 ? 0 : 12,
                    ),
                    child: _HeroPromptCard(
                      prompt: prompt,
                      imagePath: _getImagePath(index),
                      position: index + 1,
                      totalCount: widget.prompts.length,
                      onTap: () => _openPrompt(prompt),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 17),
        _CarouselIndicator(
          count: widget.prompts.length,
          currentIndex: _currentPage,
        ),
      ],
    );
  }
}

class _HeroPromptCard extends StatelessWidget {
  const _HeroPromptCard({
    required this.prompt,
    required this.imagePath,
    required this.position,
    required this.totalCount,
    required this.onTap,
  });

  final PromptModel prompt;
  final String imagePath;
  final int position;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF291F3B).withValues(alpha: 0.20),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF7042D8).withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _FeaturedImageFallback(icon: prompt.icon);
                  },
                ),

                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 0.28, 0.58, 0.78, 1.0],
                      colors: [
                        Color(0x12000000),
                        Color(0x18000000),
                        Color(0x66000000),
                        Color(0xC9000000),
                        Color(0xF5000000),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 18,
                  left: 18,
                  right: 18,
                  child: Row(
                    children: [
                      _GlassBadge(
                        icon: Icons.auto_awesome_rounded,
                        label: prompt.category.toUpperCase(),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.26),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          '$position / $totalCount',
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 21,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prompt.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          height: 1.14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              color: Color(0x88000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        prompt.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Explore Prompt',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF5F35C8),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 17,
                                  color: Color(0xFF5F35C8),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.26),
                              ),
                            ),
                            child: Icon(
                              prompt.icon,
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
}

class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF7042D8)),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 145),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.65,
                color: const Color(0xFF5F35C8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  const _CarouselIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE8E0F3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            final isSelected = index == currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: isSelected ? 25 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF7042D8), Color(0xFFA65DE2)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFFD9D1E8),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FeaturedImageFallback extends StatelessWidget {
  const _FeaturedImageFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F153B),
            Color(0xFF5F35C8),
            Color(0xFFA65DE2),
            Color(0xFFE96E9E),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -55,
            right: -35,
            child: Container(
              width: 205,
              height: 205,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD8EC).withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            bottom: -70,
            left: 45,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Center(
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: 118,
                height: 118,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(34),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 62,
                  color: Colors.white.withValues(alpha: 0.32),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
