import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yapigo/theme/app_theme.dart';

/// Base shimmer wrapper that applies the app's shimmer animation.
class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.slateGrey.withValues(alpha: 0.15),
      highlightColor: AppTheme.cream,
      child: child,
    );
  }
}

/// A rounded rectangle placeholder for shimmer loading states.
class ShimmerRect extends StatelessWidget {
  const ShimmerRect({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A circle placeholder for avatar shimmer states.
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton that mimics an event card layout during loading.
class EventCardSkeleton extends StatelessWidget {
  const EventCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBlock(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.slateGrey.withValues(alpha: 0.15),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title placeholder
            ShimmerRect(width: 200, height: 18),
            SizedBox(height: 12),
            // Subtitle placeholder
            ShimmerRect(width: 140, height: 14),
            SizedBox(height: 10),
            // Gender / participants info
            ShimmerRect(width: 100, height: 14),
            SizedBox(height: 10),
            // Countdown placeholder
            ShimmerRect(width: 160, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Skeleton that mimics a notification card during loading.
class NotificationCardSkeleton extends StatelessWidget {
  const NotificationCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerBlock(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerCircle(size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerRect(height: 14),
                  SizedBox(height: 8),
                  ShimmerRect(width: 180, height: 14),
                  SizedBox(height: 8),
                  ShimmerRect(width: 100, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
