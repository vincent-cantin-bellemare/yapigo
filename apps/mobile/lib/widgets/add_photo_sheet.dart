import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/data/mock_events.dart';
import 'package:yapigo/models/kai_event.dart';
import 'package:yapigo/theme/app_theme.dart';

class AddPhotoSheet extends StatefulWidget {
  const AddPhotoSheet({super.key, this.preselectedEventId});

  final String? preselectedEventId;

  static Future<void> show(BuildContext context, {String? eventId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPhotoSheet(preselectedEventId: eventId),
    );
  }

  @override
  State<AddPhotoSheet> createState() => _AddPhotoSheetState();
}

class _AddPhotoSheetState extends State<AddPhotoSheet> {
  String? _selectedEventId;
  final _descriptionController = TextEditingController();
  bool _photoSelected = false;
  bool _contentAccepted = false;

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.preselectedEventId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  List<KaiEvent> get _pastEvents {
    return mockEvents
        .where((e) => e.isPast && e.registrationStatus != RegistrationStatus.notRegistered)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _frenchDate(DateTime dt) {
    const months = [
      '',
      'jan.',
      'fév.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juill.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${dt.day} ${months[dt.month]}';
  }

  void _simulatePickPhoto() {
    setState(() => _photoSelected = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Photo sélectionnée (simulé)',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Photo ajoutée avec succès!',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.teal,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _pastEvents;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.slateGrey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Ajouter une photo',
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Partage un souvenir de ta course!',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.slateGrey,
                ),
              ),
              const SizedBox(height: 24),
              if (widget.preselectedEventId == null) ...[
                Text(
                  'Quel run?',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  Text(
                    'Aucun run passé',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppTheme.slateGrey,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: events.map((e) {
                      final selected = _selectedEventId == e.id;
                      return ChoiceChip(
                        label: Text(
                          '${e.neighborhood} · ${_frenchDate(e.date)}',
                        ),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedEventId = e.id),
                        selectedColor: AppTheme.teal.withValues(alpha: 0.2),
                        backgroundColor: AppTheme.cream,
                        labelStyle: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected ? AppTheme.teal : AppTheme.navy,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: selected
                                ? AppTheme.teal
                                : AppTheme.slateGrey.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
              ],
              GestureDetector(
                onTap: _simulatePickPhoto,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _photoSelected
                          ? AppTheme.teal
                          : AppTheme.slateGrey.withValues(alpha: 0.25),
                      width: _photoSelected ? 2 : 1,
                    ),
                  ),
                  child: _photoSelected
                      ? Stack(
                          children: [
                            Center(
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 48,
                                color: AppTheme.teal,
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Text(
                                'Photo sélectionnée',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  color: AppTheme.teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 40,
                              color:
                                  AppTheme.slateGrey.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Touche pour choisir une photo',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppTheme.slateGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Caméra ou galerie',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color:
                                    AppTheme.slateGrey.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Description (optionnel)',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLength: 140,
                maxLines: 2,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.navy,
                ),
                decoration: InputDecoration(
                  hintText: 'Un petit mot sur cette photo...',
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: AppTheme.slateGrey.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppTheme.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.slateGrey.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.teal),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () =>
                    setState(() => _contentAccepted = !_contentAccepted),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _contentAccepted
                        ? AppTheme.ocean.withValues(alpha: 0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _contentAccepted
                          ? AppTheme.ocean
                          : AppTheme.slateGrey.withValues(alpha: 0.3),
                      width: _contentAccepted ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _contentAccepted,
                          onChanged: (v) =>
                              setState(() => _contentAccepted = v ?? false),
                          activeColor: AppTheme.ocean,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Je confirme que cette photo ne contient aucune nudité, violence ou contenu inapproprié. J\'accepte qu\'elle puisse être affichée sur la page communauté de yapigo.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppTheme.navy,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      (_selectedEventId != null &&
                              _photoSelected &&
                              _contentAccepted)
                          ? _submit
                          : null,
                  icon: const Icon(Icons.upload_rounded, size: 20),
                  label: Text(
                    'Partager la photo',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.teal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.teal.withValues(alpha: 0.3),
                    disabledForegroundColor: Colors.white60,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
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
