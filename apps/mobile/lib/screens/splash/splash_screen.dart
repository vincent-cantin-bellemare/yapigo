import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:yapigo/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _navigated = false;
  String _version = '';
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}');
    });

    // Fallback: navigate after 6s even if video fails
    Future.delayed(const Duration(milliseconds: 6000), _navigateToApp);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_videoController != null) return;

    _isDark = Theme.of(context).brightness == Brightness.dark;
    final videoAsset = _isDark
        ? 'assets/video/yapigo_dark.mp4'
        : 'assets/video/yapigo_light.mp4';

    _videoController = VideoPlayerController.asset(videoAsset)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _videoController!.setVolume(0);
        _videoController!.play();
      });

    _videoController!.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    if (_navigated || _videoController == null) return;
    final pos = _videoController!.value.position;
    final dur = _videoController!.value.duration;
    if (dur.inMilliseconds > 0 &&
        pos >= dur - const Duration(milliseconds: 300)) {
      _navigateToApp();
    }
  }

  void _navigateToApp() {
    if (_navigated || !mounted) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppWrapper(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_onVideoProgress);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = _isDark ? AppTheme.darkScaffold : AppTheme.cream;
    final subtitleColor =
        _isDark ? const Color(0xFF94A3B8) : AppTheme.slateGrey;
    final dotColor = _isDark ? AppTheme.teal : AppTheme.ocean;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 280,
              height: 280,
              child: _videoReady && _videoController != null
                  ? FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : Image.asset(
                      _isDark
                          ? 'assets/images/logo_yapigo_white.png'
                          : 'assets/images/logo_yapigo.png',
                      width: 220,
                      height: 220,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le hub des sportifs de ton quartier.',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: subtitleColor,
                fontStyle: FontStyle.italic,
              ),
            )
                .animate()
                .fadeIn(delay: 900.ms, duration: 600.ms),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fadeIn(delay: (1200 + i * 200).ms, duration: 400.ms)
                      .then()
                      .scaleXY(begin: 1.0, end: 0.5, duration: 500.ms);
                }),
              ),
              const SizedBox(height: 10),
              if (_version.isNotEmpty)
                Text(
                  _version,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: subtitleColor.withValues(alpha: 0.6),
                  ),
                ).animate().fadeIn(delay: 1500.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
