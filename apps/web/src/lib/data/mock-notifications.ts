import type { AppNotification } from "@/lib/types";

function hoursAgo(h: number): string {
  return new Date(Date.now() - h * 3600_000).toISOString();
}

function daysAgo(d: number): string {
  return new Date(Date.now() - d * 86400_000).toISOString();
}

export const mockNotifications: AppNotification[] = [
  {
    id: "n1",
    type: "matchFound",
    title: "Ton groupe d'activité est formé! 🎯",
    body: "Bonne nouvelle! Ton groupe est formé pour le Run Date de ce samedi sur le Plateau. Tu recevras le point de rendez-vous et le niveau bientôt. Pense à ta gourde!",
    timestamp: hoursAgo(1),
    isRead: false,
  },
  {
    id: "n_threshold",
    type: "thresholdReached",
    title: "C'est confirmé! Ton activité a lieu!",
    body: "Assez de monde s'est inscrit — ton Run Date est officiel. Check les détails du parcours ou du studio et du rendez-vous dans l'app.",
    timestamp: hoursAgo(1.3),
    isRead: false,
  },
  {
    id: "n_crush",
    type: "crushMatch",
    title: "C'est un match! Vous vous êtes likés mutuellement",
    body: "Toi et quelqu'un d'autre de ton dernier groupe vous vous êtes likés. Ouvre le chat pour planifier une prochaine sortie ensemble.",
    timestamp: hoursAgo(2),
    isRead: false,
    fromUserId: "u2",
    fromUserName: "Marc-Antoine",
    fromUserPhotoUrl: "https://randomuser.me/api/portraits/women/44.jpg",
  },
  {
    id: "n_contact1",
    type: "contactRequest",
    title: "Sophie aimerait te connaître! 💌",
    body: "Sophie du Run Date Vélo Laurier de samedi dernier souhaite échanger en privé. Accepte sa demande pour continuer la conversation!",
    timestamp: hoursAgo(2.5),
    isRead: false,
    fromUserId: "u1",
    fromUserName: "Sophie",
    fromUserPhotoUrl: "https://randomuser.me/api/portraits/men/45.jpg",
  },
  {
    id: "n2",
    type: "runConfirmed",
    title: "Ton activité est confirmée! ✅",
    body: "Ton Run Date de samedi est officiel.\n• Rendez-vous au parc Laurier à 9h00\n• Sortie vélo d'environ 20 km, niveau « renard rusé »\n• Cherche le groupe avec le drapeau Run Date\n• Bonne sortie!",
    timestamp: hoursAgo(3),
    isRead: false,
  },
  {
    id: "n_spot",
    type: "spotFreed",
    title: "Une place s'est libérée! 🎟️",
    body: "Quelqu'un s'est désinscrit du kayak sur le canal dimanche matin. C'était sur ta liste d'attente — tu as 24 h pour confirmer ta place.",
    timestamp: hoursAgo(4),
    isRead: false,
  },
  {
    id: "n3",
    type: "runToday",
    title: "C'est aujourd'hui! 🧘",
    body: "Ton Run Date commence bientôt! RDV à 9h00 au parc Laurier, 2975 rue Brébeuf. N'oublie pas ta gourde, ton sourire et une couche si ça refroidit.",
    timestamp: hoursAgo(5),
    isRead: false,
  },
  {
    id: "n4",
    type: "deadlineReminder",
    title: "Plus que 2h pour t'inscrire! ⏰",
    body: "Les inscriptions pour ce samedi ferment bientôt. Il reste des places à Hochelaga et Villeray — saisis ta chance!",
    timestamp: hoursAgo(8),
    isRead: true,
  },
  {
    id: "n_no_quorum",
    type: "eventCancelledNoQuorum",
    title: "Activité annulée — pas assez de monde",
    body: "Malheureusement, le Run Date de jeudi n'a pas atteint le minimum de participants. Tu peux te réinscrire à un autre créneau sans frais.",
    timestamp: daysAgo(1),
    isRead: true,
  },
  {
    id: "n5",
    type: "rateReminder",
    title: "Comment c'était samedi? ⭐",
    body: "Note ton dernier Run Date au Mile-End — ça nous aide à former de meilleurs groupes. Bonus: 15 XP pour toi.",
    timestamp: daysAgo(2),
    isRead: true,
  },
];
