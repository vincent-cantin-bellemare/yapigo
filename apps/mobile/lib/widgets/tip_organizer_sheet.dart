import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/models/user.dart';
import 'package:rundate/theme/app_theme.dart';
import 'package:rundate/widgets/user_avatar.dart';

class TipOrganizerSheet extends StatefulWidget {
  const TipOrganizerSheet({super.key, required this.organizers});

  final List<User> organizers;

  static Future<void> show(BuildContext context, List<User> organizers) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TipOrganizerSheet(organizers: organizers),
    );
  }

  @override
  State<TipOrganizerSheet> createState() => _TipOrganizerSheetState();
}

class _TipOrganizerSheetState extends State<TipOrganizerSheet> {
  int? _selectedAmount;
  bool _submitted = false;

  static const _amounts = [2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
          const SizedBox(height: 20),
          const Text('🎁', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            widget.organizers.length == 1
                ? 'Remercie ${widget.organizers.first.firstName}!'
                : 'Remercie tes organisateurs!',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Un petit tip pour dire merci',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: widget.organizers.map((o) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UserAvatar(
                    name: o.firstName,
                    photoUrl: o.photoUrl,
                    size: 40,
                    showRing: false,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    o.firstName,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ..._amounts.map((amount) {
                final selected = _selectedAmount == amount;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: _submitted
                          ? null
                          : () => setState(() => _selectedAmount = amount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.warning.withValues(alpha: 0.15)
                              : AppTheme.cardColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.warning
                                : AppTheme.slateGrey.withValues(alpha: 0.25),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$amount \$',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? AppTheme.warning
                                : AppTheme.textColor(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: _submitted
                        ? null
                        : () => setState(() => _selectedAmount = -1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedAmount == -1
                            ? AppTheme.warning.withValues(alpha: 0.15)
                            : AppTheme.cardColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedAmount == -1
                              ? AppTheme.warning
                              : AppTheme.slateGrey.withValues(alpha: 0.25),
                          width: _selectedAmount == -1 ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Autre',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _selectedAmount == -1
                              ? AppTheme.warning
                              : AppTheme.textColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitted || _selectedAmount == null
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      setState(() => _submitted = true);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Merci pour ta générosité! 🎉',
                            style: GoogleFonts.dmSans(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              icon: _submitted
                  ? const Icon(Icons.check_rounded, size: 20)
                  : const Text('💝', style: TextStyle(fontSize: 16)),
              label: Text(_submitted ? 'Tip envoyé!' : 'Envoyer un tip'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warning,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppTheme.slateGrey.withValues(alpha: 0.25),
                disabledForegroundColor: Colors.white70,
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
