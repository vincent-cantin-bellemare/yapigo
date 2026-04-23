import type { User } from "./user";

export interface Message {
  id: string;
  senderId: string;
  content: string;
  timestamp: string; // ISO string
  isIcebreaker: boolean;
}

export interface Conversation {
  id: string;
  groupName: string;
  members: User[];
  messages: Message[];
  matchId: string;
}

export function getLastMessage(
  conversation: Conversation,
): Message | undefined {
  return conversation.messages.at(-1);
}
