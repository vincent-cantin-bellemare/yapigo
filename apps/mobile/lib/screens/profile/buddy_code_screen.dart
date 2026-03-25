import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/theme/app_theme.dart';

class BuddyCodeScreen extends StatelessWidget {
  const BuddyCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Mon Buddy Code',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.ocean.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.group_add_outlined,
                        size: 32, color: AppTheme.ocean),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Ton Buddy Code',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppTheme.ocean.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: SelectableText(
                        user.buddyCode,
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ocean,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Partage ce code avec un ami pour participer ensemble lors d\'un événement kaiiak!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppTheme.secondaryText(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: user.buddyCode));
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
                        side: const BorderSide(
                            color: AppTheme.ocean, width: 1.5),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        textStyle: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0, duration: 400.ms),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Comment ça marche?',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _HowItWorksStep(
                    step: '1',
                    text:
                        'Partage ton code avec un ami avant un événement',
                  ),
                  _HowItWorksStep(
                    step: '2',
                    text:
                        'Ton ami entre ton code lors de son inscription',
                  ),
                  _HowItWorksStep(
                    step: '3',
                    text:
                        'Vous vous retrouvez ensemble au point de départ!',
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideY(
                    begin: 0.08, end: 0, duration: 400.ms, delay: 150.ms),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({required this.step, required this.text});
  final String step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppTheme.ocean.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ocean,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
