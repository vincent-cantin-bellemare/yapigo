import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

class InviteFriendScreen extends StatelessWidget {
  const InviteFriendScreen({super.key});

  static const _inviteCode = 'RUNDATE-ALEX42';
  static const _inviteLink =
      'https://rundate.app/invite/$_inviteCode';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Inviter un ami',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.ocean.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_add_outlined,
                  size: 48, color: AppTheme.ocean),
            ),
            const SizedBox(height: 24),
            Text(
              'Invite un ami à bouger!',
              style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context)),
            ),
            const SizedBox(height: 12),
            Text(
              'Quand un ami s\'inscrit avec ton code, vous participez ensemble dès la première activité!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.secondaryText(context),
                  height: 1.45),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Text('Ton code',
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryText(context))),
                  const SizedBox(height: 10),
                  SelectableText(
                    _inviteCode,
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ocean,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          const ClipboardData(text: _inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Code copié!',
                              style: GoogleFonts.dmSans()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copier le code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.ocean,
                      side: const BorderSide(color: AppTheme.ocean),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Partage ouvert',
                          style: GoogleFonts.dmSans()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Partager le lien'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  textStyle: GoogleFonts.nunito(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _inviteLink,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.secondaryText(context)),
            ),
          ],
        ),
      ),
    );
  }
}
