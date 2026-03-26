import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/like_message_sheet.dart';
import 'package:rundate/widgets/pace_label_icon.dart';
import 'package:rundate/widgets/user_avatar.dart';
import 'package:rundate/widgets/user_photo_viewer.dart';
import 'package:rundate/data/mock_events.dart';
import 'package:rundate/data/mock_meeting_points.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/screens/events/event_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileSheet extends StatefulWidget {
  const UserProfileSheet({
    super.key,
    required this.user,
    required this.rootContext,
    this.isOwnProfile = false,
    this.similarUsers = const [],
  });

  final User user;
  final bool isOwnProfile;
  final List<User> similarUsers;

  /// Context below the modal sheet; used after [Navigator.pop] for follow-up UI.
  final BuildContext rootContext;

  static void show(
    BuildContext context,
    User user, {
    bool isOwnProfile = false,
    List<User> similarUsers = const [],
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UserProfileSheet(
        user: user,
        rootContext: context,
        isOwnProfile: isOwnProfile,
        similarUsers: similarUsers,
      ),
    );
  }

  @override
  State<UserProfileSheet> createState() => _UserProfileSheetState();
}

class _UserProfileSheetState extends State<UserProfileSheet> {
  late final List<User> _allUsers;
  late final PageController _headerPageController;
  int _currentIndex = 0;

  User get _activeUser => _allUsers[_currentIndex];
  bool get _hasSimilar => _allUsers.length > 1;

  @override
  void initState() {
    super.initState();
    _allUsers = [widget.user, ...widget.similarUsers];
    _headerPageController = PageController();
  }

  @override
  void dispose() {
    _headerPageController.dispose();
    super.dispose();
  }

  bool _isOnline(User u) {
    if (u.lastSeenDate == null) return false;
    return DateTime.now().difference(u.lastSeenDate!).inHours < 24;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final tabCount = widget.isOwnProfile ? 3 : 4;

    return DefaultTabController(
      length: tabCount,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isOwnProfile) _buildPreviewBanner(context),
                _buildHeader(context),
                _buildTabBar(context),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(_currentIndex),
                      child: TabBarView(
                        children: [
                          _buildProfileTab(context),
                          _buildStatsTab(context),
                          _buildPhotosTab(context),
                          if (!widget.isOwnProfile)
                            _buildActionsTab(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
          if (_hasSimilar)
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _headerPageController,
                itemCount: _allUsers.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (ctx, i) =>
                    _buildHeaderContent(ctx, _allUsers[i]),
              ),
            )
          else
            _buildHeaderContent(context, _activeUser),
          if (_hasSimilar) ...[
            const SizedBox(height: 10),
            _buildDotsIndicator(),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, User user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: user.firstName,
          photoUrl: user.photoUrl,
          isVerified: user.isVerified,
          xp: user.xp,
          size: 90,
          showRing: true,
          isOnline: _isOnline(user),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${user.firstName}, ${user.age}',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (user.isVerified) ...[
                    const Icon(Icons.check_circle,
                        size: 15, color: AppTheme.teal),
                    const SizedBox(width: 4),
                    Text(
                      'Vérifié',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.teal,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('·',
                          style: GoogleFonts.dmSans(
                              color:
                                  AppTheme.secondaryText(context))),
                    ),
                  ],
                  Icon(Icons.place_outlined,
                      size: 14,
                      color: AppTheme.secondaryText(context)),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      user.neighborhood ?? user.city,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppTheme.secondaryText(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDotsIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Profils similaires',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: AppTheme.secondaryText(context).withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        ...List.generate(_allUsers.length, (i) {
          final isActive = i == _currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isActive ? 8 : 6,
            height: isActive ? 8 : 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppTheme.ocean
                  : AppTheme.slateGrey.withValues(alpha: 0.3),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPreviewBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.teal.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.visibility_outlined, size: 16, color: AppTheme.teal),
          const SizedBox(width: 8),
          Text(
            'Aperçu — voilà ce que les autres voient',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      labelColor: AppTheme.ocean,
      unselectedLabelColor: AppTheme.secondaryText(context),
      indicatorColor: AppTheme.ocean,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle:
          GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle:
          GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      dividerColor: Colors.transparent,
      tabs: [
        const Tab(text: 'Profil'),
        const Tab(text: 'Stats'),
        const Tab(text: 'Photos'),
        if (!widget.isOwnProfile)
          const Tab(icon: Icon(Icons.more_horiz_rounded, size: 20)),
      ],
    );
  }

  // ── Profil tab ──

  Widget _buildBadgesRow(BuildContext context, User user) {
    final badge = BadgeLevel.fromXp(user.xp);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.ocean.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  badge.assetPath,
                  width: 14,
                  height: 14,
                  errorBuilder: (_, __, ___) => Text(
                    badge.icon,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  badge.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ocean,
                  ),
                ),
              ],
            ),
          ),
          if (user.isOrganizer) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, size: 14, color: AppTheme.ocean),
                  const SizedBox(width: 4),
                  Text(
                    'Organisateur',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    final user = _activeUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildBadgesRow(context, user),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bio',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.bio!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                height: 1.5,
                color:
                    AppTheme.textColor(context).withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (user.sexualOrientation != null &&
              user.sexualOrientation!.isNotEmpty &&
              user.sexualOrientation != 'Préfère ne pas dire') ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    '👤  ${user.sexualOrientation}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (user.bio != null || user.sexualOrientation != null)
            const SizedBox(height: 4),
          if (user.activityGoals.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Objectifs',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: user.activityGoals
                  .map(
                    (goal) => Chip(
                      label: Text(
                        goal,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.ocean,
                        ),
                      ),
                      backgroundColor:
                          AppTheme.ocean.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 0),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (user.activities.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sports & Niveaux',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...user.activities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(activity.category.emoji,
                          style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.category.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                      ),
                      intensityLevelIcon(activity.level, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        activity.level.label,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          if (user.bio == null &&
              user.activityGoals.isEmpty &&
              user.activities.isEmpty)
            _buildEmptyState(
              context,
              icon: Icons.person_outline_rounded,
              text: 'Aucune info de profil pour le moment',
            ),
        ],
      ),
    );
  }

  // ── Stats tab ──

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final df = DateFormat('d MMM yyyy', 'fr_FR');
    return df.format(date);
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '—';
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'Aujourd\'hui';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    if (diff.inDays < 30) {
      return 'Il y a ${(diff.inDays / 7).floor()} sem.';
    }
    return _formatDate(date);
  }

  Widget _buildStatsTab(BuildContext context) {
    final user = _activeUser;
    final hasStats = user.totalActivities > 0 ||
        user.connections > 0 ||
        user.averageRating != null ||
        user.memberSince != null;

    if (!hasStats) {
      return _buildEmptyState(
        context,
        icon: Icons.bar_chart_rounded,
        text: 'Pas de statistiques disponibles',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        children: [
          if (user.memberSince != null ||
              user.lastActivityDate != null ||
              user.lastSeenDate != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  if (user.memberSince != null)
                    _dateRow(
                      context,
                      icon: Icons.calendar_month_outlined,
                      label: 'Inscrit depuis',
                      value: _formatDate(user.memberSince),
                    ),
                  if (user.lastActivityDate != null) ...[
                    const SizedBox(height: 10),
                    _dateRow(
                      context,
                      icon: Icons.fitness_center_rounded,
                      label: 'Dernière activité',
                      value: _timeAgo(user.lastActivityDate),
                    ),
                  ],
                  if (user.lastSeenDate != null) ...[
                    const SizedBox(height: 10),
                    _dateRow(
                      context,
                      icon: Icons.circle,
                      label: 'Dernière connexion',
                      value: _timeAgo(user.lastSeenDate),
                      iconSize: 10,
                      iconColor: AppTheme.teal,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              if (user.connections > 0)
                _miniStat(
                  context,
                  icon: Icons.people_outline,
                  value: '${user.connections}',
                  label: 'Connexions',
                  color: AppTheme.teal,
                ),
              if (user.totalActivities > 0)
                _miniStat(
                  context,
                  icon: Icons.fitness_center_rounded,
                  value: '${user.totalActivities}',
                  label: 'Activités',
                  color: AppTheme.ocean,
                ),
              if (user.averageRating != null)
                _miniStat(
                  context,
                  icon: Icons.star_rounded,
                  value: user.averageRating!.toStringAsFixed(1),
                  label: 'Note',
                  color: AppTheme.warning,
                ),
            ],
          ),
          if (user.stravaConnected) ...[
            const SizedBox(height: 20),
            _buildStravaStatsBlock(context),
          ],
          _buildEventHistorySection(context),
        ],
      ),
    );
  }

  Widget _buildEventHistorySection(BuildContext context) {
    final userId = _activeUser.id;
    final eventIds = mockUserEventHistory[userId] ?? [];
    if (eventIds.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final allEvents = mockEvents.where((e) => eventIds.contains(e.id)).toList();

    final upcoming = allEvents.where((e) => e.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final past = allEvents.where((e) => e.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (upcoming.isEmpty && past.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (upcoming.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Prochains événements',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 10),
          ...upcoming.map((e) => _eventTile(context, e, isUpcoming: true)),
        ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Événements passés',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 10),
          ...past.map((e) => _eventTile(context, e)),
        ],
      ],
    );
  }

  Widget _eventTile(BuildContext context, KaiEvent event,
      {bool isUpcoming = false}) {
    final dateStr = DateFormat('d MMM yyyy', 'fr_CA').format(event.date);
    final mp = mockMeetingPoints
        .where((m) => m.id == event.meetingPointId)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isUpcoming
                ? AppTheme.ocean.withValues(alpha: 0.08)
                : AppTheme.teal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: mp?.photoUrl != null
                      ? Image.network(
                          mp!.photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _eventPlaceholder(event),
                        )
                      : _eventPlaceholder(event),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${event.category.emoji} ${event.neighborhood} · ${event.distanceLabel.label}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    Text(
                      '$dateStr · ${event.intensitySummary}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (event.myRating != null) ...[
                Icon(Icons.star_rounded, size: 14, color: AppTheme.warning),
                const SizedBox(width: 2),
                Text(
                  event.myRating!.toStringAsFixed(1),
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warning,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppTheme.secondaryText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventPlaceholder(KaiEvent event) {
    return Container(
      color: AppTheme.teal.withValues(alpha: 0.15),
      child: Center(
        child: Icon(
          Icons.place_rounded,
          size: 18,
          color: AppTheme.teal,
        ),
      ),
    );
  }

  Widget _buildStravaStatsBlock(BuildContext context) {
    final user = _activeUser;
    const stravaOrange = Color(0xFFFC4C02);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: stravaOrange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: stravaOrange.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: stravaOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Activité Strava',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _stravaStatChip(
                context,
                emoji: '🏅',
                value: user.stravaYtdKm != null
                    ? '${user.stravaYtdKm!.toStringAsFixed(0)} km'
                    : '—',
                label: 'cette année',
              ),
              const SizedBox(width: 8),
              _stravaStatChip(
                context,
                emoji: '📅',
                value: user.stravaYtdRuns?.toString() ?? '—',
                label: 'sorties',
              ),
              const SizedBox(width: 8),
              _stravaStatChip(
                context,
                emoji: '⚡',
                value: user.stravaAvgPaceFormatted ?? '—',
                label: 'allure moy.',
              ),
            ],
          ),
          if (user.stravaMonthKm != null) ...[
            const SizedBox(height: 10),
            Text(
              '📆  ${user.stravaMonthKm!.toStringAsFixed(0)} km ce mois',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
          if (user.stravaProfileUrl != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => launchUrl(Uri.parse(user.stravaProfileUrl!),
                    mode: LaunchMode.externalApplication),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Voir ${user.stravaDisplayName ?? user.firstName} sur Strava',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: stravaOrange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new,
                        size: 13, color: stravaOrange),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stravaStatChip(
    BuildContext context, {
    required String emoji,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppTheme.slateGrey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    double iconSize = 16,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon,
            size: iconSize,
            color: iconColor ?? AppTheme.secondaryText(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textColor(context),
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Photos tab ──

  Widget _buildPhotosTab(BuildContext context) {
    final user = _activeUser;
    if (user.photoGallery.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.photo_library_outlined,
        text: 'Aucune photo pour le moment',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: user.photoGallery.length,
      itemBuilder: (ctx, i) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserPhotoViewer(
                  photoUrls: user.photoGallery,
                  initialIndex: i,
                  userName: user.firstName,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              user.photoGallery[i],
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                color: AppTheme.slateGrey.withValues(alpha: 0.15),
                child: Icon(Icons.broken_image_outlined,
                    size: 24, color: AppTheme.secondaryText(ctx)),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Actions tab ──

  Widget _buildActionsTab(BuildContext context) {
    final user = _activeUser;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showLikeMessageBottomSheet(
                  widget.rootContext,
                  firstName: user.firstName,
                  onSend: () {
                    ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Demande envoyée à ${user.firstName}!',
                          style: GoogleFonts.dmSans(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                );
              },
              icon:
                  const Icon(Icons.favorite_outline_rounded, size: 20),
              label: Text(
                'J\'aimerais bien te connaître',
                style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Demande de connexion envoyée à ${user.firstName}!',
                      style: GoogleFonts.dmSans(),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: Text(
                'Demander une connexion',
                style: GoogleFonts.dmSans(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.teal,
                side: const BorderSide(color: AppTheme.teal),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                context,
                icon: Icons.block_outlined,
                label: 'Bloquer',
                color: AppTheme.secondaryText(context),
                onTap: () => _showBlockDialog(context),
              ),
              _actionButton(
                context,
                icon: Icons.flag_outlined,
                label: 'Signaler',
                color: AppTheme.error,
                onTap: () => _showReportDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _showBlockDialog(BuildContext context) {
    final user = _activeUser;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloquer ce profil?'),
        content: Text(
          'Tu ne verras plus ${user.firstName} '
          'dans tes groupes et conversations.',
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
              ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                SnackBar(
                  content: Text(
                    '${user.firstName} a été bloqué',
                    style: GoogleFonts.dmSans(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Bloquer'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final user = _activeUser;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler ce profil?'),
        content: Text(
          'Notre équipe va examiner le profil '
          'de ${user.firstName}.',
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
              ScaffoldMessenger.of(widget.rootContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'Signalement envoyé. Merci!',
                    style: GoogleFonts.dmSans(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style:
                FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppTheme.secondaryText(context)),
            const SizedBox(height: 8),
            Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
