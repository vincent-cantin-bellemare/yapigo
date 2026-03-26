import 'package:rundate/models/user.dart';
import 'package:rundate/models/meeting_point.dart';

class ActivityMatch {
  final String id;
  final String eventId;
  final List<User> groupMembers;
  final MeetingPoint meetingPoint;
  final DateTime dateTime;
  final MatchStatus status;
  final double? ratingGiven;
  final List<String> organizerIds;

  const ActivityMatch({
    required this.id,
    required this.eventId,
    required this.groupMembers,
    required this.meetingPoint,
    required this.dateTime,
    this.status = MatchStatus.confirmed,
    this.ratingGiven,
    this.organizerIds = const [],
  });

  int get groupSize => groupMembers.length;

  List<User> get organizers =>
      groupMembers.where((u) => organizerIds.contains(u.id)).toList();
}

enum MatchStatus {
  confirmed,
  completed,
  cancelled,
}
