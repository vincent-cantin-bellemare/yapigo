import type { EventCategoryKey, IntensityLevelKey } from "./event";

export interface UserActivity {
  category: EventCategoryKey;
  level: IntensityLevelKey;
}

export const BadgeLevel = {
  curieux: { label: "Curieux", icon: "👁️", minXp: 0 },
  social: { label: "Social", icon: "👋", minXp: 100 },
  habitue: { label: "Habitué", icon: "⭐", minXp: 300 },
  populaire: { label: "Populaire", icon: "🔥", minXp: 600 },
  legende: { label: "Légende", icon: "👑", minXp: 1000 },
} as const;

export type BadgeLevelKey = keyof typeof BadgeLevel;

export function getBadgeFromXp(xp: number): BadgeLevelKey {
  const levels = Object.entries(BadgeLevel) as [
    BadgeLevelKey,
    (typeof BadgeLevel)[BadgeLevelKey],
  ][];
  for (let i = levels.length - 1; i >= 0; i--) {
    if (xp >= levels[i][1].minXp) return levels[i][0];
  }
  return "curieux";
}

export interface User {
  id: string;
  firstName: string;
  lastName: string;
  phone: string;
  gender: string;
  sexualOrientation?: string;
  age: number;
  city: string;
  neighborhood?: string;
  photoUrl?: string;
  bio?: string;
  isVerified: boolean;
  xp: number;
  badge: BadgeLevelKey;
  isSuspended: boolean;
  memberSince?: string; // ISO string
  lastActivityDate?: string;
  lastSeenDate?: string;
  averageRating?: number;
  totalActivities: number;
  totalKm: number;
  photoGallery: string[];
  activities: UserActivity[];
  activityGoals: string[];
  isOrganizer: boolean;
  connections: number;

  stravaConnected: boolean;
  stravaAthleteId?: number;
  stravaDisplayName?: string;
  stravaYtdKm?: number;
  stravaYtdRuns?: number;
  stravaAvgPaceSeconds?: number;
  stravaMonthKm?: number;
}

export function getStravaProfileUrl(user: User): string | null {
  return user.stravaAthleteId
    ? `https://www.strava.com/athletes/${user.stravaAthleteId}`
    : null;
}

export function getStravaAvgPace(user: User): string | null {
  if (!user.stravaAvgPaceSeconds) return null;
  const minutes = Math.floor(user.stravaAvgPaceSeconds / 60);
  const seconds = user.stravaAvgPaceSeconds % 60;
  return `${minutes}:${String(seconds).padStart(2, "0")} /km`;
}
