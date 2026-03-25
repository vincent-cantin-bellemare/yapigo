class EventPhoto {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String photoUrl;
  final DateTime timestamp;
  final String? description;

  const EventPhoto({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.photoUrl,
    required this.timestamp,
    this.description,
  });
}
