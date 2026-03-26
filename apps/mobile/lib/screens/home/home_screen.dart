import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:rundate/data/mock_event_photos.dart';
import 'package:rundate/data/mock_events.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/screens/community/community_feed_screen.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/events/event_detail_screen.dart';
import 'package:rundate/screens/events/events_list_screen.dart';
import 'package:rundate/screens/events/rate_event_screen.dart';
import 'package:rundate/screens/home/main_shell.dart';
import 'package:rundate/screens/profile/contact_form_screen.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rundate/widgets/photo_gallery_viewer.dart';
import 'package:rundate/widgets/user_avatar.dart';
import 'package:rundate/widgets/skeletons/shimmer_block.dart';

// ---------------------------------------------------------------------------
// Testimonial data
// ---------------------------------------------------------------------------

final _testimonials = [
  (
    'On s\'est rencontrés lors d\'un Run Date. Maintenant on court ensemble tous les matins!',
    'Sophie',
    31,
    'https://i.pravatar.cc/100?img=1',
    5,
  ),
  (
    'Les groupes sont toujours bien formés. J\'ai trouvé mon rythme (et mon match)!',
    'Marc-Antoine',
    38,
    'https://i.pravatar.cc/100?img=3',
    4,
  ),
  (
    'J\'étais sceptique mais le Ravito après, c\'est là que la magie opère!',
    'Émilie',
    42,
    'https://i.pravatar.cc/100?img=9',
    5,
  ),
  (
    'Enfin une app de dating qui sort du swipe! On bouge, on jase, on connecte pour vrai.',
    'Olivier',
    36,
    'https://i.pravatar.cc/100?img=7',
    4,
  ),
];

const _taglines = [
  'Ce weekend, on bouge ensemble!',
  'Les plus belles rencontres commencent en bougeant',
  'Ton prochain coup de cœur t\'attend à la prochaine course',
  'Sors du swipe, bouge pour vrai',
  'Chaque course est une nouvelle rencontre',
];

// ---------------------------------------------------------------------------
// Registration status enum
// ---------------------------------------------------------------------------

enum HomeRegistrationStatus {
  notRegistered,
  registeredWaiting,
  matched,
  pastDate,
}

String _formatOrganizerNames(List<User> organizers) {
  if (organizers.isEmpty) return '';
  if (organizers.length == 1) return organizers.first.firstName;
  if (organizers.length == 2) {
    return '${organizers[0].firstName} et ${organizers[1].firstName}';
  }
  final extra = organizers.length - 2;
  return '${organizers[0].firstName}, ${organizers[1].firstName} '
      'et $extra autre${extra > 1 ? 's' : ''}';
}

// ---------------------------------------------------------------------------
// HomeScreen
// ---------------------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String _tagline;
  bool _isLoading = true;

  HomeRegistrationStatus get _demoStatus {
    final pastRated = mockEvents.where(
      (e) => e.isPast && e.registrationStatus != RegistrationStatus.notRegistered && e.myRating == null,
    );
    if (pastRated.isNotEmpty) return HomeRegistrationStatus.pastDate;

    final registered = mockEvents.where(
      (e) => !e.isPast && e.registrationStatus != RegistrationStatus.notRegistered,
    );
    if (registered.isEmpty) return HomeRegistrationStatus.notRegistered;

    final deadline = registered.first.deadline;
    if (DateTime.now().isAfter(deadline)) {
      return HomeRegistrationStatus.matched;
    }
    return HomeRegistrationStatus.registeredWaiting;
  }

  @override
  void initState() {
    super.initState();
    _tagline = _taglines[math.Random().nextInt(_taglines.length)];
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = currentUser;
    final popular = mockEvents.take(4).toList();

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: const _HomeSkeletonLoader(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.ocean,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 800));
            if (mounted) setState(() {});
          },
          child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Section 1 — Hero Banner
            SliverToBoxAdapter(
              child: _HeroBanner(user: user, theme: theme, tagline: _tagline),
            ),

            // Section 2 — Status Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: _StatusCard(status: _demoStatus, theme: theme)
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideX(begin: -0.05, end: 0, duration: 500.ms, delay: 300.ms),
              ),
            ),

            // Section 3 — Community Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                child: _CommunityStats(theme: theme),
              ),
            ),

            // Section 3b — Runners of the Month
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _RunnersOfTheMonth(theme: theme),
              ),
            ),

            // Section 3c — New members
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _NewMembersSection(theme: theme),
              ),
            ),

            // Section 3d — Compatible profiles
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _CompatibleProfilesSection(theme: theme),
              ),
            ),

            // Section — Active Members
            SliverToBoxAdapter(
              child: _ActiveMembersSection(theme: theme),
            ),

            // Section 4 — Testimonials Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 28),
                child: _TestimonialsSection(theme: theme),
              ),
            ),

            // Section 4b — Promo Video
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _PromoVideoCard(theme: theme),
              ),
            ),

            // Section 5 — Popular Events
            SliverToBoxAdapter(
              child: _PopularEventsSection(
                events: popular,
                theme: theme,
              ),
            ),

            // Section 6 — Community Photos Preview
            SliverToBoxAdapter(
              child: _CommunityPhotosPreview(theme: theme),
            ),

            // Section 6b — Propose Route Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _ProposeRouteCard(theme: theme),
              ).animate().fadeIn(duration: 500.ms, delay: 1250.ms),
            ),

            // Section 6c — Become Organizer Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _BecomeOrganizerCard(theme: theme),
              ).animate().fadeIn(duration: 500.ms, delay: 1300.ms),
            ),

            // Theme toggle card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: _ThemeToggleCard(),
              ),
            ),

            // Section 7 — Bottom CTA
            SliverToBoxAdapter(
              child: _BottomCta(theme: theme),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Skeleton loader shown while home data "loads"
// ===========================================================================

class _HomeSkeletonLoader extends StatelessWidget {
  const _HomeSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ShimmerBlock(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const ShimmerCircle(size: 56),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerRect(width: 140, height: 18),
                    SizedBox(height: 8),
                    ShimmerRect(width: 200, height: 14),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ShimmerRect(height: 120, borderRadius: 16),
            const SizedBox(height: 28),
            const ShimmerRect(width: 180, height: 20),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: ShimmerRect(height: 80, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerRect(height: 80, borderRadius: 12)),
                SizedBox(width: 12),
                Expanded(child: ShimmerRect(height: 80, borderRadius: 12)),
              ],
            ),
            const SizedBox(height: 28),
            const ShimmerRect(width: 200, height: 20),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: ShimmerRect(height: 170, borderRadius: 16)),
                SizedBox(width: 12),
                Expanded(child: ShimmerRect(height: 170, borderRadius: 16)),
              ],
            ),
            const SizedBox(height: 28),
            const ShimmerRect(width: 160, height: 20),
            const SizedBox(height: 14),
            const ShimmerRect(height: 100, borderRadius: 16),
          ],
        ),
      ),
    );  
  }
}

// ===========================================================================
// Section 1 — Hero Banner
// ===========================================================================

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.user,
    required this.theme,
    required this.tagline,
  });

  final User user;
  final ThemeData theme;
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF00BCD4),
            Color(0xFF0097A7),
            Color(0xFF00838F),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Large decorative ring (top right)
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 24,
                ),
              ),
            ),
          ),
          // Small accent dot
          Positioned(
            top: 80,
            right: 50,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),
          // Bottom-left soft glow
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar: logo wordmark + badge
                Row(
                  children: [
                    Image.asset(
                      'assets/images/logo_rundate_white.png',
                      height: 42,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1, end: 0, duration: 400.ms),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            user.badge.assetPath,
                            width: 18,
                            height: 18,
                            errorBuilder: (_, _, _) => Text(
                              user.badge.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.badge.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideX(begin: 0.1, end: 0, duration: 500.ms, delay: 200.ms),
                  ],
                ),

                const SizedBox(height: 20),

                // Avatar + greeting row
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.firstName[0],
                                style: GoogleFonts.nunito(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 50.ms)
                        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 400.ms, delay: 50.ms),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Salut ${user.firstName}!',
                            style: GoogleFonts.nunito(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 100.ms)
                              .slideX(begin: 0.1, end: 0, duration: 500.ms, delay: 100.ms),
                          const SizedBox(height: 4),
                          Text(
                            tagline,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.35,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick stats row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _HeroStat(value: '${user.totalActivities}', label: 'courses', icon: Icons.directions_run),
                      Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.2)),
                      _HeroStat(value: '4.6', label: 'note', icon: Icons.favorite_rounded),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 300.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ===========================================================================
// Section 2 — Status Card (delegates to sub-cards)
// ===========================================================================

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status, required this.theme});

  final HomeRegistrationStatus status;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      HomeRegistrationStatus.notRegistered => _NotRegisteredCard(theme: theme),
      HomeRegistrationStatus.registeredWaiting => _WaitingCard(theme: theme),
      HomeRegistrationStatus.matched => _MatchedCard(theme: theme),
      HomeRegistrationStatus.pastDate => _PastRunCard(theme: theme),
    };
  }
}

class _NotRegisteredCard extends StatelessWidget {
  const _NotRegisteredCard({required this.theme});

  final ThemeData theme;

  void _goToEvents(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EventsListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.ocean,
            AppTheme.ocean.withValues(alpha: 0.88),
            const Color(0xFF00BCD4),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ocean.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ton prochain Run Date t\'attend!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inscris-toi avant la clôture',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 22),
          const _EventDeadlineCountdown(),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _goToEvents(context),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
              textStyle:
                  GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }
}

/// Short French label for how long ago the user joined (mock `memberSince`).
String _relativeTime(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) return 'Il y a ${diff.inDays ~/ 365} an(s)';
  if (diff.inDays > 30) return 'Il y a ${diff.inDays ~/ 30} mois';
  if (diff.inDays > 0) return 'Il y a ${diff.inDays} j';
  return 'Aujourd\'hui';
}

// Returns the registration deadline for the next upcoming event.
// Falls back to 7 days from now if no future event is found.
DateTime nextEventDeadline() {
  final now = DateTime.now();
  final upcoming = mockEvents
      .where((e) => e.date.isAfter(now))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  if (upcoming.isNotEmpty) {
    final eventDate = upcoming.first.date;
    return eventDate.subtract(const Duration(days: 1));
  }
  final fallback = DateTime(now.year, now.month, now.day).add(const Duration(days: 7));
  return DateTime(fallback.year, fallback.month, fallback.day, 14, 0);
}

class _EventDeadlineCountdown extends StatefulWidget {
  const _EventDeadlineCountdown();

  @override
  State<_EventDeadlineCountdown> createState() =>
      _EventDeadlineCountdownState();
}

class _EventDeadlineCountdownState extends State<_EventDeadlineCountdown> {
  late DateTime _target;
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _target = nextEventDeadline();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final diff = _target.difference(now);
    if (!mounted) return;
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _remaining.inDays;
    final h = _remaining.inHours.remainder(24);
    final m = _remaining.inMinutes.remainder(60);
    final s = _remaining.inSeconds.remainder(60);

    final chips = <_CountChipData>[
      _CountChipData(label: 'jours', value: d.toString().padLeft(2, '0')),
      _CountChipData(label: 'heures', value: h.toString().padLeft(2, '0')),
      _CountChipData(label: 'min', value: m.toString().padLeft(2, '0')),
      _CountChipData(label: 'sec', value: s.toString().padLeft(2, '0')),
    ];

    return Row(
      children: [
        for (var i = 0; i < chips.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                ':',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          Expanded(child: _CountChip(data: chips[i])),
        ],
      ],
    );
  }
}

class _CountChipData {
  const _CountChipData({required this.label, required this.value});
  final String label;
  final String value;
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.data});

  final _CountChipData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            data.value,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatefulWidget {
  const _WaitingCard({required this.theme});

  final ThemeData theme;

  @override
  State<_WaitingCard> createState() => _WaitingCardState();
}

class _WaitingCardState extends State<_WaitingCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const _slides = [
    (
      'assets/images/carousel/carousel_01_activity.png',
      'Trouve ton Run Date',
      'Choisis une course près de chez toi et rencontre quelqu\'un qui partage ta passion.',
    ),
    (
      'assets/images/carousel/carousel_02_meetup.png',
      'Rejoins le groupe',
      'On se retrouve au point de rencontre. L\'organisateur fait les présentations.',
    ),
    (
      'assets/images/carousel/carousel_03_activity.png',
      'On court ensemble!',
      'On court en duo ou en groupe, à ton rythme. L\'important, c\'est la connexion.',
    ),
    (
      'assets/images/carousel/carousel_04_ravito.png',
      'L\'Apéro Smoothie',
      'Après la course, on jase autour d\'un smoothie. C\'est là que la magie opère!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final (imageUrl, title, description) = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.2, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.teal,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${index + 1}/${_slides.length}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_slides.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: i == _currentPage ? 20 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppTheme.teal
                    : AppTheme.slateGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _MatchedCard extends StatelessWidget {
  const _MatchedCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final shell = context.findAncestorStateOfType<MainShellState>();
          shell?.switchTab(3);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.ocean.withValues(alpha: 0.55),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.ocean.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.ocean.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.groups_rounded,
                    color: AppTheme.ocean, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ton groupe est prêt!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.textColor(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Découvre les membres de ton groupe et le point de départ!',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppTheme.secondaryText(context)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.ocean),
            ],
          ),
        ),
      ),
    );
  }
}

class _PastRunCard extends StatelessWidget {
  const _PastRunCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border:
            Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Comment c\'était?',
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Ton avis nous aide à améliorer les prochains rendez-vous.',
            style:
                theme.textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryText(context)),
          ),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              final pastEvent = mockEvents
                  .where(
                      (e) => e.isPast && e.registrationStatus != RegistrationStatus.notRegistered && e.myRating == null)
                  .firstOrNull;
              if (pastEvent != null) {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => RateEventScreen(event: pastEvent),
                  ),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.teal,
              side: const BorderSide(color: AppTheme.teal, width: 1.8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              'Noter la course',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section 3 — Community Stats
// ===========================================================================

class _CommunityStats extends StatelessWidget {
  const _CommunityStats({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ce mois-ci',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 400.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 400.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.event_rounded,
                iconColor: AppTheme.ocean,
                targetValue: 8,
                label: 'courses',
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 500.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.location_on_rounded,
                iconColor: AppTheme.teal,
                targetValue: 5,
                label: 'quartiers',
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 600.ms),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.group_add_rounded,
                iconColor: AppTheme.warning,
                targetValue: 42,
                label: 'inscrits',
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 700.ms),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    this.icon,
    this.iconWidget,
    required this.iconColor,
    required this.targetValue,
    required this.label,
    this.formatAsThousand = false,
    this.isRating = false,
  }) : assert(icon != null || iconWidget != null);

  final IconData? icon;
  final Widget? iconWidget;
  final Color iconColor;
  final int targetValue;
  final String label;
  final bool formatAsThousand;
  final bool isRating;

  String _formatNumber(int value) {
    if (isRating) return '${(value / 10).toStringAsFixed(1)} ★';
    if (formatAsThousand) {
      final str = value.toString();
      final buf = StringBuffer();
      for (var i = 0; i < str.length; i++) {
        if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
        buf.write(str[i]);
      }
      return buf.toString();
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          iconWidget ??
              Icon(icon!, color: iconColor, size: 26),
          const SizedBox(height: 10),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: targetValue),
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Text(
                _formatNumber(value),
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(context),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryText(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section 3b — Runners of the Moment ("La Royauté du moment")
// ===========================================================================

class _RunnersOfTheMonth extends StatelessWidget {
  const _RunnersOfTheMonth({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final men = mockUsers.where((u) => u.gender == 'Homme').toList()
      ..sort((a, b) => b.totalActivities.compareTo(a.totalActivities));
    final women = mockUsers.where((u) => u.gender != 'Homme').toList()
      ..sort((a, b) => b.totalActivities.compareTo(a.totalActivities));
    final king = men.isNotEmpty ? men.first : null;
    final queen = women.isNotEmpty ? women.first : null;

    if (king == null && queen == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'La Royauté du moment',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/icons/crown.png',
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) => const Text('👑',
                  style: TextStyle(fontSize: 22)),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 500.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 500.ms),
        const SizedBox(height: 6),
        Text(
          'Les plus actifs de la communauté en ce moment!',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.secondaryText(context),
          ),
        ).animate().fadeIn(delay: 550.ms, duration: 300.ms),
        const SizedBox(height: 16),
        Row(
          children: [
            if (king != null)
              Expanded(
                child: _CrownCard(
                  user: king,
                  title: 'Le King',
                  accentColor: AppTheme.navyIcon(context),
                  crownEmoji: '👑',
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 600.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 600.ms),
              ),
            if (king != null && queen != null) const SizedBox(width: 12),
            if (queen != null)
              Expanded(
                child: _CrownCard(
                  user: queen,
                  title: 'La Queen',
                  accentColor: AppTheme.ocean,
                  crownEmoji: '👑',
                )
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 700.ms)
                    .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 700.ms),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Center(
          child: TextButton.icon(
            onPressed: () => _showCastleMembers(context, men, women),
            icon: const Icon(Icons.castle_outlined, size: 18),
            label: Text(
              'Voir les autres membres du château',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.navyIcon(context),
            ),
          ),
        ).animate().fadeIn(delay: 800.ms, duration: 300.ms),
      ],
    );
  }

  static void _showCastleMembers(
    BuildContext context,
    List<User> men,
    List<User> women,
  ) {
    final allSorted = <User>[...men, ...women]
      ..sort((a, b) => b.totalActivities.compareTo(a.totalActivities));
    final top = allSorted.take(10).toList();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                'Les membres du château 🏰',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textColor(ctx),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: top.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final u = top[i];
                  final rank = i + 1;
                  final medal = rank == 1
                      ? '🥇'
                      : rank == 2
                          ? '🥈'
                          : rank == 3
                              ? '🥉'
                              : '#$rank';
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            medal,
                            style: GoogleFonts.dmSans(
                              fontSize: rank <= 3 ? 20 : 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondaryText(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 10),
                        UserAvatar(
                          name: u.firstName,
                          photoUrl: u.photoUrl,
                          size: 42,
                          showRing: rank <= 3,
                        ),
                      ],
                    ),
                    title: Text(
                      u.firstName,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Image.asset(
                          u.badge.assetPath,
                          width: 20,
                          height: 20,
                          errorBuilder: (_, _, _) => Text(
                            u.badge.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            u.badge.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.secondaryText(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.navyIcon(context).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${u.totalActivities} courses',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.navyIcon(context),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      UserProfileSheet.show(context, u);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CrownCard extends StatelessWidget {
  const _CrownCard({
    required this.user,
    required this.title,
    required this.accentColor,
    required this.crownEmoji,
  });

  final User user;
  final String title;
  final Color accentColor;
  final String crownEmoji;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UserProfileSheet.show(context, user),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar with crown overlay
            SizedBox(
              width: 72,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: UserAvatar(
                        name: user.firstName,
                        photoUrl: user.photoUrl,
                        size: 60,
                        showRing: false,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: Text(crownEmoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              user.firstName,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 8),
            // Km progress bar
            Column(
              children: [
                Text(
                  '${user.totalActivities} courses',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: LinearProgressIndicator(
                      value: (user.totalActivities / 15).clamp(0.0, 1.0),
                      backgroundColor:
                          accentColor.withValues(alpha: 0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Section 3c — New members ("Les p'tits nouveaux")
// ===========================================================================

class _NewMembersSection extends StatelessWidget {
  const _NewMembersSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final sorted = mockUsers.toList()
      ..sort((a, b) {
        final ad = a.memberSince;
        final bd = b.memberSince;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    final members = sorted.take(6).toList();

    if (members.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Les p\'tits nouveaux',
              style: GoogleFonts.nunito(
                textStyle: theme.textTheme.titleLarge,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              'assets/icons/nouveaux_membres.png',
              width: 24,
              height: 24,
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 820.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 820.ms),
        const SizedBox(height: 6),
        Text(
          'Bienvenue parmi nous!',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.secondaryText(context),
          ),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: 860.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 155,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: members.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final user = members[index];
              return _NewMemberCard(user: user)
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: Duration(milliseconds: 880 + index * 70),
                  )
                  .slideY(
                    begin: 0.12,
                    end: 0,
                    duration: 500.ms,
                    delay: Duration(milliseconds: 880 + index * 70),
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _NewMemberCard extends StatelessWidget {
  const _NewMemberCard({required this.user});

  final User user;

  bool get _hasPhoto => user.photoUrl != null && user.photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    const photoHeight = 95.0;

    return GestureDetector(
      onTap: () => UserProfileSheet.show(context, user),
      child: Container(
        width: 110,
        height: 155,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: photoHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasPhoto)
                    Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _placeholderPhoto(),
                    )
                  else
                    _placeholderPhoto(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Text(
                        user.firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                                blurRadius: 4, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (user.isVerified)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: Icon(Icons.verified_rounded,
                          size: 16, color: Colors.white),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    _relativeTime(user.memberSince),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderPhoto() {
    final colors = [
      AppTheme.ocean, AppTheme.teal, AppTheme.teal,
      AppTheme.warning, const Color(0xFF7B8FD4), AppTheme.error,
    ];
    final color =
        colors[user.firstName.hashCode.abs() % colors.length];
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        user.firstName.isNotEmpty
            ? user.firstName[0].toUpperCase()
            : '?',
        style: GoogleFonts.nunito(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ===========================================================================
// Section 3d — Compatible profiles suggestion
// ===========================================================================

const _compatibilityReasons = [
  'Même niveau d\'intensité',
  'Actif dans ton quartier',
  'Courses en commun',
  'Même tranche d\'âge',
];

class _CompatibleProfilesSection extends StatelessWidget {
  const _CompatibleProfilesSection({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final current = currentUser;
    final others = mockUsers
        .where((u) => u.id != current.id)
        .take(4)
        .toList();

    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Des gens à découvrir',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 900.ms)
            .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 900.ms),
        const SizedBox(height: 6),
        Text(
          'Run Date favorise les rencontres actives, en vrai. '
          'Découvre ces profils à ta prochaine course!',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.secondaryText(context),
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 940.ms, duration: 300.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: others.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = others[index];
              final reason = _compatibilityReasons[
                  index % _compatibilityReasons.length];
              return _CompatibleProfileCard(
                user: user,
                reason: reason,
              )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: Duration(milliseconds: 960 + index * 80),
                  )
                  .slideY(
                    begin: 0.12,
                    end: 0,
                    duration: 500.ms,
                    delay: Duration(milliseconds: 960 + index * 80),
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _CompatibleProfileCard extends StatelessWidget {
  const _CompatibleProfileCard({
    required this.user,
    required this.reason,
  });

  final User user;
  final String reason;

  bool get _hasPhoto => user.photoUrl != null && user.photoUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    const photoHeight = 130.0;

    return GestureDetector(
      onTap: () => UserProfileSheet.show(context, user),
      child: Container(
        width: 150,
        height: 205,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppTheme.ocean.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: photoHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_hasPhoto)
                    Image.network(
                      user.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _placeholderPhoto(),
                    )
                  else
                    _placeholderPhoto(),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding:
                          const EdgeInsets.fromLTRB(10, 20, 10, 8),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black54
                          ],
                        ),
                      ),
                      child: Text(
                        '${user.firstName}, ${user.age}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                                blurRadius: 4,
                                color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (user.isVerified)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.verified_rounded,
                          size: 18, color: Colors.white),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.ocean.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.ocean,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderPhoto() {
    final colors = [
      AppTheme.ocean, AppTheme.teal, AppTheme.teal,
      AppTheme.warning, const Color(0xFF7B8FD4), AppTheme.error,
    ];
    final color =
        colors[user.firstName.hashCode.abs() % colors.length];
    return Container(
      color: color.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        user.firstName.isNotEmpty
            ? user.firstName[0].toUpperCase()
            : '?',
        style: GoogleFonts.nunito(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ===========================================================================
// Section 4 — Testimonials Carousel
// ===========================================================================

class _TestimonialsSection extends StatefulWidget {
  const _TestimonialsSection({required this.theme});

  final ThemeData theme;

  @override
  State<_TestimonialsSection> createState() => _TestimonialsSectionState();
}

class _TestimonialsSectionState extends State<_TestimonialsSection> {
  final _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Ce qu\'ils en disent',
            style: widget.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 800.ms),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _testimonials.length,
            itemBuilder: (context, index) {
              final t = _testimonials[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _TestimonialCard(
                  quote: t.$1,
                  name: t.$2,
                  age: t.$3,
                  photoUrl: t.$4,
                  rating: t.$5,
                ),
              );
            },
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 900.ms),
        const SizedBox(height: 14),
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: _testimonials.length,
            effect: WormEffect(
              dotWidth: 8,
              dotHeight: 8,
              spacing: 8,
              activeDotColor: AppTheme.ocean,
              dotColor: AppTheme.slateGrey.withValues(alpha: 0.25),
            ),
          ),
        ),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({
    required this.quote,
    required this.name,
    required this.age,
    required this.photoUrl,
    required this.rating,
  });

  final String quote;
  final String name;
  final int age;
  final String photoUrl;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppTheme.ocean.withValues(alpha: 0.35),
            size: 28,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              quote,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppTheme.textColor(context),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              UserAvatar(
                name: name,
                photoUrl: photoUrl,
                size: 36,
                showRing: false,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$name, $age ans',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textColor(context),
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 14,
                          color: i < rating
                              ? AppTheme.warning
                              : AppTheme.slateGrey.withValues(alpha: 0.3),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section 4b — Promo Video
// ===========================================================================

class _PromoVideoCard extends StatelessWidget {
  const _PromoVideoCard({required this.theme});
  final ThemeData theme;

  static const _videoId = '8-0Zm4cV5ro';
  static const _youtubeUrl = 'https://www.youtube.com/watch?v=$_videoId';
  static const _thumbnailUrl = 'https://img.youtube.com/vi/$_videoId/hqdefault.jpg';

  Future<void> _openVideo() async {
    final uri = Uri.parse(_youtubeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inspiration course',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Pourquoi bouger change ta vie — regarde cette vidéo motivante!',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.secondaryText(context),
          ),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _openVideo,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  _thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppTheme.navy,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.ocean.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          'Regarder sur YouTube',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 950.ms).slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 950.ms);
  }
}

// ===========================================================================
// Section 5 — Popular Events
// ===========================================================================

class _PopularEventsSection extends StatelessWidget {
  const _PopularEventsSection({
    required this.events,
    required this.theme,
  });

  final List<KaiEvent> events;
  final ThemeData theme;

  static const _gradients = [
    [AppTheme.ocean, Color(0xFF00BCD4)],
    [AppTheme.navy, Color(0xFF3B5998)],
    [AppTheme.teal, AppTheme.teal],
    [AppTheme.warning, Color(0xFFE8C44A)],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Événements populaires',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const EventsListScreen()),
                  );
                },
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ocean,
                  ),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 400.ms, delay: 1000.ms),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final gradient = _gradients[i % _gradients.length];
              return _EnhancedEventCard(
                event: events[i],
                theme: theme,
                gradientColors: gradient,
              )
                  .animate()
                  .fadeIn(
                    duration: 500.ms,
                    delay: Duration(milliseconds: 1100 + i * 100),
                  )
                  .slideX(
                    begin: 0.15,
                    end: 0,
                    duration: 500.ms,
                    delay: Duration(milliseconds: 1100 + i * 100),
                  );
            },
          ),
        ),
      ],
    );
  }
}

class _EnhancedEventCard extends StatelessWidget {
  const _EnhancedEventCard({
    required this.event,
    required this.theme,
    required this.gradientColors,
  });

  final KaiEvent event;
  final ThemeData theme;
  final List<Color> gradientColors;

  String _formatDate(DateTime dt) {
    const days = [
      '', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche',
    ];
    const months = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
    ];
    return '${days[dt.weekday].substring(0, 1).toUpperCase()}${days[dt.weekday].substring(1)} ${dt.day} ${months[dt.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        width: 210,
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header strip
            Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.neighborhood,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navyIcon(context),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(event.date),
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) {
                        final orgUsers = event.organizerIds
                            .map((id) => mockUsers.cast<User?>().firstWhere(
                                  (u) => u!.id == id,
                                  orElse: () => null,
                                ))
                            .whereType<User>()
                            .toList();
                        if (orgUsers.isEmpty) return const SizedBox.shrink();
                        final names = _formatOrganizerNames(orgUsers);
                        return Row(
                          children: [
                            SizedBox(
                              width: orgUsers.length > 1 ? 32.0 : 20.0,
                              height: 20,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  for (var i = 0; i < orgUsers.length.clamp(0, 2); i++)
                                    Positioned(
                                      left: i * 12.0,
                                      child: UserAvatar(
                                        name: orgUsers[i].firstName,
                                        photoUrl: orgUsers[i].photoUrl,
                                        size: 20,
                                        showRing: false,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Organisé par $names',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppTheme.secondaryText(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.people_alt_outlined,
                            size: 14, color: AppTheme.secondaryText(context)),
                        const SizedBox(width: 4),
                        Text(
                        '${event.menCount}H - ${event.womenCount}F',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.textColor(context),
                        ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            size: 13, color: AppTheme.slateGrey.withValues(alpha: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// Section 6b — Propose Route Card
// ===========================================================================

class _ProposeRouteCard extends StatelessWidget {
  const _ProposeRouteCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.explore_outlined, color: AppTheme.teal, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Propose-nous un endroit',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'On pourrait l\'ajouter au prochain événement!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactFormScreen(
                      preselectedSubject: ContactSubject.newMeetingPoint,
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.teal,
                side: BorderSide(color: AppTheme.teal.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Proposer un parcours',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section 6c — Become Organizer Card
// ===========================================================================

class _BecomeOrganizerCard extends StatelessWidget {
  const _BecomeOrganizerCard({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.navy,
            Color(0xFF163A5C),
          ],
        ),
        border: Border.all(
          color: AppTheme.teal.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, size: 26, color: AppTheme.teal),
          ),
          const SizedBox(height: 14),
          Text(
            'Deviens Organisateur dans ton quartier!',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les Organisateurs sont les leaders de la communauté. Tu guides le groupe, '
            'tu donnes le rythme et tu t\'assures que tout le monde passe un bon moment.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactFormScreen(
                      preselectedSubject: ContactSubject.becomeOrganizer,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: AppTheme.navy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Postuler',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Section 7 — Bottom CTA
// ===========================================================================

class _BottomCta extends StatelessWidget {
  const _BottomCta({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Text(
              'Prêt à bouger?',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Bouge et rencontre du monde pour vrai!',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EventsListScreen(),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  textStyle: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: const Text('Explorer les événements'),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1400.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1400.ms);
  }
}

// ===========================================================================
// Section 6 — Community Photos Preview
// ===========================================================================

class _CommunityPhotosPreview extends StatelessWidget {
  const _CommunityPhotosPreview({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final photos = mockEventPhotos.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (photos.isEmpty) return const SizedBox.shrink();

    final display = photos.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Communauté',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.camera_alt_rounded,
                size: 22,
                color: AppTheme.teal,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CommunityFeedScreen(),
                    ),
                  );
                },
                child: Text(
                  'Voir tout',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ocean,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: display.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final photo = display[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PhotoGalleryViewer(
                          photos: photos,
                          initialIndex: i,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            photo.photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: AppTheme.slateGrey.withValues(alpha: 0.1),
                              child: Icon(Icons.image_outlined,
                                  color: AppTheme.secondaryText(context)),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Text(
                                photo.userName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 1200.ms)
        .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: 1200.ms);
  }
}

// ---------------------------------------------------------------------------
// Active Members Section — horizontal scroll linking to Members tab
// ---------------------------------------------------------------------------

class _ActiveMembersSection extends StatelessWidget {
  const _ActiveMembersSection({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final members = mockUsers
        .where((u) => u.id != 'u0')
        .toList()
      ..sort((a, b) => b.totalActivities.compareTo(a.totalActivities));
    final top = members.take(8).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Membres actifs',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final shell =
                        context.findAncestorStateOfType<MainShellState>();
                    shell?.switchTab(2);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voir tout',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.ocean,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppTheme.ocean),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: top.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final u = top[i];
                return GestureDetector(
                  onTap: () => UserProfileSheet.show(context, u),
                  child: SizedBox(
                    width: 68,
                    child: Column(
                      children: [
                        UserAvatar(
                          name: u.firstName,
                          photoUrl: u.photoUrl,
                          size: 56,
                          isVerified: u.isVerified,
                          xp: u.xp,
                          showRing: true,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          u.firstName,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (100 + i * 60).ms)
                    .slideX(
                      begin: 0.15,
                      end: 0,
                      duration: 300.ms,
                      delay: (100 + i * 60).ms,
                    );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 900.ms)
        .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 900.ms);
  }
}

class _ThemeToggleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        AppTheme.toggleTheme();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.slateGrey.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.warning.withValues(alpha: 0.12)
                    : AppTheme.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                size: 22,
                color: isDark ? AppTheme.warning : AppTheme.navy,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDark ? 'Trop sombre?' : 'Mal aux yeux?',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDark
                        ? 'Passe en mode ensoleillé'
                        : 'Passe en mode sombre',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark ? AppTheme.warning : AppTheme.navy,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                    size: 14,
                    color: isDark ? AppTheme.warning : AppTheme.navy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
