import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

/// App icon ("y" with wave on gradient) with optional app name text.
///
/// Set [fullLogo] to true to display the full wordmark instead of the
/// square icon. In that case [size] controls the width of the image.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool fullLogo;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 56,
    this.showText = true,
    this.fullLogo = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (fullLogo) {
      final isDark =
          Theme.of(context).brightness == Brightness.dark;
      final asset = isDark
          ? 'assets/images/logo_rundate_white.png'
          : 'assets/images/logo_rundate.png';
      return Image.asset(
        asset,
        width: size,
        fit: BoxFit.contain,
      );
    }

    final textColor = color ?? AppTheme.navy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.22),
          child: Image.asset(
            'assets/images/rundate_icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.18),
          Text(
            'Run Date',
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
