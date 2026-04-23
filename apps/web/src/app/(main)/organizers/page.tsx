"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { mockUsers, mockEvents } from "@/lib/data";
import { EventCategory } from "@/lib/types";
import type { User, KaiEvent } from "@/lib/types";
import { ChevronRight, Gift } from "lucide-react";

const dayNames = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
const monthNames = [
  "",
  "jan",
  "fév",
  "mars",
  "avr",
  "mai",
  "juin",
  "juil",
  "août",
  "sept",
  "oct",
  "nov",
  "déc",
];

function formatShortDate(iso: string): string {
  const dt = new Date(iso);
  const day = dayNames[(dt.getDay() + 6) % 7];
  return `${day} ${dt.getDate()} ${monthNames[dt.getMonth() + 1]} · ${dt.getHours()}h${String(dt.getMinutes()).padStart(2, "0")}`;
}

export default function OrganizersPage() {
  const organizers = useMemo(
    () => mockUsers.filter((u) => u.isOrganizer),
    [],
  );

  return (
    <div className="min-h-screen bg-background">
      <div className="px-5 pt-8 pb-2">
        <h1 className="text-center font-heading text-xl font-bold">
          Nos organisateurs
        </h1>
      </div>

      <div className="mx-auto max-w-lg space-y-5 px-5 pt-2 pb-32">
        {organizers.map((org) => (
          <OrganizerCard key={org.id} organizer={org} />
        ))}
      </div>
    </div>
  );
}

function OrganizerCard({ organizer }: { organizer: User }) {
  const [profileUser, setProfileUser] = useState<User | null>(null);

  const { upcoming, past } = useMemo(() => {
    const now = new Date();
    const all = mockEvents.filter((e) =>
      e.organizerIds.includes(organizer.id),
    );
    const up = all
      .filter((e) => new Date(e.date) >= now)
      .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    const pa = all
      .filter((e) => new Date(e.date) < now)
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
    return { upcoming: up, past: pa };
  }, [organizer.id]);

  const totalEvents = upcoming.length + past.length;

  return (
    <>
      <div className="rounded-2xl border border-border bg-card overflow-hidden">
        {/* Header */}
        <button
          className="flex w-full items-center gap-3.5 p-[18px] text-left"
          onClick={() => setProfileUser(organizer)}
        >
          <UserAvatar
            photoUrl={organizer.photoUrl}
            firstName={organizer.firstName}
            lastName={organizer.lastName}
            size="lg"
          />
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-2">
              <span className="truncate font-heading text-lg font-extrabold">
                {organizer.firstName} {organizer.lastName}
              </span>
              <span className="shrink-0 rounded-lg bg-teal-500/12 px-2 py-0.5 text-[11px] font-bold text-teal-600">
                Organisateur
              </span>
            </div>
            {organizer.neighborhood && (
              <p className="text-[13px] text-muted-foreground">
                {organizer.neighborhood}
              </p>
            )}
            <p className="text-[13px] font-semibold text-primary">
              {totalEvents} événement{totalEvents > 1 ? "s" : ""} organisé
              {totalEvents > 1 ? "s" : ""}
            </p>
          </div>
          <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/40" />
        </button>

        {/* Bio */}
        {organizer.bio && (
          <p className="px-[18px] pb-3.5 text-sm leading-relaxed text-muted-foreground line-clamp-3">
            {organizer.bio}
          </p>
        )}

        {/* Upcoming events */}
        {upcoming.length > 0 && (
          <div className="px-[18px] pb-2">
            <p className="pb-2 font-heading text-[15px] font-bold">À venir</p>
            {upcoming.slice(0, 3).map((e) => (
              <CompactEventTile key={e.id} event={e} />
            ))}
          </div>
        )}

        {/* Past events */}
        {past.length > 0 && (
          <div className="px-[18px] pb-2 pt-2">
            <p className="pb-2 font-heading text-[15px] font-bold text-muted-foreground">
              Passés
            </p>
            {past.slice(0, 2).map((e) => (
              <CompactEventTile key={e.id} event={e} isPast />
            ))}
          </div>
        )}

        {/* Tip button */}
        <div className="px-[18px] pt-3 pb-[18px]">
          <button className="flex w-full items-center justify-center gap-2 rounded-xl border border-amber-400/50 py-3 text-amber-500 hover:bg-amber-50 dark:hover:bg-amber-950/30">
            <Gift className="h-4 w-4" />
            <span className="font-heading text-sm font-bold">
              Envoyer un tip à {organizer.firstName}
            </span>
          </button>
        </div>
      </div>

      {profileUser && (
        <UserProfileSheet
          user={profileUser}
          open
          onOpenChange={(open) => {
            if (!open) setProfileUser(null);
          }}
        />
      )}
    </>
  );
}

function CompactEventTile({
  event,
  isPast = false,
}: {
  event: KaiEvent;
  isPast?: boolean;
}) {
  const cat = EventCategory[event.category];

  return (
    <Link
      href={`/events/${event.id}`}
      className="flex items-center gap-3 rounded-lg py-1.5 hover:bg-muted/50"
    >
      <div
        className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-[10px] text-lg ${
          isPast ? "bg-muted" : "bg-teal-500/10"
        }`}
      >
        {cat?.emoji ?? "🏃"}
      </div>
      <div className="min-w-0 flex-1">
        <p
          className={`text-sm font-semibold truncate ${isPast ? "text-muted-foreground" : ""}`}
        >
          {event.neighborhood}
        </p>
        <p className="text-[13px] text-muted-foreground">
          {formatShortDate(event.date)}
        </p>
      </div>
      <ChevronRight className="h-3.5 w-3.5 shrink-0 text-muted-foreground/35" />
    </Link>
  );
}
