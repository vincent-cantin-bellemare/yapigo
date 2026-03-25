import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_events.dart';
import 'package:kaiiak/data/mock_notifications.dart';
import 'package:kaiiak/models/app_notification.dart';
import 'package:kaiiak/models/kai_event.dart';
import 'package:kaiiak/screens/events/event_detail_screen.dart';
import 'package:kaiiak/theme/app_theme.dart';
import 'package:kaiiak/widgets/user_avatar.dart';

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
  if (days < 7) {
    return days <= 1 ? 'hier' : 'il y a $days jours';
  }

  return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
}

KaiEvent _firstUpcomingMockEvent() {
  final now = DateTime.now();
  final upcoming = mockEvents.where((e) => e.date.isAfter(now)).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return upcoming.isNotEmpty ? upcoming.first : mockEvents.first;
}

({IconData icon, Color color}) _iconForType(BuildContext context, NotificationType type) {
  switch (type) {
    case NotificationType.matchFound:
      return (icon: Icons.favorite_rounded, color: AppTheme.ocean);
    case NotificationType.runConfirmed:
      return (icon: Icons.check_circle_rounded, color: AppTheme.teal);
    case NotificationType.runCancelled:
      return (icon: Icons.cancel_rounded, color: AppTheme.error);
    case NotificationType.deadlineReminder:
      return (icon: Icons.schedule_rounded, color: AppTheme.warning);
    case NotificationType.runToday:
      return (icon: Icons.calendar_today_rounded, color: AppTheme.navyIcon(context));
    case NotificationType.rateReminder:
      return (icon: Icons.star_rounded, color: AppTheme.teal);
    case NotificationType.friendInvited:
      return (icon: Icons.card_giftcard_rounded, color: AppTheme.ocean);
    case NotificationType.contactRequest:
      return (icon: Icons.favorite_rounded, color: const Color(0xFFE8547A));
    case NotificationType.thresholdReached:
      return (icon: Icons.group_rounded, color: AppTheme.teal);
    case NotificationType.eventCancelledNoQuorum:
      return (icon: Icons.group_off_rounded, color: AppTheme.error);
    case NotificationType.spotFreed:
      return (icon: Icons.celebration_rounded, color: AppTheme.warning);
    case NotificationType.crushMatch:
      return (icon: Icons.favorite_rounded, color: const Color(0xFFE8547A));
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(mockNotifications);
  }

  Widget _buildList(BuildContext context) {
    return _items.isEmpty
        ? _EmptyState()
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              final n = _items[index];
              final spec = _iconForType(context, n.type);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.slateGrey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Archiver',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.archive_outlined,
                            color: AppTheme.secondaryText(context), size: 22),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    final removed = n;
                    final removedIndex = index;
                    setState(() => _items.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notification archivée',
                            style: GoogleFonts.dmSans()),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Annuler',
                          textColor: AppTheme.ocean,
                          onPressed: () {
                            setState(() {
                              _items.insert(
                                removedIndex.clamp(0, _items.length),
                                removed,
                              );
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: _NotificationCard(
                    notification: n,
                    icon: spec.icon,
                    iconColor: spec.color,
                    timeLabel: _formatRelativeTime(n.timestamp),
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: 300.ms,
                      delay: (50 * index).ms,
                    )
                    .slideX(
                      begin: 0.15,
                      end: 0,
                      duration: 300.ms,
                      delay: (50 * index).ms,
                      curve: Curves.easeOut,
                    ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildList(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
      ),
      body: _buildList(context),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.icon,
    required this.iconColor,
    required this.timeLabel,
  });

  final AppNotification notification;
  final IconData icon;
  final Color iconColor;
  final String timeLabel;

  void _showContactRequestSheet(BuildContext context) {
    final name = notification.fromUserName ?? 'Quelqu\'un';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(ctx),
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.slateGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  UserAvatar(
                    name: name,
                    photoUrl: notification.fromUserPhotoUrl,
                    size: 64,
                    showRing: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$name aimerait te connaître!',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(ctx),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Vous étiez dans le même groupe au dernier run. '
                    'Accepte sa demande pour échanger en privé!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      height: 1.45,
                      color: AppTheme.navy.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Demande déclinée.',
                                    style: GoogleFonts.dmSans()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondaryText(ctx),
                            side: BorderSide(
                                color: AppTheme.slateGrey
                                    .withValues(alpha: 0.4)),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Décliner'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Connexion acceptée! Tu peux maintenant discuter avec $name.',
                                  style: GoogleFonts.dmSans(),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ocean,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                            textStyle: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Accepter'),
                        ),
                      ),
                    ],
                  ),
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
    final read = notification.isRead;

    return Opacity(
      opacity: read ? 0.72 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (notification.type == NotificationType.contactRequest) {
              _showContactRequestSheet(context);
            } else if (notification.type == NotificationType.matchFound) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EventDetailScreen(
                    event: _firstUpcomingMockEvent(),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text(notification.title, style: GoogleFonts.dmSans()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.slateGrey.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!read)
                    Container(
                      width: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.ocean,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(read ? 16 : 12, 14, 16, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  notification.body,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    height: 1.4,
                                    color: read
                                        ? AppTheme.slateGrey
                                            .withValues(alpha: 0.9)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  timeLabel,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    color: AppTheme.secondaryText(context),
                                  ),
                                ),
                                if (notification.type ==
                                    NotificationType.contactRequest) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Demande déclinée.',
                                                  style:
                                                      GoogleFonts.dmSans(),
                                                ),
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppTheme.secondaryText(context),
                                            side: BorderSide(
                                              color: AppTheme.slateGrey
                                                  .withValues(alpha: 0.4),
                                            ),
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            textStyle: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          child: const Text('Décliner'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final name =
                                                notification.fromUserName ??
                                                    'Quelqu\'un';
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Connexion acceptée! Tu peux maintenant discuter avec $name.',
                                                  style:
                                                      GoogleFonts.dmSans(),
                                                ),
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.ocean,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                            textStyle: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          child: const Text('Accepter'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                if (notification.type ==
                                    NotificationType.spotFreed) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Place déclinée.',
                                                  style:
                                                      GoogleFonts.dmSans(),
                                                ),
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                AppTheme.secondaryText(context),
                                            side: BorderSide(
                                              color: AppTheme.slateGrey
                                                  .withValues(alpha: 0.4),
                                            ),
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            textStyle: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          child: const Text('Décliner'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Inscription confirmée! Tu es dans le run.',
                                                  style:
                                                      GoogleFonts.dmSans(),
                                                ),
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppTheme.ocean,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets
                                                .symmetric(vertical: 8),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                            textStyle: GoogleFonts.nunito(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          child: const Text('Participer'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/empty/no_notifications.png',
              width: 88,
              height: 88,
              errorBuilder: (_, __, ___) => Icon(
                Icons.notifications_none_rounded,
                size: 72,
                color: AppTheme.ocean.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune notification pour le moment.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
