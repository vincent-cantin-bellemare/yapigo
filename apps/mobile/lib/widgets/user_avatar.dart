import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

/// Reusable avatar widget that shows either a network image or a colored initial.
/// Supports gradient ring for verified/active users.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 48,
    this.isVerified = false,
    this.xp = 0,
    this.showRing = true,
    this.isOnline = false,
    this.onTap,
  });

  final String name;
  final String? photoUrl;
  final double size;
  final bool isVerified;
  final int xp;
  final bool showRing;
  final bool isOnline;
  final VoidCallback? onTap;

  static const _colors = [
    AppTheme.ocean,
    AppTheme.teal,
    AppTheme.teal,
    AppTheme.warning,
    Color(0xFF7B8FD4),
    AppTheme.error,
    Color(0xFF9B7FBF),
    AppTheme.navy,
  ];

  bool get _hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  String get _initial =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  Color get _initialColor =>
      _colors[name.hashCode.abs() % _colors.length];

  /// Gradient depends on user status: verified > active (xp>300) > default.
  Gradient? get _ringGradient {
    if (!showRing) return null;
    if (isVerified) {
      return const LinearGradient(
        colors: [AppTheme.ocean, AppTheme.error],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (xp > 300) {
      return const LinearGradient(
        colors: [AppTheme.teal, AppTheme.teal],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRing = showRing && size > 36;
    const ringWidth = 2.5;
    final thinRing = showRing && size <= 36;
    final innerSize = effectiveRing ? size - ringWidth * 2 : (thinRing ? size - 2 : size);

    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: effectiveRing ? _ringGradient : null,
        border: thinRing
            ? Border.all(
                color: _ringGradient != null
                    ? AppTheme.ocean.withValues(alpha: 0.6)
                    : AppTheme.slateGrey.withValues(alpha: 0.25),
                width: 1,
              )
            : (effectiveRing && _ringGradient == null
                ? Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.25),
                    width: 1,
                  )
                : null),
      ),
      padding: effectiveRing ? const EdgeInsets.all(ringWidth) : (thinRing ? const EdgeInsets.all(1) : null),
      child: ClipOval(
        child: SizedBox(
          width: innerSize,
          height: innerSize,
          child: _hasPhoto ? _networkImage(innerSize) : _initialAvatar(innerSize),
        ),
      ),
    );

    final avatar = onTap != null
        ? GestureDetector(onTap: onTap, child: content)
        : content;

    if (!isOnline) return avatar;

    final dotSize = (size * 0.18).clamp(8.0, 14.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: AppTheme.teal,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _networkImage(double imgSize) {
    return Image.network(
      photoUrl!,
      width: imgSize,
      height: imgSize,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => _initialAvatar(imgSize),
    );
  }

  Widget _initialAvatar(double imgSize) {
    return Container(
      width: imgSize,
      height: imgSize,
      decoration: BoxDecoration(
        color: _initialColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: GoogleFonts.nunito(
          fontSize: imgSize * 0.4,
          fontWeight: FontWeight.w700,
          color: _initialColor,
        ),
      ),
    );
  }
}
