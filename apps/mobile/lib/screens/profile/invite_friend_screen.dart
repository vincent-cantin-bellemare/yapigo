import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

enum _InviteMethod { email, phone }

class InviteFriendScreen extends StatefulWidget {
  const InviteFriendScreen({super.key});

  @override
  State<InviteFriendScreen> createState() => _InviteFriendScreenState();
}

class _InviteFriendScreenState extends State<InviteFriendScreen> {
  _InviteMethod _method = _InviteMethod.email;
  final _contactController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;
  String? _contactError;

  @override
  void dispose() {
    _contactController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _isValidContact {
    final value = _contactController.text.trim();
    if (value.isEmpty) return false;
    if (_method == _InviteMethod.email) {
      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    }
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    return digits.length >= 10;
  }

  void _validateAndSend() {
    final value = _contactController.text.trim();
    if (value.isEmpty) {
      setState(() => _contactError = _method == _InviteMethod.email
          ? 'Entre un courriel'
          : 'Entre un numéro de téléphone');
      return;
    }
    if (!_isValidContact) {
      setState(() => _contactError = _method == _InviteMethod.email
          ? 'Courriel invalide'
          : 'Numéro invalide');
      return;
    }
    setState(() {
      _contactError = null;
      _isSending = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitation envoyée!',
            style: GoogleFonts.dmSans(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Inviter un ami',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
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
                  color: AppTheme.textColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Entre le courriel ou le numéro de ton ami(e), '
                'on lui envoie une invitation!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.secondaryText(context),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              _buildMethodToggle(),
              const SizedBox(height: 24),
              _buildContactField(),
              const SizedBox(height: 16),
              _buildMessageField(),
              const SizedBox(height: 28),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodToggle() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppTheme.slateGrey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleOption(
            label: 'Courriel',
            icon: Icons.email_outlined,
            selected: _method == _InviteMethod.email,
            onTap: () {
              if (_method == _InviteMethod.email) return;
              setState(() {
                _method = _InviteMethod.email;
                _contactController.clear();
                _contactError = null;
              });
            },
          ),
          _toggleOption(
            label: 'Téléphone',
            icon: Icons.phone_outlined,
            selected: _method == _InviteMethod.phone,
            onTap: () {
              if (_method == _InviteMethod.phone) return;
              setState(() {
                _method = _InviteMethod.phone;
                _contactController.clear();
                _contactError = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _toggleOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: selected ? AppTheme.ocean : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppTheme.slateGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : AppTheme.slateGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactField() {
    final isEmail = _method == _InviteMethod.email;
    return TextField(
      controller: _contactController,
      keyboardType:
          isEmail ? TextInputType.emailAddress : TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_contactError != null) setState(() => _contactError = null);
      },
      decoration: InputDecoration(
        hintText: isEmail ? 'nom@exemple.com' : '(514) 555-1234',
        prefixIcon: Icon(
          isEmail ? Icons.email_outlined : Icons.phone_outlined,
          color: AppTheme.slateGrey,
        ),
        errorText: _contactError,
        filled: true,
        fillColor: AppTheme.cardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.ocean, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.error, width: 2),
        ),
      ),
      style: GoogleFonts.dmSans(
        fontSize: 16,
        color: AppTheme.textColor(context),
      ),
    );
  }

  Widget _buildMessageField() {
    return TextField(
      controller: _messageController,
      maxLines: 3,
      minLines: 2,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: 'Ajoute un message (optionnel)',
        hintStyle: GoogleFonts.dmSans(
          fontSize: 15,
          color: AppTheme.slateGrey.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppTheme.cardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: AppTheme.slateGrey.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.ocean, width: 2),
        ),
      ),
      style: GoogleFonts.dmSans(
        fontSize: 15,
        color: AppTheme.textColor(context),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _validateAndSend,
        icon: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded, size: 20),
        label: Text(_isSending ? 'Envoi en cours...' : 'Envoyer l\'invitation'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.ocean,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.ocean.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white70,
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
      ),
    );
  }
}
