import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:yapigo/main.dart';

/// OPTION A — "Wave & Letters"
/// Letters slide in one by one from below, then the wave draws itself
/// underneath with a shimmer gradient sweep.
class SplashScreenWave extends StatefulWidget {
  const SplashScreenWave({super.key});

  @override
  State<SplashScreenWave> createState() => _SplashScreenWaveState();
}

class _SplashScreenWaveState extends State<SplashScreenWave>
    with TickerProviderStateMixin {
  late final AnimationController _letterController;
  late final AnimationController _waveController;
  late final AnimationController _shimmerController;
  late final AnimationController _taglineController;
  String _version = '';
  bool _navigated = false;

  static const _letters = ['k', 'a', 'i', 'i', 'a', 'k'];
  static const _colors = [
    Color(0xFF00D4AA),
    Color(0xFF00BCD4),
    Color(0xFF0097A7),
    Color(0xFF00838F),
    Color(0xFF1B4A6A),
    Color(0xFF1B2A4A),
  ];

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });

    _letterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _letterController.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    _waveController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _shimmerController.repeat();
    _taglineController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
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
    _letterController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : AppTheme.cream,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated letters
            SizedBox(
              height: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(_letters.length, (i) {
                  final stagger = i / _letters.length;
                  return AnimatedBuilder(
                    animation: _letterController,
                    builder: (context, child) {
                      final t = Curves.elasticOut.transform(
                        (_letterController.value - stagger * 0.5).clamp(0, 1) /
                            (1 - stagger * 0.5).clamp(0.01, 1),
                      );
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - t.clamp(0, 1))),
                        child: Opacity(
                          opacity: t.clamp(0, 1).toDouble(),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _letters[i],
                      style: GoogleFonts.nunito(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: _colors[i],
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Animated wave
            SizedBox(
              height: 30,
              width: 200,
              child: AnimatedBuilder(
                animation: Listenable.merge([_waveController, _shimmerController]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _WavePainter(
                      progress: _waveController.value,
                      shimmer: _shimmerController.value,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Tagline
            FadeTransition(
              opacity: _taglineController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
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

class _WavePainter extends CustomPainter {
  final double progress;
  final double shimmer;

  _WavePainter({required this.progress, required this.shimmer});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final path = Path();
    final waveWidth = size.width * progress;

    path.moveTo(0, size.height * 0.5);
    for (double x = 0; x <= waveWidth; x++) {
      final y = size.height * 0.5 +
          sin(x / size.width * 2 * pi) * 6;
      path.lineTo(x, y);
    }

    final gradient = LinearGradient(
      colors: const [
        Color(0xFF00D4AA),
        Color(0xFF00BCD4),
        Color(0xFF1B2A4A),
      ],
      stops: [
        (shimmer - 0.3).clamp(0, 1),
        shimmer.clamp(0, 1),
        (shimmer + 0.3).clamp(0, 1),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}
