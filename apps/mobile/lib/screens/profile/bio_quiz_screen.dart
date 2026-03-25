import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yapigo/theme/app_theme.dart';

class _QuizQuestion {
  final String title;
  final String? subtitle;
  final List<String> options;
  final List<String> hints;
  final bool isTextInput;
  final String? multiSelectKey;
  final String? textHint;
  final String? emoji;
  // Scroll picker range (min, max, step, unit suffix)
  final int? scrollMin;
  final int? scrollMax;
  final int scrollStep;
  final String? scrollUnit;

  const _QuizQuestion({
    required this.title,
    this.subtitle,
    this.options = const [],
    this.hints = const [],
    this.isTextInput = false,
    this.multiSelectKey,
    this.textHint,
    this.emoji,
    this.scrollMin,
    this.scrollMax,
    this.scrollStep = 1,
    this.scrollUnit,
  });

  bool get isScrollPicker => scrollMin != null && scrollMax != null;
}

// ── Phase 1: 10 questions ──────────────────────────────────────────────────

const _phase1 = <_QuizQuestion>[
  // Q0 — Profession (text)
  _QuizQuestion(
    title: 'Tu fais quoi dans la vie?',
    subtitle: 'Ça aide à briser la glace!',
    isTextInput: true,
    textHint: 'Ex: Designer, enseignante, pompier...',
    emoji: '💼',
  ),
  // Q1 — Sports plein air (multi-select + levels)
  _QuizQuestion(
    title: 'Tes sports plein air?',
    subtitle: 'Sélectionne tes activités et ton niveau!',
    emoji: '🏔️',
    multiSelectKey: 'sports',
  ),
  // Q2 — Passe-temps (multi-select, no levels)
  _QuizQuestion(
    title: 'Tes passe-temps?',
    subtitle: 'Sélectionne tout ce qui te ressemble!',
    emoji: '🎨',
    multiSelectKey: 'hobbies',
  ),
  // Q3 — Running playlist (multi-select, no levels)
  _QuizQuestion(
    title: 'En bougeant, t\'écoutes quoi?',
    subtitle: 'Ta playlist d\'activité, ça te définit!',
    emoji: '🎧',
    multiSelectKey: 'music',
  ),
  // Q4 — Types de films (multi-select, no levels)
  _QuizQuestion(
    title: 'Tes types de films/séries?',
    subtitle: 'Netflix & chill, mais quoi exactement?',
    emoji: '🎬',
    multiSelectKey: 'films',
  ),
  // Q5 — Ideal race distance (running identity)
  _QuizQuestion(
    title: 'Ton activité parfaite, c\'est...?',
    subtitle: 'Ça définit ton style sportif!',
    emoji: '🎯',
    options: [
      '5 km — court, intense et je rentre pour le brunch 🥞',
      '10 km — le sweet spot, assez pour se sentir vivant 💪',
      '21 km — demi-marathon, j\'aime souffrir juste assez 🔥',
      '42 km — marathon, c\'est un mode de vie 🏅',
      'Ultra + — pourquoi s\'arrêter? 🦸',
      'Aucun intérêt, je bouge pour le social! 🥳',
    ],
    hints: [
      'Efficace et réaliste, qualité avant quantité',
      'Équilibré et solide, le juste milieu parfait',
      'Ambitieux et discipliné, tu te dépasses',
      'Déterminé et endurant, rien ne t\'arrête',
      'Tu repousses toutes les limites, respect',
      'Le fun d\'abord, la distance on s\'en fout!',
    ],
  ),
  // Q6 — Mud on calves (fun running question)
  _QuizQuestion(
    title: 'De la bouette sur les mollets, c\'est sexy?',
    subtitle: 'La question que personne ose poser 😏',
    emoji: '🦵',
    options: [
      'Absolument, c\'est un look! L\'aventure c\'est la vie 🏆',
      'Bof, je préfère rester propre et sentir bon 🧼',
      'Seulement si l\'autre personne en a aussi 😏',
      'Ça dépend du contexte... et de la bouette 🤔',
    ],
    hints: [
      'Traileur dans l\'âme, la nature c\'est ton gym',
      'Clean et soigné, rien de mal là-dedans',
      'Romantique et complice, tu veux partager l\'expérience',
      'Flexible et pragmatique, toujours nuancé',
    ],
  ),
  // Q7 — Pets (choice)
  _QuizQuestion(
    title: 'Tu as des animaux de compagnie?',
    subtitle: 'Les sportifs à quatre pattes comptent aussi!',
    emoji: '🐾',
    options: [
      'Un chien — mon partner d\'activité! 🐕',
      'Un chat — il me juge quand je sors bouger 🐈',
      'Plusieurs! C\'est un zoo chez nous 🦜',
      'Pas encore, mais j\'en veux un jour 🥺',
      'Non, je suis team liberté totale 🦅',
    ],
    hints: [
      'Un vrai duo sportif, fidèle compagnon',
      'L\'indépendance, ça se respecte',
      'Coeur grand comme ça, amour illimité',
      'Bientôt dans ta famille!',
      'Léger et libre de voyager',
    ],
  ),
  // Q8 — Family / children (choice)
  _QuizQuestion(
    title: 'Et côté famille?',
    subtitle: 'Pas de jugement, juste pour mieux te connaître!',
    emoji: '👨‍👩‍👧',
    options: [
      'J\'ai des enfants, ma plus belle aventure! 👶',
      'Pas encore, mais c\'est dans les plans 🍼',
      'Pas d\'enfants, et c\'est mon choix ✨',
      'On verra ce que la vie décide 🤷',
    ],
    hints: [
      'Parent fier, la famille c\'est sacré',
      'Tu planifies l\'avenir avec optimisme',
      'Tu sais ce que tu veux, et c\'est parfait',
      'Ouvert et flexible, la vie est pleine de surprises',
    ],
  ),
  // Q9 — Longest distance run (scroll picker)
  _QuizQuestion(
    title: 'Ta plus grosse distance en une activité?',
    subtitle: 'En une seule journée, ton record perso!',
    emoji: '📏',
    scrollMin: 2,
    scrollMax: 100,
    scrollStep: 1,
    scrollUnit: 'km',
  ),
];

// ── Phase 2: 10 questions ──────────────────────────────────────────────────

const _phase2 = <_QuizQuestion>[
  // Q10 — Strava / sport app (choice)
  _QuizQuestion(
    title: 'T\'es sur Strava ou une app de sport?',
    subtitle: 'On juge pas... ok, un peu 📊',
    emoji: '📱',
    options: [
      'Strava évidemment, si c\'est pas sur Strava c\'est pas arrivé 🏆',
      'Garmin Connect, j\'ai une montre qui coûte plus cher que mon loyer ⌚',
      'Nike Run Club, le coach me dit que je suis bon 👟',
      'Apple Watch Fitness, j\'ai fermé mes anneaux! ⌚',
      'Aucune app, je cours avec mon instinct 🐺',
    ],
    hints: [
      'Data nerd assumé, tu analyses chaque split',
      'Équipé et sérieux, ta montre sait tout de toi',
      'Motivé par les défis et le coaching',
      'Tech-friendly, tu aimes les stats sans te casser la tête',
      'Libre et instinctif, pas besoin de données',
    ],
  ),
  // Q11 — Practical skills (multi-select + levels)
  _QuizQuestion(
    title: 'Tes compétences utiles?',
    subtitle: 'La personne ressource de la gang, c\'est toi?',
    emoji: '🛠️',
    multiSelectKey: 'skills',
  ),
  // Q12 — Languages (multi-select + levels)
  _QuizQuestion(
    title: 'Les langues que tu parles?',
    subtitle: 'Polyglotte ou unilingue assumé?',
    emoji: '🌍',
    multiSelectKey: 'languages',
  ),
  // Q13 — Bike flat repair (fun skill check)
  _QuizQuestion(
    title: 'Tu sais réparer un flat de vélo?',
    subtitle: 'Compétence de survie en plein air 🔧',
    emoji: '🚲',
    options: [
      'Oui, les yeux fermés! J\'ai ma trousse dans le sac 🔧',
      'En théorie... j\'ai vu un YouTube une fois 📱',
      'Non, j\'appelle un ami ou je marche 📞',
      'C\'est quoi un flat? 🤔',
    ],
    hints: [
      'Débrouillard et autonome, on peut compter sur toi',
      'Autodidacte moderne, tu te formes sur le tas',
      'Honnête et social, tu sais demander de l\'aide',
      'Charmant dans ta candeur, on va t\'apprendre!',
    ],
  ),
  // Q14 — Winter running (dedication reveal)
  _QuizQuestion(
    title: 'Tu bouges l\'hiver?',
    subtitle: 'Ça sépare les vrais des prétendants ❄️',
    emoji: '🥶',
    options: [
      'Oui, -20 et je suis dehors! Crampons et tuque, c\'est la base ❄️',
      'Quand ça fond un peu, genre -5 max 🌡️',
      'Non, l\'hiver c\'est gym ou Netflix 🛋️',
      'J\'ai essayé une fois... plus jamais, mes poumons s\'en souviennent 😰',
    ],
    hints: [
      'Guerrier nordique, rien ne t\'arrête',
      'Raisonnable et adaptable, tu choisis tes batailles',
      'Tu sais quand te reposer, et c\'est correct',
      'Au moins t\'as essayé, c\'est l\'intention qui compte!',
    ],
  ),
  // Q15 — Future in-laws (choice, fun personality reveal)
  _QuizQuestion(
    title: 'Tes futurs beaux-parents vont t\'aimer pour...?',
    subtitle: 'Fais bonne impression, on écoute 😏',
    emoji: '👨‍👩‍👦',
    options: [
      'Je fais la vaisselle sans qu\'on me le demande 🍽️',
      'Je répare tout ce qui est brisé dans la maison 🔧',
      'Je cuisine mieux que leur enfant, désolé 👨‍🍳',
      'Je ris à toutes leurs jokes, même les poches 😂',
      'Mon salaire. Soyons honnêtes. 💰',
    ],
    hints: [
      'Serviable et attentionné, le gendre/bru parfait',
      'Manuel et débrouillard, tu vaux de l\'or',
      'Foodie et généreux, tu gagnes par l\'estomac',
      'Diplomate naturel, tu charmes tout le monde',
      'Au moins t\'es honnête, on respecte ça',
    ],
  ),
  // Q16 — Stop sign while running (runner debate)
  _QuizQuestion(
    title: 'Tu arrêtes au stop en bougeant?',
    subtitle: 'Le grand débat de la communauté sportive 🛑',
    emoji: '🚦',
    options: [
      'Évidemment, la loi c\'est la loi! 🛑',
      'Je ralentis... genre un petit peu 🏃',
      'Stop? Quel stop? Je suis dans ma zone 💨',
      'Ça dépend s\'il y a des chars 👀',
    ],
    hints: [
      'Citoyen modèle, tu respectes les règles',
      'Compromis acceptable, effort minimum',
      'Inarrêtable, ta foulée c\'est sacré',
      'Pragmatique et honnête, survie d\'abord',
    ],
  ),
  // Q17 — Travel style (lifestyle reveal)
  _QuizQuestion(
    title: 'En voyage, t\'es plutôt...?',
    subtitle: 'Ça en dit long sur ta personnalité!',
    emoji: '✈️',
    options: [
      'Backpack et hostel, budget serré, max d\'aventures 🎒',
      'Campervan, la liberté sur quatre roues 🚐',
      'Camping, la nature pis un feu de camp 🏕️',
      'Hôtel, spa pis room service, je le mérite 🏨',
      'Casanier, je suis bien chez nous! 🏠',
    ],
    hints: [
      'Aventurier et débrouillard, tu voyages léger',
      'Libre comme l\'air, la route c\'est ta maison',
      'Plein air dans l\'âme, la simplicité te comble',
      'Tu sais te gâter et tu l\'assumes pleinement',
      'Ton chez-toi c\'est ton sanctuaire, et c\'est correct',
    ],
  ),
  // Q18 — Fun fact (text)
  _QuizQuestion(
    title: 'Dis-nous un fun fact sur toi!',
    subtitle: 'Le plus random, le mieux! Ça rend ta bio unique.',
    isTextInput: true,
    textHint: 'Ex: J\'ai déjà fait un demi-marathon en gougounes...',
    emoji: '🎲',
  ),
  // Q19 — Competitive in sports (personality)
  _QuizQuestion(
    title: 'T\'es compétitif dans le sport?',
    subtitle: 'Pas de mauvaise réponse... sauf mentir 🏅',
    emoji: '🏁',
    options: [
      'J\'ai un dossard pour chaque fin de semaine! 🏅',
      'Un peu, j\'aime me dépasser sans pression 💪',
      'Zéro, je bouge pour le plaisir et la jasette 😊',
      'Je compétitionne juste avec moi-même, mon Strava le sait ⏱️',
    ],
    hints: [
      'Athlète dans l\'âme, tu collectionnes les activités',
      'Équilibré, tu te pousses sans te stresser',
      'Social d\'abord, la performance c\'est un bonus',
      'Introspectif et discipliné, ton pire adversaire c\'est toi',
    ],
  ),
];

/// Full-screen quiz that generates a bio from answers.
/// Returns the generated bio string via [Navigator.pop].
class BioQuizScreen extends StatefulWidget {
  const BioQuizScreen({super.key, this.userName});

  final String? userName;

  @override
  State<BioQuizScreen> createState() => _BioQuizScreenState();
}

class _BioQuizScreenState extends State<BioQuizScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _phase2Unlocked = false;

  final Map<int, String> _answers = {};
  final Map<int, TextEditingController> _textControllers = {};

  // Stores selections for all multi-select questions keyed by question index.
  // Value maps item label → level (empty string when no levels apply).
  final Map<int, Map<String, String>> _multiSelections = {};

  List<_QuizQuestion> get _activeQuestions =>
      _phase2Unlocked ? [..._phase1, ..._phase2] : _phase1;

  int get _totalPages {
    if (!_phase2Unlocked) return _phase1.length + 1;
    return _phase1.length + _phase2.length + 1;
  }

  bool get _isCheckpointPage =>
      _currentPage == _phase1.length && !_phase2Unlocked;

  int get _phase2QuestionIndex {
    if (!_phase2Unlocked || _currentPage < _phase1.length) return -1;
    return _currentPage - _phase1.length + 1;
  }

  double get _progress {
    final answered = _answers.length;
    final total =
        _phase2Unlocked ? _phase1.length + _phase2.length : _phase1.length;
    return (answered / total).clamp(0.0, 1.0);
  }

  // ── Multi-select item catalogues ────────────────────────────────────────

  static const _sportsItems = [
    (icon: Icons.directions_bike, label: 'Vélo'),
    (icon: Icons.hiking, label: 'Randonnée'),
    (icon: Icons.pool, label: 'Natation'),
    (icon: Icons.directions_run, label: 'Course'),
    (icon: Icons.kayaking, label: 'Kayak'),
    (icon: Icons.downhill_skiing, label: 'Ski de fond'),
    (icon: Icons.skateboarding, label: 'Patin à roues alignées'),
    (icon: Icons.landscape, label: 'Escalade'),
  ];

  static const _hobbiesItems = [
    (icon: Icons.restaurant, label: 'Cuisine'),
    (icon: Icons.local_florist, label: 'Jardinage'),
    (icon: Icons.menu_book, label: 'Lecture'),
    (icon: Icons.sports_esports, label: 'Jeux vidéo'),
    (icon: Icons.camera_alt, label: 'Photographie'),
    (icon: Icons.handyman, label: 'Bricolage / DIY'),
    (icon: Icons.flight, label: 'Voyage'),
    (icon: Icons.self_improvement, label: 'Yoga / Méditation'),
  ];

  static const _musicItems = [
    (icon: Icons.music_note, label: 'Pop'),
    (icon: Icons.electric_bolt, label: 'Rock'),
    (icon: Icons.whatshot, label: 'Metal'),
    (icon: Icons.mic, label: 'Hip-hop / Rap'),
    (icon: Icons.speaker, label: 'EDM / Électro'),
    (icon: Icons.nightlife, label: 'R&B / Soul'),
    (icon: Icons.album, label: 'Indie / Alternatif'),
    (icon: Icons.grass, label: 'Country / Folk'),
    (icon: Icons.library_music, label: 'Classique'),
    (icon: Icons.podcasts, label: 'Podcasts'),
    (icon: Icons.hearing, label: 'Rien, juste le bruit de mes pas'),
  ];

  static const _filmItems = [
    (icon: Icons.local_fire_department, label: 'Action'),
    (icon: Icons.sentiment_very_satisfied, label: 'Comédie'),
    (icon: Icons.dark_mode, label: 'Horreur'),
    (icon: Icons.favorite, label: 'Romance'),
    (icon: Icons.rocket_launch, label: 'Science-fiction'),
    (icon: Icons.video_library, label: 'Documentaire'),
    (icon: Icons.psychology, label: 'Thriller'),
    (icon: Icons.animation, label: 'Animation'),
    (icon: Icons.theater_comedy, label: 'Drame'),
    (icon: Icons.auto_awesome, label: 'Fantastique'),
  ];

  static const _artisticItems = [
    (icon: Icons.piano, label: 'Musique / Instrument'),
    (icon: Icons.palette, label: 'Peinture / Dessin'),
    (icon: Icons.edit_note, label: 'Écriture'),
    (icon: Icons.accessibility_new, label: 'Danse'),
    (icon: Icons.camera, label: 'Photo artistique'),
    (icon: Icons.theaters, label: 'Théâtre / Impro'),
    (icon: Icons.videocam, label: 'Vidéo / Montage'),
    (icon: Icons.brush, label: 'Artisanat'),
  ];

  static const _skillsItems = [
    (icon: Icons.computer, label: 'Informatique / Tech'),
    (icon: Icons.build, label: 'Bricolage / Réno'),
    (icon: Icons.account_balance, label: 'Finances / Budget'),
    (icon: Icons.directions_car, label: 'Mécanique'),
    (icon: Icons.checklist, label: 'Organisation'),
    (icon: Icons.restaurant_menu, label: 'Cuisine avancée'),
  ];

  static const _languageItems = [
    (icon: Icons.chat, label: 'Français'),
    (icon: Icons.chat_bubble, label: 'Anglais'),
    (icon: Icons.chat_bubble_outline, label: 'Espagnol'),
    (icon: Icons.translate, label: 'Mandarin'),
    (icon: Icons.translate, label: 'Arabe'),
    (icon: Icons.translate, label: 'Portugais'),
    (icon: Icons.translate, label: 'Allemand'),
    (icon: Icons.translate, label: 'Italien'),
    (icon: Icons.translate, label: 'Japonais'),
    (icon: Icons.translate, label: 'Coréen'),
  ];

  static const _proficiencyLevels = ['Débutant', 'Avancé', 'Expert'];
  static const _hobbyLevels = ['Un peu', 'Passionné', 'Accro'];
  static const _languageLevels = [
    'Débutant',
    'Avancé',
    'Je maîtrise',
    'Natif',
  ];

  // Key → (items, optional levels)
  static final _multiSelectConfig =
      <String,
          ({
            List<({IconData icon, String label})> items,
            List<String>? levels,
          })>{
    'sports': (items: _sportsItems, levels: _proficiencyLevels),
    'hobbies': (items: _hobbiesItems, levels: _hobbyLevels),
    'music': (items: _musicItems, levels: null),
    'films': (items: _filmItems, levels: null),
    'artistic': (items: _artisticItems, levels: _proficiencyLevels),
    'skills': (items: _skillsItems, levels: _proficiencyLevels),
    'languages': (items: _languageItems, levels: _languageLevels),
  };

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _textControllers.values) {
      c.dispose();
    }
    for (final c in _scrollControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(int qi) {
    return _textControllers.putIfAbsent(qi, () {
      final c = TextEditingController(text: _answers[qi] ?? '');
      c.addListener(() {
        final txt = c.text.trim();
        if (txt.isNotEmpty) {
          _answers[qi] = txt;
        } else {
          _answers.remove(qi);
        }
        setState(() {});
      });
      return c;
    });
  }

  // ── Navigation ──────────────────────────────────────────────────────────

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      HapticFeedback.selectionClick();
      _goToPage(_currentPage + 1);
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  void _selectOption(int qi, String option) {
    HapticFeedback.selectionClick();
    setState(() => _answers[qi] = option);
    Future.delayed(const Duration(milliseconds: 350), _next);
  }

  void _finishPhase1() {
    HapticFeedback.mediumImpact();
    _goToPage(_totalPages - 1);
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToResult();
    });
  }

  void _navigateToResult() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _BioResultScreen(
          bio: _generateBio(),
          userName: widget.userName,
          onAccept: (bio) {
            Navigator.of(context).pop(bio);
          },
        ),
      ),
    );
  }

  void _startPhase2() {
    HapticFeedback.mediumImpact();
    setState(() => _phase2Unlocked = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToPage(_phase1.length);
    });
  }

  // ── Multi-select helpers ────────────────────────────────────────────────

  void _updateMultiSelectAnswer(int qi) {
    final selections = _multiSelections[qi];
    if (selections == null || selections.isEmpty) {
      _answers.remove(qi);
    } else {
      final q = _activeQuestions[qi];
      final config = _multiSelectConfig[q.multiSelectKey];
      final hasLevels = config?.levels != null;
      final parts = selections.entries
          .map((e) => hasLevels ? '${e.key} (${e.value})' : e.key)
          .join(', ');
      _answers[qi] = parts;
    }
    setState(() {});
  }

  // ── Bio generation ──────────────────────────────────────────────────────

  String _generateBio() {
    final name = widget.userName ?? '';
    final parts = <String>[];

    // Phase 1: 0=profession, 1=sports, 2=hobbies, 3=music, 4=films,
    //          5=drink, 6=party, 7=animals, 8=children, 9=cherche
    final profession = _answers[0];
    final sports = _answers[1];
    final hobbies = _answers[2];
    final music = _answers[3];
    final films = _answers[4];
    final idealDistance = _cleanEmoji(_answers[5]);
    final mud = _cleanEmoji(_answers[6]);
    final animals = _cleanEmoji(_answers[7]);
    final children = _cleanEmoji(_answers[8]);
    final longestRun = _answers[9];

    if (name.isNotEmpty || profession != null) {
      final intro = [if (name.isNotEmpty) name, ?profession].join(', ');
      parts.add('$intro.');
    }

    if (sports != null && sports.isNotEmpty) {
      parts.add('Sports: $sports.');
    }
    if (hobbies != null && hobbies.isNotEmpty) {
      parts.add('Passe-temps: $hobbies.');
    }
    if (idealDistance != null) parts.add('Activité parfaite: $idealDistance.');
    if (mud != null) parts.add('La bouette sur les mollets? $mud.');

    if (music != null && music.isNotEmpty) {
      parts.add('En bougeant j\'écoute: $music.');
    }
    if (films != null && films.isNotEmpty) {
      parts.add('Films: $films.');
    }

    if (animals != null) parts.add('Animaux: $animals.');
    if (children != null) parts.add('Famille: $children.');

    // Phase 2: p2+0=strava, p2+1=skills, p2+2=languages, p2+3=bikeFlat,
    //          p2+4=winter, p2+5=beauxParents, p2+6=stopSign, p2+7=travel,
    //          p2+8=funFact, p2+9=competitive
    final p2 = _phase1.length;
    if (_phase2Unlocked) {
      final strava = _cleanEmoji(_answers[p2]);
      final skills = _answers[p2 + 1];
      final languages = _answers[p2 + 2];
      final bikeFlat = _cleanEmoji(_answers[p2 + 3]);
      final winter = _cleanEmoji(_answers[p2 + 4]);
      final beauxParents = _cleanEmoji(_answers[p2 + 5]);
      final stopSign = _cleanEmoji(_answers[p2 + 6]);
      final travel = _cleanEmoji(_answers[p2 + 7]);
      final funFact = _answers[p2 + 8];
      final competitive = _cleanEmoji(_answers[p2 + 9]);

      if (strava != null) parts.add('App de sport: $strava.');
      if (skills != null && skills.isNotEmpty) {
        parts.add('Compétences: $skills.');
      }
      if (languages != null && languages.isNotEmpty) {
        parts.add('Langues: $languages.');
      }
      if (bikeFlat != null) parts.add('Réparer un flat de vélo? $bikeFlat.');
      if (winter != null) parts.add('Bouger l\'hiver? $winter.');
      if (beauxParents != null) {
        parts.add('Les beaux-parents vont l\'aimer pour: $beauxParents.');
      }
      if (stopSign != null) parts.add('Arrêter au stop en bougeant? $stopSign.');
      if (travel != null) parts.add('En voyage: $travel.');
      if (funFact != null && funFact.isNotEmpty) {
        parts.add('Fun fact: $funFact.');
      }
      if (competitive != null) parts.add('Compétitif? $competitive.');
    }

    if (longestRun != null) parts.add('Record perso: $longestRun en une journée.');

    return parts.join(' ');
  }

  String? _cleanEmoji(String? s) {
    if (s == null) return null;
    return s
        .replaceAll(
          RegExp(
            r"[^\w\sàâäéèêëïîôùûüÿçÀÂÄÉÈÊËÏÎÔÙÛÜŸÇ°.,!?''\-—+/]+",
          ),
          '',
        )
        .trim();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final questions = _activeQuestions;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgress(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  if (_isCheckpointPage && index == _phase1.length) {
                    return _buildCheckpoint();
                  }
                  if (_phase2Unlocked &&
                      index == _phase1.length + _phase2.length) {
                    return _buildCheckpoint();
                  }
                  final qi = index;
                  if (qi >= questions.length) return const SizedBox.shrink();
                  return _buildQuestionPage(qi, questions[qi]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          if (_currentPage == 0)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 22),
              color: AppTheme.textColor(context),
            )
          else
            IconButton(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: AppTheme.textColor(context),
            ),
          const Spacer(),
          TextButton(
            onPressed: _next,
            child: Text(
              'Passer',
              style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final total =
        _phase2Unlocked ? _phase1.length + _phase2.length : _phase1.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: _progress),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor:
                      AppTheme.slateGrey.withValues(alpha: 0.15),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                  minHeight: 4,
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          if (_phase2Unlocked && _phase2QuestionIndex > 0)
            Text(
              'Question $_phase2QuestionIndex/${_phase2.length} — Dernier sprint!',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.ocean,
              ),
            )
          else
            Text(
              '${_answers.length} / $total réponses',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int qi, _QuizQuestion q) {
    if (q.multiSelectKey != null) return _buildMultiSelectPage(qi, q);
    if (q.isScrollPicker) return _buildScrollPickerPage(qi, q);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (q.emoji != null)
            Text(q.emoji!, style: const TextStyle(fontSize: 40))
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
          const SizedBox(height: 12),
          Text(
            q.title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
          if (q.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              q.subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: 28),
          if (q.isTextInput)
            _buildTextInput(qi, q)
          else
            Expanded(child: _buildOptions(qi, q)),
        ],
      ),
    );
  }

  Widget _buildTextInput(int qi, _QuizQuestion q) {
    final controller = _controllerFor(qi);
    return Column(
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          style: GoogleFonts.dmSans(fontSize: 18),
          decoration: InputDecoration(
            hintText: q.textHint ?? '',
            hintStyle: GoogleFonts.dmSans(
              color: AppTheme.slateGrey.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppTheme.cardColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.slateGrey.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppTheme.slateGrey.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.all(18),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continuer',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Scroll picker (distance, etc.) ──────────────────────────────────────

  final Map<int, FixedExtentScrollController> _scrollControllers = {};

  Widget _buildScrollPickerPage(int qi, _QuizQuestion q) {
    final min = q.scrollMin!;
    final max = q.scrollMax!;
    final step = q.scrollStep;
    final unit = q.scrollUnit ?? '';
    final itemCount = ((max - min) ~/ step) + 1;

    final currentVal = _answers[qi] != null
        ? int.tryParse(_answers[qi]!.replaceAll(RegExp(r'[^0-9]'), '')) ?? min
        : min + ((max - min) ~/ 3);

    final initialIndex = ((currentVal - min) / step).round().clamp(0, itemCount - 1);

    final controller = _scrollControllers.putIfAbsent(
      qi,
      () => FixedExtentScrollController(initialItem: initialIndex),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (q.emoji != null)
            Text(q.emoji!, style: const TextStyle(fontSize: 40))
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
          const SizedBox(height: 12),
          Text(
            q.title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
          if (q.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              q.subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: AppTheme.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.teal.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 54,
                  perspective: 0.003,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    final value = min + index * step;
                    setState(() => _answers[qi] = '$value $unit');
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: itemCount,
                    builder: (context, index) {
                      final value = min + index * step;
                      final selected = controller.hasClients &&
                          controller.selectedItem == index;
                      return Center(
                        child: Text(
                          '$value $unit',
                          style: GoogleFonts.nunito(
                            fontSize: selected ? 32 : 22,
                            fontWeight: selected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: selected
                                ? AppTheme.teal
                                : AppTheme.slateGrey.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_answers.containsKey(qi)) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                _scrollPickerComment(qi),
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.secondaryText(context),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _answers.containsKey(qi) ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continuer',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _scrollPickerComment(int qi) {
    final raw = _answers[qi];
    if (raw == null) return '';
    final val = int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (val <= 5) return 'Tout le monde commence quelque part!';
    if (val <= 10) return 'Solide, le 10 km c\'est un classique!';
    if (val <= 21) return 'Demi-marathon? Tu te laisses pas impressionner!';
    if (val <= 42) return 'Marathonien! Tu fais partie du club select.';
    return 'Ultra sportif! On s\'incline devant toi. 🙇';
  }

  Widget _buildOptions(int qi, _QuizQuestion q) {
    final selected = _answers[qi];
    return ListView.separated(
      itemCount: q.options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final opt = q.options[i];
        final hint = i < q.hints.length ? q.hints[i] : null;
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => _selectOption(qi, opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.teal.withValues(alpha: 0.1)
                  : AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppTheme.teal
                    : AppTheme.slateGrey.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color:
                              isSelected ? AppTheme.teal : AppTheme.textColor(context),
                        ),
                      ),
                      if (hint != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          hint,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.teal,
                    size: 22,
                  ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (80 * i).ms, duration: 250.ms)
            .slideX(begin: 0.06, end: 0);
      },
    );
  }

  // ── Generic multi-select page (sports, hobbies, music, films, etc.) ───

  Widget _buildMultiSelectPage(int qi, _QuizQuestion q) {
    final config = _multiSelectConfig[q.multiSelectKey];
    if (config == null) return const SizedBox.shrink();

    final items = config.items;
    final levels = config.levels;
    final selections = _multiSelections.putIfAbsent(qi, () => {});

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (q.emoji != null)
            Text(q.emoji!, style: const TextStyle(fontSize: 40))
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 400.ms,
                  curve: Curves.elasticOut,
                ),
          const SizedBox(height: 12),
          Text(
            q.title,
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0),
          if (q.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              q.subtitle!,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppTheme.secondaryText(context),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final item = items[i];
                final isSelected = selections.containsKey(item.label);
                final currentLevel = selections[item.label];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.teal.withValues(alpha: 0.08)
                        : AppTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.teal
                          : AppTheme.slateGrey.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          if (isSelected) {
                            selections.remove(item.label);
                          } else {
                            selections[item.label] = levels != null
                                ? (levels.length > 1 ? levels[1] : levels[0])
                                : '';
                          }
                          _updateMultiSelectAnswer(qi);
                        },
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 24,
                              color: isSelected
                                  ? AppTheme.teal
                                  : AppTheme.secondaryText(context),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? AppTheme.teal
                                      : AppTheme.textColor(context),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.teal,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                      if (isSelected && levels != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: levels.map((lvl) {
                            final active = currentLevel == lvl;
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    selections[item.label] = lvl;
                                    _updateMultiSelectAnswer(qi);
                                  },
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppTheme.teal
                                          : AppTheme.slateGrey
                                              .withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      lvl,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: active
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: active
                                            ? Colors.white
                                            : AppTheme.secondaryText(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: (60 * i).ms, duration: 250.ms);
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selections.isNotEmpty ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continuer',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Checkpoint / phase gate ─────────────────────────────────────────────

  Widget _buildCheckpoint() {
    if (_phase2Unlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToResult();
      });
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.teal),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, size: 44, color: AppTheme.teal),
          ).animate().scale(
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 20),
          Text(
            '${_phase1.length} questions complétées!',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textColor(context),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 10),
          Text(
            'On a assez pour te connaître... ou tu veux qu\'on creuse un peu plus?',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppTheme.secondaryText(context),
              height: 1.4,
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishPhase1,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'C\'est assez, génère ma bio!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 300.ms),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _startPhase2,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.ocean,
                side: const BorderSide(color: AppTheme.ocean, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Dernière ligne droite! 10 questions finales 🏁',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 750.ms, duration: 300.ms),
          const SizedBox(height: 8),
          Text(
            'Promis, c\'est les dernières. Après ça, ta bio sera encore plus complète!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.secondaryText(context),
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(delay: 850.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ── Bio result screen ─────────────────────────────────────────────────────

class _BioResultScreen extends StatefulWidget {
  const _BioResultScreen({
    required this.bio,
    required this.onAccept,
    this.userName,
  });

  final String bio;
  final String? userName;
  final void Function(String bio) onAccept;

  @override
  State<_BioResultScreen> createState() => _BioResultScreenState();
}

class _BioResultScreenState extends State<_BioResultScreen> {
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.bio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ta bio',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor(context),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.teal.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.teal,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Voici ta bio générée! Tu peux la modifier à ta guise.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppTheme.textColor(context),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms),
            const SizedBox(height: 24),
            TextField(
              controller: _bioController,
              maxLines: 8,
              maxLength: 500,
              style: GoogleFonts.dmSans(fontSize: 15, height: 1.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.slateGrey.withValues(alpha: 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: AppTheme.slateGrey.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppTheme.teal, width: 2),
                ),
                contentPadding: const EdgeInsets.all(18),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                final bio = _bioController.text.trim();
                Navigator.of(context).pop();
                widget.onAccept(bio);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ocean,
                foregroundColor: Colors.white,
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
              child: const Text('C\'est moi! ✨'),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Retour aux questions',
                  style: GoogleFonts.dmSans(color: AppTheme.secondaryText(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
