import 'package:kaiiak/models/waiting_question.dart';

final mockWaitingQuestions = <WaitingQuestion>[
  const WaitingQuestion(
    id: 'q1',
    question: 'À quel rythme tu bouges en général?',
    options: [
      'Balade',
      'Tranquille',
      'Modérée',
      'Rapide',
      'Intense',
    ],
    category: 'Intensité',
  ),
  const WaitingQuestion(
    id: 'q2',
    question: 'Tu fais du sport surtout pour...?',
    options: [
      'Te remettre en forme',
      'Rencontrer du monde',
      'Le café ou l\'apéro après',
      'Un défi perso',
    ],
    category: 'Motivation',
  ),
  const WaitingQuestion(
    id: 'q3',
    question: 'Ambiance sonore pour ta prochaine sortie?',
    options: [
      'Quelque chose d\'épique (rock / hip-hop)',
      'Pop feel-good',
      'Électro / house',
      'Podcast ou silence, je focus',
    ],
    category: 'Musique',
  ),
  const WaitingQuestion(
    id: 'q4',
    question: 'Ton move quand t\'es à bout de souffle devant quelqu\'un de cute?',
    options: [
      'Je souris et je ralentis un peu, zen',
      'Je fais semblant d\'être en échauffement',
      'Je dis un joke sur mon souffle court',
      'Je change de voie ou de sentier, crise d\'anxiété 😅',
    ],
    category: 'Flirt',
  ),
  const WaitingQuestion(
    id: 'q5',
    question: 'Comment tu te sens avant une activité avec des inconnus?',
    options: ['Pumped!', 'Un peu nerveux mais excité', 'Chill total', 'J\'ai besoin de café d\'abord'],
    category: 'Humeur',
  ),
  const WaitingQuestion(
    id: 'q6',
    question: 'Tu es plutôt...',
    options: ['Introverti', 'Extraverti', 'Un peu des deux'],
    category: 'Personnalité',
  ),
  const WaitingQuestion(
    id: 'q7',
    question: 'Ton spot préféré pour bouger à Montréal?',
    options: ['Mont-Royal', 'Canal / Lachine', 'Parcs du Plateau', 'Piscines ou gyms du coin', 'Je découvre encore'],
    category: 'Local',
  ),
  const WaitingQuestion(
    id: 'q8',
    question: 'Activité du matin ou après le travail?',
    options: ['Early bird 🌅', 'Soirée seulement', 'Week-end warrior', 'N\'importe quand si y\'a du monde sympa'],
    category: 'Horaire',
  ),
  const WaitingQuestion(
    id: 'q9',
    question: 'Après l\'activité, tu...',
    options: [
      'Café, smoothie ou bouchée avec le groupe',
      'Douche puis dodo',
      'Étirements ou cooldown solo',
      'Tu restes pour jaser une heure',
    ],
    category: 'Après-activité',
  ),
  const WaitingQuestion(
    id: 'q10',
    question: 'Tu parles de quoi quand tu es à côté de quelqu\'un en groupe?',
    options: ['Voyages', 'Bouffe post-effort', 'Séries', 'Sports et entraînement', 'La météo, classique'],
    category: 'Jasette',
  ),
  const WaitingQuestion(
    id: 'q11',
    question: 'Pluie légère sur le parcours ou en chemin, tu...',
    options: ['J\'y vais quand même', 'Je reporte', 'J\'adore, ça rafraîchit', 'Imperméable + plan B, game on'],
    category: 'Météo',
  ),
  const WaitingQuestion(
    id: 'q12',
    question: 'Objectif sur un kaiiak?',
    options: [
      'Finir en souriant',
      'Me faire un ami sportif',
      'Voir si y\'a une étincelle',
      'Me dépasser sans me comparer (shh)',
    ],
    category: 'Intentions',
  ),
  const WaitingQuestion(
    id: 'q13',
    question: 'C\'est quoi ton red flag en groupe?',
    options: [
      'Toujours sur son cell',
      'Partir en shot sans prévenir personne',
      'Jamais à l\'heure au point de départ',
      'Critique le niveau des autres',
    ],
    category: 'Valeurs',
  ),
  const WaitingQuestion(
    id: 'q14',
    question: 'Tu connais bien les sentiers, pistes ou salles du coin?',
    options: ['Comme ma poche', 'Un peu', 'Je me laisse guider', 'Google Maps est mon coach'],
    category: 'Local',
  ),
  const WaitingQuestion(
    id: 'q15',
    question: 'Chien en laisse sur le trajet, tu...',
    options: ['J\'adore, je dis bonjour', 'Je décale poliment', 'Je ralentis pour pas stresser le toutou', 'Ça dépend de mon souffle du jour'],
    category: 'Vibe',
  ),
  const WaitingQuestion(
    id: 'q16',
    question: 'Tu arrives au point de rendez-vous...',
    options: ['5 min en avance (étirements)', 'Pile à l\'heure', 'Je pédale / je cours pour arriver à l\'heure meta 😂'],
    category: 'Ponctualité',
  ),
  const WaitingQuestion(
    id: 'q17',
    question: 'Hiver à Montréal, tu bouges dehors?',
    options: ['Oui, crampons, fat bike ou ski', 'Gym ou maison', 'Un peu des deux', 'J\'hiberne, on se revoit au printemps'],
    category: 'Saison',
  ),
  const WaitingQuestion(
    id: 'q18',
    question: 'Si quelqu\'un te propose un café après, tu...',
    options: ['Oui direct', 'Si la vibe était bonne', 'Je préfère rester sur l\'app d\'abord', 'Je propose une autre activité plutôt'],
    category: 'Suite',
  ),
  const WaitingQuestion(
    id: 'q19',
    question: 'Playlist ou nature?',
    options: ['Écouteurs souvent', 'Juste le vent ou l\'eau', 'Mix des deux', 'Ça dépend du sport et du groupe'],
    category: 'Ambiance',
  ),
  const WaitingQuestion(
    id: 'q20',
    question: 'Premier kaiiak, tu espères surtout...',
    options: [
      'Ne pas finir à la traîne (lol)',
      'Rire au moins une fois',
      'Découvrir un nouveau spot',
      'Une belle rencontre pour la suite',
    ],
    category: 'Attentes',
  ),
];

/// Icebreaker prompts shown at checkpoints during a group activity.
final mockIcebreakers = <String>[
  'Étape 1 — C\'est quoi ta chanson du moment pour te motiver?',
  'Étape 2 — Ça fait combien de temps que tu pratiques ce sport?',
  'Étape 3 — Meilleur snack post-effort: sucré ou salé?',
  'Étape 4 — Si tu pouvais faire une activité n\'importe où demain, ce serait où?',
  'Étape 5 — C\'est quoi le prochain défi sportif ou sortie fun sur ta liste?',
  'Étape 6 — Tu préfères finir sur une montée, un sprint ou un cooldown zen?',
  'Dernier moment — Un compliment honnête à la personne à ta droite (sans weird 😉)',
];

final mockWaitingTips = <String>[
  'Hydrate-toi avant le départ',
  'Arrive 5 min tôt au point de rendez-vous',
  'Garde un rythme où tu peux encore jaser',
  'Laisse une oreillette libre si tu veux entendre le groupe',
  'Sois toi-même — l\'intensité s\'ajuste, la personnalité reste',
  'Apporte une couche ou l\'équipement météo si c\'est incertain',
];
