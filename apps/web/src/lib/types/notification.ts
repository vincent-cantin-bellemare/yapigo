export type NotificationType =
  | "matchFound"
  | "runConfirmed"
  | "runCancelled"
  | "deadlineReminder"
  | "runToday"
  | "rateReminder"
  | "friendInvited"
  | "contactRequest"
  | "thresholdReached"
  | "eventCancelledNoQuorum"
  | "spotFreed"
  | "crushMatch";

export interface AppNotification {
  id: string;
  type: NotificationType;
  title: string;
  body: string;
  timestamp: string; // ISO string
  isRead: boolean;
  fromUserId?: string;
  fromUserName?: string;
  fromUserPhotoUrl?: string;
}
