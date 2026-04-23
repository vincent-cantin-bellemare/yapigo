"use client";

import { useState, useMemo, useCallback } from "react";
import Link from "next/link";
import {
  mockUsers,
  currentUser,
  mockConversations,
  mockNotifications,
  bannerSubtitles,
} from "@/lib/data";
import type { User, Conversation, AppNotification, NotificationType } from "@/lib/types";
import { getLastMessage } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { cn } from "@/lib/utils";
import {
  MessageSquare,
  Bell,
  UserPlus,
  Users,
  Heart,
  CheckCircle,
  XCircle,
  Clock,
  CalendarDays,
  Star,
  Gift,
  AlertTriangle,
  UserCheck,
  Sparkles,
  Ticket,
  ChevronRight,
  X,
  Check,
  Send,
  Quote,
} from "lucide-react";

type ActivityTab = "messages" | "notifications" | "connections";

function formatRelativeTime(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const secs = Math.floor(diff / 1000);
  if (secs < 45) return "à l'instant";
  const mins = Math.floor(secs / 60);
  if (mins < 60) return `il y a ${mins} min`;
  const hours = Math.floor(mins / 60);
  if (hours < 24) return `il y a ${hours}h`;
  const days = Math.floor(hours / 24);
  if (days === 1) return "hier";
  if (days < 7) return `il y a ${days} jours`;
  const d = new Date(iso);
  return `${String(d.getDate()).padStart(2, "0")}/${String(d.getMonth() + 1).padStart(2, "0")}`;
}

function hasUnread(conv: Conversation): boolean {
  const last = getLastMessage(conv);
  return !!last && last.senderId !== "current";
}

function senderName(senderId: string, members: User[]): string {
  if (senderId === "current") return "Toi";
  if (senderId === "system") return "";
  return members.find((m) => m.id === senderId)?.firstName ?? "";
}

const NOTIF_ICON_MAP: Record<
  NotificationType,
  { Icon: typeof Heart; colorClass: string; bgClass: string }
> = {
  matchFound: { Icon: Heart, colorClass: "text-primary", bgClass: "bg-primary/15" },
  runConfirmed: { Icon: CheckCircle, colorClass: "text-teal-500", bgClass: "bg-teal-500/15" },
  runCancelled: { Icon: XCircle, colorClass: "text-destructive", bgClass: "bg-destructive/15" },
  deadlineReminder: { Icon: Clock, colorClass: "text-amber-500", bgClass: "bg-amber-500/15" },
  runToday: { Icon: CalendarDays, colorClass: "text-navy", bgClass: "bg-navy/15" },
  rateReminder: { Icon: Star, colorClass: "text-teal-500", bgClass: "bg-teal-500/15" },
  friendInvited: { Icon: Gift, colorClass: "text-primary", bgClass: "bg-primary/15" },
  contactRequest: { Icon: Heart, colorClass: "text-pink-500", bgClass: "bg-pink-500/15" },
  thresholdReached: { Icon: Users, colorClass: "text-teal-500", bgClass: "bg-teal-500/15" },
  eventCancelledNoQuorum: { Icon: AlertTriangle, colorClass: "text-destructive", bgClass: "bg-destructive/15" },
  spotFreed: { Icon: Ticket, colorClass: "text-amber-500", bgClass: "bg-amber-500/15" },
  crushMatch: { Icon: Heart, colorClass: "text-pink-500", bgClass: "bg-pink-500/15" },
};

type RequestStatus = "pending" | "accepted" | "declined";

interface ConnectionRequest {
  id: string;
  user: User;
  sentAt: string;
  message?: string;
  status: RequestStatus;
}

export default function ActivityPage() {
  const [activeTab, setActiveTab] = useState<ActivityTab>("messages");
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  const openProfile = useCallback((user: User) => {
    setSelectedUser(user);
    setSheetOpen(true);
  }, []);

  return (
    <div className="min-h-screen bg-background">
      {/* Title */}
      <div className="px-5 pt-8 pb-0">
        <h1 className="font-heading text-[28px] font-extrabold">Activité</h1>
      </div>

      {/* Tab bar */}
      <div className="px-5 pt-3 pb-1">
        <div className="flex h-[42px] rounded-xl bg-muted/60 p-1">
          {(
            [
              { key: "messages", label: "Messages" },
              { key: "notifications", label: "Notifications" },
              { key: "connections", label: "Connexions" },
            ] as const
          ).map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setActiveTab(key)}
              className={cn(
                "flex-1 rounded-[10px] text-sm font-bold transition-all",
                activeTab === key
                  ? "bg-primary text-white shadow-sm"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {/* Tab content */}
      <div className="mt-1">
        {activeTab === "messages" && (
          <MessagesTab onOpenProfile={openProfile} />
        )}
        {activeTab === "notifications" && (
          <NotificationsTab onOpenProfile={openProfile} />
        )}
        {activeTab === "connections" && (
          <ConnectionsTab onOpenProfile={openProfile} />
        )}
      </div>

      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   MESSAGES TAB
   ═══════════════════════════════════════════════════════════════ */

function MessagesTab({
  onOpenProfile,
}: {
  onOpenProfile: (u: User) => void;
}) {
  const conversations = mockConversations;
  const subtitle = useMemo(
    () => bannerSubtitles[Math.floor(Math.random() * bannerSubtitles.length)],
    [],
  );

  if (conversations.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center px-8 py-20 text-center">
        <div className="flex h-24 w-24 items-center justify-center rounded-full bg-primary/10">
          <MessageSquare className="h-12 w-12 text-primary/70" />
        </div>
        <h2 className="mt-6 font-heading text-xl font-bold">
          Tes conversations apparaîtront ici
        </h2>
        <p className="mt-3 text-[15px] leading-relaxed text-muted-foreground">
          Inscris-toi à un événement et tu courras avec un groupe de coureurs!
        </p>
        <Link
          href="/events"
          className="mt-7 inline-flex items-center gap-2 rounded-[14px] bg-primary px-6 py-3.5 text-[15px] font-semibold text-white hover:bg-primary/90"
        >
          <Sparkles className="h-5 w-5" />
          Découvrir les événements
        </Link>
      </div>
    );
  }

  return (
    <div className="pb-32">
      {/* Banner */}
      <div className="mx-4 mt-2 rounded-[14px] border border-teal-500/20 bg-gradient-to-r from-teal-500/10 to-teal-500/5 p-4">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-teal-500/15">
            <Users className="h-5 w-5 text-teal-500" />
          </div>
          <div>
            <p className="font-heading text-[15px] font-bold">
              {conversations.length} groupes actifs
            </p>
            <p className="text-sm text-muted-foreground">{subtitle}</p>
          </div>
        </div>
      </div>

      {/* Conversation list */}
      {conversations.map((conv, i) => {
        const last = getLastMessage(conv);
        const unread = hasUnread(conv);
        const memberCount = conv.members.length + 1;

        let preview = "";
        if (last) {
          const name = senderName(last.senderId, conv.members);
          preview = last.isIcebreaker
            ? last.content
            : name
              ? `${name}: ${last.content}`
              : last.content;
        }

        return (
          <div key={conv.id}>
            {i > 0 && (
              <div className="ml-[88px] mr-4 h-px bg-border/40" />
            )}
            <Link
              href={`/activity/chat/${conv.id}`}
              className={cn(
                "flex items-center gap-3 px-4 py-3.5 transition-colors hover:bg-accent/30",
                unread && "border-l-[3px] border-l-primary bg-primary/[0.04]",
              )}
            >
              <GroupAvatarStack members={conv.members} />
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-1.5">
                  <span
                    className={cn(
                      "truncate text-base",
                      unread ? "font-extrabold" : "font-bold",
                    )}
                  >
                    {conv.groupName}
                  </span>
                  <span className="shrink-0 rounded-lg bg-teal-500/15 px-1.5 py-0.5 text-xs font-bold text-teal-600">
                    {memberCount}
                  </span>
                </div>
                {last && (
                  <p className="text-sm italic text-teal-600">
                    Vendredi{" "}
                    {new Date(
                      new Date(last.timestamp).getTime() + 2 * 86400_000,
                    ).toLocaleDateString("fr-CA", {
                      day: "numeric",
                      month: "short",
                    })}
                  </p>
                )}
                <p
                  className={cn(
                    "mt-0.5 truncate text-sm",
                    unread
                      ? "font-semibold text-foreground"
                      : "text-muted-foreground",
                  )}
                >
                  {preview}
                </p>
              </div>
              <div className="flex shrink-0 flex-col items-end gap-1.5">
                {last && (
                  <span
                    className={cn(
                      "text-sm",
                      unread
                        ? "font-semibold text-primary"
                        : "text-muted-foreground",
                    )}
                  >
                    {formatRelativeTime(last.timestamp)}
                  </span>
                )}
                {unread && (
                  <span className="h-2.5 w-2.5 rounded-full bg-primary" />
                )}
              </div>
            </Link>
          </div>
        );
      })}
    </div>
  );
}

function GroupAvatarStack({ members }: { members: User[] }) {
  const show = members.slice(0, 3);
  const extra = members.length - 3;
  const colors = [
    "bg-primary",
    "bg-teal-500",
    "bg-teal-500",
    "bg-amber-500",
  ];

  return (
    <div className="relative h-12 w-14 shrink-0">
      {show.map((m, i) => (
        <div
          key={m.id}
          className={cn(
            "absolute flex h-8 w-8 items-center justify-center rounded-full border-2 border-background font-heading text-sm font-extrabold text-white",
            colors[i % colors.length],
          )}
          style={{
            left: i * 14,
            top: i % 2 === 0 ? 0 : 12,
          }}
        >
          {m.photoUrl ? (
            <img
              src={m.photoUrl}
              alt={m.firstName}
              className="h-full w-full rounded-full object-cover"
            />
          ) : (
            m.firstName[0]
          )}
        </div>
      ))}
      {extra > 0 && (
        <div
          className="absolute flex h-7 w-7 items-center justify-center rounded-full border-2 border-background bg-muted text-xs font-bold"
          style={{ left: show.length * 14, top: 6 }}
        >
          +{extra}
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   NOTIFICATIONS TAB
   ═══════════════════════════════════════════════════════════════ */

function NotificationsTab({
  onOpenProfile,
}: {
  onOpenProfile: (u: User) => void;
}) {
  const [items, setItems] = useState(mockNotifications);

  const archiveItem = useCallback(
    (id: string) => {
      setItems((prev) => prev.filter((n) => n.id !== id));
    },
    [],
  );

  if (items.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center px-8 py-20 text-center">
        <Bell className="h-16 w-16 text-primary/40" />
        <p className="mt-4 text-base text-muted-foreground">
          Aucune notification pour le moment.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-3 px-4 pb-32 pt-3">
      {items.map((notif) => (
        <NotificationCard
          key={notif.id}
          notification={notif}
          onArchive={() => archiveItem(notif.id)}
        />
      ))}
    </div>
  );
}

function NotificationCard({
  notification,
  onArchive,
}: {
  notification: AppNotification;
  onArchive: () => void;
}) {
  const spec = NOTIF_ICON_MAP[notification.type];
  const IconComp = spec.Icon;
  const isRead = notification.isRead;

  const hasActionButtons =
    notification.type === "contactRequest" ||
    notification.type === "spotFreed";

  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-2xl border bg-card shadow-sm",
        isRead ? "opacity-70" : "",
      )}
    >
      {/* Unread indicator */}
      {!isRead && (
        <div className="absolute inset-y-0 left-0 w-1 rounded-l-2xl bg-primary" />
      )}
      <div
        className={cn(
          "flex items-start gap-3 p-4",
          !isRead ? "pl-5" : "",
        )}
      >
        <div
          className={cn(
            "flex h-11 w-11 shrink-0 items-center justify-center rounded-xl",
            spec.bgClass,
          )}
        >
          <IconComp className={cn("h-6 w-6", spec.colorClass)} />
        </div>
        <div className="min-w-0 flex-1">
          <h3 className="font-heading text-base font-bold">
            {notification.title}
          </h3>
          <p className="mt-1 whitespace-pre-line text-sm leading-snug text-muted-foreground">
            {notification.body}
          </p>
          <p className="mt-2 text-sm text-muted-foreground/70">
            {formatRelativeTime(notification.timestamp)}
          </p>

          {/* Action buttons */}
          {hasActionButtons && (
            <div className="mt-3 flex gap-2">
              <button
                onClick={onArchive}
                className="flex-1 rounded-xl border border-border py-2 text-sm font-bold text-muted-foreground hover:bg-muted"
              >
                Décliner
              </button>
              <button
                onClick={onArchive}
                className="flex-1 rounded-xl bg-primary py-2 text-sm font-bold text-white hover:bg-primary/90"
              >
                {notification.type === "spotFreed"
                  ? "Participer"
                  : "Accepter"}
              </button>
            </div>
          )}
        </div>

        {/* Archive button */}
        {!hasActionButtons && (
          <button
            onClick={onArchive}
            className="shrink-0 rounded-lg p-1 text-muted-foreground/40 hover:bg-muted hover:text-muted-foreground"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   CONNECTIONS TAB
   ═══════════════════════════════════════════════════════════════ */

function ConnectionsTab({
  onOpenProfile,
}: {
  onOpenProfile: (u: User) => void;
}) {
  const [innerTab, setInnerTab] = useState<"received" | "sent">("received");
  const others = useMemo(
    () => mockUsers.filter((u) => u.id !== currentUser.id),
    [],
  );

  const [received, setReceived] = useState<ConnectionRequest[]>(() => [
    {
      id: "cr1",
      user: others[0],
      sentAt: new Date(Date.now() - 2 * 3600_000).toISOString(),
      message:
        "Salut! On s'est croisés à l'activité du Plateau, ça te dit?",
      status: "pending",
    },
    {
      id: "cr2",
      user: others[1],
      sentAt: new Date(Date.now() - 8 * 3600_000).toISOString(),
      status: "pending",
    },
    {
      id: "cr3",
      user: others.length > 2 ? others[2] : others[0],
      sentAt: new Date(Date.now() - 86400_000).toISOString(),
      message: "Hey! Je cherche un buddy pour le 5K de samedi.",
      status: "pending",
    },
    ...(others.length > 3
      ? [
          {
            id: "cr4",
            user: others[3],
            sentAt: new Date(Date.now() - 2 * 86400_000).toISOString(),
            status: "pending" as RequestStatus,
          },
        ]
      : []),
  ]);

  const [sent] = useState<ConnectionRequest[]>(() => [
    ...(others.length > 4
      ? [
          {
            id: "cs1",
            user: others[4],
            sentAt: new Date(Date.now() - 86400_000).toISOString(),
            status: "accepted" as RequestStatus,
          },
        ]
      : []),
    {
      id: "cs2",
      user: others.length > 5 ? others[5] : others[0],
      sentAt: new Date(Date.now() - 3 * 86400_000).toISOString(),
      status: "pending",
    },
  ]);

  const pendingCount = received.filter(
    (r) => r.status === "pending",
  ).length;

  const updateRequest = useCallback(
    (id: string, status: RequestStatus) => {
      setReceived((prev) =>
        prev.map((r) => (r.id === id ? { ...r, status } : r)),
      );
    },
    [],
  );

  return (
    <div>
      {/* Inner tab bar */}
      <div className="flex border-b border-border">
        <button
          onClick={() => setInnerTab("received")}
          className={cn(
            "flex flex-1 items-center justify-center gap-1.5 border-b-2 py-3 text-sm font-bold transition-colors",
            innerTab === "received"
              ? "border-primary text-primary"
              : "border-transparent text-muted-foreground",
          )}
        >
          Reçues
          {pendingCount > 0 && (
            <span className="rounded-full bg-primary px-2 py-0.5 text-xs font-bold text-white">
              {pendingCount}
            </span>
          )}
        </button>
        <button
          onClick={() => setInnerTab("sent")}
          className={cn(
            "flex-1 border-b-2 py-3 text-sm font-bold transition-colors",
            innerTab === "sent"
              ? "border-primary text-primary"
              : "border-transparent text-muted-foreground",
          )}
        >
          Envoyées
        </button>
      </div>

      {innerTab === "received" ? (
        received.length === 0 ? (
          <EmptyConnectionState
            icon="received"
            title="Aucune demande de connexion pour le moment"
            subtitle="Participe à des activités pour rencontrer du monde!"
          />
        ) : (
          <div className="space-y-3 px-4 pb-32 pt-4">
            {received.map((req) => (
              <ReceivedRequestCard
                key={req.id}
                request={req}
                onAccept={() => updateRequest(req.id, "accepted")}
                onDecline={() => updateRequest(req.id, "declined")}
                onTapProfile={() => onOpenProfile(req.user)}
              />
            ))}
          </div>
        )
      ) : sent.length === 0 ? (
        <EmptyConnectionState
          icon="sent"
          title="Aucune demande envoyée"
          subtitle="Visite le profil d'un participant pour envoyer une demande."
        />
      ) : (
        <div className="space-y-3 px-4 pb-32 pt-4">
          {sent.map((req) => (
            <SentRequestCard
              key={req.id}
              request={req}
              onTapProfile={() => onOpenProfile(req.user)}
            />
          ))}
        </div>
      )}
    </div>
  );
}

function EmptyConnectionState({
  icon,
  title,
  subtitle,
}: {
  icon: "received" | "sent";
  title: string;
  subtitle: string;
}) {
  return (
    <div className="flex flex-col items-center justify-center px-10 py-20 text-center">
      <div className="flex h-[72px] w-[72px] items-center justify-center rounded-full bg-muted/60">
        {icon === "received" ? (
          <UserPlus className="h-9 w-9 text-muted-foreground" />
        ) : (
          <Send className="h-9 w-9 text-muted-foreground" />
        )}
      </div>
      <h3 className="mt-4 font-heading text-base font-bold">{title}</h3>
      <p className="mt-1.5 text-sm text-muted-foreground">{subtitle}</p>
    </div>
  );
}

function ReceivedRequestCard({
  request,
  onAccept,
  onDecline,
  onTapProfile,
}: {
  request: ConnectionRequest;
  onAccept: () => void;
  onDecline: () => void;
  onTapProfile: () => void;
}) {
  const isPending = request.status === "pending";
  const isAccepted = request.status === "accepted";

  return (
    <div
      className={cn(
        "rounded-2xl border p-4",
        isPending ? "border-teal-500/25" : "border-border",
      )}
    >
      {/* User row */}
      <button
        onClick={onTapProfile}
        className="flex w-full items-center gap-3 text-left"
      >
        <UserAvatar
          photoUrl={request.user.photoUrl}
          firstName={request.user.firstName}
          lastName={request.user.lastName}
          size="lg"
        />
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-1">
            <span className="font-heading text-base font-bold">
              {request.user.firstName}, {request.user.age}
            </span>
            {request.user.isVerified && (
              <CheckCircle className="h-4 w-4 text-teal-500" />
            )}
          </div>
          <p className="text-[13px] text-muted-foreground">
            {request.user.city} · {formatRelativeTime(request.sentAt)}
          </p>
        </div>
        <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/40" />
      </button>

      {/* Message quote */}
      {request.message && (
        <div className="mt-3 rounded-xl bg-muted/50 p-3">
          <div className="flex items-start gap-2">
            <Quote className="mt-0.5 h-4 w-4 shrink-0 text-muted-foreground/40" />
            <p className="text-sm italic leading-snug">{request.message}</p>
          </div>
        </div>
      )}

      {/* Actions */}
      <div className="mt-3.5">
        {isPending ? (
          <div className="flex gap-2.5">
            <button
              onClick={onDecline}
              className="flex-1 rounded-[10px] border border-border py-2.5 text-sm font-semibold text-muted-foreground hover:bg-muted"
            >
              Refuser
            </button>
            <button
              onClick={onAccept}
              className="flex-1 rounded-[10px] bg-teal-500 py-2.5 text-sm font-semibold text-white hover:bg-teal-600"
            >
              Accepter
            </button>
          </div>
        ) : (
          <div
            className={cn(
              "flex items-center justify-center gap-1.5 rounded-[10px] py-2",
              isAccepted ? "bg-teal-500/10" : "bg-muted/60",
            )}
          >
            {isAccepted ? (
              <CheckCircle className="h-4 w-4 text-teal-500" />
            ) : (
              <XCircle className="h-4 w-4 text-muted-foreground" />
            )}
            <span
              className={cn(
                "text-sm font-semibold",
                isAccepted ? "text-teal-600" : "text-muted-foreground",
              )}
            >
              {isAccepted ? "Acceptée" : "Refusée"}
            </span>
          </div>
        )}
      </div>
    </div>
  );
}

function SentRequestCard({
  request,
  onTapProfile,
}: {
  request: ConnectionRequest;
  onTapProfile: () => void;
}) {
  const isPending = request.status === "pending";
  const isAccepted = request.status === "accepted";

  return (
    <button
      onClick={onTapProfile}
      className="flex w-full items-center gap-3 rounded-2xl border border-border p-4 text-left transition-colors hover:bg-accent/30"
    >
      <UserAvatar
        photoUrl={request.user.photoUrl}
        firstName={request.user.firstName}
        lastName={request.user.lastName}
        size="lg"
      />
      <div className="min-w-0 flex-1">
        <p className="font-heading text-[15px] font-bold">
          {request.user.firstName}
        </p>
        <p className="text-[13px] text-muted-foreground">
          Envoyée {formatRelativeTime(request.sentAt).toLowerCase()}
        </p>
      </div>
      <span
        className={cn(
          "shrink-0 rounded-lg px-2.5 py-1 text-xs font-semibold",
          isPending
            ? "bg-amber-500/10 text-amber-600"
            : isAccepted
              ? "bg-teal-500/10 text-teal-600"
              : "bg-muted text-muted-foreground",
        )}
      >
        {isPending ? "En attente" : isAccepted ? "Acceptée" : "Refusée"}
      </span>
    </button>
  );
}
