import type { EventPhoto } from "@/lib/types";

function daysAgo(days: number): string {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return d.toISOString();
}

export const mockEventPhotos: EventPhoto[] = [
  {
    id: "ph1",
    eventId: "e7",
    userId: "u1",
    userName: "Sophie",
    photoUrl: "https://picsum.photos/seed/event_e7_1/400/300",
    timestamp: daysAgo(6),
    description: "Le coucher de soleil était malade!",
  },
  {
    id: "ph2",
    eventId: "e7",
    userId: "u7",
    userName: "Olivier",
    photoUrl: "https://picsum.photos/seed/event_e7_2/400/300",
    timestamp: daysAgo(6),
    description: "Jam session improvisée",
  },
  {
    id: "ph3",
    eventId: "e7",
    userId: "u4",
    userName: "Émilie",
    photoUrl: "https://picsum.photos/seed/event_e7_3/400/300",
    timestamp: daysAgo(5),
  },
  {
    id: "ph4",
    eventId: "e8",
    userId: "u2",
    userName: "Marc-Antoine",
    photoUrl: "https://picsum.photos/seed/event_e8_1/400/300",
    timestamp: daysAgo(13),
    description: "Le plateau de fromages était A+",
  },
  {
    id: "ph5",
    eventId: "e8",
    userId: "u5",
    userName: "Jean-Philippe",
    photoUrl: "https://picsum.photos/seed/event_e8_2/400/300",
    timestamp: daysAgo(13),
  },
  {
    id: "ph6",
    eventId: "e8",
    userId: "u3",
    userName: "Camille",
    photoUrl: "https://picsum.photos/seed/event_e8_3/400/300",
    timestamp: daysAgo(12),
    description: "Notre coin au bord de l'eau",
  },
  {
    id: "ph7",
    eventId: "e9",
    userId: "u6",
    userName: "Maude",
    photoUrl: "https://picsum.photos/seed/event_e9_1/400/300",
    timestamp: daysAgo(20),
    description: "Meilleur run de l'été!",
  },
  {
    id: "ph8",
    eventId: "e9",
    userId: "u8",
    userName: "Isabelle",
    photoUrl: "https://picsum.photos/seed/event_e9_2/400/300",
    timestamp: daysAgo(19),
  },
];
