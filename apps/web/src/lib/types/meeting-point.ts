export type MeetingPointType = "park" | "cafe" | "landmark";

export interface MeetingPoint {
  id: string;
  name: string;
  type: MeetingPointType;
  address: string;
  neighborhood: string;
  description?: string;
  photoUrl?: string;
  mapsUrl?: string;
}

const typeLabels: Record<MeetingPointType, string> = {
  park: "Parc",
  cafe: "Café",
  landmark: "Point de repère",
};

const typeEmojis: Record<MeetingPointType, string> = {
  park: "🌳",
  cafe: "☕",
  landmark: "📍",
};

export function getMeetingPointLabel(type: MeetingPointType): string {
  return typeLabels[type];
}

export function getMeetingPointEmoji(type: MeetingPointType): string {
  return typeEmojis[type];
}
