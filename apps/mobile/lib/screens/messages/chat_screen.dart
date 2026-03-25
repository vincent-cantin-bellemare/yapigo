import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_questions.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/models/message.dart';
import 'package:kaiiak/models/user.dart';
import 'package:kaiiak/screens/profile/user_profile_sheet.dart';
import 'package:kaiiak/theme/app_theme.dart';

const String _kCurrentUserId = 'current';

String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 45) return 'à l\'instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  final todayStart = DateTime(now.year, now.month, now.day);
  final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
  if (msgDay == todayStart) {
    final h = diff.inHours;
    return h < 1 ? 'il y a ${diff.inMinutes} min' : 'il y a ${h}h';
  }
  final yesterday = todayStart.subtract(const Duration(days: 1));
  if (msgDay == yesterday) return 'hier';
  final days = todayStart.difference(msgDay).inDays;
  if (days < 7) return days <= 1 ? 'hier' : 'il y a $days jours';
  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
}

String _formatMessageTime(DateTime dateTime) {
  final h = dateTime.hour.toString().padLeft(2, '0');
  final m = dateTime.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversation});
  final Conversation conversation;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<Message> _messages;
  final TextEditingController _controller = TextEditingController();
  int _idCounter = 0;
  bool _notificationsMuted = false;

  List<User> get _members => widget.conversation.members;

  static const _memberColors = <Color>[
    AppTheme.ocean,
    AppTheme.teal,
    AppTheme.teal,
    AppTheme.warning,
    Color(0xFF7B8FD4),
    AppTheme.error,
    Color(0xFF9B7FBF),
    AppTheme.navy,
  ];

  Color _colorForSender(String senderId) {
    for (var i = 0; i < _members.length; i++) {
      if (_members[i].id == senderId) {
        return _memberColors[i % _memberColors.length];
      }
    }
    return AppTheme.slateGrey;
  }

  String _nameForSender(String senderId) {
    for (final m in _members) {
      if (m.id == senderId) return m.firstName;
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _messages = List<Message>.from(widget.conversation.messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _idCounter++;
      _messages.add(
        Message(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}_$_idCounter',
          senderId: _kCurrentUserId,
          content: trimmed,
          timestamp: DateTime.now(),
        ),
      );
      _controller.clear();
    });
  }

  void _showSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label), behavior: SnackBarBehavior.floating),
    );
  }

  void _showLeaveDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quitter le groupe?'),
        content: const Text(
          'Tu ne pourras plus envoyer de messages ni voir la conversation. '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              _showSnack('Tu as quitté le groupe');
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    String? selectedReason;
    final reasons = [
      'Contenu inapproprié',
      'Harcèlement',
      'Spam',
      'Faux profil',
      'Autre',
    ];
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Signaler le groupe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pourquoi signales-tu ce groupe?',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 12),
              ...reasons.map(
                (r) => InkWell(
                  onTap: () => setLocal(() => selectedReason = r),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          selectedReason == r
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selectedReason == r
                              ? AppTheme.ocean
                              : AppTheme.secondaryText(ctx),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(r,
                              style: GoogleFonts.dmSans(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.of(ctx).pop();
                      _showSnack('Signalement envoyé. Merci!');
                    }
                  : null,
              child: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showMembersSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.slateGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Membres du groupe', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textColor(ctx))),
                  const SizedBox(height: 16),
                  ...widget.conversation.members.map((u) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.ocean.withValues(alpha: 0.2),
                        backgroundImage: u.photoUrl != null ? NetworkImage(u.photoUrl!) : null,
                        child: u.photoUrl == null ? Text(u.firstName[0]) : null,
                      ),
                      title: Text('${u.firstName} ${u.lastName}', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                      subtitle: Text(u.activities.map((a) => a.category.emoji).join(' '), style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.secondaryText(ctx))),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        UserProfileSheet.show(context, u);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestion = mockIcebreakers.isNotEmpty ? mockIcebreakers.first : '';
    final memberCount = _members.length + 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.conversation.groupName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '$memberCount membres',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'mute') {
                setState(() => _notificationsMuted = !_notificationsMuted);
                _showSnack(_notificationsMuted
                    ? 'Notifications coupées pour ce groupe'
                    : 'Notifications réactivées');
              } else if (value == 'members') {
                _showMembersSheet();
              } else if (value == 'leave') {
                _showLeaveDialog();
              } else if (value == 'report') {
                _showReportDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'members',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, size: 20, color: Theme.of(context).colorScheme.onSurface),
                    const SizedBox(width: 10),
                    const Text('Voir les membres'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(
                      _notificationsMuted
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Text(_notificationsMuted
                        ? 'Réactiver les notifications'
                        : 'Couper les notifications'),
                  ],
                ),
              ),
              const PopupMenuItem(value: 'leave', child: Text('Quitter le groupe')),
              const PopupMenuItem(value: 'report', child: Text('Signaler')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _EmptyIcebreakerHint(
                    suggestion: suggestion,
                    onSendSuggestion: () => _sendText(suggestion),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MessageBlock(
                          message: msg,
                          timeLabel: _formatMessageTime(msg.timestamp),
                          subtleRelative:
                              _formatRelativeTime(msg.timestamp),
                          senderName: _nameForSender(msg.senderId),
                          senderColor: _colorForSender(msg.senderId),
                        ),
                      );
                    },
                  ),
          ),
          _MessageInputBar(
            controller: _controller,
            onSend: () => _sendText(_controller.text),
          ),
        ],
      ),
    );
  }
}

class _EmptyIcebreakerHint extends StatelessWidget {
  const _EmptyIcebreakerHint({
    required this.suggestion,
    required this.onSendSuggestion,
  });

  final String suggestion;
  final VoidCallback onSendSuggestion;

  @override
  Widget build(BuildContext context) {
    if (suggestion.isEmpty) {
      return Center(
        child: Text(
          'Lancez la conversation de groupe!',
          style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Idée pour briser la glace',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryText(context),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.2)),
              ),
              child: Text(
                suggestion,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ActionChip(
              label: Text(
                'Envoyer au groupe',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.ocean,
                ),
              ),
              side: const BorderSide(color: AppTheme.ocean),
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: onSendSuggestion,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
    required this.message,
    required this.timeLabel,
    required this.subtleRelative,
    required this.senderName,
    required this.senderColor,
  });

  final Message message;
  final String timeLabel;
  final String subtleRelative;
  final String senderName;
  final Color senderColor;

  void _showSenderActions(BuildContext context) {
    final user = mockUsers.firstWhere(
      (u) => u.id == message.senderId,
      orElse: () => mockUsers.first,
    );
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.slateGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text('Voir le profil',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    UserProfileSheet.show(context, user);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined,
                      color: AppTheme.error),
                  title: Text('Signaler',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.error)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Signalement envoyé',
                            style: GoogleFonts.dmSans()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (message.isIcebreaker) {
      return Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome,
                        size: 18,
                        color: Colors.white.withValues(alpha: 0.95)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message.content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '$timeLabel · $subtleRelative',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.slateGrey.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      );
    }

    final isMine = message.senderId == _kCurrentUserId;

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (!isMine && senderName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 4),
            child: GestureDetector(
              onTap: () => _showSenderActions(context),
              child: Text(
                senderName,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: senderColor,
                ),
              ),
            ),
          ),
        Align(
          alignment:
              isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isMine
                    ? AppTheme.ocean
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMine ? 16 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Text(
                  message.content,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    height: 1.35,
                    color: isMine
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding:
              EdgeInsets.only(left: isMine ? 0 : 8, right: isMine ? 8 : 0),
          child: Text(
            '$timeLabel · $subtleRelative',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.slateGrey.withValues(alpha: 0.85),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      shadowColor: AppTheme.navy.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Message au groupe…',
                    hintStyle:
                        GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
                    filled: true,
                    fillColor: AppTheme.cream,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color:
                              AppTheme.slateGrey.withValues(alpha: 0.25)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(
                          color:
                              AppTheme.slateGrey.withValues(alpha: 0.25)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: AppTheme.ocean, width: 2),
                    ),
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: onSend,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
