import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/theme/app_theme.dart';

class CommunityRulesScreen extends StatelessWidget {
  const CommunityRulesScreen({super.key});

  static const _rules = <_Rule>[
    _Rule(
      icon: Icons.schedule_outlined,
      title: 'Ponctualité',
      body:
          'On attend maximum 10 minutes après l\'heure officielle. Après, le groupe part!',
    ),
    _Rule(
      icon: Icons.groups_outlined,
      title: 'Personne seul à la queue',
      body:
          'On ne laisse jamais quelqu\'un seul à l\'arrière. Si tu vois que quelqu\'un décroche, ralentis avec lui/elle.',
    ),
    _Rule(
      icon: Icons.loop_outlined,
      title: 'Les rapides font des loops',
      body:
          'T\'es plus vite que le groupe? Fais des aller-retours pour revenir vers les plus lents. C\'est une activité sociale, pas une compétition!',
    ),
    _Rule(
      icon: Icons.speed_outlined,
      title: 'Respect du niveau annoncé',
      body:
          'Le niveau d\'intensité affiché (Chill, Modéré, Intense, etc.) c\'est un guide. On s\'adapte au groupe, pas l\'inverse.',
    ),
    _Rule(
      icon: Icons.favorite_outline,
      title: 'Bienveillance',
      body:
          'Tout le monde est bienvenu, peu importe le niveau. On encourage, on ne juge pas.',
    ),
    _Rule(
      icon: Icons.local_cafe_outlined,
      title: 'Ravito Smoothie',
      body:
          'Le café après, c\'est pas optionnel! C\'est là que la magie se passe. ☕',
    ),
    _Rule(
      icon: Icons.shield_outlined,
      title: 'Sécurité',
      body:
          'On bouge dans des endroits éclairés et publics. La nuit, on reste visible.',
    ),
    _Rule(
      icon: Icons.handshake_outlined,
      title: 'Respect des autres',
      body:
          'On est là pour se rencontrer. Pas de pression, pas d\'insistance. Un non, c\'est un non.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Règles de la communauté',
            style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textColor(context))),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        itemCount: _rules.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final rule = _rules[index];
          return Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppTheme.slateGrey.withValues(alpha: 0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.ocean.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rule.icon, size: 22, color: AppTheme.ocean),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.title,
                          style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textColor(context))),
                      const SizedBox(height: 6),
                      Text(rule.body,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.secondaryText(context),
                              height: 1.45)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Rule {
  final IconData icon;
  final String title;
  final String body;
  const _Rule({required this.icon, required this.title, required this.body});
}
