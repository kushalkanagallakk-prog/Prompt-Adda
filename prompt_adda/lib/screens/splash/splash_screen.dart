import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _waveController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _introController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: Curves.easeOutCubic,
      ),
    );

    _introController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 650),
          pageBuilder: (_, animation, secondaryAnimation) {
            return const MainScreen();
          },
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _introController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: _PremiumGradientBackground(),
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _AnimatedWavePainter(
                    progress: _waveController.value,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: const _PromptAddaLogo(),
                      ),
                      const SizedBox(height: 30),
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.5,
                          ),
                          children: const [
                            TextSpan(
                              text: 'Prompt ',
                              style: TextStyle(
                                color: Color(0xFF171728),
                              ),
                            ),
                            TextSpan(
                              text: 'Adda',
                              style: TextStyle(
                                color: Color(0xFF7547D8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Create Better with AI',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF646475),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const _AccentDivider(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumGradientBackground extends StatelessWidget {
  const _PremiumGradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2E9FF),
            Color(0xFFFFFAF8),
            Color(0xFFF8F1FF),
            Color(0xFFFFEDE8),
          ],
          stops: [0, 0.38, 0.7, 1],
        ),
      ),
    );
  }
}

class _PromptAddaLogo extends StatelessWidget {
  const _PromptAddaLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFA776FF),
            Color(0xFF7441D7),
            Color(0xFF4B249A),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x407743D8),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'PA',
              style: GoogleFonts.poppins(
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -5,
              ),
            ),
          ),
          const Positioned(
            top: 18,
            right: 18,
            child: Icon(
              Icons.auto_awesome,
              size: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentDivider extends StatelessWidget {
  const _AccentDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 70,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Color(0xFF9D76E8),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.auto_awesome,
            size: 16,
            color: Color(0xFF8B5DE0),
          ),
        ),
        Container(
          width: 70,
          height: 1.5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF9D76E8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedWavePainter extends CustomPainter {
  const _AnimatedWavePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final firstPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x22FF8EA8),
          Color(0x337C4DFF),
          Color(0x228E7CFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      );

    final secondPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x18FFFFFF),
          Color(0x337B4DE2),
          Color(0x22E483D4),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      );

    final phase = progress * math.pi * 2;

    final firstWave = Path()
      ..moveTo(0, size.height * 0.76)
      ..cubicTo(
        size.width * 0.22,
        size.height * (0.68 + 0.025 * math.sin(phase)),
        size.width * 0.48,
        size.height * (0.83 + 0.02 * math.cos(phase)),
        size.width * 0.72,
        size.height * (0.71 + 0.025 * math.sin(phase)),
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.64,
        size.width,
        size.height * 0.7,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final secondWave = Path()
      ..moveTo(0, size.height * 0.84)
      ..cubicTo(
        size.width * 0.2,
        size.height * (0.93 + 0.015 * math.cos(phase)),
        size.width * 0.5,
        size.height * (0.75 + 0.02 * math.sin(phase)),
        size.width * 0.76,
        size.height * (0.83 + 0.02 * math.cos(phase)),
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.87,
        size.width,
        size.height * 0.81,
        size.width,
        size.height * 0.81,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(firstWave, firstPaint);
    canvas.drawPath(secondWave, secondPaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}