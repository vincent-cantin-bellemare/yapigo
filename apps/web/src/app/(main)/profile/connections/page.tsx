"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { ArrowLeft, Award } from "lucide-react";

export default function ConnectionsPage() {
  const [stravaConnected, setStravaConnected] = useState(false);
  const [isOrganizer] = useState(false);

  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="flex items-center gap-3 px-5 pt-6 pb-4">
        <Link href="/profile" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="font-heading text-lg font-bold">Mes connexions</h1>
      </div>

      <div className="mx-auto max-w-lg space-y-5 px-5">
        {/* Strava */}
        <div className="rounded-2xl border border-border p-5">
          <div className="flex items-center gap-3">
            <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-[#FC4C02]">
              <span className="text-xl font-extrabold text-white">S</span>
            </div>
            <div className="min-w-0 flex-1">
              <p className="font-heading text-base font-bold">
                {stravaConnected ? "Strava connecté" : "Strava"}
              </p>
              {stravaConnected && (
                <span className="inline-block rounded-md bg-teal-500/10 px-2 py-0.5 text-xs font-semibold text-teal-600">
                  Actif
                </span>
              )}
            </div>
          </div>

          {stravaConnected ? (
            <>
              <div className="mt-4 grid grid-cols-3 gap-3">
                <StatBox label="Cette année" value="342 km" />
                <StatBox label="Sorties" value="28" />
                <StatBox label="Allure moy." value="5:23/km" />
              </div>
              <button
                onClick={() => setStravaConnected(false)}
                className="mt-4 text-sm font-semibold text-red-500 hover:underline"
              >
                Déconnecter Strava
              </button>
            </>
          ) : (
            <>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                Connecte ton compte Strava pour synchroniser tes activités et
                afficher tes statistiques sur ton profil Run Date.
              </p>
              <p className="mt-1.5 text-xs text-muted-foreground/70">
                Tes données restent privées et ne sont visibles que par toi.
              </p>
              <button
                onClick={() => setStravaConnected(true)}
                className="mt-4 w-full rounded-xl bg-[#FC4C02] py-3 text-sm font-bold text-white hover:bg-[#e04400] transition-colors"
              >
                Connecter Strava
              </button>
            </>
          )}
        </div>

        {/* Organizer */}
        <div
          className={cn(
            "rounded-2xl border p-5",
            isOrganizer
              ? "border-amber-400/40 bg-gradient-to-br from-amber-50 to-amber-100/50 dark:from-amber-900/20 dark:to-amber-800/10"
              : "border-border",
          )}
        >
          <div className="flex items-center gap-3">
            <Award
              className={cn(
                "h-7 w-7",
                isOrganizer ? "text-amber-500" : "text-foreground/70",
              )}
            />
            <p className="font-heading text-base font-bold">
              {isOrganizer ? "Organisateur certifié 🏅" : "Organisateur"}
            </p>
          </div>

          {isOrganizer ? (
            <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
              Tu es un organisateur certifié Run Date! Tu peux créer et gérer
              des activités pour la communauté.
            </p>
          ) : (
            <>
              <p className="mt-3 text-sm leading-relaxed text-muted-foreground">
                Deviens Organisateur! Crée et anime des activités pour la
                communauté Run Date. L&apos;Organisateur est la personne
                ressource sur le terrain : il accueille les participants,
                s&apos;assure que tout le monde est à l&apos;aise et gère le
                déroulement de l&apos;activité.
              </p>
              <button className="mt-4 w-full rounded-xl bg-amber-500 py-3 text-sm font-bold text-white hover:bg-amber-600 transition-colors">
                Postuler comme Organisateur
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function StatBox({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-xl border border-border bg-card px-3 py-2.5 text-center">
      <p className="text-xs text-muted-foreground">{label}</p>
      <p className="mt-0.5 font-heading text-base font-bold">{value}</p>
    </div>
  );
}
