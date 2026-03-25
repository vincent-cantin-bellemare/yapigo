import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/data/mock_users.dart';
import 'package:kaiiak/theme/app_theme.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({super.key});

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  int? _selectedSlot;
  bool _booked = false;

  static final _slots = [
    'Lundi 10h00 - 10h15',
    'Lundi 14h00 - 14h15',
    'Mardi 11h00 - 11h15',
    'Mardi 16h00 - 16h15',
    'Mercredi 9h00 - 9h15',
    'Jeudi 13h00 - 13h15',
  ];

  @override
  Widget build(BuildContext context) {
    final isVerified = currentUser.isVerified;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Vérifier mon compte',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: isVerified
            ? _buildAlreadyVerified()
            : _booked
                ? _buildBooked()
                : _buildSlotPicker(),
      ),
    );
  }

  Widget _buildAlreadyVerified() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.teal.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified,
              size: 56, color: AppTheme.teal),
        ),
        const SizedBox(height: 24),
        Text('Ton compte est déjà vérifié!',
            style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 12),
        Text(
          'Tu as le badge vérifié sur ton profil.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 15, color: AppTheme.secondaryText(context), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildBooked() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.teal.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.event_available,
              size: 56, color: AppTheme.teal),
        ),
        const SizedBox(height: 24),
        Text('Rendez-vous confirmé!',
            style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 12),
        Text(
          'Créneau: ${_slots[_selectedSlot!]}',
          style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.teal),
        ),
        const SizedBox(height: 16),
        Text(
          'Tu recevras un lien FaceTime par notification. '
          'L\'appel dure environ 2 minutes.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 14, color: AppTheme.secondaryText(context), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildSlotPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.videocam_outlined,
                size: 40, color: AppTheme.teal),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Vérifie ton identité',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor(context)),
        ),
        const SizedBox(height: 8),
        Text(
          'Un membre de notre équipe validera ton identité par un court appel FaceTime (~2 min).',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              fontSize: 14, color: AppTheme.secondaryText(context), height: 1.5),
        ),
        const SizedBox(height: 28),
        Text('Choisis un créneau:',
            style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context))),
        const SizedBox(height: 14),
        ...List.generate(_slots.length, (i) {
          final selected = _selectedSlot == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => setState(() => _selectedSlot = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: selected
                        ? AppTheme.teal.withValues(alpha: 0.08)
                        : AppTheme.cardColor(context),
                    border: Border.all(
                      color: selected
                          ? AppTheme.teal
                          : AppTheme.slateGrey.withValues(alpha: 0.25),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: selected
                            ? AppTheme.teal
                            : AppTheme.secondaryText(context),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(_slots[i],
                          style: GoogleFonts.dmSans(
                              fontSize: 15, color: AppTheme.textColor(context))),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedSlot != null
              ? () => setState(() => _booked = true)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.teal,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppTheme.slateGrey.withValues(alpha: 0.3),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            textStyle: GoogleFonts.nunito(
                fontSize: 16, fontWeight: FontWeight.w700),
          ),
          child: const Text('Confirmer le créneau'),
        ),
      ],
    );
  }
}
