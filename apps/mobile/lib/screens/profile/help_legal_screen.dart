import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/screens/profile/community_rules_screen.dart';
import 'package:rundate/screens/profile/contact_form_screen.dart';
import 'package:rundate/screens/profile/faq_screen.dart';
import 'package:rundate/screens/profile/privacy_screen.dart';
import 'package:rundate/screens/profile/terms_screen.dart';
import 'package:rundate/theme/app_theme.dart';

class HelpAndLegalScreen extends StatelessWidget {
  const HelpAndLegalScreen({super.key});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.help_outline_rounded, 'FAQ', AppTheme.ocean, const FaqScreen()),
      (Icons.mail_outline_rounded, 'Nous contacter', AppTheme.ocean,
          const ContactFormScreen()),
      (Icons.description_outlined, "Conditions d'utilisation",
          AppTheme.navyIcon(context), const TermsScreen()),
      (Icons.privacy_tip_outlined, 'Politique de confidentialité',
          AppTheme.navyIcon(context), const PrivacyScreen()),
      (Icons.people_outline, 'Règles de la communauté',
          AppTheme.navyIcon(context), const CommunityRulesScreen()),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Aide & infos',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final (icon, title, color, screen) = items[index];
          return ListTile(
            leading: Icon(icon, size: 22, color: color),
            title: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor(context),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.slateGrey.withValues(alpha: 0.4),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () => _push(context, screen),
          );
        },
      ),
    );
  }
}
