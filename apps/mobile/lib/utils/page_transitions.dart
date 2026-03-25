import 'package:flutter/material.dart';

/// Slide-up transition for detail screens.
class SlideUpRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// Fade-through transition for tab switches.
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation, ) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Outgoing page fades out + scales down
            final fadeOut = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOut,
            );
            // Incoming page fades in + scales up from 0.92
            final fadeIn = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            );

            return FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(fadeIn),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(fadeIn),
                child: FadeTransition(
                  opacity:
                      Tween<double>(begin: 1, end: 0).animate(fadeOut),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 0.92)
                        .animate(fadeOut),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}

/// Push a page with slide-up transition.
void pushSlideUp(BuildContext context, Widget page) {
  Navigator.of(context).push(SlideUpRoute(page: page));
}

/// Push a page with fade-through transition.
void pushFadeThrough(BuildContext context, Widget page) {
  Navigator.of(context).push(FadeThroughRoute(page: page));
}
