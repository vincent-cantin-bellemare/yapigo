import 'package:flutter/material.dart';

/// Substrings (lowercase) tested with [String.contains] against the input.
/// First rule that matches wins.
const _neighborhoodRules = <(List<String>, String)>[
  (
    ['hochelaga'],
    'assets/neighborhoods/hochelaga.png',
  ),
  (
    ['plateau'],
    'assets/neighborhoods/plateau.png',
  ),
  (
    ['mile-end', 'mile end'],
    'assets/neighborhoods/mile_end.png',
  ),
  (
    ['villeray'],
    'assets/neighborhoods/villeray.png',
  ),
  (
    ['rosemont'],
    'assets/neighborhoods/rosemont.png',
  ),
  (
    ['verdun'],
    'assets/neighborhoods/verdun.png',
  ),
  (
    ['griffintown'],
    'assets/neighborhoods/griffintown.png',
  ),
  (
    [
      'vieux-port',
      'vieux port',
      'vieux-montréal',
      'vieux montréal',
    ],
    'assets/neighborhoods/vieux_port.png',
  ),
];

/// Resolves a banner image path for [neighborhood] using case-insensitive
/// substring matching. Returns null when no known neighborhood matches.
String? neighborhoodAsset(String neighborhood) {
  final normalized = neighborhood.toLowerCase();
  if (normalized.isEmpty) return null;

  for (final (fragments, path) in _neighborhoodRules) {
    for (final fragment in fragments) {
      if (normalized.contains(fragment)) {
        return path;
      }
    }
  }
  return null;
}

/// Full-width neighborhood photo when [neighborhood] maps to an asset;
/// otherwise renders nothing. Displays the image at its natural aspect ratio.
class NeighborhoodBanner extends StatelessWidget {
  const NeighborhoodBanner({
    super.key,
    required this.neighborhood,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final String neighborhood;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final path = neighborhoodAsset(neighborhood);
    if (path == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        path,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
