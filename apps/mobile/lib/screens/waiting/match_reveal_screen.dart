import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_bring_items.dart';
import 'package:kaiiak/data/mock_events.dart';
import 'package:kaiiak/data/mock_meeting_points.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/data/mock_weather.dart';
import 'package:kaiiak/models/meeting_point.dart';
import 'package:kaiiak/models/kai_event.dart';
import 'package:kaiiak/models/user.dart';
import 'package:kaiiak/screens/home/main_shell.dart';
import 'package:kaiiak/theme/app_theme.dart';
import 'package:kaiiak/widgets/weather_badge.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchRevealScreen extends StatefulWidget {
  const MatchRevealScreen({super.key, this.event, this.buddyUserId});
  final KaiEvent? event;
  final String? buddyUserId;

  @override
  State<MatchRevealScreen> createState() => _MatchRevealScreenState();
}

class _MatchRevealScreenState extends State<MatchRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;
  late final Animation<double> _emojiScale;
  late final Animation<double> _titleFade;

  bool _phase2 = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _emojiScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0, 0.65, curve: Curves.elasticOut),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.38, 0.92, curve: Curves.easeOut),
      ),
    );

    _revealController.forward().then((_) {
      if (mounted) setState(() => _phase2 = true);
    });
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  void _openMainShell(int tabIndex) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => MainShell(initialTabIndex: tabIndex),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ev = widget.event ??
        mockEvents.firstWhere((e) => e.isRegistered && !e.isPast,
            orElse: () => mockEvents.first);
    final meetingPoint = mockMeetingPoints.firstWhere(
      (p) => p.id == ev.meetingPointId,
      orElse: () => mockMeetingPoints.first,
    );
    // Demo: synthetic group mates (real matching not wired yet).
    final matchedGroup = mockUsers
        .where((u) => u.id != currentUser.id)
        .take(5)
        .toList();

    User? organizer;
    if (ev.hasOrganizers && ev.organizerIds.isNotEmpty) {
      final organizerMatches = mockUsers.where((u) => u.id == ev.organizerIds.first);
      if (organizerMatches.isNotEmpty) organizer = organizerMatches.first;
    }

    User? buddy;
    if (widget.buddyUserId != null) {
      final buddyMatches =
          mockUsers.where((u) => u.id == widget.buddyUserId);
      if (buddyMatches.isNotEmpty) buddy = buddyMatches.first;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOut,
        child: _phase2
            ? _PhaseTwoContent(
                key: const ValueKey('phase2'),
                meetingPoint: meetingPoint,
                event: ev,
                groupMembers: matchedGroup,
                organizer: organizer,
                buddy: buddy,
                onMessage: () => _openMainShell(3),
                onHome: () => _openMainShell(0),
              )
            : _PhaseOneReveal(
                key: const ValueKey('phase1'),
                controller: _revealController,
                emojiScale: _emojiScale,
                titleFade: _titleFade,
              ),
      ),
    );
  }
}

class _PhaseOneReveal extends StatelessWidget {
  const _PhaseOneReveal({
    super.key,
    required this.controller,
    required this.emojiScale,
    required this.titleFade,
  });

  final AnimationController controller;
  final Animation<double> emojiScale;
  final Animation<double> titleFade;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: emojiScale,
                  child: const Text(
                    '🏃',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 112),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: titleFade,
                  child: Text(
                    'Ton groupe est formé!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PhaseTwoContent extends StatelessWidget {
  const _PhaseTwoContent({
    super.key,
    required this.meetingPoint,
    required this.event,
    required this.groupMembers,
    required this.onMessage,
    required this.onHome,
    this.organizer,
    this.buddy,
  });

  final MeetingPoint meetingPoint;
  final KaiEvent event;
  final List<User> groupMembers;
  final User? organizer;
  final User? buddy;
  final VoidCallback onMessage;
  final VoidCallback onHome;

  String get _formattedDateTime {
    const days = [
      '',
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche'
    ];
    final d = event.date;
    final day = days[d.weekday];
    final dayCapitalized = '${day[0].toUpperCase()}${day.substring(1)}';
    return '$dayCapitalized ${d.day}/${d.month} à ${d.hour}h${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ton groupe est prêt!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${groupMembers.length + 1} participants (toi inclus)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _GroupMembersGrid(members: groupMembers),
                    const SizedBox(height: 20),
                    _OrganizerSection(organizer: organizer),
                    if (buddy != null) ...[
                      const SizedBox(height: 12),
                      _BuddyBanner(buddy: buddy!),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Votre rendez-vous',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.secondaryText(context),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formattedDateTime,
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.warning,
                      ),
                    ),
                    if (mockWeatherByEventId.containsKey(event.id)) ...[
                      const SizedBox(height: 16),
                      WeatherBadge(
                        forecast: mockWeatherByEventId[event.id]!,
                      ),
                    ],
                    const SizedBox(height: 22),
                    _PaceDistanceCard(event: event),
                    const SizedBox(height: 16),
                    _MeetingPointRevealCard(meetingPoint: meetingPoint),
                    if (event.aperoSmoothieSpot != null) ...[
                      const SizedBox(height: 16),
                      _AperoSmoothieCard(spot: event.aperoSmoothieSpot!),
                    ],
                    const SizedBox(height: 22),
                    _BringItemsSection(members: groupMembers),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: onMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ocean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Écrire au groupe 💬',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onHome,
                    child: Text(
                      'Retour à l\'accueil',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryText(context),
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.secondaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupMembersGrid extends StatelessWidget {
  const _GroupMembersGrid({required this.members});
  final List<User> members;

  static const _avatarColors = [
    AppTheme.ocean,
    AppTheme.teal,
    AppTheme.teal,
    AppTheme.warning,
    Color(0xFF7B8FD4),
    AppTheme.error,
    Color(0xFF9B7FBF),
    AppTheme.navy,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 14,
      alignment: WrapAlignment.center,
      children: List.generate(members.length, (i) {
        final user = members[i];
        final color = _avatarColors[i % _avatarColors.length];
        return SizedBox(
          width: 90,
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withValues(alpha: 0.8),
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      user.firstName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  if (user.isVerified) ...[
                    const SizedBox(width: 3),
                    const Icon(Icons.verified,
                        color: AppTheme.teal, size: 14),
                  ],
                ],
              ),
              Text(
                '${user.age} ans',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    user.badge.assetPath,
                    width: 20,
                    height: 20,
                    errorBuilder: (_, _, _) => Text(
                      user.badge.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.badge.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.slateGrey.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Organizer section.
class _OrganizerSection extends StatelessWidget {
  const _OrganizerSection({this.organizer});
  final User? organizer;

  @override
  Widget build(BuildContext context) {
    if (organizer != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.warning,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warning.withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.shield_rounded, size: 20, color: AppTheme.ocean),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ton Organisateur : ${organizer!.firstName}',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.warning,
                    ),
                  ),
                  Text(
                    'Il/elle donne le rythme au groupe',
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
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.groups_rounded, size: 24, color: AppTheme.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pas d\'Organisateur — le groupe décide du rythme ensemble!',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Buddy highlight banner.
class _BuddyBanner extends StatelessWidget {
  const _BuddyBanner({required this.buddy});
  final User buddy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_rounded, color: AppTheme.teal, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tu participes avec ${buddy.firstName}! 🎯',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Intensity and distance card.
class _PaceDistanceCard extends StatelessWidget {
  const _PaceDistanceCard({required this.event});
  final KaiEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  event.intensityLevel.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  event.intensityLevel.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                Text(
                  event.intensityLevel.description,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppTheme.slateGrey.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  event.distanceLabel.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(height: 6),
                Text(
                  event.distanceLabel.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                Text(
                  event.distanceLabel.description,
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
    );
  }
}

class _MeetingPointRevealCard extends StatelessWidget {
  const _MeetingPointRevealCard({required this.meetingPoint});

  final MeetingPoint meetingPoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppTheme.warning.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warning.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Point de départ 📍',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meetingPoint.typeEmoji,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetingPoint.name,
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      meetingPoint.address,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.35,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meetingPoint.neighborhood,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.navyIcon(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (meetingPoint.mapsUrl != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(meetingPoint.mapsUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri,
                        mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Voir sur la carte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navyIcon(context),
                  side: BorderSide(
                      color: AppTheme.navy.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ravito Smoothie post-run spot card.
class _AperoSmoothieCard extends StatelessWidget {
  const _AperoSmoothieCard({required this.spot});
  final String spot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icons/apero_smoothie.png',
            width: 28,
            height: 28,
            errorBuilder: (_, _, _) =>
                const Text('🥤', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ravito Smoothie',
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spot,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BringItemsSection extends StatelessWidget {
  const _BringItemsSection({required this.members});
  final List<User> members;

  @override
  Widget build(BuildContext context) {
    final allMembers = [currentUser, ...members];
    final membersWithItems = allMembers
        .where((u) => mockBringItems.containsKey(u.id))
        .toList();

    if (membersWithItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'On amène quoi? 🎒',
            style: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ...membersWithItems.map((user) {
            final items = mockBringItems[user.id] ?? [];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      user.firstName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: items.map((item) {
                        final emoji = bringItemEmojis[item] ?? '📦';
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.teal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$emoji $item',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textColor(context),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
