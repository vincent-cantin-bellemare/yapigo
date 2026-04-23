export const EventCategory = {
  running: { label: "Course à pied", emoji: "🏃", icon: "running" },
  roadCycling: { label: "Vélo de route", emoji: "🚴", icon: "road_cycling" },
  mountainBiking: {
    label: "Vélo de montagne",
    emoji: "🚵",
    icon: "mountain_biking",
  },
  kayaking: { label: "Kayak", emoji: "🛶", icon: "kayaking" },
  yoga: { label: "Yoga", emoji: "🧘", icon: "yoga" },
  hiking: { label: "Randonnée", emoji: "🥾", icon: "hiking" },
  swimming: { label: "Natation", emoji: "🏊", icon: "swimming" },
  crossCountrySkiing: {
    label: "Ski de fond",
    emoji: "⛷️",
    icon: "cross_country_skiing",
  },
  snowshoeing: { label: "Raquette", emoji: "🏔️", icon: "snowshoeing" },
  skating: { label: "Patin", emoji: "⛸️", icon: "skating" },
  socialGathering: {
    label: "Rassemblement social",
    emoji: "🧺",
    icon: "social_gathering",
  },
  mixedTraining: {
    label: "Entraînement mixte",
    emoji: "💪",
    icon: "mixed_training",
  },
} as const;

export type EventCategoryKey = keyof typeof EventCategory;

export type EventStatus = "upcoming" | "waitlisted" | "confirmed" | "past";

export type RegistrationStatus =
  | "notRegistered"
  | "waitlisted"
  | "confirmed"
  | "waitlistFull"
  | "cancelled";

export const IntensityLevel = {
  chill: {
    label: "Chill",
    emoji: "🚶",
    description: "On jase, on prend notre temps",
  },
  relax: {
    label: "Relax",
    emoji: "🌿",
    description: "Rythme confortable, pas de pression",
  },
  moderate: {
    label: "Modéré",
    emoji: "👟",
    description: "On se dépense bien",
  },
  intense: {
    label: "Intense",
    emoji: "💨",
    description: "On pousse la machine",
  },
  extreme: { label: "Extrême", emoji: "🔥", description: "Mode athlète" },
} as const;

export type IntensityLevelKey = keyof typeof IntensityLevel;

export const DistanceLabel = {
  short: {
    label: "Courte",
    emoji: "🏁",
    description: "Parfait pour débuter",
  },
  medium: {
    label: "Moyenne",
    emoji: "📍",
    description: "L'idéale pour jaser",
  },
  long: {
    label: "Longue",
    emoji: "⚡",
    description: "On commence à être sérieux",
  },
  veryLong: {
    label: "Très longue",
    emoji: "🏅",
    description: "Pour les passionnés",
  },
  ultra: {
    label: "Ultra",
    emoji: "🌟",
    description: "Pour les plus ambitieux",
  },
} as const;

export type DistanceLabelKey = keyof typeof DistanceLabel;

export type PaymentStatus = "none" | "pending" | "completed" | "refunded";

export const RecurrenceType = {
  oneTime: { label: "Ponctuelle" },
  weekly: { label: "Chaque semaine" },
  biWeekly: { label: "Aux 2 semaines" },
  monthly: { label: "Chaque mois" },
  custom: { label: "Personnalisée" },
} as const;

export type RecurrenceTypeKey = keyof typeof RecurrenceType;

const dayNames = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

export interface KaiEvent {
  id: string;
  category: EventCategoryKey;
  neighborhood: string;
  city: string;
  date: string; // ISO string
  deadline: string; // ISO string
  totalRegistered: number;
  menCount: number;
  womenCount: number;
  meetingPointId?: string;
  tags: string[];
  intensityLevel: IntensityLevelKey;
  distanceLabel: DistanceLabelKey;
  aperoSmoothieSpot?: string;
  minThreshold: number;
  maxCapacity: number;
  targetGroupSize: number;
  subGroupCount: number;
  isConfirmed: boolean;
  isFull: boolean;
  registrationStatus: RegistrationStatus;
  organizerIds: string[];
  myRating?: number;
  waitlistPosition?: number;
  price?: number;
  paymentStatus: PaymentStatus;
  recurrence: RecurrenceTypeKey;
  customDays?: number[];
}

export function getEventStatus(event: KaiEvent): EventStatus {
  if (new Date(event.date) < new Date()) return "past";
  if (event.registrationStatus === "confirmed") return "confirmed";
  if (event.registrationStatus === "waitlisted") return "waitlisted";
  return "upcoming";
}

export function getSpotsRemaining(event: KaiEvent): number {
  return event.maxCapacity - event.totalRegistered;
}

export function getNeededForThreshold(event: KaiEvent): number {
  if (event.isConfirmed) return 0;
  return Math.max(0, event.minThreshold - event.totalRegistered);
}

export function getPriceLabel(event: KaiEvent): string {
  return event.price == null ? "Gratuit" : `${event.price} $`;
}

export function getRecurrenceLabel(event: KaiEvent): string {
  if (
    event.recurrence === "custom" &&
    event.customDays &&
    event.customDays.length > 0
  ) {
    const names = event.customDays.map((d) => dayNames[d - 1]).join(", ");
    return `Chaque ${names}`;
  }
  return RecurrenceType[event.recurrence].label;
}
