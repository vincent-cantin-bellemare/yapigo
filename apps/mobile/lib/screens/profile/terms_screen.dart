import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Conditions d'utilisation",
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section(context, '1. Acceptation des conditions',
                'En utilisant l\'application Run Date, vous acceptez les présentes conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.'),
            _section(context, '2. Description du service',
                'Run Date est une plateforme d\'activités sportives sociales qui organise des sorties en groupe dans les quartiers de Montréal. L\'application forme des sous-groupes de 6 à 8 personnes selon les préférences et le niveau d\'intensité des utilisateurs.'),
            _section(context, '3. Inscription et compte',
                'Vous devez avoir au moins 18 ans pour utiliser le service. Vous êtes responsable de maintenir la confidentialité de votre compte et de toutes les activités qui s\'y déroulent. Les informations fournies doivent être exactes et à jour.'),
            _section(context, '4. Comportement des utilisateurs',
                'Vous vous engagez à traiter tous les participants avec respect et courtoisie. Tout comportement abusif, harcelant, discriminatoire ou inapproprié entraînera la suspension ou la suppression de votre compte.'),
            _section(context, '5. Système de notation',
                'Après chaque activité, les participants peuvent évaluer leur expérience et les autres membres du groupe. Les évaluations doivent être honnêtes et respectueuses. Notre équipe examine les signalements dans les plus brefs délais.'),
            _section(context, '6. Annulations et désinscriptions',
                'Vous pouvez vous désinscrire d\'une activité avant la date limite d\'inscription. Les annulations répétées peuvent affecter votre score et votre priorité de placement.'),
            _section(context, '7. Paiements et remboursements',
                'Certaines activités sont payantes. Le paiement est effectué en ligne via une plateforme sécurisée (Stripe). Vos informations bancaires ne sont jamais stockées sur nos serveurs.\n\n'
                'Politique de remboursement :\n'
                '• Plus de 48 h avant l\'activité : remboursement intégral (100 %)\n'
                '• Entre 24 h et 48 h avant : remboursement partiel (50 %)\n'
                '• Moins de 24 h avant : aucun remboursement\n\n'
                'Les remboursements sont traités sous 5 à 10 jours ouvrables et crédités sur le mode de paiement original.'),
            _section(context, '8. Propriété intellectuelle',
                'Tout le contenu de l\'application, y compris les textes, graphiques, logos et logiciels, est la propriété de Run Date et est protégé par les lois sur la propriété intellectuelle.'),
            _section(context, '9. Limitation de responsabilité',
                'Run Date ne peut être tenu responsable des interactions entre utilisateurs en dehors de la plateforme. Nous recommandons de toujours vous rencontrer dans des lieux publics et éclairés.'),
            _section(context, '10. Modifications',
                'Nous nous réservons le droit de modifier ces conditions à tout moment. Les utilisateurs seront informés des changements importants par notification.'),
            _section(context, '11. Contact',
                'Pour toute question concernant ces conditions, contactez-nous à contact@rundate.app.'),
            const SizedBox(height: 16),
            Text(
              'Dernière mise à jour: Mars 2026',
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: AppTheme.secondaryText(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor(context))),
          const SizedBox(height: 8),
          Text(body,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppTheme.textColor(context),
                  height: 1.55)),
        ],
      ),
    );
  }
}
