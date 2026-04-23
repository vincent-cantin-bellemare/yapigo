"use client";

import { useState, useRef, useEffect, useCallback, use } from "react";
import Link from "next/link";
import { mockConversations, mockUsers, mockIcebreakers } from "@/lib/data";
import type { User, Message } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { EventCategory } from "@/lib/types";
import { cn } from "@/lib/utils";
import {
  ArrowLeft,
  MoreHorizontal,
  Send,
  Users,
  BellOff,
  Bell,
  LogOut,
  Flag,
  Sparkles,
  X,
} from "lucide-react";

const MEMBER_COLORS = [
  "text-primary",
  "text-teal-500",
  "text-teal-600",
  "text-amber-500",
  "text-indigo-400",
  "text-destructive",
  "text-purple-500",
  "text-navy",
];

const BUBBLE_BG_COLORS = [
  "bg-primary/5",
  "bg-teal-500/5",
  "bg-teal-600/5",
  "bg-amber-500/5",
  "bg-indigo-400/5",
  "bg-rose-500/5",
  "bg-purple-500/5",
  "bg-navy/5",
];

function formatTime(iso: string): string {
  const d = new Date(iso);
  return `${String(d.getHours()).padStart(2, "0")}:${String(d.getMinutes()).padStart(2, "0")}`;
}

function formatRelative(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const secs = Math.floor(diff / 1000);
  if (secs < 45) return "à l'instant";
  const mins = Math.floor(secs / 60);
  if (mins < 60) return `il y a ${mins} min`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `il y a ${hours}h`;
  const days = Math.floor(hours / 24);
  if (days === 1) return "hier";
  return `il y a ${days} jours`;
}

interface Props {
  params: Promise<{ id: string }>;
}

export default function ChatPage({ params }: Props) {
  const { id } = use(params);
  const conversation = mockConversations.find((c) => c.id === id);

  const [messages, setMessages] = useState<Message[]>(
    conversation?.messages ?? [],
  );
  const [inputText, setInputText] = useState("");
  const [showMenu, setShowMenu] = useState(false);
  const [muted, setMuted] = useState(false);
  const [showMembers, setShowMembers] = useState(false);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);
  let idCounter = useRef(0);

  const members = conversation?.members ?? [];
  const memberCount = members.length + 1;

  useEffect(() => {
    scrollRef.current?.scrollTo({
      top: scrollRef.current.scrollHeight,
      behavior: "smooth",
    });
  }, [messages]);

  const colorForSender = useCallback(
    (senderId: string) => {
      const idx = members.findIndex((m) => m.id === senderId);
      return idx >= 0 ? idx % MEMBER_COLORS.length : 0;
    },
    [members],
  );

  const nameForSender = useCallback(
    (senderId: string): string => {
      return members.find((m) => m.id === senderId)?.firstName ?? "";
    },
    [members],
  );

  const sendMessage = useCallback(
    (text: string) => {
      const trimmed = text.trim();
      if (!trimmed) return;
      idCounter.current++;
      const msg: Message = {
        id: `local_${Date.now()}_${idCounter.current}`,
        senderId: "current",
        content: trimmed,
        timestamp: new Date().toISOString(),
        isIcebreaker: false,
      };
      setMessages((prev) => [...prev, msg]);
      setInputText("");
      inputRef.current?.focus();
    },
    [],
  );

  const openProfile = useCallback((user: User) => {
    setSelectedUser(user);
    setSheetOpen(true);
    setShowMembers(false);
  }, []);

  if (!conversation) {
    return (
      <div className="flex h-[calc(100dvh-5rem)] items-center justify-center">
        <p className="text-muted-foreground">Conversation introuvable</p>
      </div>
    );
  }

  const icebreaker =
    mockIcebreakers.length > 0 ? mockIcebreakers[0] : "";

  return (
    <div className="flex h-[calc(100dvh-5rem)] flex-col">
      {/* Header */}
      <header className="relative flex items-center gap-3 border-b border-border px-3 py-3">
        <Link
          href="/activity"
          className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full hover:bg-muted"
        >
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div className="min-w-0 flex-1">
          <h1 className="truncate font-heading text-[17px] font-bold">
            {conversation.groupName}
          </h1>
          <p className="text-sm text-muted-foreground">
            {memberCount} membres
          </p>
        </div>
        <div className="relative">
          <button
            onClick={() => setShowMenu(!showMenu)}
            className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-muted"
          >
            <MoreHorizontal className="h-5 w-5" />
          </button>
          {showMenu && (
            <>
              <div
                className="fixed inset-0 z-40"
                onClick={() => setShowMenu(false)}
              />
              <div className="absolute right-0 top-full z-50 mt-1 w-56 rounded-xl border bg-popover py-1 shadow-lg">
                <button
                  onClick={() => {
                    setShowMembers(true);
                    setShowMenu(false);
                  }}
                  className="flex w-full items-center gap-2.5 px-3 py-2.5 text-sm hover:bg-accent"
                >
                  <Users className="h-4 w-4" />
                  Voir les membres
                </button>
                <button
                  onClick={() => {
                    setMuted(!muted);
                    setShowMenu(false);
                  }}
                  className="flex w-full items-center gap-2.5 px-3 py-2.5 text-sm hover:bg-accent"
                >
                  {muted ? (
                    <Bell className="h-4 w-4" />
                  ) : (
                    <BellOff className="h-4 w-4" />
                  )}
                  {muted
                    ? "Réactiver les notifications"
                    : "Couper les notifications"}
                </button>
                <button
                  onClick={() => setShowMenu(false)}
                  className="flex w-full items-center gap-2.5 px-3 py-2.5 text-sm hover:bg-accent"
                >
                  <LogOut className="h-4 w-4" />
                  Quitter le groupe
                </button>
                <button
                  onClick={() => setShowMenu(false)}
                  className="flex w-full items-center gap-2.5 px-3 py-2.5 text-sm text-destructive hover:bg-accent"
                >
                  <Flag className="h-4 w-4" />
                  Signaler
                </button>
              </div>
            </>
          )}
        </div>
      </header>

      {/* Messages area */}
      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto px-4 py-3"
      >
        {messages.length === 0 && icebreaker ? (
          <IcebreakerHint
            suggestion={icebreaker}
            onSend={() => sendMessage(icebreaker)}
          />
        ) : (
          <div className="space-y-3">
            {messages.map((msg) => {
              if (msg.isIcebreaker) {
                return (
                  <IcebreakerBubble
                    key={msg.id}
                    content={msg.content}
                    time={`${formatTime(msg.timestamp)} · ${formatRelative(msg.timestamp)}`}
                  />
                );
              }

              const isMine = msg.senderId === "current";
              const colorIdx = colorForSender(msg.senderId);

              return (
                <div
                  key={msg.id}
                  className={cn(
                    "flex flex-col",
                    isMine ? "items-end" : "items-start",
                  )}
                >
                  {!isMine && (
                    <button
                      onClick={() => {
                        const user = mockUsers.find(
                          (u) => u.id === msg.senderId,
                        );
                        if (user) openProfile(user);
                      }}
                      className={cn(
                        "mb-1 pl-2 text-sm font-bold",
                        MEMBER_COLORS[colorIdx],
                      )}
                    >
                      {nameForSender(msg.senderId)}
                    </button>
                  )}
                  <div
                    className={cn(
                      "max-w-[78%] rounded-2xl px-3.5 py-2.5 shadow-sm",
                      isMine
                        ? "rounded-br-sm bg-primary text-white"
                        : cn(
                            "rounded-bl-sm border border-border/50",
                            BUBBLE_BG_COLORS[colorIdx],
                          ),
                    )}
                  >
                    <p className="text-[15px] leading-snug">
                      {msg.content}
                    </p>
                  </div>
                  <p
                    className={cn(
                      "mt-1 text-sm text-muted-foreground/70",
                      isMine ? "pr-2" : "pl-2",
                    )}
                  >
                    {formatTime(msg.timestamp)} ·{" "}
                    {formatRelative(msg.timestamp)}
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Input bar */}
      <div className="border-t border-border bg-background px-3 py-2 shadow-[0_-2px_8px_rgba(0,0,0,0.04)]">
        <div className="flex items-end gap-1.5">
          <input
            ref={inputRef}
            type="text"
            value={inputText}
            onChange={(e) => setInputText(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                sendMessage(inputText);
              }
            }}
            placeholder="Message au groupe…"
            className="flex-1 rounded-full border border-border bg-muted/30 px-4 py-2.5 text-base placeholder:text-muted-foreground/50 focus:border-primary focus:outline-none focus:ring-2 focus:ring-primary/20"
          />
          <button
            onClick={() => sendMessage(inputText)}
            className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-primary text-white hover:bg-primary/90"
          >
            <Send className="h-5 w-5" />
          </button>
        </div>
      </div>

      {/* Members drawer */}
      {showMembers && (
        <>
          <div
            className="fixed inset-0 z-40 bg-black/30"
            onClick={() => setShowMembers(false)}
          />
          <div className="fixed inset-x-0 bottom-0 z-50 rounded-t-3xl bg-background pb-8 pt-4 shadow-xl">
            <div className="mx-auto mb-5 h-1 w-10 rounded-full bg-muted-foreground/30" />
            <h2 className="px-6 font-heading text-lg font-bold">
              Membres du groupe
            </h2>
            <div className="mt-4 space-y-1 px-4">
              {members.map((u) => (
                <button
                  key={u.id}
                  onClick={() => openProfile(u)}
                  className="flex w-full items-center gap-3 rounded-xl px-2 py-2.5 text-left hover:bg-accent"
                >
                  <UserAvatar
                    photoUrl={u.photoUrl}
                    firstName={u.firstName}
                    lastName={u.lastName}
                    size="md"
                  />
                  <div className="min-w-0 flex-1">
                    <p className="font-semibold">
                      {u.firstName} {u.lastName}
                    </p>
                    <p className="text-sm text-muted-foreground">
                      {u.activities
                        .map((a) => EventCategory[a.category]?.emoji ?? a.category)
                        .join(" ")}
                    </p>
                  </div>
                </button>
              ))}
            </div>
          </div>
        </>
      )}

      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
    </div>
  );
}

function IcebreakerBubble({
  content,
  time,
}: {
  content: string;
  time: string;
}) {
  return (
    <div className="flex flex-col items-center">
      <div className="inline-flex max-w-xs items-center gap-2 rounded-2xl bg-teal-500 px-3.5 py-2.5">
        <Sparkles className="h-4 w-4 shrink-0 text-white/90" />
        <p className="text-sm italic leading-snug text-white">
          {content}
        </p>
      </div>
      <p className="mt-1 text-sm text-muted-foreground/70">{time}</p>
    </div>
  );
}

function IcebreakerHint({
  suggestion,
  onSend,
}: {
  suggestion: string;
  onSend: () => void;
}) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center px-6">
      <p className="text-sm font-semibold text-muted-foreground">
        Idée pour briser la glace
      </p>
      <div className="mt-3 w-full rounded-2xl border border-border bg-card p-4">
        <p className="text-center text-base leading-relaxed">
          {suggestion}
        </p>
      </div>
      <button
        onClick={onSend}
        className="mt-4 rounded-full border border-primary px-5 py-2 text-sm font-semibold text-primary hover:bg-primary/5"
      >
        Envoyer au groupe
      </button>
    </div>
  );
}
