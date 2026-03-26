import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/data/mock_users.dart';
import 'package:rundate/theme/app_theme.dart';

enum ContactSubject {
  newCity('Proposer une nouvelle ville', Icons.location_city_outlined),
  newMeetingPoint('Proposer un nouveau point de départ', Icons.add_location_alt_outlined),
  becomeOrganizer('Devenir Organisateur', Icons.event_available_outlined),
  reportBug('Signaler un bug', Icons.bug_report_outlined),
  other('Autre', Icons.chat_bubble_outline);

  final String label;
  final IconData icon;
  const ContactSubject(this.label, this.icon);
}

class ContactFormScreen extends StatefulWidget {
  const ContactFormScreen({super.key, this.preselectedSubject});

  final ContactSubject? preselectedSubject;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  late ContactSubject? _selectedSubject;
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.preselectedSubject;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _selectedSubject != null && _messageController.text.trim().isNotEmpty;

  void _submit() {
    setState(() => _submitted = true);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Message envoyé! On te revient rapidement.',
          style: GoogleFonts.dmSans(),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.teal,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Nous contacter',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'On veut t\'entendre!',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Que ce soit une idée, un bug ou une envie de s\'impliquer, écris-nous.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            _buildLabel('Nom'),
            const SizedBox(height: 6),
            _buildReadOnlyField('${user.firstName} ${user.lastName}'),
            const SizedBox(height: 18),

            _buildLabel('Téléphone'),
            const SizedBox(height: 6),
            _buildReadOnlyField(user.phone),
            const SizedBox(height: 18),

            _buildLabel('Courriel (optionnel)'),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textColor(context)),
              decoration: InputDecoration(
                hintText: 'ton@courriel.com',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.slateGrey.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.ocean, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 18),

            _buildLabel('Sujet'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: ContactSubject.values.map((subject) {
                  final selected = _selectedSubject == subject;
                  return InkWell(
                    onTap: () => setState(() => _selectedSubject = subject),
                    borderRadius: subject == ContactSubject.values.first
                        ? const BorderRadius.vertical(top: Radius.circular(12))
                        : subject == ContactSubject.values.last
                            ? const BorderRadius.vertical(bottom: Radius.circular(12))
                            : BorderRadius.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.ocean.withValues(alpha: 0.08) : Colors.transparent,
                        border: subject != ContactSubject.values.last
                            ? Border(
                                bottom: BorderSide(
                                  color: AppTheme.slateGrey.withValues(alpha: 0.1),
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            subject.icon,
                            size: 20,
                            color: selected ? AppTheme.ocean : AppTheme.secondaryText(context),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              subject.label,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                color: selected ? AppTheme.textColor(context) : AppTheme.secondaryText(context),
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, size: 20, color: AppTheme.ocean),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            _buildLabel('Message'),
            const SizedBox(height: 6),
            TextField(
              controller: _messageController,
              maxLines: 5,
              maxLength: 1000,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.dmSans(fontSize: 15, color: AppTheme.textColor(context)),
              decoration: InputDecoration(
                hintText: 'Décris-nous ton idée, ton problème ou ta demande...',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.slateGrey.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.ocean, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canSubmit && !_submitted ? _submit : null,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  'Envoyer',
                  style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ocean,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.ocean.withValues(alpha: 0.3),
                  disabledForegroundColor: Colors.white60,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Tu peux aussi nous écrire à contact@rundate.app',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppTheme.textColor(context),
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.slateGrey.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppTheme.navy.withValues(alpha: 0.7),
              ),
            ),
          ),
          Icon(Icons.lock_outline, size: 16, color: AppTheme.slateGrey.withValues(alpha: 0.4)),
        ],
      ),
    );
  }
}
