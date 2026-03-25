import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/theme/app_theme.dart';

/// App icon ("k" with wave on gradient) with optional app name text.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTheme.navy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/images/yapigo_icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          Text(
            'yapigo',
            style: GoogleFonts.dmSans(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w300,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
