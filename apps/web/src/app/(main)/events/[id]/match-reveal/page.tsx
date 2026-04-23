"use client";

import React, { useState, useEffect, use } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { mockEvents, mockUsers, currentUser } from "@/lib/data";
import {
  EventCategory,
  IntensityLevel,
  DistanceLabel,
} from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import {
  MapPin,
  CalendarDays,
  Zap,
  Ruler,
  Shield,
  Coffee,
  Backpack,
  MessageCircle,
  Home,
  ExternalLink,
} from "lucide-react";

const groupMembers = mockUsers.filter((u) => u.id !== currentUser.id).slice(0, 4);
const allMembers = [currentUser, ...groupMembers];

const organizer = groupMembers.find((u) => u.isOrganizer) ?? groupMembers[0];

const itemsPerMember: Record<string, string[]> = {
  [currentUser.id]: ["Bouteille d'eau", "Serviette"],
  [groupMembers[0].id]: ["Crème solaire"],
  [groupMembers[1].id]: ["Speaker bluetooth"],
  [groupMembers[2].id]: ["Barres énergétiques"],
  [groupMembers[3].id]: ["Trousse premiers soins"],
};

interface Props {
  params: Promise<{ id: string }>;
}

export default function MatchRevealPage({ params }: Props) {
  const { id } = use(params);
  const router = useRouter();
  const event = mockEvents.find((e) => e.id === id);

  const [phase, setPhase] = useState<"intro" | "content">("intro");
  const [emojiScale, setEmojiScale] = useState(false);
  const [textVisible, setTextVisible] = useState(false);

  useEffect(() => {
    const t1 = setTimeout(() => setEmojiScale(true), 100);
    const t2 = setTimeout(() => setTextVisible(true), 600);
    const t3 = setTimeout(() => setPhase("content"), 2000);
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
      clearTimeout(t3);
    };
  }, []);

  if (!event) {
    router.replace("/events");
    return null;
  }

  const cat = EventCategory[event.category];
  const intensity = IntensityLevel[event.intensityLevel];
  const distance = DistanceLabel[event.distanceLabel];
  const eventDate = new Date(event.date);

  if (phase === "intro") {
    return (
      <div className="flex min-h-[calc(100dvh-5rem)] flex-col items-center justify-center px-6">
        <span
          className={cn(
            "text-8xl transition-transform duration-700 ease-out",
            emojiScale ? "scale-100" : "scale-50",
          )}
        >
          {cat.emoji}
        </span>
        <h1
          className={cn(
            "mt-6 font-heading text-2xl font-extrabold transition-all duration-700",
            textVisible
              ? "translate-y-0 opacity-100"
              : "translate-y-4 opacity-0",
          )}
        >
          Ton groupe est formé!
        </h1>
      </div>
    );
  }

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col animate-in fade-in duration-500">
      <div className="flex-1 overflow-y-auto px-6 pb-8 pt-6">
        <div className="text-center">
          <h1 className="font-heading text-2xl font-extrabold">
            Ton groupe est prêt!
          </h1>
          <p className="mt-1 text-sm text-muted-foreground">
            {allMembers.length} participants (toi inclus)
          </p>
        </div>

        <div className="mt-6 flex flex-wrap justify-center gap-3">
          {allMembers.map((member) => (
            <div key={member.id} className="flex flex-col items-center">
              <div className="relative">
                <UserAvatar
                  photoUrl={member.photoUrl}
                  firstName={member.firstName}
                  lastName={member.lastName}
                  size="lg"
                />
                {member.id === currentUser.id && (
                  <div className="absolute -bottom-1 -right-1 rounded-full bg-primary px-1.5 py-0.5 text-[9px] font-bold text-white">
                    Toi
                  </div>
                )}
              </div>
              <span className="mt-2 text-center text-sm font-semibold">
                {member.firstName}
              </span>
              <span className="text-xs text-muted-foreground">
                {member.age} ans
              </span>
            </div>
          ))}
        </div>

        <div className="mt-6 overflow-hidden rounded-2xl border border-amber-300 bg-amber-50 dark:border-amber-500/30 dark:bg-amber-500/10">
          <div className="flex items-center gap-2 bg-amber-100 px-4 py-2 dark:bg-amber-500/20">
            <Shield className="h-4 w-4 text-amber-700 dark:text-amber-400" />
            <span className="text-sm font-bold text-amber-800 dark:text-amber-300">
              Ton Organisateur
            </span>
          </div>
          <div className="flex items-center gap-3 px-4 py-3">
            <UserAvatar
              photoUrl={organizer.photoUrl}
              firstName={organizer.firstName}
              lastName={organizer.lastName}
              size="md"
            />
            <div>
              <p className="font-semibold">{organizer.firstName}</p>
              <p className="text-xs text-muted-foreground">
                {organizer.totalActivities} activités · ⭐{" "}
                {organizer.averageRating?.toFixed(1) ?? "N/A"}
              </p>
            </div>
          </div>
        </div>

        <div className="mt-4 flex items-center gap-2.5 rounded-2xl border bg-card p-4 shadow-sm">
          <CalendarDays className="h-5 w-5 shrink-0 text-muted-foreground" />
          <span className="text-sm">
            {eventDate.toLocaleDateString("fr-CA", {
              weekday: "long",
              day: "numeric",
              month: "long",
            })}{" "}
            à{" "}
            {eventDate.toLocaleTimeString("fr-CA", {
              hour: "2-digit",
              minute: "2-digit",
            })}
          </span>
        </div>

        <div className="mt-4 grid grid-cols-2 gap-3">
          <div className="rounded-2xl border bg-card p-4 shadow-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Zap className="h-4 w-4" />
              <span className="text-xs font-semibold">Intensité</span>
            </div>
            <p className="mt-1 font-heading text-base font-bold">
              {intensity.emoji} {intensity.label}
            </p>
          </div>
          <div className="rounded-2xl border bg-card p-4 shadow-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Ruler className="h-4 w-4" />
              <span className="text-xs font-semibold">Distance</span>
            </div>
            <p className="mt-1 font-heading text-base font-bold">
              {distance.emoji} {distance.label}
            </p>
          </div>
        </div>

        <div className="mt-4 rounded-2xl border bg-card p-4 shadow-sm">
          <div className="flex items-center gap-2 text-muted-foreground">
            <MapPin className="h-4 w-4" />
            <span className="text-xs font-semibold">Point de rencontre</span>
          </div>
          <p className="mt-1 font-heading text-base font-bold">
            Parc La Fontaine
          </p>
          <p className="text-sm text-muted-foreground">
            3933 Avenue du Parc-La Fontaine
          </p>
          <p className="text-xs text-muted-foreground">
            {event.neighborhood}
          </p>
          <button className="mt-2 flex items-center gap-1.5 text-sm font-semibold text-primary">
            <ExternalLink className="h-3.5 w-3.5" />
            Voir sur la carte
          </button>
        </div>

        {event.aperoSmoothieSpot && (
          <div className="mt-4 rounded-2xl border bg-card p-4 shadow-sm">
            <div className="flex items-center gap-2 text-muted-foreground">
              <Coffee className="h-4 w-4" />
              <span className="text-xs font-semibold">Ravito Smoothie</span>
            </div>
            <p className="mt-1 font-heading text-base font-bold">
              {event.aperoSmoothieSpot}
            </p>
          </div>
        )}

        <div className="mt-4 rounded-2xl border bg-card p-4 shadow-sm">
          <div className="flex items-center gap-2">
            <Backpack className="h-4 w-4 text-muted-foreground" />
            <span className="font-heading text-base font-bold">
              On amène quoi? 🎒
            </span>
          </div>
          <div className="mt-3 space-y-2">
            {allMembers.map((member) => {
              const items = itemsPerMember[member.id];
              if (!items) return null;
              return (
                <div key={member.id} className="flex items-start gap-2.5">
                  <UserAvatar
                    photoUrl={member.photoUrl}
                    firstName={member.firstName}
                    lastName={member.lastName}
                    size="xs"
                    className="mt-0.5"
                  />
                  <div className="min-w-0">
                    <span className="text-sm font-semibold">
                      {member.id === currentUser.id
                        ? "Toi"
                        : member.firstName}
                    </span>
                    <p className="text-xs text-muted-foreground">
                      {items.join(", ")}
                    </p>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      <div className="shrink-0 space-y-3 px-6 pb-6 pt-2">
        <Link href="/activity">
          <Button className="w-full py-5 text-base font-bold" size="lg">
            <MessageCircle className="mr-2 h-5 w-5" />
            Écrire au groupe 💬
          </Button>
        </Link>
        <Link href="/">
          <Button
            variant="outline"
            className="w-full py-5 text-base font-bold"
            size="lg"
          >
            <Home className="mr-2 h-5 w-5" />
            Retour à l&apos;accueil
          </Button>
        </Link>
      </div>
    </div>
  );
}
