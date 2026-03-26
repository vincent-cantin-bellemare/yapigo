import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_events.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/events/event_detail_screen.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/tip_organizer_sheet.dart';
import 'package:rundate/widgets/user_avatar.dart';

class OrganizersListScreen extends StatefulWidget {
  const OrganizersListScreen({super.key, this.initialOrganizerId});

  final String? initialOrganizerId;

  @override
  State<OrganizersListScreen> createState() => _OrganizersListScreenState();
}

class _OrganizersListScreenState extends State<OrganizersListScreen> {
  late final List<User> _organizers;
  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _organizers = mockUsers.where((u) => u.isOrganizer).toList();
    for (final org in _organizers) {
      _cardKeys[org.id] = GlobalKey();
    }
    if (widget.initialOrganizerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToOrganizer(widget.initialOrganizerId!);
      });
    }
  }

  void _scrollToOrganizer(String organizerId) {
    final key = _cardKeys[organizerId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Nos organisateurs',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        itemCount: _organizers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final org = _organizers[index];
          return _OrganizerCard(
            key: _cardKeys[org.id],
            organizer: org,
          );
        },
      ),
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  const _OrganizerCard({super.key, required this.organizer});
  final User organizer;

  @override
  Widget build(BuildContext context) {
    final upcomingEvents = mockEvents
        .where((e) =>
            e.organizerIds.contains(organizer.id) && !e.isPast)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final pastEvents = mockEvents
        .where((e) =>
            e.organizerIds.contains(organizer.id) && e.isPast)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final totalEvents = upcomingEvents.length + pastEvents.length;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.slateGrey.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => UserProfileSheet.show(context, organizer),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  UserAvatar(
                    name: organizer.firstName,
                    photoUrl: organizer.photoUrl,
                    size: 56,
                    showRing: false,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${organizer.firstName} ${organizer.lastName}',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.teal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Organisateur',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (organizer.neighborhood != null)
                          Text(
                            organizer.neighborhood!,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalEvents événement${totalEvents > 1 ? 's' : ''} organisé${totalEvents > 1 ? 's' : ''}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ocean,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.slateGrey.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),

          if (organizer.bio != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: Text(
                organizer.bio!,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                  height: 1.45,
                ),
              ),
            ),
          ],

          if (upcomingEvents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Text(
                'À venir',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            ...upcomingEvents.take(3).map(
              (e) => _CompactEventTile(event: e),
            ),
          ],

          if (pastEvents.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
              child: Text(
                'Passés',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ),
            ...pastEvents.take(2).map(
              (e) => _CompactEventTile(event: e, isPast: true),
            ),
          ],

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    TipOrganizerSheet.show(context, [organizer]),
                icon: const Text('🎁', style: TextStyle(fontSize: 16)),
                label: Text(
                  'Envoyer un tip à ${organizer.firstName}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warning,
                  side: BorderSide(
                    color: AppTheme.warning.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactEventTile extends StatelessWidget {
  const _CompactEventTile({required this.event, this.isPast = false});
  final KaiEvent event;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => EventDetailScreen(event: event),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isPast
                    ? AppTheme.slateGrey.withValues(alpha: 0.08)
                    : AppTheme.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                event.category.emoji,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.neighborhood,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPast
                          ? AppTheme.secondaryText(context)
                          : AppTheme.textColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatShortDate(event.date),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppTheme.slateGrey.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatShortDate(DateTime dt) {
    const days = [
      'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim',
    ];
    const months = [
      '', 'jan', 'fév', 'mars', 'avr', 'mai', 'juin',
      'juil', 'août', 'sept', 'oct', 'nov', 'déc',
    ];
    final day = days[(dt.weekday - 1).clamp(0, 6)];
    return '$day ${dt.day} ${months[dt.month]} · '
        '${dt.hour}h${dt.minute.toString().padLeft(2, '0')}';
  }
}
