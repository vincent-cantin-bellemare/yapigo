import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rundate/theme/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Politique de confidentialité',
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
            _section(context, '1. Collecte des données',
                'Nous collectons les informations que vous nous fournissez lors de l\'inscription: prénom, numéro de téléphone, âge, genre, ville, photo de profil et bio. Nous collectons également vos préférences d\'activité (intensité, distance, objectifs) et votre historique de participation.'),
            _section(context, '2. Utilisation des données',
                'Vos données sont utilisées pour:\n• Créer et gérer votre profil\n• Former des sous-groupes d\'activité\n• Améliorer notre service de mise en groupe\n• Vous envoyer des notifications pertinentes\n• Assurer la sécurité de la communauté'),
            _section(context, '3. Partage des données',
                'Vos informations de profil (prénom, âge, bio, badge, intensité) sont visibles par les autres membres de votre groupe. Votre numéro de téléphone n\'est jamais partagé. Nous ne vendons pas vos données à des tiers.'),
            _section(context, '4. Vérification d\'identité',
                'Le selfie de vérification et l\'appel FaceTime servent uniquement à confirmer votre identité. Le selfie n\'est pas affiché publiquement et est supprimé après vérification.'),
            _section(context, '5. Stockage et sécurité',
                'Vos données sont stockées de manière sécurisée sur des serveurs situés au Canada. Nous utilisons le chiffrement pour protéger vos informations personnelles en transit et au repos.'),
            _section(context, '6. Conservation des données',
                'Vos données sont conservées tant que votre compte est actif. En cas de suspension, elles sont archivées. En cas de suppression, elles sont définitivement effacées dans un délai de 30 jours.'),
            _section(context, '7. Vos droits',
                'Vous avez le droit de:\n• Accéder à vos données personnelles\n• Rectifier vos informations\n• Supprimer votre compte et vos données\n• Exporter vos données\n• Retirer votre consentement'),
            _section(context, '8. Cookies et analytics',
                'L\'application mobile n\'utilise pas de cookies. Nous collectons des données d\'utilisation anonymisées pour améliorer l\'expérience utilisateur.'),
            _section(context, '9. Contact DPO',
                'Pour toute question relative à la protection de vos données, contactez notre délégué à la protection des données: contact@rundate.app'),
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
