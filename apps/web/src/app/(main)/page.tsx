"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import {
  mockEvents,
  currentUser,
  mockUsers,
  mockEventPhotos,
} from "@/lib/data";
import {
  IntensityLevel,
  BadgeLevel,
  EventCategory,
  getEventStatus,
} from "@/lib/types";
import type { User } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { EventCard } from "@/components/shared/event-card";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { PromoVideo } from "@/components/shared/promo-video";
import {
  ContactFormDrawer,
  type ContactSubject,
} from "@/components/shared/contact-form-drawer";
import { PhotoGalleryViewer } from "@/components/shared/photo-gallery-viewer";
import { WaitingCarousel } from "@/components/shared/waiting-carousel";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import {
  ArrowRight,
  Calendar,
  Camera,
  ChevronRight,
  Compass,
  MapPin,
  Moon,
  Shield,
  Star,
  Sun,
  TrendingUp,
  Users,
} from "lucide-react";
import { useTheme } from "next-themes";
import { cn } from "@/lib/utils";

const taglines = [
  "Ce weekend, on bouge ensemble!",
  "Prêt à lancer tes running shoes?",
  "La course à pied, c'est mieux à deux!",
  "On se retrouve sur le parcours?",
  "Ta prochaine connexion t'attend dehors!",
];

const compatibilityReasons = [
  "Même niveau d'intensité",
  "Actif dans ton quartier",
  "Courses en commun",
  "Même tranche d'âge",
];

function relativeTime(dateStr?: string): string {
  if (!dateStr) return "";
  const diff = Date.now() - new Date(dateStr).getTime();
  const days = Math.floor(diff / 86400000);
  if (days > 365) return `Il y a ${Math.floor(days / 365)} an(s)`;
  if (days > 30) return `Il y a ${Math.floor(days / 30)} mois`;
  if (days > 0) return `Il y a ${days} j`;
  return "Aujourd'hui";
}

export default function HomePage() {
  const [tagline] = useState(
    () => taglines[Math.floor(Math.random() * taglines.length)],
  );
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);
  const [contactOpen, setContactOpen] = useState(false);
  const [contactSubject, setContactSubject] = useState<ContactSubject>("other");
  const [galleryOpen, setGalleryOpen] = useState(false);
  const [galleryIndex, setGalleryIndex] = useState(0);
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  const openContactForm = (subject: ContactSubject) => {
    setContactSubject(subject);
    setContactOpen(true);
  };

  const openGallery = (index: number) => {
    setGalleryIndex(index);
    setGalleryOpen(true);
  };

  const openProfile = (user: User) => {
    setSelectedUser(user);
    setSheetOpen(true);
  };

  const upcomingEvents = mockEvents.filter(
    (e) => getEventStatus(e) !== "past",
  );
  const popularEvents = upcomingEvents.slice(0, 4);
  const otherUsers = mockUsers.filter((u) => u.id !== currentUser.id);
  const badge = BadgeLevel[currentUser.badge];

  // Runners of the month
  const men = mockUsers
    .filter((u) => u.gender === "Homme")
    .sort((a, b) => b.totalActivities - a.totalActivities);
  const women = mockUsers
    .filter((u) => u.gender !== "Homme")
    .sort((a, b) => b.totalActivities - a.totalActivities);
  const king = men[0] ?? null;
  const queen = women[0] ?? null;

  // New members sorted by memberSince (newest first)
  const newMembers = [...mockUsers]
    .sort((a, b) => {
      if (!a.memberSince && !b.memberSince) return 0;
      if (!a.memberSince) return 1;
      if (!b.memberSince) return -1;
      return (
        new Date(b.memberSince).getTime() - new Date(a.memberSince).getTime()
      );
    })
    .slice(0, 6);

  // Compatible profiles
  const compatibleProfiles = otherUsers.slice(0, 4);

  // Active members
  const activeMembers = otherUsers
    .sort((a, b) => b.totalActivities - a.totalActivities)
    .slice(0, 8);

  // Organizers
  const organizers = mockUsers.filter((u) => u.isOrganizer);

  // Community photos
  const communityPhotos = [...mockEventPhotos]
    .sort(
      (a, b) =>
        new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime(),
    )
    .slice(0, 4);

  // Countdown to next event deadline
  const nextDeadline = (() => {
    const now = new Date();
    const upcoming = mockEvents
      .filter((e) => new Date(e.date) > now)
      .sort(
        (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
      );
    if (upcoming.length > 0) {
      const d = new Date(upcoming[0].date);
      d.setDate(d.getDate() - 1);
      return d;
    }
    const fb = new Date(now);
    fb.setDate(fb.getDate() + 7);
    fb.setHours(14, 0, 0, 0);
    return fb;
  })();

  return (
    <div className="space-y-0">
      {/* ── Hero Banner ── */}
      <section className="relative overflow-hidden bg-gradient-to-b from-cyan via-ocean to-deep-teal px-6 pb-8 pt-10 text-white">
        <div className="absolute -right-8 -top-10 h-40 w-40 rounded-full border-[24px] border-white/[0.08]" />
        <div className="absolute right-12 top-20 h-2 w-2 rounded-full bg-white/25" />
        <div className="absolute -bottom-5 -left-5 h-28 w-28 rounded-full bg-gradient-radial from-white/[0.06] to-transparent" />

        <div className="relative mx-auto max-w-2xl space-y-5">
          <div className="flex items-center justify-between">
            <h1 className="font-heading text-[2.5rem] font-extrabold leading-none tracking-tight">
              Run Date
            </h1>
            <Badge className="bg-white/15 text-white backdrop-blur-sm border-0">
              {badge.icon} {badge.label}
            </Badge>
          </div>

          <div className="flex items-center gap-4">
            <div className="rounded-full border-[2.5px] border-white/50 shadow-lg shadow-black/15">
              <UserAvatar
                photoUrl={currentUser.photoUrl}
                firstName={currentUser.firstName}
                lastName={currentUser.lastName}
                size="xl"
              />
            </div>
            <div>
              <h2 className="font-heading text-[1.75rem] font-extrabold leading-tight">
                Salut {currentUser.firstName}!
              </h2>
              <p className="mt-1 text-sm text-white/85">{tagline}</p>
            </div>
          </div>

          {/* Quick stats in hero */}
          <div className="flex items-center justify-around rounded-[14px] bg-white/12 px-4 py-3">
            <div className="flex items-center gap-1.5">
              <span className="text-white/70">🏃</span>
              <div>
                <p className="font-heading text-base font-extrabold leading-tight">
                  {currentUser.totalActivities}
                </p>
                <p className="text-xs text-white/70">courses</p>
              </div>
            </div>
            <div className="h-7 w-px bg-white/20" />
            <div className="flex items-center gap-1.5">
              <span className="text-white/70">❤️</span>
              <div>
                <p className="font-heading text-base font-extrabold leading-tight">
                  4.6
                </p>
                <p className="text-xs text-white/70">note</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-2xl space-y-8 px-4 py-6">
        {/* ── Status Card with Countdown ── */}
        <StatusCard
          upcomingCount={
            upcomingEvents.filter((e) => e.registrationStatus === "confirmed")
              .length
          }
          nextEvent={popularEvents[0]}
          deadline={nextDeadline}
        />

        {/* ── Waiting Carousel ("Trouve ton Run Date") ── */}
        <WaitingCarousel />

        {/* ── Community Stats ("Ce mois-ci") ── */}
        <section>
          <h2 className="font-heading text-xl font-extrabold">Ce mois-ci</h2>
          <div className="mt-3 grid grid-cols-3 gap-3">
            {[
              { icon: Calendar, color: "text-primary", value: 8, label: "courses" },
              { icon: MapPin, color: "text-teal", value: 5, label: "quartiers" },
              { icon: Users, color: "text-amber-500", value: 42, label: "inscrits" },
            ].map((stat) => (
              <Card key={stat.label} className="text-center">
                <CardContent className="flex flex-col items-center p-4">
                  <stat.icon className={cn("h-6 w-6", stat.color)} />
                  <p className="mt-2.5 font-heading text-lg font-extrabold">
                    {stat.value}
                  </p>
                  <p className="text-sm text-muted-foreground">{stat.label}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>

        {/* ── Runners of the Month ("La Royauté du moment") ── */}
        {(king || queen) && (
          <section>
            <div className="flex items-center gap-2">
              <h2 className="font-heading text-xl font-extrabold">
                La Royauté du moment
              </h2>
              <span className="text-xl">👑</span>
            </div>
            <p className="mt-1 text-sm text-muted-foreground">
              Les plus actifs de la communauté en ce moment!
            </p>
            <div className="mt-4 grid grid-cols-2 gap-3">
              {king && (
                <CrownCard
                  user={king}
                  title="Le King"
                  accentClass="border-navy/20 text-navy"
                  onTap={() => openProfile(king)}
                />
              )}
              {queen && (
                <CrownCard
                  user={queen}
                  title="La Queen"
                  accentClass="border-primary/20 text-primary"
                  onTap={() => openProfile(queen)}
                />
              )}
            </div>
          </section>
        )}

        {/* ── New Members ("Les p'tits nouveaux") ── */}
        <section>
          <div className="flex items-center gap-2">
            <h2 className="font-heading text-xl font-extrabold">
              Les p&apos;tits nouveaux
            </h2>
            <span className="text-lg">🌱</span>
          </div>
          <p className="mt-1 text-sm text-muted-foreground">
            Bienvenue parmi nous!
          </p>
          <div className="mt-4 flex gap-2.5 overflow-x-auto pb-2">
            {newMembers.map((user) => (
              <button
                key={user.id}
                className="flex w-[110px] shrink-0 flex-col overflow-hidden rounded-[14px] border bg-card"
                onClick={() => openProfile(user)}
              >
                <div className="relative h-24 w-full">
                  {user.photoUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={user.photoUrl}
                      alt={user.firstName}
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center bg-primary/10">
                      <span className="font-heading text-3xl font-bold text-primary">
                        {user.firstName[0]}
                      </span>
                    </div>
                  )}
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent px-2 pb-1.5 pt-5">
                    <p className="truncate text-sm font-bold text-white drop-shadow">
                      {user.firstName}
                    </p>
                  </div>
                  {user.isVerified && (
                    <span className="absolute right-1.5 top-1.5 text-xs text-white">✓</span>
                  )}
                </div>
                <div className="flex flex-1 items-center justify-center px-1.5 py-2">
                  <p className="truncate text-xs text-muted-foreground">
                    {relativeTime(user.memberSince)}
                  </p>
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* ── Compatible Profiles ("Des gens à découvrir") ── */}
        <section>
          <h2 className="font-heading text-xl font-extrabold">
            Des gens à découvrir
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Run Date favorise les rencontres actives, en vrai. Découvre ces
            profils à ta prochaine course!
          </p>
          <div className="mt-4 flex gap-3 overflow-x-auto pb-2">
            {compatibleProfiles.map((user, i) => (
              <button
                key={user.id}
                className="flex w-[150px] shrink-0 flex-col overflow-hidden rounded-2xl border border-primary/15 bg-card shadow-sm"
                onClick={() => openProfile(user)}
              >
                <div className="relative h-[130px] w-full">
                  {user.photoUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={user.photoUrl}
                      alt={user.firstName}
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center bg-primary/10">
                      <span className="font-heading text-4xl font-bold text-primary">
                        {user.firstName[0]}
                      </span>
                    </div>
                  )}
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent px-2.5 pb-2 pt-5">
                    <p className="truncate text-sm font-bold text-white drop-shadow">
                      {user.firstName}, {user.age}
                    </p>
                  </div>
                  {user.isVerified && (
                    <span className="absolute right-2 top-2 text-sm text-white">✓</span>
                  )}
                </div>
                <div className="flex flex-1 items-center justify-center px-2 py-2.5">
                  <span className="rounded-lg bg-primary/10 px-2 py-1 text-xs font-semibold text-primary">
                    {compatibilityReasons[i % compatibilityReasons.length]}
                  </span>
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* ── Active Members ── */}
        <section>
          <div className="flex items-center justify-between">
            <h2 className="font-heading text-xl font-extrabold">
              Membres actifs
            </h2>
            <Link
              href="/members"
              className="flex items-center gap-1 text-sm font-semibold text-primary"
            >
              Voir tout
              <ArrowRight className="h-4 w-4" />
            </Link>
          </div>
          <div className="mt-3 flex gap-4 overflow-x-auto pb-2">
            {activeMembers.map((u) => (
              <button
                key={u.id}
                className="flex w-[68px] shrink-0 flex-col items-center gap-1.5"
                onClick={() => openProfile(u)}
              >
                <UserAvatar
                  photoUrl={u.photoUrl}
                  firstName={u.firstName}
                  lastName={u.lastName}
                  size="lg"
                />
                <span className="w-full truncate text-center text-xs font-semibold">
                  {u.firstName}
                </span>
              </button>
            ))}
          </div>
        </section>

        {/* ── Testimonials ── */}
        <section>
          <h2 className="font-heading text-xl font-extrabold">
            Ce qu&apos;ils en disent
          </h2>
          <div className="mt-3 flex gap-3 overflow-x-auto pb-2">
            {[
              {
                quote:
                  "On s'est rencontrés lors d'un Run Date. Maintenant on court ensemble tous les matins!",
                name: "Sophie",
                age: 31,
                photo: "https://i.pravatar.cc/100?img=1",
                rating: 5,
              },
              {
                quote:
                  "Les groupes sont toujours bien formés. J'ai trouvé mon rythme (et mon match)!",
                name: "Marc-Antoine",
                age: 38,
                photo: "https://i.pravatar.cc/100?img=3",
                rating: 4,
              },
              {
                quote:
                  "J'étais sceptique mais le Ravito après, c'est là que la magie opère!",
                name: "Émilie",
                age: 42,
                photo: "https://i.pravatar.cc/100?img=9",
                rating: 5,
              },
              {
                quote:
                  "Enfin une app de dating qui sort du swipe! On bouge, on jase, on connecte pour vrai.",
                name: "Olivier",
                age: 36,
                photo: "https://i.pravatar.cc/100?img=7",
                rating: 4,
              },
            ].map((t) => (
              <Card
                key={t.name}
                className="w-[280px] shrink-0 rounded-2xl"
              >
                <CardContent className="flex h-full flex-col p-5">
                  <span className="text-2xl text-primary/35">"</span>
                  <p className="mt-1 flex-1 text-sm italic leading-relaxed">
                    {t.quote}
                  </p>
                  <div className="mt-4 flex items-center gap-2.5">
                    <UserAvatar
                      photoUrl={t.photo}
                      firstName={t.name}
                      size="sm"
                    />
                    <div>
                      <p className="text-sm font-semibold">
                        {t.name}, {t.age} ans
                      </p>
                      <div className="flex gap-0.5">
                        {Array.from({ length: 5 }).map((_, i) => (
                          <Star
                            key={i}
                            className={cn(
                              "h-3.5 w-3.5",
                              i < t.rating
                                ? "fill-amber-400 text-amber-400"
                                : "text-muted",
                            )}
                          />
                        ))}
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </section>

        {/* ── Promo Video Card ── */}
        <section>
          <h2 className="font-heading text-xl font-extrabold">
            Découvre Run Date
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Fais le premier pas. Le deuxième, vous le ferez ensemble.
          </p>
          <PromoVideo />
        </section>

        {/* ── Popular Events (horizontal scroll like Flutter) ── */}
        <section>
          <div className="flex items-center justify-between">
            <h2 className="font-heading text-xl font-extrabold">
              Événements populaires
            </h2>
            <Link
              href="/events"
              className="text-sm font-semibold text-primary hover:underline"
            >
              Voir tout
            </Link>
          </div>
          <div className="mt-3 flex gap-3.5 overflow-x-auto pb-2">
            {popularEvents.map((event, i) => {
              const gradients = [
                "from-ocean to-cyan",
                "from-navy to-navy-blue",
                "from-teal to-teal",
                "from-amber-500 to-amber-400",
              ];
              return (
                <Link
                  key={event.id}
                  href={`/events/${event.id}`}
                  className="w-[210px] shrink-0 overflow-hidden rounded-2xl border bg-card shadow-sm"
                >
                  <div
                    className={cn(
                      "h-2 bg-gradient-to-r",
                      gradients[i % gradients.length],
                    )}
                  />
                  <div className="flex h-[180px] flex-col p-4">
                    <p className="font-heading text-base font-extrabold leading-tight">
                      {event.neighborhood}
                    </p>
                    <p className="mt-1.5 text-sm text-muted-foreground">
                      {new Date(event.date).toLocaleDateString("fr-CA", {
                        weekday: "long",
                        day: "numeric",
                        month: "long",
                      })}
                    </p>
                    <div className="mt-auto flex items-center justify-between text-sm">
                      <span className="text-muted-foreground">
                        {event.menCount}H - {event.womenCount}F
                      </span>
                      <ChevronRight className="h-4 w-4 text-muted-foreground/50" />
                    </div>
                  </div>
                </Link>
              );
            })}
          </div>
        </section>

        {/* ── Organizers ── */}
        {organizers.length > 0 && (
          <section>
            <div className="flex items-center justify-between">
              <h2 className="font-heading text-xl font-extrabold">
                Nos organisateurs
              </h2>
              <Link
                href="/organizers"
                className="text-sm font-semibold text-teal hover:underline"
              >
                Voir tous
              </Link>
            </div>
            <div className="mt-3 flex gap-3.5 overflow-x-auto pb-2">
              {organizers.map((org) => {
                const eventCount = mockEvents.filter((e) =>
                  e.organizerIds.includes(org.id),
                ).length;
                return (
                  <button
                    key={org.id}
                    className="flex w-[140px] shrink-0 flex-col items-center rounded-2xl border border-teal/20 bg-card p-3.5"
                    onClick={() => openProfile(org)}
                  >
                    <UserAvatar
                      photoUrl={org.photoUrl}
                      firstName={org.firstName}
                      lastName={org.lastName}
                      size="lg"
                    />
                    <p className="mt-2.5 font-heading text-sm font-extrabold">
                      {org.firstName}
                    </p>
                    <span className="mt-1 rounded-lg bg-teal/10 px-2 py-0.5 text-[11px] font-bold text-teal">
                      Organisateur
                    </span>
                    <p className="mt-1.5 text-xs text-muted-foreground">
                      {eventCount} événement{eventCount > 1 ? "s" : ""}
                    </p>
                  </button>
                );
              })}
            </div>
          </section>
        )}

        {/* ── Community Photos ── */}
        {communityPhotos.length > 0 && (
          <section>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <h2 className="font-heading text-xl font-extrabold">
                  Communauté
                </h2>
                <Camera className="h-5 w-5 text-teal" />
              </div>
              <span className="text-sm font-semibold text-primary">
                Voir tout
              </span>
            </div>
            <div className="mt-3 flex gap-2.5 overflow-x-auto pb-2">
              {communityPhotos.map((photo, i) => (
                <button
                  key={photo.id}
                  className="relative h-[120px] w-[120px] shrink-0 overflow-hidden rounded-xl"
                  onClick={() => openGallery(i)}
                >
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={photo.photoUrl}
                    alt={photo.userName}
                    className="h-full w-full object-cover"
                  />
                  <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent px-1.5 pb-1 pt-4">
                    <p className="truncate text-sm font-semibold text-white">
                      {photo.userName}
                    </p>
                  </div>
                </button>
              ))}
            </div>
          </section>
        )}

        {/* ── Propose Route Card ── */}
        <Card>
          <CardContent className="p-5">
            <div className="flex items-center gap-2.5">
              <Compass className="h-6 w-6 text-teal" />
              <h3 className="font-heading text-lg font-bold">
                Propose-nous un endroit
              </h3>
            </div>
            <p className="mt-2 text-sm text-muted-foreground">
              On pourrait l&apos;ajouter au prochain événement!
            </p>
            <Button
              variant="outline"
              className="mt-4 w-full border-teal/50 text-teal hover:bg-teal/5"
              onClick={() => openContactForm("newMeetingPoint")}
            >
              Proposer un parcours
            </Button>
          </CardContent>
        </Card>

        {/* ── Become Organizer Card ── */}
        <section className="overflow-hidden rounded-2xl bg-gradient-to-br from-navy to-navy-blue border border-teal/25 p-5 text-white">
          <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-teal/15">
            <Shield className="h-6 w-6 text-teal" />
          </div>
          <h3 className="mt-3.5 font-heading text-lg font-extrabold">
            Deviens Organisateur dans ton quartier!
          </h3>
          <p className="mt-2 text-sm text-white/75 leading-relaxed">
            Les Organisateurs sont les leaders de la communauté. Tu guides le
            groupe, tu donnes le rythme et tu t&apos;assures que tout le monde
            passe un bon moment.
          </p>
          <Button
            className="mt-4 w-full bg-teal text-navy font-bold hover:bg-teal/90"
            onClick={() => openContactForm("becomeOrganizer")}
          >
            Postuler
          </Button>
        </section>

        {/* ── Theme Toggle ── */}
        {mounted && (
          <button
            className="flex w-full items-center gap-3.5 rounded-2xl border bg-card p-[18px]"
            onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
          >
            <div
              className={cn(
                "flex h-11 w-11 items-center justify-center rounded-xl",
                theme === "dark"
                  ? "bg-amber-500/12"
                  : "bg-navy/8",
              )}
            >
              {theme === "dark" ? (
                <Sun className="h-5 w-5 text-amber-500" />
              ) : (
                <Moon className="h-5 w-5 text-navy" />
              )}
            </div>
            <div className="flex-1 text-left">
              <p className="font-heading text-sm font-bold">
                {theme === "dark" ? "Trop sombre?" : "Mal aux yeux?"}
              </p>
              <p className="text-xs text-muted-foreground">
                {theme === "dark"
                  ? "Passe en mode ensoleillé"
                  : "Passe en mode sombre"}
              </p>
            </div>
            <div
              className={cn(
                "flex h-7 w-12 items-center rounded-full px-0.5",
                theme === "dark" ? "justify-end bg-amber-500" : "justify-start bg-navy",
              )}
            >
              <div className="flex h-6 w-6 items-center justify-center rounded-full bg-white">
                {theme === "dark" ? (
                  <Sun className="h-3.5 w-3.5 text-amber-500" />
                ) : (
                  <Moon className="h-3.5 w-3.5 text-navy" />
                )}
              </div>
            </div>
          </button>
        )}

        {/* ── Bottom CTA ── */}
        <Card className="text-center">
          <CardContent className="p-7">
            <h2 className="font-heading text-xl font-extrabold">
              Prêt à bouger?
            </h2>
            <p className="mt-2.5 text-sm text-muted-foreground">
              Bouge et rencontre du monde pour vrai!
            </p>
            <Link href="/events">
              <Button size="lg" className="mt-5 w-full bg-primary text-white">
                Explorer les événements
              </Button>
            </Link>
          </CardContent>
        </Card>
      </div>

      {/* User Profile Sheet */}
      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
      <ContactFormDrawer
        open={contactOpen}
        onOpenChange={setContactOpen}
        preselectedSubject={contactSubject}
      />
      <PhotoGalleryViewer
        photos={communityPhotos}
        initialIndex={galleryIndex}
        open={galleryOpen}
        onOpenChange={setGalleryOpen}
      />
    </div>
  );
}

/* ── Sub-components ── */

function StatusCard({
  upcomingCount,
  nextEvent,
  deadline,
}: {
  upcomingCount: number;
  nextEvent?: { neighborhood: string; date: string };
  deadline: Date;
}) {
  const [remaining, setRemaining] = useState(() => deadline.getTime() - Date.now());

  useEffect(() => {
    const interval = setInterval(() => {
      const diff = deadline.getTime() - Date.now();
      setRemaining(Math.max(0, diff));
    }, 1000);
    return () => clearInterval(interval);
  }, [deadline]);

  const days = Math.floor(remaining / 86400000);
  const hours = Math.floor((remaining % 86400000) / 3600000);
  const minutes = Math.floor((remaining % 3600000) / 60000);
  const seconds = Math.floor((remaining % 60000) / 1000);

  if (upcomingCount === 0) {
    return (
      <div className="overflow-hidden rounded-2xl bg-gradient-to-br from-ocean via-ocean/90 to-cyan p-6 text-center text-white shadow-xl shadow-ocean/40">
        <h3 className="font-heading text-xl font-extrabold">
          Ton prochain Run Date t&apos;attend!
        </h3>
        <p className="mt-2 text-sm text-white/90">
          Inscris-toi avant la clôture
        </p>

        <div className="mt-5 grid grid-cols-4 gap-2">
          {[
            { label: "jours", value: String(days).padStart(2, "0") },
            { label: "heures", value: String(hours).padStart(2, "0") },
            { label: "min", value: String(minutes).padStart(2, "0") },
            { label: "sec", value: String(seconds).padStart(2, "0") },
          ].map((c, i) => (
            <div
              key={c.label}
              className="flex flex-col items-center rounded-xl border border-white/35 bg-white/20 py-3"
            >
              <span className="font-heading text-xl font-extrabold">{c.value}</span>
              <span className="text-sm text-white/90">{c.label}</span>
            </div>
          ))}
        </div>

        <Link href="/events">
          <Button className="mt-6 w-full bg-navy text-white font-extrabold hover:bg-navy/90" size="lg">
            S&apos;inscrire
          </Button>
        </Link>
      </div>
    );
  }

  return (
    <Card className="border-primary/20 bg-gradient-to-r from-primary/5 to-teal/5">
      <CardContent className="flex items-center gap-4 p-4">
        <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-primary/10">
          <Calendar className="h-6 w-6 text-primary" />
        </div>
        <div className="flex-1">
          <p className="font-heading font-bold">
            Tu es inscrit à {upcomingCount} activité(s)
          </p>
          {nextEvent && (
            <p className="text-sm text-muted-foreground">
              Prochaine : {nextEvent.neighborhood},{" "}
              {new Date(nextEvent.date).toLocaleDateString("fr-CA", {
                weekday: "long",
                day: "numeric",
                month: "long",
              })}
            </p>
          )}
        </div>
        <Link href="/events">
          <ArrowRight className="h-5 w-5 text-muted-foreground" />
        </Link>
      </CardContent>
    </Card>
  );
}

function CrownCard({
  user,
  title,
  accentClass,
  onTap,
}: {
  user: User;
  title: string;
  accentClass: string;
  onTap: () => void;
}) {
  return (
    <button
      onClick={onTap}
      className="flex flex-col items-center rounded-2xl border bg-card p-5 shadow-sm"
    >
      <div className="relative">
        <span className="absolute -top-5 left-1/2 -translate-x-1/2 text-2xl">
          👑
        </span>
        <UserAvatar
          photoUrl={user.photoUrl}
          firstName={user.firstName}
          lastName={user.lastName}
          size="xl"
          className="border-2 border-primary/40 shadow-md"
        />
      </div>
      <Badge
        variant="outline"
        className={cn("mt-3", accentClass)}
      >
        {title}
      </Badge>
      <p className="mt-1.5 font-heading text-base font-extrabold">
        {user.firstName}
      </p>
      <p className="mt-1 font-heading text-base font-extrabold text-primary">
        {user.totalActivities} courses
      </p>
      <Progress
        value={Math.min(100, (user.totalActivities / 15) * 100)}
        className="mt-2 h-1.5 w-full"
      />
    </button>
  );
}
