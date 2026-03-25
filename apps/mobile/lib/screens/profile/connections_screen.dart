import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/data/mock_users.dart';
import 'package:yapigo/models/user.dart';
import 'package:yapigo/screens/profile/contact_form_screen.dart';
import 'package:yapigo/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectionsScreen extends StatelessWidget {
  const ConnectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mes connexions',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StravaConnectionCard(user: user)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0, duration: 400.ms),
            const SizedBox(height: 20),
            OrganizerCard(isOrganizer: user.isOrganizer)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideY(
                    begin: 0.08, end: 0, duration: 400.ms, delay: 100.ms),
          ],
        ),
      ),
    );
  }
}

// ── Strava connection card ──────────────────────────────────────────────────

class StravaConnectionCard extends StatefulWidget {
  const StravaConnectionCard({super.key, required this.user});
  final User user;

  @override
  State<StravaConnectionCard> createState() => _StravaConnectionCardState();
}

class _StravaConnectionCardState extends State<StravaConnectionCard> {
  static const Color _stravaOrange = Color(0xFFFC4C02);

  late bool _connected;

  @override
  void initState() {
    super.initState();
    _connected = widget.user.stravaConnected;
  }

  void _handleConnect() {
    setState(() => _connected = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Compte Strava connecté !', style: GoogleFonts.dmSans()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _stravaOrange,
      ),
    );
  }

  void _handleDisconnect() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Déconnecter Strava ?',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        content: Text(
          'Tes données Strava seront supprimées de yapigo. Tu pourras reconnecter en tout temps.',
          style: GoogleFonts.dmSans(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Déconnecter',
                style: GoogleFonts.dmSans(color: AppTheme.error)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        setState(() => _connected = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Strava déconnecté.', style: GoogleFonts.dmSans()),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _connected
              ? _stravaOrange.withValues(alpha: 0.35)
              : AppTheme.slateGrey.withValues(alpha: 0.2),
        ),
      ),
      child: _connected ? _buildConnected() : _buildDisconnected(),
    );
  }

  Widget _buildDisconnected() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StravaLogo(size: 38),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Connecte ton compte Strava',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Synchronise tes activités pour afficher tes stats, détecter ton niveau naturel et épater la galerie — sans rien saisir à la main.',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.secondaryText(context),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.slateGrey.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '🔒  Tes données restent privées, ne sont jamais revendues et sont supprimées si tu fermes ton compte. Tu peux déconnecter Strava en tout temps.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.secondaryText(context),
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleConnect,
            icon: StravaLogo(size: 20, tint: Colors.white),
            label: const Text('Connecter Strava'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _stravaOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnected() {
    final user = widget.user;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StravaLogo(size: 38),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Strava connecté',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: user.stravaProfileUrl != null
                        ? () => launchUrl(
                            Uri.parse(user.stravaProfileUrl!),
                            mode: LaunchMode.externalApplication)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.stravaDisplayName ??
                              '${user.firstName} ${user.lastName}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: user.stravaProfileUrl != null
                                ? _stravaOrange
                                : AppTheme.secondaryText(context),
                          ),
                        ),
                        if (user.stravaProfileUrl != null) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.open_in_new,
                              size: 12, color: _stravaOrange),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      size: 14, color: AppTheme.teal),
                  const SizedBox(width: 4),
                  Text(
                    'Actif',
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            StravaStat(
              label: 'cette année',
              value: user.stravaYtdKm != null
                  ? '${user.stravaYtdKm!.toStringAsFixed(0)} km'
                  : '—',
              icon: '🏅',
            ),
            const SizedBox(width: 12),
            StravaStat(
              label: 'sorties',
              value: user.stravaYtdRuns?.toString() ?? '—',
              icon: '📅',
            ),
            const SizedBox(width: 12),
            StravaStat(
              label: 'allure moy.',
              value: user.stravaAvgPaceFormatted ?? '—',
              icon: '⚡',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleDisconnect,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Déconnecter Strava',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StravaLogo extends StatelessWidget {
  const StravaLogo({super.key, required this.size, this.tint});
  final double size;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    const stravaOrange = Color(0xFFFC4C02);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint != null ? Colors.transparent : stravaOrange,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'S',
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontWeight: FontWeight.w900,
            fontSize: size * 0.62,
            color: tint ?? Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class StravaStat extends StatelessWidget {
  const StravaStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.slateGrey.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
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
}

class OrganizerCard extends StatelessWidget {
  const OrganizerCard({super.key, required this.isOrganizer});
  final bool isOrganizer;

  @override
  Widget build(BuildContext context) {
    if (isOrganizer) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.warning.withValues(alpha: 0.15),
              AppTheme.warning.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(Icons.shield_rounded, size: 32, color: AppTheme.ocean),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Organisateur certifié 🏅',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.warning,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tu guides les groupes avec brio!',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.textColor(context),
                      height: 1.3,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, size: 32, color: AppTheme.ocean),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Deviens Organisateur!',
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Les Organisateurs sont les personnes ressources de yapigo. '
            'Tu guides le groupe, tu donnes le rythme et tu '
            't\'assures que personne ne reste seul à l\'arrière. '
            'C\'est un rôle clé pour la communauté!',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ContactFormScreen(
                      preselectedSubject: ContactSubject.becomeOrganizer,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.mail_outline, size: 18),
              label: const Text('Postuler comme Organisateur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: GoogleFonts.nunito(
                  fontSize: 15,
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
