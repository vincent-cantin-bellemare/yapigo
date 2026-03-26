import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/models/cancellation_policy.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/screens/apply/apply_wizard_screen.dart';
import 'package:rundate/theme/app_theme.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key, required this.event});

  final KaiEvent event;

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    Future.microtask(() => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  String get _mockConfirmationCode {
    final r = Random(widget.event.id.hashCode);
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  void _continueToRegistration() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ApplyWizardScreen(event: widget.event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),

                  // Success icon
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.teal.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 44,
                        color: AppTheme.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Paiement confirmé!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ton inscription sera finalisée après les prochaines étapes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: AppTheme.secondaryText(context),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Payment details card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.slateGrey.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                            label: 'Activité',
                            value:
                                '${e.category.emoji} ${e.category.label}'),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: 'Lieu',
                          value: '${e.neighborhood}, ${e.city}',
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: 'Montant',
                          value: e.priceLabel,
                          valueColor: AppTheme.ocean,
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          label: 'Confirmation',
                          value: _mockConfirmationCode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Cancellation reminder
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.ocean.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: AppTheme.ocean),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            CancellationPolicy.policyText,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.secondaryText(context),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continueToRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ocean,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continuer l\'inscription',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.06,
              numberOfParticles: 25,
              gravity: 0.15,
              colors: const [
                AppTheme.teal,
                AppTheme.ocean,
                AppTheme.cyan,
                Color(0xFFFFA000),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.secondaryText(context),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textColor(context),
            ),
          ),
        ),
      ],
    );
  }
}
