enum EventCategory {
  running(label: 'Course à pied', emoji: '🏃', icon: 'running'),
  roadCycling(label: 'Vélo de route', emoji: '🚴', icon: 'road_cycling'),
  mountainBiking(label: 'Vélo de montagne', emoji: '🚵', icon: 'mountain_biking'),
  kayaking(label: 'Kayak', emoji: '🛶', icon: 'kayaking'),
  yoga(label: 'Yoga', emoji: '🧘', icon: 'yoga'),
  hiking(label: 'Randonnée', emoji: '🥾', icon: 'hiking'),
  swimming(label: 'Natation', emoji: '🏊', icon: 'swimming'),
  crossCountrySkiing(label: 'Ski de fond', emoji: '⛷️', icon: 'cross_country_skiing'),
  snowshoeing(label: 'Raquette', emoji: '🏔️', icon: 'snowshoeing'),
  skating(label: 'Patin', emoji: '⛸️', icon: 'skating'),
  socialGathering(label: 'Rassemblement social', emoji: '🧺', icon: 'social_gathering'),
  mixedTraining(label: 'Entraînement mixte', emoji: '💪', icon: 'mixed_training');

  final String label;
  final String emoji;
  final String icon;
  const EventCategory({required this.label, required this.emoji, required this.icon});
}

enum EventStatus { upcoming, waitlisted, confirmed, past }

enum RegistrationStatus {
  notRegistered,
  waitlisted,
  confirmed,
  waitlistFull,
  cancelled,
}

enum IntensityLevel {
  chill(
    label: 'Chill',
    emoji: '🚶',
    description: 'On jase, on prend notre temps',
  ),
  relax(
    label: 'Relax',
    emoji: '🌿',
    description: 'Rythme confortable, pas de pression',
  ),
  moderate(
    label: 'Modéré',
    emoji: '👟',
    description: 'On se dépense bien',
  ),
  intense(
    label: 'Intense',
    emoji: '💨',
    description: 'On pousse la machine',
  ),
  extreme(
    label: 'Extrême',
    emoji: '🔥',
    description: 'Mode athlète',
  );

  final String label;
  final String emoji;
  final String description;

  const IntensityLevel({
    required this.label,
    required this.emoji,
    required this.description,
  });
}

enum DistanceLabel {
  short_(
    label: 'Courte',
    emoji: '🏁',
    description: 'Parfait pour débuter',
  ),
  medium(
    label: 'Moyenne',
    emoji: '📍',
    description: 'L\'idéale pour jaser',
  ),
  long_(
    label: 'Longue',
    emoji: '⚡',
    description: 'On commence à être sérieux',
  ),
  veryLong(
    label: 'Très longue',
    emoji: '🏅',
    description: 'Pour les passionnés',
  ),
  ultra(
    label: 'Ultra',
    emoji: '🌟',
    description: 'Pour les plus ambitieux',
  );

  final String label;
  final String emoji;
  final String description;

  const DistanceLabel({
    required this.label,
    required this.emoji,
    required this.description,
  });
}

enum RecurrenceType {
  oneTime(label: 'Ponctuelle'),
  weekly(label: 'Chaque semaine'),
  biWeekly(label: 'Aux 2 semaines'),
  monthly(label: 'Chaque mois'),
  custom(label: 'Personnalisée');

  final String label;
  const RecurrenceType({required this.label});

  static const dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
}

class KaiEvent {
  final String id;
  final EventCategory category;
  final String neighborhood;
  final String city;
  final DateTime date;
  final DateTime deadline;
  final int totalRegistered;
  final int menCount;
  final int womenCount;
  final String? meetingPointId;
  final List<String> tags;
  final IntensityLevel intensityLevel;
  final DistanceLabel distanceLabel;
  final String? aperoSmoothieSpot;
  final int minThreshold;
  final int maxCapacity;
  final int targetGroupSize;
  final int subGroupCount;
  final bool isConfirmed;
  final bool isFull;
  final RegistrationStatus registrationStatus;
  final List<String> organizerIds;
  final double? myRating;
  final int? waitlistPosition;

  final double? price;
  final bool isPaidOnSite;

  final RecurrenceType recurrence;
  final List<int>? customDays;

  const KaiEvent({
    required this.id,
    this.category = EventCategory.running,
    required this.neighborhood,
    required this.city,
    required this.date,
    required this.deadline,
    required this.totalRegistered,
    required this.menCount,
    required this.womenCount,
    this.meetingPointId,
    this.tags = const [],
    this.intensityLevel = IntensityLevel.moderate,
    this.distanceLabel = DistanceLabel.medium,
    this.aperoSmoothieSpot,
    this.minThreshold = 6,
    this.maxCapacity = 30,
    this.targetGroupSize = 6,
    this.subGroupCount = 0,
    this.isConfirmed = false,
    this.isFull = false,
    this.registrationStatus = RegistrationStatus.notRegistered,
    this.organizerIds = const [],
    this.myRating,
    this.waitlistPosition,
    this.price,
    this.isPaidOnSite = false,
    this.recurrence = RecurrenceType.oneTime,
    this.customDays,
  });

  bool get isRegistered => registrationStatus == RegistrationStatus.confirmed;
  bool get isFree => price == null;
  bool get isRecurring => recurrence != RecurrenceType.oneTime;
  bool get hasOrganizers => organizerIds.isNotEmpty;

  int get otherCount => totalRegistered - menCount - womenCount;
  double get menRatio => totalRegistered > 0 ? menCount / totalRegistered : 0;
  double get womenRatio =>
      totalRegistered > 0 ? womenCount / totalRegistered : 0;
  Duration get timeUntilDeadline => deadline.difference(DateTime.now());
  bool get isDeadlinePassed => DateTime.now().isAfter(deadline);
  bool get isPast => DateTime.now().isAfter(date);
  int get spotsRemaining => maxCapacity - totalRegistered;
  int get neededForThreshold =>
      isConfirmed ? 0 : (minThreshold - totalRegistered).clamp(0, minThreshold);

  EventStatus get status {
    if (isPast) return EventStatus.past;
    if (registrationStatus == RegistrationStatus.confirmed) {
      return EventStatus.confirmed;
    }
    if (registrationStatus == RegistrationStatus.waitlisted) {
      return EventStatus.waitlisted;
    }
    return EventStatus.upcoming;
  }

  String get intensitySummary => intensityLevel.label;
  String get distanceSummary => distanceLabel.label;

  String get priceLabel => isFree ? 'Gratuit' : '${price!.toStringAsFixed(0)} \$';

  String get recurrenceLabel {
    if (recurrence == RecurrenceType.custom && customDays != null && customDays!.isNotEmpty) {
      final names = customDays!.map((d) => RecurrenceType.dayNames[d - 1]).join(', ');
      return 'Chaque $names';
    }
    return recurrence.label;
  }
}
