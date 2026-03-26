import 'package:rundate/models/event_photo.dart';

final mockEventPhotos = <EventPhoto>[
  // Past event e7 — Hochelaga
  EventPhoto(
    id: 'ph1',
    eventId: 'e7',
    userId: 'u1',
    userName: 'Sophie',
    photoUrl: 'https://picsum.photos/seed/event_e7_1/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    description: 'Le coucher de soleil était malade!',
  ),
  EventPhoto(
    id: 'ph2',
    eventId: 'e7',
    userId: 'u7',
    userName: 'Olivier',
    photoUrl: 'https://picsum.photos/seed/event_e7_2/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 6)),
    description: 'Jam session improvisée 🎸',
  ),
  EventPhoto(
    id: 'ph3',
    eventId: 'e7',
    userId: 'u4',
    userName: 'Émilie',
    photoUrl: 'https://picsum.photos/seed/event_e7_3/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
  ),

  // Past event e8 — Vieux-Port
  EventPhoto(
    id: 'ph4',
    eventId: 'e8',
    userId: 'u2',
    userName: 'Marc-Antoine',
    photoUrl: 'https://picsum.photos/seed/event_e8_1/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 13)),
    description: 'Le plateau de fromages était A+',
  ),
  EventPhoto(
    id: 'ph5',
    eventId: 'e8',
    userId: 'u5',
    userName: 'Jean-Philippe',
    photoUrl: 'https://picsum.photos/seed/event_e8_2/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 13)),
  ),
  EventPhoto(
    id: 'ph6',
    eventId: 'e8',
    userId: 'u3',
    userName: 'Camille',
    photoUrl: 'https://picsum.photos/seed/event_e8_3/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 12)),
    description: 'Notre coin au bord de l\'eau',
  ),

  // Past event e9 — Plateau
  EventPhoto(
    id: 'ph7',
    eventId: 'e9',
    userId: 'u6',
    userName: 'Maude',
    photoUrl: 'https://picsum.photos/seed/event_e9_1/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 20)),
    description: 'Meilleur run de l\'été!',
  ),
  EventPhoto(
    id: 'ph8',
    eventId: 'e9',
    userId: 'u8',
    userName: 'Isabelle',
    photoUrl: 'https://picsum.photos/seed/event_e9_2/400/300',
    timestamp: DateTime.now().subtract(const Duration(days: 19)),
  ),
];
