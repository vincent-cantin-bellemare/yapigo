"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { currentUser } from "@/lib/data";
import { BadgeLevel, EventCategory } from "@/lib/types";
import { ClickableUser } from "@/components/shared/clickable-user";
import { cn } from "@/lib/utils";
import {
  Eye,
  User,
  ShieldCheck,
  Share2,
  Receipt,
  Activity,
  HelpCircle,
  Globe,
  Moon,
  Sun,
  LogOut,
  ChevronRight,
  ChevronDown,
  CheckCircle,
  Camera,
  Pencil,
  Star,
  Compass,
  Target,
} from "lucide-react";

function computeCompleteness() {
  let total = 0;
  if (currentUser.photoUrl) total += 20;
  if (currentUser.bio) total += 15;
  if (currentUser.isVerified) total += 20;
  if (currentUser.totalActivities >= 1) total += 15;
  if (currentUser.averageRating != null) total += 15;
  if (currentUser.activities.length > 0) total += 15;
  return total;
}

function getFirstSuggestion(): {
  text: string;
  cta: string;
  Icon: typeof Camera;
} | null {
  if (!currentUser.photoUrl)
    return {
      text: "Ajoute une photo pour te démarquer!",
      cta: "Ajouter",
      Icon: Camera,
    };
  if (!currentUser.bio)
    return {
      text: "Écris une bio pour te présenter!",
      cta: "Écrire",
      Icon: Pencil,
    };
  if (!currentUser.isVerified)
    return {
      text: "Vérifie ton compte pour inspirer confiance!",
      cta: "Vérifier",
      Icon: ShieldCheck,
    };
  if (currentUser.activities.length === 0)
    return {
      text: "Choisis tes sports pour être bien placé!",
      cta: "Choisir",
      Icon: Target,
    };
  if (currentUser.totalActivities < 1)
    return {
      text: "Participe à ta première activité!",
      cta: "Explorer",
      Icon: Compass,
    };
  if (currentUser.averageRating == null)
    return {
      text: "Reçois ta première évaluation!",
      cta: "Participer",
      Icon: Star,
    };
  return null;
}

export default function ProfilePage() {
  const badge = BadgeLevel[currentUser.badge];
  const pct = computeCompleteness();
  const suggestion = getFirstSuggestion();
  const [bioExpanded, setBioExpanded] = useState(false);

  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="mx-auto max-w-lg px-5 pt-6">
        {/* ── Profile Header (centered) ── */}
        <div className="flex flex-col items-center">
          {/* Avatar */}
          <div className="relative h-28 w-28 overflow-hidden rounded-full border-2 border-border/30 shadow-lg">
            {currentUser.photoUrl ? (
              <Image
                src={currentUser.photoUrl}
                alt={currentUser.firstName}
                fill
                className="object-cover"
              />
            ) : (
              <div className="flex h-full w-full items-center justify-center bg-primary/20">
                <span className="font-heading text-4xl font-extrabold text-primary">
                  {currentUser.firstName[0]}
                </span>
              </div>
            )}
          </div>

          {/* Name + badge */}
          <div className="mt-5 flex flex-wrap items-center justify-center gap-1.5">
            <h1 className="font-heading text-[22px] font-extrabold">
              {currentUser.firstName}
            </h1>
            <span className="text-base">{badge.icon}</span>
            <span className="font-heading text-[22px] font-extrabold">
              {badge.label}
            </span>
          </div>

          {/* Verification chip */}
          <div className="mt-3">
            {currentUser.isVerified ? (
              <span className="inline-flex items-center rounded-full border border-teal-500/40 bg-teal-500/15 px-3 py-1.5 text-sm font-semibold text-teal-600">
                ✓ Vérifié
              </span>
            ) : (
              <span className="inline-flex items-center rounded-full border border-border bg-muted/50 px-3 py-1.5 text-sm font-semibold text-muted-foreground">
                Non vérifié
              </span>
            )}
          </div>

          {/* Location + age */}
          <p className="mt-3 text-[15px] text-muted-foreground">
            {currentUser.neighborhood
              ? `${currentUser.neighborhood}, ${currentUser.city}`
              : currentUser.city}{" "}
            · {currentUser.age} ans
          </p>

          {/* Photo gallery */}
          {currentUser.photoGallery.length > 0 && (
            <div className="mt-4 flex items-center justify-center gap-2">
              {currentUser.photoGallery.slice(0, 4).map((url, i) => (
                <div
                  key={i}
                  className="relative h-[72px] w-[72px] overflow-hidden rounded-xl"
                >
                  <Image
                    src={url}
                    alt={`Photo ${i + 1}`}
                    fill
                    className="object-cover"
                  />
                </div>
              ))}
              {currentUser.photoGallery.length > 4 && (
                <div className="flex h-[72px] w-[72px] items-center justify-center rounded-xl bg-muted">
                  <span className="text-base font-bold text-muted-foreground">
                    +{currentUser.photoGallery.length - 4}
                  </span>
                </div>
              )}
            </div>
          )}
        </div>

        {/* "Voir mon profil" button */}
        <div className="mt-3.5 flex justify-center">
          <ClickableUser
            user={currentUser}
            isOwnProfile
            className="inline-flex items-center gap-2 rounded-[10px] border border-teal-500/30 px-4 py-2 text-sm font-semibold text-teal-600 transition-colors hover:bg-teal-500/5"
          >
            <Eye className="h-4 w-4" />
            Voir mon profil public
          </ClickableUser>
        </div>

        {/* ── Profile Completeness ── */}
        <div className="mt-5">
          {pct >= 100 ? (
            <div className="flex items-center gap-2.5 rounded-[14px] border border-teal-500/25 bg-teal-500/8 px-4 py-3.5">
              <CheckCircle className="h-5 w-5 shrink-0 text-teal-500" />
              <span className="text-sm font-semibold text-teal-600">
                Profil complet!
              </span>
            </div>
          ) : (
            <div className="rounded-2xl border border-border p-5">
              <div className="flex items-center gap-4">
                {/* Circular progress */}
                <div className="relative h-14 w-14 shrink-0">
                  <svg
                    viewBox="0 0 56 56"
                    className="h-14 w-14 -rotate-90"
                  >
                    <circle
                      cx="28"
                      cy="28"
                      r="24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="5"
                      className="text-muted/40"
                    />
                    <circle
                      cx="28"
                      cy="28"
                      r="24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="5"
                      strokeLinecap="round"
                      strokeDasharray={`${(pct / 100) * 2 * Math.PI * 24} ${2 * Math.PI * 24}`}
                      className="text-primary"
                    />
                  </svg>
                  <span className="absolute inset-0 flex items-center justify-center font-heading text-sm font-extrabold text-primary">
                    {pct}%
                  </span>
                </div>
                <div className="min-w-0 flex-1">
                  <p className="font-heading text-base font-bold">
                    Ton profil est complet à {pct}%
                  </p>
                  {suggestion && (
                    <p className="mt-1 text-sm leading-snug text-muted-foreground">
                      {suggestion.text}
                    </p>
                  )}
                </div>
              </div>
              {suggestion && (
                <button className="mt-3.5 flex w-full items-center justify-center gap-2 rounded-xl border-[1.5px] border-primary py-3 text-sm font-bold text-primary hover:bg-primary/5">
                  <suggestion.Icon className="h-4.5 w-4.5" />
                  {suggestion.cta}
                </button>
              )}
            </div>
          )}
        </div>

        {/* ── Bio (expandable) ── */}
        {currentUser.bio && (
          <div className="mt-5 rounded-2xl border border-border p-5">
            <button
              onClick={() => setBioExpanded(!bioExpanded)}
              className="flex w-full items-center justify-between"
            >
              <h3 className="font-heading text-base font-bold">À propos</h3>
              <ChevronDown
                className={cn(
                  "h-5 w-5 text-muted-foreground transition-transform duration-200",
                  bioExpanded && "rotate-180",
                )}
              />
            </button>
            <div className="mt-2.5">
              <p
                className={cn(
                  "text-[15px] leading-relaxed",
                  !bioExpanded && "line-clamp-3",
                )}
              >
                {currentUser.bio}
              </p>
              {!bioExpanded && currentUser.bio.length > 120 && (
                <button
                  onClick={() => setBioExpanded(true)}
                  className="mt-1.5 text-sm font-semibold text-primary"
                >
                  Lire la suite
                </button>
              )}
            </div>
          </div>
        )}

        {/* ── Activity Goals ── */}
        {currentUser.activityGoals.length > 0 && (
          <div className="mt-5 rounded-2xl border border-border p-5">
            <h3 className="font-heading text-[17px] font-bold">
              Mes objectifs
            </h3>
            <div className="mt-3.5 flex flex-wrap gap-1.5">
              {currentUser.activityGoals.map((goal) => (
                <span
                  key={goal}
                  className="rounded-xl bg-primary/12 px-2.5 py-1.5 text-sm font-semibold text-primary"
                >
                  {goal}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* ── Menu ── */}
        <div className="mt-6 overflow-hidden rounded-2xl border border-border">
          <MenuItem
            Icon={User}
            label="Mon profil"
            href="/profile/edit"
          />
          <MenuItem
            Icon={ShieldCheck}
            label="Vérifier mon compte"
            iconClass={currentUser.isVerified ? "" : "text-teal-500"}
          />
          <MenuItem
            Icon={Share2}
            label="Inviter un ami"
            iconClass="text-primary"
          />
          <MenuItem Icon={Receipt} label="Factures & paiements" />
          <div className="mx-4 h-px bg-border" />
          <MenuItem
            Icon={Activity}
            label="Strava"
            iconClass="text-[#FC4C02]"
            badge={
              currentUser.stravaConnected ? (
                <span className="rounded-lg bg-teal-500/10 px-2 py-0.5 text-xs font-semibold text-teal-600">
                  Connecté
                </span>
              ) : undefined
            }
          />
          <div className="mx-4 h-px bg-border" />
          <MenuItem Icon={HelpCircle} label="Aide & infos légales" />
          <MenuItem
            Icon={Globe}
            label="Langue : Français"
            showChevron={false}
          />
          <MenuItem
            Icon={Moon}
            label="Mode sombre"
            showChevron={false}
          />
          <div className="mx-4 h-px bg-border" />
          <MenuItem
            Icon={LogOut}
            label="Déconnexion"
            iconClass="text-muted-foreground"
          />
        </div>

        {/* Version */}
        <p className="mt-7 text-center text-sm text-muted-foreground">
          Run Date v3.2.2 (69)
        </p>
      </div>
    </div>
  );
}

function MenuItem({
  Icon,
  label,
  href,
  iconClass,
  showChevron = true,
  badge,
}: {
  Icon: typeof User;
  label: string;
  href?: string;
  iconClass?: string;
  showChevron?: boolean;
  badge?: React.ReactNode;
}) {
  const content = (
    <div className="flex items-center gap-4 px-[18px] py-3.5">
      <Icon className={cn("h-6 w-6", iconClass || "text-foreground/70")} />
      <span className="flex-1 text-[15px] font-semibold">{label}</span>
      {badge}
      {showChevron && (
        <ChevronRight className="h-5 w-5 text-muted-foreground/50" />
      )}
    </div>
  );

  if (href) {
    return (
      <Link href={href} className="block hover:bg-accent/50 transition-colors">
        {content}
      </Link>
    );
  }

  return (
    <button className="block w-full text-left hover:bg-accent/50 transition-colors">
      {content}
    </button>
  );
}
