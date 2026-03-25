enum NotificationType {
  matchFound,
  runConfirmed,
  runCancelled,
  deadlineReminder,
  runToday,
  rateReminder,
  friendInvited,
  contactRequest,
  thresholdReached,
  eventCancelledNoQuorum,
  spotFreed,
  crushMatch,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? fromUserId;
  final String? fromUserName;
  final String? fromUserPhotoUrl;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.fromUserId,
    this.fromUserName,
    this.fromUserPhotoUrl,
  });
}
