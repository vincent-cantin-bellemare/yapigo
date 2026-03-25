import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:yapigo/main.dart';

/// OPTION B — "Ripple Drop"
/// The logo PNG fades in with a scale bounce, then concentric ripple rings
/// emanate outward from behind it. The tagline slides up last.
class SplashScreenRipple extends StatefulWidget {
  const SplashScreenRipple({super.key});

  @override
  State<SplashScreenRipple> createState() => _SplashScreenRippleState();
}

class _SplashScreenRippleState extends State<SplashScreenRipple>
    with TickerProviderStateMixin {
  late final AnimationController _dropController;
  late final AnimationController _rippleController;
  late final AnimationController _taglineController;
  late final AnimationController _pulseController;
  String _version = '';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });

    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Logo drops in
    _dropController.forward();
    await Future.delayed(const Duration(milliseconds: 600));

    // Ripples emanate
    _rippleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    // Gentle pulse
    _pulseController.repeat(reverse: true);

    // Tagline appears
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 2500));

    _navigateToApp();
  }

  void _navigateToApp() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppWrapper(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _dropController.dispose();
    _rippleController.dispose();
    _taglineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple rings behind logo
                  AnimatedBuilder(
                    animation: _rippleController,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(screenSize.width, 160),
                        painter: _RipplePainter(
                          progress: _rippleController.value,
                          ringCount: 3,
                        ),
                      );
                    },
                  ),

                  // Logo image with drop + pulse
                  AnimatedBuilder(
                    animation: Listenable.merge([_dropController, _pulseController]),
                    builder: (context, child) {
                      final dropCurve = Curves.elasticOut.transform(
                        _dropController.value,
                      );
                      final pulse = 1.0 + _pulseController.value * 0.03;

                      return Transform.scale(
                        scale: dropCurve * pulse,
                        child: Opacity(
                          opacity: _dropController.value.clamp(0, 1),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/images/logo_yapigo.png',
                      width: 240,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tagline
            FadeTransition(
              opacity: _taglineController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _taglineController,
                  curve: Curves.easeOut,
                )),
                child: Text(
                  'L\'activité sociale de ton quartier.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.slateGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _version.isNotEmpty
              ? Center(
                  child: FadeTransition(
                    opacity: _taglineController,
                    child: Text(
                      _version,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.slateGrey.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final int ringCount;

  _RipplePainter({required this.progress, required this.ringCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.6;

    for (int i = 0; i < ringCount; i++) {
      final ringDelay = i * 0.15;
      final ringProgress = ((progress - ringDelay) / (1 - ringDelay)).clamp(0.0, 1.0);

      if (ringProgress <= 0) continue;

      final radius = maxRadius * Curves.easeOut.transform(ringProgress);
      final opacity = (1 - ringProgress) * 0.4;

      final gradient = RadialGradient(
        colors: [
          const Color(0xFF00BCD4).withValues(alpha: opacity),
          const Color(0xFF1B2A4A).withValues(alpha: opacity * 0.3),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
