enum MeetingPointType { park, cafe, landmark }

class MeetingPoint {
  final String id;
  final String name;
  final MeetingPointType type;
  final String address;
  final String neighborhood;
  final String? description;
  final String? photoUrl;
  final String? mapsUrl;

  const MeetingPoint({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.neighborhood,
    this.description,
    this.photoUrl,
    this.mapsUrl,
  });

  String get typeLabel => switch (type) {
        MeetingPointType.park => 'Parc',
        MeetingPointType.cafe => 'Café',
        MeetingPointType.landmark => 'Point de repère',
      };

  String get typeEmoji => switch (type) {
        MeetingPointType.park => '🌳',
        MeetingPointType.cafe => '☕',
        MeetingPointType.landmark => '📍',
      };
}
