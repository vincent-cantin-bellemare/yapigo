"use client";

import React, { useState, useRef, useCallback, useEffect } from "react";
import Link from "next/link";
import {
  Drawer,
  DrawerContent,
  DrawerTitle,
} from "@/components/ui/drawer";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { UserAvatar } from "./user-avatar";
import type { User } from "@/lib/types/user";
import {
  BadgeLevel,
  EventCategory,
  IntensityLevel,
  getStravaProfileUrl,
  getStravaAvgPace,
} from "@/lib/types";
import { mockEvents, mockUserEventHistory } from "@/lib/data";
import {
  MapPin,
  CheckCircle,
  Star,
  Users,
  TrendingUp,
  Calendar,
  Dumbbell,
  Circle,
  ChevronRight,
  Heart,
  MessageSquare,
  Flag,
  ExternalLink,
} from "lucide-react";
import { cn } from "@/lib/utils";

const TAB_KEYS = ["profile", "stats", "photos", "actions"] as const;
const TAB_LABELS: Record<string, string> = {
  profile: "Profil",
  stats: "Stats",
  photos: "Photos",
  actions: "⋯",
};

function SwipeableTabs({
  activeTab,
  onTabChange,
  isOwnProfile,
  children,
}: {
  activeTab: string;
  onTabChange: (tab: string) => void;
  isOwnProfile: boolean;
  children: React.ReactNode[];
}) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const isScrollingRef = useRef(false);

  const tabs = isOwnProfile
    ? TAB_KEYS.filter((k) => k !== "actions")
    : [...TAB_KEYS];
  const activeIndex = Math.max(0, tabs.indexOf(activeTab as typeof TAB_KEYS[number]));

  const scrollToTab = useCallback(
    (index: number) => {
      const el = scrollRef.current;
      if (!el) return;
      isScrollingRef.current = true;
      el.scrollTo({ left: index * el.clientWidth, behavior: "smooth" });
      setTimeout(() => {
        isScrollingRef.current = false;
      }, 350);
    },
    [],
  );

  const handleTabClick = useCallback(
    (tab: string) => {
      const idx = tabs.indexOf(tab as typeof TAB_KEYS[number]);
      if (idx >= 0) {
        onTabChange(tab);
        scrollToTab(idx);
      }
    },
    [tabs, onTabChange, scrollToTab],
  );

  const handleScroll = useCallback(() => {
    if (isScrollingRef.current) return;
    const el = scrollRef.current;
    if (!el) return;
    const idx = Math.round(el.scrollLeft / el.clientWidth);
    const clamped = Math.max(0, Math.min(idx, tabs.length - 1));
    if (tabs[clamped] && tabs[clamped] !== activeTab) {
      onTabChange(tabs[clamped]);
    }
  }, [tabs, activeTab, onTabChange]);

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollLeft = activeIndex * el.clientWidth;
  }, []);

  return (
    <div className="flex min-h-0 flex-1 flex-col">
      {/* Tab bar */}
      <div className="relative mx-6 shrink-0">
        <div
          className={cn(
            "grid",
            isOwnProfile ? "grid-cols-3" : "grid-cols-4",
          )}
        >
          {tabs.map((tab) => (
            <button
              key={tab}
              onClick={() => handleTabClick(tab)}
              className={cn(
                "pb-2.5 pt-2 text-center text-sm font-bold transition-colors",
                activeTab === tab
                  ? "text-primary"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              {TAB_LABELS[tab]}
            </button>
          ))}
        </div>
        {/* Animated indicator */}
        <div
          className="absolute bottom-0 h-0.5 bg-primary transition-all duration-200 ease-out"
          style={{
            width: `${100 / tabs.length}%`,
            left: `${(activeIndex * 100) / tabs.length}%`,
          }}
        />
        <div className="absolute inset-x-0 bottom-0 h-px bg-border" />
      </div>

      {/* Swipeable content */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="flex flex-1 snap-x snap-mandatory overflow-x-auto overflow-y-hidden scrollbar-none"
        style={{ scrollbarWidth: "none", msOverflowStyle: "none" }}
      >
        {React.Children.map(children, (child, i) => (
          <div
            key={tabs[i] ?? i}
            className="w-full shrink-0 snap-start overflow-y-auto px-6 pb-8 pt-4"
          >
            {child}
          </div>
        ))}
      </div>
    </div>
  );
}

interface UserProfileSheetProps {
  user: User | null;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  isOwnProfile?: boolean;
  similarUsers?: User[];
}

function timeAgo(dateStr?: string): string {
  if (!dateStr) return "—";
  const diff = Date.now() - new Date(dateStr).getTime();
  const days = Math.floor(diff / 86400000);
  if (days === 0) return "Aujourd'hui";
  if (days === 1) return "Hier";
  if (days < 7) return `Il y a ${days} jours`;
  if (days < 30) return `Il y a ${Math.floor(days / 7)} sem.`;
  return new Date(dateStr).toLocaleDateString("fr-CA", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function formatDate(dateStr?: string): string {
  if (!dateStr) return "—";
  return new Date(dateStr).toLocaleDateString("fr-CA", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
}

function isOnline(user: User): boolean {
  if (!user.lastSeenDate) return false;
  const diff = Date.now() - new Date(user.lastSeenDate).getTime();
  return diff < 24 * 3600000;
}

export function UserProfileSheet({
  user,
  open,
  onOpenChange,
  isOwnProfile = false,
}: UserProfileSheetProps) {
  const [activeTab, setActiveTab] = useState("profile");
  const prevUserId = useRef<string | null>(null);

  if (user && user.id !== prevUserId.current) {
    prevUserId.current = user.id;
    if (activeTab !== "profile") setActiveTab("profile");
  }

  const badge = user ? BadgeLevel[user.badge] : BadgeLevel.curieux;
  const online = user ? isOnline(user) : false;
  const eventIds = user ? (mockUserEventHistory[user.id] ?? []) : [];
  const userEvents = mockEvents.filter((e) => eventIds.includes(e.id));
  const now = new Date();
  const upcomingEvents = userEvents
    .filter((e) => new Date(e.date) > now)
    .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  const pastEvents = userEvents
    .filter((e) => new Date(e.date) <= now)
    .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  const stravaUrl = user ? getStravaProfileUrl(user) : null;
  const stravaPace = user ? getStravaAvgPace(user) : null;

  return (
    <Drawer open={open} onOpenChange={onOpenChange}>
      <DrawerContent className="mx-auto max-h-[85vh] w-full max-w-lg rounded-t-3xl p-0">
        <DrawerTitle className="sr-only">
          {user?.firstName ?? "Profil"}
        </DrawerTitle>

        {user && (
          <div className="flex flex-col overflow-hidden">
            {/* Preview banner for own profile */}
            {isOwnProfile && (
              <div className="flex shrink-0 items-center justify-center gap-2 bg-teal/10 px-4 py-2.5 text-sm font-semibold text-teal">
                <span>👁️</span>
                Aperçu — voilà ce que les autres voient
              </div>
            )}

            {/* Header */}
            <div className="flex shrink-0 items-center gap-4 px-6 py-4">
              <div className="relative">
                <UserAvatar
                  photoUrl={user.photoUrl}
                  firstName={user.firstName}
                  lastName={user.lastName}
                  size="xl"
                  className="border-2 border-primary/20"
                />
                {online && (
                  <span className="absolute bottom-0.5 right-0.5 h-4 w-4 rounded-full border-2 border-background bg-emerald-500" />
                )}
              </div>
              <div className="min-w-0 flex-1">
                <h2 className="font-heading text-xl font-extrabold">
                  {user.firstName}, {user.age}
                </h2>
                <div className="mt-1 flex items-center gap-1.5 text-sm text-muted-foreground">
                  {user.isVerified && (
                    <>
                      <CheckCircle className="h-3.5 w-3.5 text-teal" />
                      <span className="font-semibold text-teal">Vérifié</span>
                      <span>·</span>
                    </>
                  )}
                  <MapPin className="h-3.5 w-3.5" />
                  <span className="truncate">
                    {user.neighborhood ?? user.city}
                  </span>
                </div>
              </div>
            </div>

            {/* Swipeable Tabs */}
            <SwipeableTabs
              activeTab={activeTab}
              onTabChange={setActiveTab}
              isOwnProfile={isOwnProfile}
            >
              {/* Profile Tab */}
              <div className="space-y-5">
                  <div className="flex flex-wrap gap-2">
                    <Badge variant="outline" className="border-primary/30 bg-primary/5 text-primary">
                      {badge.icon} {badge.label}
                    </Badge>
                    {user.isOrganizer && (
                      <Badge variant="outline" className="border-teal/30 bg-teal/5 text-teal">
                        🛡️ Organisateur
                      </Badge>
                    )}
                  </div>

                  {user.bio && (
                    <div>
                      <h3 className="font-heading font-bold">Bio</h3>
                      <p className="mt-2 whitespace-pre-line text-sm leading-relaxed text-muted-foreground">
                        {user.bio}
                      </p>
                    </div>
                  )}

                  {user.sexualOrientation &&
                    user.sexualOrientation !== "Préfère ne pas dire" && (
                      <p className="text-sm text-muted-foreground">
                        👤 {user.sexualOrientation}
                      </p>
                    )}

                  {user.activityGoals.length > 0 && (
                    <div>
                      <h3 className="font-heading font-bold">Objectifs</h3>
                      <div className="mt-2 flex flex-wrap gap-2">
                        {user.activityGoals.map((goal) => (
                          <span
                            key={goal}
                            className="rounded-full bg-primary/10 px-3 py-1 text-sm font-medium text-primary"
                          >
                            {goal}
                          </span>
                        ))}
                      </div>
                    </div>
                  )}

                  {user.activities.length > 0 && (
                    <div>
                      <h3 className="font-heading font-bold">
                        Sports & Niveaux
                      </h3>
                      <div className="mt-2 space-y-2">
                        {user.activities.map((activity) => (
                          <div
                            key={activity.category}
                            className="flex items-center gap-2 text-sm"
                          >
                            <span className="text-lg">
                              {EventCategory[activity.category].emoji}
                            </span>
                            <span className="flex-1 font-medium">
                              {EventCategory[activity.category].label}
                            </span>
                            <span className="text-muted-foreground">
                              {IntensityLevel[activity.level].emoji}{" "}
                              {IntensityLevel[activity.level].label}
                            </span>
                          </div>
                        ))}
                      </div>
                    </div>
                  )}
                </div>

              {/* Stats Tab */}
              <div className="space-y-5">
                  <div className="space-y-2.5 rounded-xl bg-teal/5 p-4">
                    {user.memberSince && (
                      <div className="flex items-center gap-3 text-sm">
                        <Calendar className="h-4 w-4 text-primary" />
                        <span className="flex-1 text-muted-foreground">
                          Inscrit depuis
                        </span>
                        <span className="font-medium">
                          {formatDate(user.memberSince)}
                        </span>
                      </div>
                    )}
                    {user.lastActivityDate && (
                      <div className="flex items-center gap-3 text-sm">
                        <Dumbbell className="h-4 w-4 text-primary" />
                        <span className="flex-1 text-muted-foreground">
                          Dernière activité
                        </span>
                        <span className="font-medium">
                          {timeAgo(user.lastActivityDate)}
                        </span>
                      </div>
                    )}
                    {user.lastSeenDate && (
                      <div className="flex items-center gap-3 text-sm">
                        <Circle
                          className={cn(
                            "h-3 w-3",
                            online
                              ? "fill-emerald-500 text-emerald-500"
                              : "fill-muted-foreground text-muted-foreground",
                          )}
                        />
                        <span className="flex-1 text-muted-foreground">
                          Dernière connexion
                        </span>
                        <span className="font-medium">
                          {timeAgo(user.lastSeenDate)}
                        </span>
                      </div>
                    )}
                  </div>

                  <div className="grid grid-cols-3 gap-3">
                    {user.connections > 0 && (
                      <div className="flex flex-col items-center rounded-xl bg-teal/5 p-3">
                        <Users className="h-5 w-5 text-teal" />
                        <p className="mt-1 font-heading text-lg font-bold">
                          {user.connections}
                        </p>
                        <p className="text-xs text-muted-foreground">Connexions</p>
                      </div>
                    )}
                    {user.totalActivities > 0 && (
                      <div className="flex flex-col items-center rounded-xl bg-primary/5 p-3">
                        <Dumbbell className="h-5 w-5 text-primary" />
                        <p className="mt-1 font-heading text-lg font-bold">
                          {user.totalActivities}
                        </p>
                        <p className="text-xs text-muted-foreground">Activités</p>
                      </div>
                    )}
                    {user.averageRating != null && (
                      <div className="flex flex-col items-center rounded-xl bg-amber-50 p-3 dark:bg-amber-500/10">
                        <Star className="h-5 w-5 fill-amber-400 text-amber-400" />
                        <p className="mt-1 font-heading text-lg font-bold">
                          {user.averageRating.toFixed(1)}
                        </p>
                        <p className="text-xs text-muted-foreground">Note</p>
                      </div>
                    )}
                  </div>

                  {user.stravaConnected && (
                    <div className="rounded-xl border border-[#FC4C02]/20 bg-[#FC4C02]/5 p-4">
                      <div className="flex items-center gap-2">
                        <div className="flex h-6 w-6 items-center justify-center rounded bg-[#FC4C02] text-xs font-black text-white">
                          S
                        </div>
                        <h3 className="font-heading font-bold">
                          Activité Strava
                        </h3>
                      </div>
                      <div className="mt-3 grid grid-cols-2 gap-3 text-sm">
                        {user.stravaYtdKm != null && (
                          <div>
                            <p className="font-heading text-lg font-bold">
                              {user.stravaYtdKm} km
                            </p>
                            <p className="text-xs text-muted-foreground">
                              cette année
                            </p>
                          </div>
                        )}
                        {user.stravaYtdRuns != null && (
                          <div>
                            <p className="font-heading text-lg font-bold">
                              {user.stravaYtdRuns}
                            </p>
                            <p className="text-xs text-muted-foreground">
                              courses
                            </p>
                          </div>
                        )}
                        {stravaPace && (
                          <div>
                            <p className="font-heading text-lg font-bold">
                              {stravaPace}
                            </p>
                            <p className="text-xs text-muted-foreground">
                              allure moy.
                            </p>
                          </div>
                        )}
                        {user.stravaMonthKm != null && (
                          <div>
                            <p className="font-heading text-lg font-bold">
                              {user.stravaMonthKm} km
                            </p>
                            <p className="text-xs text-muted-foreground">
                              ce mois-ci
                            </p>
                          </div>
                        )}
                      </div>
                      {stravaUrl && (
                        <a
                          href={stravaUrl}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="mt-3 flex items-center gap-1 text-sm font-medium text-[#FC4C02] hover:underline"
                        >
                          Voir sur Strava
                          <ExternalLink className="h-3.5 w-3.5" />
                        </a>
                      )}
                    </div>
                  )}

                  {upcomingEvents.length > 0 && (
                    <div>
                      <h3 className="font-heading font-bold">
                        Prochains événements
                      </h3>
                      <div className="mt-2 space-y-2">
                        {upcomingEvents.map((event) => (
                          <Link
                            key={event.id}
                            href={`/events/${event.id}`}
                            onClick={() => onOpenChange(false)}
                            className="flex items-center gap-3 rounded-xl bg-primary/5 p-3 hover:bg-primary/10"
                          >
                            <span className="text-lg">
                              {EventCategory[event.category].emoji}
                            </span>
                            <div className="min-w-0 flex-1">
                              <p className="text-sm font-semibold">
                                {event.neighborhood} · {event.distanceLabel}
                              </p>
                              <p className="text-xs text-muted-foreground">
                                {new Date(event.date).toLocaleDateString("fr-CA", {
                                  day: "numeric",
                                  month: "short",
                                  year: "numeric",
                                })}
                              </p>
                            </div>
                            <ChevronRight className="h-4 w-4 text-muted-foreground" />
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}

                  {pastEvents.length > 0 && (
                    <div>
                      <h3 className="font-heading font-bold">
                        Événements passés
                      </h3>
                      <div className="mt-2 space-y-2">
                        {pastEvents.slice(0, 5).map((event) => (
                          <Link
                            key={event.id}
                            href={`/events/${event.id}`}
                            onClick={() => onOpenChange(false)}
                            className="flex items-center gap-3 rounded-xl bg-teal/5 p-3 hover:bg-teal/10"
                          >
                            <span className="text-lg">
                              {EventCategory[event.category].emoji}
                            </span>
                            <div className="min-w-0 flex-1">
                              <p className="text-sm font-semibold">
                                {event.neighborhood} · {event.distanceLabel}
                              </p>
                              <p className="text-xs text-muted-foreground">
                                {new Date(event.date).toLocaleDateString("fr-CA", {
                                  day: "numeric",
                                  month: "short",
                                  year: "numeric",
                                })}
                              </p>
                            </div>
                            {event.myRating != null && (
                              <div className="flex items-center gap-1 text-sm">
                                <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                                <span className="text-xs font-bold text-amber-600">
                                  {event.myRating.toFixed(1)}
                                </span>
                              </div>
                            )}
                            <ChevronRight className="h-4 w-4 text-muted-foreground" />
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}
                </div>

              {/* Photos Tab */}
              <div>
                  {user.photoGallery.length > 0 ? (
                    <div className="grid grid-cols-3 gap-2">
                      {user.photoGallery.map((url, i) => (
                        <div
                          key={i}
                          className="aspect-square overflow-hidden rounded-xl"
                        >
                          {/* eslint-disable-next-line @next/next/no-img-element */}
                          <img
                            src={url}
                            alt={`Photo ${i + 1}`}
                            className="h-full w-full object-cover"
                          />
                        </div>
                      ))}
                    </div>
                  ) : (
                    <div className="flex flex-col items-center py-12 text-muted-foreground">
                      <span className="text-4xl">📷</span>
                      <p className="mt-2 text-sm">Aucune photo pour le moment</p>
                    </div>
                  )}
                </div>

              {/* Actions Tab */}
              {!isOwnProfile && (
                <div className="space-y-3">
                  <Button className="w-full gap-2" variant="default">
                    <Heart className="h-4 w-4" />
                    Envoyer un like
                  </Button>
                  <Button className="w-full gap-2" variant="outline">
                    <MessageSquare className="h-4 w-4" />
                    Envoyer un message
                  </Button>
                  <Separator />
                  <Button
                    className="w-full gap-2 text-destructive"
                    variant="ghost"
                  >
                    <Flag className="h-4 w-4" />
                    Signaler
                  </Button>
                </div>
              )}
            </SwipeableTabs>
          </div>
        )}
      </DrawerContent>
    </Drawer>
  );
}
