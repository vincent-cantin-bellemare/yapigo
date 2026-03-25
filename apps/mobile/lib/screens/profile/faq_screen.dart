import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaiiak/theme/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = <_FaqItem>[
    _FaqItem(
      question: 'C\'est quoi kaiiak?',
      answer: 'kaiiak c\'est une app sociale sportive pour bouger en groupe '
          'à Montréal. On te place dans un sous-groupe '
          'compatible selon ton niveau d\'intensité, tes intérêts et ta vibe. Après '
          'l\'activité, on se retrouve pour le Ravito Smoothie!',
    ),
    _FaqItem(
      question: 'Comment ça marche la mise en groupe?',
      answer: 'Tu t\'inscris à une activité dans ton quartier. On forme les groupes selon '
          'ton niveau d\'intensité (Chill, Modéré, Intense, etc.), ta distance '
          'préférée, ta tranche d\'âge et ta vibe pour te placer dans un '
          'sous-groupe de 6 à 8 personnes. L\'objectif: que tu te sentes '
          'à l\'aise pour bouger ET jaser!',
    ),
    _FaqItem(
      question: 'C\'est quoi un point de départ?',
      answer: 'C\'est le lieu de rencontre pour ton activité! Ça peut être un '
          'parc, un café ou un spot bien connu de ton quartier. Le point '
          'de départ t\'est révélé quand ton groupe est formé, quelques '
          'heures avant l\'activité.',
    ),
    _FaqItem(
      question: 'C\'est quoi le Ravito Smoothie?',
      answer: 'C\'est le moment social après l\'activité! On se retrouve '
          'dans un café ou spot partenaire pour un smoothie, un café ou '
          'ce que tu veux. C\'est là que les vraies connexions se font. '
          'C\'est pas optionnel, c\'est la meilleure partie! 😄',
    ),
    _FaqItem(
      question: 'Comment marchent les sous-groupes?',
      answer: 'Chaque activité regroupe plusieurs sous-groupes de 6 à 8 personnes. '
          'Chaque sous-groupe a son propre Organisateur et un niveau d\'intensité '
          'défini. Après l\'activité, tous les sous-groupes se rejoignent '
          'pour le Ravito Smoothie. Plus de monde, plus de rencontres!',
    ),
    _FaqItem(
      question: 'C\'est quoi un Organisateur?',
      answer: 'L\'Organisateur c\'est la personne ressource de ton sous-groupe. Il '
          'donne le rythme, s\'assure que personne reste seul à l\'arrière '
          'et met de l\'ambiance. Les Organisateurs sont des participants '
          'expérimentés et bénévoles sélectionnés par l\'équipe kaiiak.',
    ),
    _FaqItem(
      question: 'C\'est quoi un Buddy Code?',
      answer: 'C\'est un code unique que tu partages avec un ami. En '
          'entrant ton Buddy Code à l\'inscription, ton ami et toi serez '
          'placés dans le même sous-groupe. Parfait pour se motiver '
          'ensemble tout en rencontrant du nouveau monde!',
    ),
    _FaqItem(
      question: 'C\'est quoi le système de badges?',
      answer: 'Plus tu participes aux activités et reçois de bonnes évaluations, '
          'plus ton badge évolue! Les niveaux sont:\n'
          '• 👁️ Curieux\n'
          '• 👋 Social\n'
          '• ⭐ Habitué\n'
          '• 🔥 Populaire\n'
          '• 👑 Légende',
    ),
    _FaqItem(
      question: 'Est-ce que je peux choisir les membres de mon groupe?',
      answer: 'Non, la magie de kaiiak c\'est de rencontrer des '
          'nouvelles personnes! L\'IA se charge de former un groupe avec '
          'lequel tu devrais bien t\'entendre. Par contre, tu peux '
          'utiliser un Buddy Code pour être jumelé avec un ami.',
    ),
    _FaqItem(
      question: 'C\'est quoi les différents niveaux d\'intensité?',
      answer: 'On a cinq niveaux d\'intensité:\n'
          '• 🧘 Chill – On jase plus qu\'on bouge\n'
          '• 🌿 Léger – Relax mais ça avance\n'
          '• 👟 Modéré – Le rythme idéal\n'
          '• 💨 Intense – Ça déboule\n'
          '• 🔥 Extrême – Pour les machines',
    ),
    _FaqItem(
      question: 'Est-ce gratuit?',
      answer: 'L\'inscription et la participation sont gratuites. Tu paies '
          'seulement ton café/smoothie au Ravito Smoothie si tu veux. '
          'Pas de frais cachés!',
    ),
    _FaqItem(
      question: 'Comment signaler un comportement inapproprié?',
      answer: 'Dans le chat de groupe, appuie sur le menu (⋯) en haut à '
          'droite et sélectionne "Signaler". Tu peux aussi nous écrire '
          'à contact@kaiiak.com. On prend chaque signalement au sérieux.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppTheme.textColor(context),
        elevation: 0,
        title: Text(
          'FAQ',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.slateGrey.withValues(alpha: 0.15)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  iconColor: AppTheme.ocean,
                  collapsedIconColor: AppTheme.secondaryText(context),
                  title: Text(
                    faq.question,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textColor(context),
                    ),
                  ),
                  children: [
                    Text(
                      faq.answer,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        height: 1.5,
                        color: AppTheme.navy.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;
}
