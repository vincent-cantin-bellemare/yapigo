import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted glass container with blur effect for modern UI.
class FrostedContainer extends StatelessWidget {
  const FrostedContainer({
    super.key,
    required this.child,
    this.sigmaX = 20,
    this.sigmaY = 20,
    this.opacity = 0.7,
    this.borderRadius = 16,
    this.color,
    this.padding,
    this.border,
  });

  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final double opacity;
  final double borderRadius;
  final Color? color;
  final EdgeInsets? padding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? Colors.white.withValues(alpha: opacity);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
