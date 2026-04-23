export interface EventPhoto {
  id: string;
  eventId: string;
  userId: string;
  userName: string;
  photoUrl: string;
  timestamp: string; // ISO string
  description?: string;
}
