import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:rundate/theme/app_theme.dart';

const double _kMaxAppWidth = 500;

class WebShell extends StatelessWidget {
  const WebShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= _kMaxAppWidth) return child;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return ColoredBox(
          color: isDark ? const Color(0xFF0D1B2A) : AppTheme.navy,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF0D1B2A), const Color(0xFF1A1A2E)]
                    : [AppTheme.navy, const Color(0xFF0A2540)],
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  const _NativeBanner(),
                  Expanded(
                    child: Container(
                      width: _kMaxAppWidth,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NativeBanner extends StatelessWidget {
  const _NativeBanner();

  static const _appStoreUrl =
      'https://apps.apple.com/app/run-date/id0000000000';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.codeshop.rundate';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kMaxAppWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.phone_iphone_rounded,
              color: Colors.white70, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Meilleure expérience sur l\'app native',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _StoreButton(
            label: 'App Store',
            icon: Icons.apple_rounded,
            onTap: () => _openUrl(_appStoreUrl),
          ),
          const SizedBox(width: 8),
          _StoreButton(
            label: 'Google Play',
            icon: Icons.play_arrow_rounded,
            onTap: () => _openUrl(_playStoreUrl),
          ),
        ],
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  const _StoreButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
