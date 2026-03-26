import 'package:rundate/models/user.dart';

class Message {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isIcebreaker;

  const Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isIcebreaker = false,
  });
}

class Conversation {
  final String id;
  final String groupName;
  final List<User> members;
  final List<Message> messages;
  final String matchId;

  const Conversation({
    required this.id,
    required this.groupName,
    required this.members,
    required this.messages,
    required this.matchId,
  });

  Message? get lastMessage => messages.isNotEmpty ? messages.last : null;
}
