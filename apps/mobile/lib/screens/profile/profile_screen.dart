import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/screens/profile/billing_screen.dart';
import 'package:rundate/screens/profile/connections_screen.dart';
import 'package:rundate/screens/profile/edit_profile_screen.dart';
import 'package:rundate/screens/profile/help_legal_screen.dart';
import 'package:rundate/screens/profile/invite_friend_screen.dart';
import 'package:rundate/screens/profile/user_profile_sheet.dart';
import 'package:rundate/screens/profile/verify_account_screen.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/utils/app_locale.dart';
import 'package:rundate/widgets/demo_banner.dart';
import 'package:rundate/widgets/user_photo_viewer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _showLanguageDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Langue / Language',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'Français',
              flag: '🇫🇷',
              selected: isFrench,
              onTap: () {
                setLocale(const Locale('fr'));
                Navigator.of(ctx).pop();
                setState(() {});
                _showRestartSnackBar();
              },
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'English',
              flag: '🇬🇧',
              selected: isEnglish,
              onTap: () {
                setLocale(const Locale('en'));
                Navigator.of(ctx).pop();
                setState(() {});
                _showRestartSnackBar();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFrench
              ? 'Redémarre l\'app pour appliquer le changement'
              : 'Restart the app to apply the change',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(user: user)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      UserProfileSheet.show(context, user, isOwnProfile: true),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: Text('Voir mon profil public',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.teal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: AppTheme.teal.withValues(alpha: 0.3)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _ProfileCompletenessCard(user: user)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
              if (user.bio != null && user.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                _BioCard(bio: user.bio!.trim()),
              ],
              if (user.activityGoals.isNotEmpty) ...[
                const SizedBox(height: 20),
                _ActivityGoalsCard(user: user),
              ],
              const SizedBox(height: 24),
              _buildMenuCard(user),
              const SizedBox(height: 28),
              FutureBuilder<PackageInfo>(
                future: _packageInfoFuture,
                builder: (context, snapshot) {
                  final version =
                      snapshot.hasData ? snapshot.data!.version : '1.0.0';
                  final build =
                      snapshot.hasData ? snapshot.data!.buildNumber : '';
                  const buildDate = String.fromEnvironment('BUILD_DATE',
                      defaultValue: '');
                  final label = buildDate.isNotEmpty
                      ? 'Run Date v$version ($build) · $buildDate'
                      : 'Run Date v$version ($build)';
                  return Center(
                    child: Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _DemoToggleRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(User user) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.slateGrey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.person_outline,
            title: 'Mon profil',
            iconColor: AppTheme.navyIcon(context),
            onTap: () => _push(const EditProfileScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.verified_user_outlined,
            title: 'Vérifier mon compte',
            iconColor: user.isVerified ? AppTheme.navyIcon(context) : AppTheme.teal,
            onTap: () => _push(const VerifyAccountScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.share_outlined,
            title: 'Inviter un ami',
            iconColor: AppTheme.ocean,
            onTap: () => _push(const InviteFriendScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Factures & paiements',
            iconColor: AppTheme.navyIcon(context),
            onTap: () => _push(const BillingScreen()),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuTile(
            icon: Icons.directions_run_rounded,
            title: 'Strava',
            iconColor: const Color(0xFFFC4C02),
            onTap: () => _push(const ConnectionsScreen()),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuTile(
            icon: Icons.info_outline,
            title: 'Aide & infos légales',
            iconColor: AppTheme.navyIcon(context),
            onTap: () => _push(const HelpAndLegalScreen()),
          ),
          _ProfileMenuTile(
            icon: Icons.language,
            title: 'Langue : ${isFrench ? 'Français' : 'English'}',
            iconColor: AppTheme.navyIcon(context),
            onTap: _showLanguageDialog,
            showChevron: false,
          ),
          _ProfileMenuTile(
            icon: AppTheme.themeMode.value == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            title: 'Mode sombre',
            iconColor: AppTheme.navyIcon(context),
            onTap: () {
              AppTheme.toggleTheme();
              setState(() {});
            },
            showChevron: false,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileMenuTile(
            icon: Icons.logout,
            title: 'Déconnexion',
            iconColor: AppTheme.secondaryText(context),
            onTap: () => demoMode.value = false,
          ),
        ],
      ),
    );
  }
}

class _DemoToggleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: demoMode,
      builder: (context, isConnected, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.navy.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppTheme.navy.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'DEMO',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isConnected ? 'Connecté' : 'Non connecté',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ),
              Switch.adaptive(
                value: isConnected,
                onChanged: (_) => demoMode.toggle(),
                activeTrackColor: AppTheme.ocean,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final initial =
        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';

    return Column(
      children: [
        Container(
          width: 112,
          height: 112,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.slateGrey.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Container(
              color: AppTheme.cardColor(context),
              width: 108,
              height: 108,
              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                  ? Image.network(
                      user.photoUrl!,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _AvatarPlaceholder(initial: initial),
                    )
                  : _AvatarPlaceholder(initial: initial),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Text(
              user.firstName,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
            ),
            Image.asset(
              user.badge.assetPath,
              width: 20,
              height: 20,
              errorBuilder: (_, _, _) => Text(
                user.badge.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Text(
              user.badge.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _VerificationChip(isVerified: user.isVerified),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${user.neighborhood != null ? '${user.neighborhood}, ${user.city}' : user.city} · ${user.age} ans',
          style: GoogleFonts.dmSans(
            fontSize: 15,
            color: AppTheme.secondaryText(context),
            fontWeight: FontWeight.w500,
          ),
        ),
        if (user.photoGallery.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...user.photoGallery.take(4).toList().asMap().entries.map(
                  (entry) {
                    final i = entry.key;
                    final url = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
                      child: GestureDetector(
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
                            url,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 72,
                              height: 72,
                              color:
                                  AppTheme.slateGrey.withValues(alpha: 0.15),
                              child: Icon(Icons.broken_image_outlined,
                                  size: 20, color: AppTheme.secondaryText(context)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (user.photoGallery.length > 4)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => UserPhotoViewer(
                              photoUrls: user.photoGallery,
                              initialIndex: 4,
                              userName: user.firstName,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppTheme.slateGrey.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '+${user.photoGallery.length - 4}',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.secondaryText(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.initial});
  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.ocean.withValues(alpha: 0.2),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: GoogleFonts.nunito(
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: AppTheme.ocean,
        ),
      ),
    );
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.teal.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: AppTheme.teal.withValues(alpha: 0.45)),
        ),
        child: Text(
          '✓ Vérifié',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.teal,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.slateGrey.withValues(alpha: 0.25)),
      ),
      child: Text(
        'Non vérifié',
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.secondaryText(context),
        ),
      ),
    );
  }
}


class _ProfileCompletenessCard extends StatelessWidget {
  const _ProfileCompletenessCard({required this.user});
  final User user;

  double get _completionPercentage {
    double total = 0;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) total += 20;
    if (user.bio != null && user.bio!.isNotEmpty) total += 15;
    if (user.isVerified) total += 20;
    if (user.totalActivities >= 1) total += 15;
    if (user.averageRating != null) total += 15;
    if (user.activities.isNotEmpty) total += 15;
    return total;
  }

  (String, String, IconData)? get _firstIncompleteSuggestion {
    if (user.photoUrl == null || user.photoUrl!.isEmpty) {
      return ('Ajoute une photo pour te démarquer!', 'Ajouter', Icons.camera_alt_outlined);
    }
    if (user.bio == null || user.bio!.isEmpty) {
      return ('Écris une bio pour te présenter!', 'Écrire', Icons.edit_outlined);
    }
    if (!user.isVerified) {
      return ('Vérifie ton compte pour inspirer confiance!', 'Vérifier', Icons.verified_user_outlined);
    }
    if (user.activities.isEmpty) {
      return ('Choisis tes sports pour être bien placé!', 'Choisir', Icons.sports_outlined);
    }
    if (user.totalActivities < 1) {
      return ('Participe à ta première activité!', 'Explorer', Icons.explore_outlined);
    }
    if (user.averageRating == null) {
      return ('Reçois ta première évaluation!', 'Participer', Icons.star_outline);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pct = _completionPercentage;
    final isComplete = pct >= 100;

    if (isComplete) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.teal.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.teal, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profil complet!',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.teal,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms);
    }

    final suggestion = _firstIncompleteSuggestion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.slateGrey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: pct / 100,
                    color: AppTheme.ocean,
                    trackColor: AppTheme.slateGrey.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${pct.toInt()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ocean,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ton profil est complet à ${pct.toInt()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (suggestion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        suggestion.$1,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.secondaryText(context),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (suggestion != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(suggestion.$3, size: 18),
                label: Text(suggestion.$2),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.ocean,
                  side: const BorderSide(color: AppTheme.ocean, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.05,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }
}

class _CircularProgressPainter extends CustomPainter {
  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 6) / 2;
    const strokeWidth = 5.0;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}


class _BioCard extends StatefulWidget {
  const _BioCard({required this.bio});
  final String bio;

  @override
  State<_BioCard> createState() => _BioCardState();
}

class _BioCardState extends State<_BioCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(
                  'À propos',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navyIcon(context),
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: AppTheme.secondaryText(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            firstChild: GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Text(
                widget.bio,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  height: 1.45,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
            secondChild: Text(
              widget.bio,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                height: 1.45,
                color: AppTheme.textColor(context),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          if (!_expanded && widget.bio.length > 120)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Text(
                  'Lire la suite',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ocean,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textColor(context),
        ),
      ),
      trailing: showChevron
          ? Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.slateGrey.withValues(alpha: 0.6),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _ActivityGoalsCard extends StatelessWidget {
  const _ActivityGoalsCard({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.slateGrey.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes objectifs',
            style: GoogleFonts.nunito(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 14),
          if (user.activityGoals.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: user.activityGoals.map((goal) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.ocean.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.ocean,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}


class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.flag,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppTheme.ocean.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.ocean : AppTheme.slateGrey.withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? AppTheme.textColor(context) : AppTheme.secondaryText(context),
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, size: 22, color: AppTheme.ocean),
          ],
        ),
      ),
    );
  }
}
