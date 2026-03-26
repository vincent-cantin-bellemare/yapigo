import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/models/cancellation_policy.dart';
import 'package:rundate/models/kai_event.dart';
import 'package:rundate/screens/payment/payment_confirmation_screen.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/cancellation_policy_sheet.dart';

class PaymentCheckoutScreen extends StatefulWidget {
  const PaymentCheckoutScreen({super.key, required this.event});

  final KaiEvent event;

  @override
  State<PaymentCheckoutScreen> createState() => _PaymentCheckoutScreenState();
}

class _PaymentCheckoutScreenState extends State<PaymentCheckoutScreen> {
  bool _acceptedPolicy = false;

  void _pay() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => _MockStripePaymentSheet(
        amount: widget.event.price!,
      ),
    ).then((success) {
      if (success == true && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => PaymentConfirmationScreen(event: widget.event),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final tierLabel = CancellationPolicy.currentTierLabel(e.date);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppTheme.textColor(context),
        elevation: 0,
        title: Text(
          'Paiement',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Event summary
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.slateGrey.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résumé',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textColor(context),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SummaryLine(
                          label: 'Activité',
                          value: '${e.category.emoji} ${e.category.label}',
                        ),
                        const SizedBox(height: 8),
                        _SummaryLine(
                          label: 'Lieu',
                          value: '${e.neighborhood}, ${e.city}',
                        ),
                        const SizedBox(height: 8),
                        _SummaryLine(
                          label: 'Date',
                          value:
                              '${e.date.day}/${e.date.month}/${e.date.year} · '
                              '${e.date.hour}h${e.date.minute.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 8),
                        _SummaryLine(
                          label: 'Intensité',
                          value:
                              '${e.intensityLevel.emoji} ${e.intensityLevel.label}',
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '1× ${e.category.label}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 15,
                                  color: AppTheme.textColor(context),
                                ),
                              ),
                            ),
                            Text(
                              e.priceLabel,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textColor(context),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Total',
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textColor(context),
                                ),
                              ),
                            ),
                            Text(
                              e.priceLabel,
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ocean,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancellation policy card
                  GestureDetector(
                    onTap: () => CancellationPolicySheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.ocean.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.ocean.withValues(alpha: 0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.policy_outlined,
                                  size: 20, color: AppTheme.ocean),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Politique d\'annulation',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textColor(context),
                                  ),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: AppTheme.ocean, size: 22),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            CancellationPolicy.policyText,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.secondaryText(context),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Actuellement : $tierLabel',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment security badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.slateGrey.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 20, color: AppTheme.teal),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Paiement sécurisé par Stripe. Tes informations '
                            'bancaires ne sont jamais stockées sur nos serveurs.',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: AppTheme.secondaryText(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accept policy checkbox
                  GestureDetector(
                    onTap: () =>
                        setState(() => _acceptedPolicy = !_acceptedPolicy),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptedPolicy,
                            onChanged: (v) =>
                                setState(() => _acceptedPolicy = v ?? false),
                            activeColor: AppTheme.ocean,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'J\'accepte les conditions d\'annulation et '
                            'de remboursement',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.textColor(context),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _acceptedPolicy ? _pay : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ocean,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.slateGrey.withValues(alpha: 0.35),
                    disabledForegroundColor: Colors.white70,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Payer ${e.priceLabel}',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
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
              color: AppTheme.textColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Mock Stripe Payment Sheet
// ---------------------------------------------------------------------------

class _MockStripePaymentSheet extends StatefulWidget {
  const _MockStripePaymentSheet({required this.amount});

  final double amount;

  @override
  State<_MockStripePaymentSheet> createState() =>
      _MockStripePaymentSheetState();
}

class _MockStripePaymentSheetState extends State<_MockStripePaymentSheet> {
  bool _processing = false;

  static const _stripePurple = Color(0xFF635BFF);

  void _confirm() {
    setState(() => _processing = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.lock_rounded, size: 20, color: _stripePurple),
                const SizedBox(width: 10),
                Text(
                  'Paiement sécurisé',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade900,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _stripePurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'stripe',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _stripePurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Mock card field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded,
                      size: 22, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    '•••• •••• •••• 4242',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '12/28',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Amount
            Center(
              child: Text(
                '${widget.amount.toStringAsFixed(0)} \$',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade900,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _processing ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stripePurple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _stripePurple.withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Confirmer le paiement',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            if (!_processing) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
