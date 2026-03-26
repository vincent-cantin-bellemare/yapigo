import 'package:rundate/models/kai_event.dart';

class UserActivity {
  final EventCategory category;
  final IntensityLevel level;

  const UserActivity({required this.category, required this.level});
}

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String gender;
  final String? sexualOrientation;
  final int age;
  final String city;
  final String? neighborhood;
  final String? photoUrl;
  final String? bio;
  final bool isVerified;
  final int xp;
  final BadgeLevel badge;
  final bool isSuspended;
  final DateTime? memberSince;
  final DateTime? lastActivityDate;
  final DateTime? lastSeenDate;
  final double? averageRating;
  final int totalActivities;
  final double totalKm;
  final List<String> photoGallery;
  final List<UserActivity> activities;
  final List<String> activityGoals;
  final bool isOrganizer;
  final int connections;

  final bool stravaConnected;
  final int? stravaAthleteId;
  final String? stravaDisplayName;
  final double? stravaYtdKm;
  final int? stravaYtdRuns;
  final int? stravaAvgPaceSeconds;
  final double? stravaMonthKm;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.gender,
    this.sexualOrientation,
    required this.age,
    required this.city,
    this.neighborhood,
    this.photoUrl,
    this.bio,
    this.isVerified = false,
    this.xp = 0,
    this.badge = BadgeLevel.curieux,
    this.isSuspended = false,
    this.memberSince,
    this.lastActivityDate,
    this.lastSeenDate,
    this.averageRating,
    this.totalActivities = 0,
    this.totalKm = 0,
    this.photoGallery = const [],
    this.activities = const [],
    this.activityGoals = const [],
    this.isOrganizer = false,
    this.connections = 0,
    this.stravaConnected = false,
    this.stravaAthleteId,
    this.stravaDisplayName,
    this.stravaYtdKm,
    this.stravaYtdRuns,
    this.stravaAvgPaceSeconds,
    this.stravaMonthKm,
  });

  String? get stravaProfileUrl => stravaAthleteId != null
      ? 'https://www.strava.com/athletes/$stravaAthleteId'
      : null;

  String? get stravaAvgPaceFormatted {
    if (stravaAvgPaceSeconds == null) return null;
    final minutes = stravaAvgPaceSeconds! ~/ 60;
    final seconds = stravaAvgPaceSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
  }

  List<EventCategory> get preferredCategories =>
      activities.map((a) => a.category).toList();

  bool hasActivityInCommon(User other) {
    final myCategories = preferredCategories.toSet();
    return other.preferredCategories.any((c) => myCategories.contains(c));
  }
}

enum BadgeLevel {
  curieux(
      label: 'Curieux',
      icon: '👁️',
      minXp: 0,
      assetPath: 'assets/badges/curieux.png'),
  social(
      label: 'Social',
      icon: '👋',
      minXp: 100,
      assetPath: 'assets/badges/social.png'),
  habitue(
      label: 'Habitué',
      icon: '⭐',
      minXp: 300,
      assetPath: 'assets/badges/habitue.png'),
  populaire(
      label: 'Populaire',
      icon: '🔥',
      minXp: 600,
      assetPath: 'assets/badges/populaire.png'),
  legende(
      label: 'Légende',
      icon: '👑',
      minXp: 1000,
      assetPath: 'assets/badges/legende.png');

  final String label;
  final String icon;
  final int minXp;
  final String assetPath;
  const BadgeLevel({
    required this.label,
    required this.icon,
    required this.minXp,
    required this.assetPath,
  });

  static BadgeLevel fromXp(int xp) {
    return BadgeLevel.values
        .lastWhere((b) => xp >= b.minXp, orElse: () => BadgeLevel.curieux);
  }

  BadgeLevel? get next {
    final idx = BadgeLevel.values.indexOf(this);
    return idx < BadgeLevel.values.length - 1
        ? BadgeLevel.values[idx + 1]
        : null;
  }

  int get xpToNext => next != null ? next!.minXp : 0;
}
