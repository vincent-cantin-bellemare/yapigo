import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/models/cancellation_policy.dart';
import 'package:rundate/theme/app_theme.dart';

class CancellationPolicySheet extends StatelessWidget {
  const CancellationPolicySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppTheme.cardColor(context),
      builder: (_) => const CancellationPolicySheet(),
    );
  }

  static const _tierColors = [Color(0xFF00C853), Color(0xFFFFA000), Color(0xFFD32F2F)];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.slateGrey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.policy_outlined, color: AppTheme.ocean, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Politique d\'annulation',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < CancellationPolicy.tiers.length; i++) ...[
              _TierRow(
                tier: CancellationPolicy.tiers[i],
                color: _tierColors[i],
              ),
              if (i < CancellationPolicy.tiers.length - 1)
                const SizedBox(height: 14),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.ocean.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.ocean.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppTheme.ocean),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cette politique s\'applique à tous les événements '
                      'payants sur yapigo. Les remboursements sont traités '
                      'sous 5 à 10 jours ouvrables.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.secondaryText(context),
                        height: 1.45,
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

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.color});

  final ({String title, String description, String emoji}) tier;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(tier.emoji, style: const TextStyle(fontSize: 18)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tier.title,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                tier.description,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
