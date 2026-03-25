import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_messages.dart';
import 'package:kaiiak/models/message.dart';
import 'package:kaiiak/models/user.dart';
import 'package:kaiiak/screens/messages/chat_screen.dart';
import 'package:kaiiak/theme/app_theme.dart';

const _bannerSubtitles = [
  'Planifie ta prochaine sortie!',
  'Tes co-coureurs t\'attendent!',
  'Un run, des connexions!',
  'Qui court avec toi ce vendredi?',
  'Organise un after-run!',
  'L\'aventure t\'attend!',
  'Prêt pour le prochain run?',
];

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

bool _showUnreadDot(Conversation c) {
  final last = c.lastMessage;
  if (last == null) return false;
  return last.senderId != 'current';
}

String _senderName(String senderId, List<User> members) {
  if (senderId == 'current') return 'Toi';
  if (senderId == 'system') return '';
  for (final m in members) {
    if (m.id == senderId) return m.firstName;
  }
  return '';
}

String _formatEventDate(Conversation conv) {
  final last = conv.lastMessage;
  if (last == null) return '';
  final d = last.timestamp.add(const Duration(days: 2));
  const months = ['', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
  return '${d.day} ${months[d.month]}';
}

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key, this.embedded = false});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final conversations = mockConversations;

    if (embedded) {
      return conversations.isEmpty
          ? _EmptyState()
          : _buildBody(context, conversations);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: conversations.isEmpty
          ? _EmptyState()
          : _buildBody(context, conversations),
    );
  }

  Widget _buildBody(BuildContext context, List<Conversation> conversations) {
    return RefreshIndicator(
              color: AppTheme.ocean,
              onRefresh: () async {
                await Future<void>.delayed(const Duration(milliseconds: 600));
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
                itemCount: conversations.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.teal.withValues(alpha: 0.1),
                              AppTheme.teal.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.teal.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.groups_rounded, size: 22, color: AppTheme.teal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${conversations.length} groupes actifs',
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textColor(context),
                                    ),
                                  ),
                                  Text(
                                    _bannerSubtitles[math.Random().nextInt(_bannerSubtitles.length)],
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      color: AppTheme.secondaryText(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, duration: 400.ms);
                  }

                  final convIndex = index - 1;
                  final conv = conversations[convIndex];
                  final last = conv.lastMessage;
                  final allMembers = conv.members;
                  final memberCount = allMembers.length + 1;

                  String preview = '';
                  if (last != null) {
                    final name = _senderName(last.senderId, allMembers);
                    if (last.isIcebreaker) {
                      preview = last.content;
                    } else if (name.isNotEmpty) {
                      preview = '$name: ${last.content}';
                    } else {
                      preview = last.content;
                    }
                  }

                  final hasUnread = _showUnreadDot(conv);

                  return Column(
                    children: [
                      if (convIndex > 0)
                        Divider(
                          height: 1,
                          indent: 88,
                          color: AppTheme.slateGrey.withValues(alpha: 0.15),
                        ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ChatScreen(conversation: conv),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: hasUnread
                              ? BoxDecoration(
                                  color: AppTheme.ocean.withValues(alpha: 0.04),
                                  border: Border(
                                    left: BorderSide(color: AppTheme.ocean, width: 3),
                                  ),
                                )
                              : null,
                          child: Row(
                            children: [
                              _GroupAvatarStack(members: allMembers),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            conv.groupName,
                                            style: GoogleFonts.nunito(
                                              fontSize: 16,
                                              fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                                              color: AppTheme.textColor(context),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.teal.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '$memberCount',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.teal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Vendredi ${_formatEventDate(conv)}',
                                      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.teal, fontStyle: FontStyle.italic),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preview,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                        color: hasUnread ? AppTheme.textColor(context) : AppTheme.secondaryText(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (last != null)
                                    Text(
                                      _formatRelativeTime(last.timestamp),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        color: hasUnread ? AppTheme.ocean : AppTheme.secondaryText(context),
                                        fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                                      ),
                                    ),
                                  if (hasUnread) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.ocean,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 350.ms, delay: (100 + convIndex * 80).ms)
                      .slideX(begin: 0.05, end: 0, duration: 350.ms, delay: (100 + convIndex * 80).ms);
                },
              ),
    );
  }
}

class _GroupAvatarStack extends StatelessWidget {
  const _GroupAvatarStack({required this.members});
  final List<User> members;

  static const _colors = [
    AppTheme.ocean,
    AppTheme.teal,
    AppTheme.teal,
    AppTheme.warning,
  ];

  @override
  Widget build(BuildContext context) {
    final show = members.take(3).toList();
    final extra = members.length - 3;

    return SizedBox(
      width: 56,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < show.length; i++)
            Positioned(
              left: i * 14.0,
              top: i.isEven ? 0 : 12,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _colors[i % _colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cardColor(context), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  show[i].firstName[0].toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: show.length * 14.0,
              top: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.slateGrey.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.cardColor(context), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
        ],
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.ocean.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_rounded,
                size: 48,
                color: AppTheme.ocean.withValues(alpha: 0.7),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 500.ms),
            const SizedBox(height: 24),
            Text(
              'Tes conversations\napparaîtront ici',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 150.ms),
            const SizedBox(height: 12),
            Text(
              'Inscris-toi à un événement et tu courras\navec un groupe de coureurs!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                height: 1.45,
                color: AppTheme.secondaryText(context),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 250.ms),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.explore_outlined, size: 20),
              label: Text(
                'Découvrir les événements',
                style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
