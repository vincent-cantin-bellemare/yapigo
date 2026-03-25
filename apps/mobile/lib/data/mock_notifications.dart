import 'package:kaiiak/models/app_notification.dart';

final mockNotifications = <AppNotification>[
  AppNotification(
    id: 'n1',
    type: NotificationType.matchFound,
    title: 'Ton groupe d\'activité est formé! 🎯',
    body: 'Bonne nouvelle! Ton groupe est formé pour le kaiiak de ce samedi sur le Plateau. '
        'Tu recevras le point de rendez-vous et le niveau bientôt. Pense à ta gourde!',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  AppNotification(
    id: 'n_threshold',
    type: NotificationType.thresholdReached,
    title: 'C\'est confirmé! Ton activité a lieu!',
    body: 'Assez de monde s\'est inscrit — ton kaiiak est officiel. '
        'Check les détails du parcours ou du studio et du rendez-vous dans l\'app.',
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
  ),
  AppNotification(
    id: 'n_crush',
    type: NotificationType.crushMatch,
    title: 'C\'est un match! Vous vous êtes likés mutuellement',
    body: 'Toi et quelqu\'un d\'autre de ton dernier groupe vous vous êtes likés. '
        'Ouvre le chat pour planifier une prochaine sortie ensemble.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    fromUserId: 'u2',
    fromUserName: 'Marc-Antoine',
    fromUserPhotoUrl: 'https://i.pravatar.cc/300?img=12',
  ),
  AppNotification(
    id: 'n_contact1',
    type: NotificationType.contactRequest,
    title: 'Sophie aimerait te connaître! 💌',
    body: 'Sophie du kaiiak Vélo Laurier de samedi dernier souhaite '
        'échanger en privé. Accepte sa demande pour continuer la conversation!',
    timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
    fromUserId: 'u1',
    fromUserName: 'Sophie',
    fromUserPhotoUrl: 'https://i.pravatar.cc/300?img=1',
  ),
  AppNotification(
    id: 'n2',
    type: NotificationType.runConfirmed,
    title: 'Ton activité est confirmée! ✅',
    body: 'Ton kaiiak de samedi est officiel.\n'
        '• Rendez-vous au parc Laurier à 9h00\n'
        '• Sortie vélo d\'environ 20 km, niveau « renard rusé »\n'
        '• Cherche le groupe avec le drapeau kaiiak\n'
        '• Bonne sortie!',
    timestamp: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  AppNotification(
    id: 'n_spot',
    type: NotificationType.spotFreed,
    title: 'Une place s\'est libérée! 🎟️',
    body: 'Quelqu\'un s\'est désinscrit du kayak sur le canal dimanche matin. '
        'C\'était sur ta liste d\'attente — tu as 24 h pour confirmer ta place.',
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  AppNotification(
    id: 'n3',
    type: NotificationType.runToday,
    title: 'C\'est aujourd\'hui! 🧘',
    body: 'Ton kaiiak commence bientôt! RDV à 9h00 au parc Laurier, 2975 rue Brébeuf. '
        'N\'oublie pas ta gourde, ton sourire et une couche si ça refroidit.',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  AppNotification(
    id: 'n4',
    type: NotificationType.deadlineReminder,
    title: 'Plus que 2h pour t\'inscrire! ⏰',
    body: 'Les inscriptions pour ce samedi ferment bientôt. '
        'Il reste des places à Hochelaga et Villeray — saisis ta chance!',
    timestamp: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  AppNotification(
    id: 'n_no_quorum',
    type: NotificationType.eventCancelledNoQuorum,
    title: 'Activité annulée — pas assez de monde',
    body: 'Malheureusement, le kaiiak de jeudi n\'a pas atteint le minimum de participants. '
        'Tu peux te réinscrire à un autre créneau sans frais.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  AppNotification(
    id: 'n5',
    type: NotificationType.rateReminder,
    title: 'Comment c\'était samedi? ⭐',
    body: 'Note ton dernier kaiiak au Mile-End — ça nous aide à former de meilleurs groupes. '
        'Bonus: 15 XP pour toi.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
];
