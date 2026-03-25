import 'package:yapigo/models/user.dart';
import 'package:yapigo/models/meeting_point.dart';

class ActivityMatch {
  final String id;
  final String eventId;
  final List<User> groupMembers;
  final MeetingPoint meetingPoint;
  final DateTime dateTime;
  final MatchStatus status;
  final double? ratingGiven;
  final List<String> organizerIds;
  final String? buddyId;

  const ActivityMatch({
    required this.id,
    required this.eventId,
    required this.groupMembers,
    required this.meetingPoint,
    required this.dateTime,
    this.status = MatchStatus.confirmed,
    this.ratingGiven,
    this.organizerIds = const [],
    this.buddyId,
  });

  int get groupSize => groupMembers.length;

  List<User> get organizers =>
      groupMembers.where((u) => organizerIds.contains(u.id)).toList();

  User? get buddy =>
      buddyId != null
          ? groupMembers.where((u) => u.id == buddyId).firstOrNull
          : null;
}

enum MatchStatus {
  confirmed,
  completed,
  cancelled,
}
