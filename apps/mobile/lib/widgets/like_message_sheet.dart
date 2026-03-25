import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/theme/app_theme.dart';

Future<void> showLikeMessageBottomSheet(
  BuildContext context, {
  required String firstName,
  required VoidCallback onSend,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return _LikeMessageSheetContent(
        firstName: firstName,
        onSend: () {
          Navigator.of(ctx).pop();
          onSend();
        },
      );
    },
  );
}

class _LikeMessageSheetContent extends StatefulWidget {
  const _LikeMessageSheetContent({
    required this.firstName,
    required this.onSend,
  });

  final String firstName;
  final VoidCallback onSend;

  static const _presets = [
    'C\'était le fun!',
    'Tu vas revenir pour que je te paye un drink?',
    'On se reprend ça bientôt?',
    'T\'es pas mal rapide, j\'ai aimé ça!',
  ];

  @override
  State<_LikeMessageSheetContent> createState() =>
      _LikeMessageSheetContentState();
}

class _LikeMessageSheetContentState extends State<_LikeMessageSheetContent> {
  int? _selectedPreset;
  final _customController = TextEditingController();

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  bool get _canSend =>
      _selectedPreset != null ||
      _customController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 48),
      decoration: const BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 10, 24, 24 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppTheme.slateGrey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Envoyer un message à ${widget.firstName}?',
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  _LikeMessageSheetContent._presets.length,
                  (i) {
                    final text = _LikeMessageSheetContent._presets[i];
                    final selected = _selectedPreset == i;
                    return ChoiceChip(
                      label: Text(
                        text,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              selected ? Colors.white : AppTheme.navy,
                          height: 1.25,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedPreset = i),
                      selectedColor: AppTheme.ocean,
                      backgroundColor: AppTheme.cardColor(context),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.ocean
                            : AppTheme.slateGrey.withValues(alpha: 0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customController,
                onChanged: (_) => setState(() {}),
                maxLines: 2,
                maxLength: 200,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.navy,
                ),
                decoration: InputDecoration(
                  hintText: 'Ton message (optionnel)',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.slateGrey.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.ocean,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSend ? widget.onSend : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ocean,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.slateGrey.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Envoyer'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Annuler',
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slateGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
