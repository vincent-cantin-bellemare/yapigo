import type { Conversation } from "@/lib/types";
import { mockUsers } from "./mock-users";

function hoursAgo(h: number): string {
  return new Date(Date.now() - h * 3600_000).toISOString();
}

function daysAgo(d: number, extraHours = 0): string {
  return new Date(
    Date.now() - (d * 86400_000 + extraHours * 3600_000),
  ).toISOString();
}

export const mockConversations: Conversation[] = [
  {
    id: "c1",
    groupName: "🏃 Course · Lachine",
    members: [mockUsers[1], mockUsers[2], mockUsers[3], mockUsers[5], mockUsers[6]],
    matchId: "m1",
    messages: [
      {
        id: "msg0",
        senderId: "system",
        content:
          "Bienvenue dans ton groupe! Présentez-vous après la sortie 🚴",
        timestamp: hoursAgo(8),
        isIcebreaker: true,
      },
      {
        id: "msg1",
        senderId: "u1",
        content:
          "Salut! Sophie ici — t'as roulé en combien de temps? J'étais en mode chill à 22 km/h haha",
        timestamp: hoursAgo(7),
        isIcebreaker: false,
      },
      {
        id: "msg2",
        senderId: "current",
        content:
          "Hey! Alex, j'ai tellement ri sur le bord du canal, t'es drôle!",
        timestamp: hoursAgo(6.5),
        isIcebreaker: false,
      },
      {
        id: "msg3",
        senderId: "u2",
        content:
          "Marc-Antoine! Le café après était parfait, on remet ça?",
        timestamp: hoursAgo(6),
        isIcebreaker: false,
      },
      {
        id: "msg4",
        senderId: "u6",
        content:
          "Oui! Maude btw — as-tu déjà essayé la piste vers le Vieux-Port?",
        timestamp: hoursAgo(5.5),
        isIcebreaker: false,
      },
      {
        id: "msg5",
        senderId: "u3",
        content:
          "Pas encore! Camille — qui revient dimanche prochain pour un autre tour?",
        timestamp: hoursAgo(5),
        isIcebreaker: false,
      },
      {
        id: "msg6",
        senderId: "u7",
        content:
          "Oli ici — moi j'y suis si le vent est correct. J'amène une rustine au cas où",
        timestamp: hoursAgo(4),
        isIcebreaker: false,
      },
      {
        id: "msg7",
        senderId: "u1",
        content:
          "Parfait! Quelqu'un veut un 25 km tranquille jeudi soir? 😅",
        timestamp: hoursAgo(3),
        isIcebreaker: false,
      },
      {
        id: "msg8",
        senderId: "current",
        content:
          "Je suis partant! On se donne le point de départ demain",
        timestamp: hoursAgo(2.5),
        isIcebreaker: false,
      },
      {
        id: "msg9",
        senderId: "u6",
        content: "Nice! Hâte de recroiser le monde sur la piste 🙌",
        timestamp: hoursAgo(2),
        isIcebreaker: false,
      },
    ],
  },
  {
    id: "c2",
    groupName: "🥾 Rando · Mont-Royal",
    members: [mockUsers[3], mockUsers[4], mockUsers[7]],
    matchId: "m2",
    messages: [
      {
        id: "msg10",
        senderId: "system",
        content:
          "Comment s'est passée votre randonnée? Partagez vos impressions!",
        timestamp: daysAgo(7),
        isIcebreaker: true,
      },
      {
        id: "msg11",
        senderId: "u4",
        content:
          "C'était le fun! Le dénivelé était bon pour jaser sans être essoufflé 👌",
        timestamp: daysAgo(6, 20),
        isIcebreaker: false,
      },
      {
        id: "msg12",
        senderId: "current",
        content:
          "Tellement! Si quelqu'un est down pour un yoga à Villeray dimanche puis brunch, écris-moi",
        timestamp: daysAgo(6, 18),
        isIcebreaker: false,
      },
    ],
  },
  {
    id: "c_private",
    groupName: "Marc 💘",
    members: [mockUsers[1]],
    matchId: "match_private",
    messages: [
      {
        id: "pm1",
        senderId: "system",
        content:
          "Vous vous êtes mutuellement likés! La conversation est ouverte 💘",
        timestamp: daysAgo(1, 3),
        isIcebreaker: true,
      },
      {
        id: "pm2",
        senderId: "u1",
        content:
          "Hey! C'était vraiment le fun de faire la rando Mont-Royal avec toi samedi. T'as un bon rythme!",
        timestamp: daysAgo(1, 2),
        isIcebreaker: false,
      },
      {
        id: "pm3",
        senderId: "current",
        content:
          "Merci! Toi aussi! J'ai adoré le sentier que t'as proposé 🥾",
        timestamp: daysAgo(1, 1.5),
        isIcebreaker: false,
      },
      {
        id: "pm4",
        senderId: "u1",
        content:
          "On se refait une sortie Run Date bientôt? Je connais un beau spot kayak à Lachine",
        timestamp: hoursAgo(20),
        isIcebreaker: false,
      },
      {
        id: "pm5",
        senderId: "current",
        content:
          "Oui tellement! Je suis libre vendredi soir si ça te dit",
        timestamp: hoursAgo(18),
        isIcebreaker: false,
      },
      {
        id: "pm6",
        senderId: "u1",
        content: "Parfait! On se dit 18h au quai? ☀️",
        timestamp: hoursAgo(5),
        isIcebreaker: false,
      },
    ],
  },
];

export const mockIcebreakers = [
  "Étape 1 — C'est quoi ta chanson du moment pour te motiver?",
  "Étape 2 — Ça fait combien de temps que tu pratiques ce sport?",
  "Étape 3 — Meilleur snack post-effort: sucré ou salé?",
  "Étape 4 — Si tu pouvais faire une activité n'importe où demain, ce serait où?",
  "Étape 5 — C'est quoi le prochain défi sportif ou sortie fun sur ta liste?",
];

export const bannerSubtitles = [
  "Planifie ta prochaine sortie!",
  "Tes co-coureurs t'attendent!",
  "Un run, des connexions!",
  "Qui court avec toi ce vendredi?",
  "Organise un after-run!",
];
