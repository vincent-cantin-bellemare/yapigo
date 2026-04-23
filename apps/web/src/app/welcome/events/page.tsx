"use client";

import { useMemo, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { mockEvents } from "@/lib/data";
import { EventCategory } from "@/lib/types";
import { ArrowLeft, Info, Coffee } from "lucide-react";

const dayNames = [
  "",
  "Lundi",
  "Mardi",
  "Mercredi",
  "Jeudi",
  "Vendredi",
  "Samedi",
  "Dimanche",
];
const monthNames = [
  "",
  "janvier",
  "février",
  "mars",
  "avril",
  "mai",
  "juin",
  "juillet",
  "août",
  "septembre",
  "octobre",
  "novembre",
  "décembre",
];

function formatGuestDate(iso: string): string {
  const dt = new Date(iso);
  const d = dt.getDay() === 0 ? 7 : dt.getDay();
  const h = String(dt.getHours()).padStart(2, "0");
  const m = String(dt.getMinutes()).padStart(2, "0");
  return `${dayNames[d]} ${dt.getDate()} ${monthNames[dt.getMonth() + 1]} · ${h} h ${m}`;
}

export default function GuestEventsPage() {
  const { isLoggedIn, login } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isLoggedIn) router.replace("/");
  }, [isLoggedIn, router]);

  const upcoming = useMemo(() => {
    const now = new Date();
    return mockEvents
      .filter((e) => new Date(e.date) >= now)
      .sort(
        (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime(),
      );
  }, []);

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Header */}
      <div className="flex items-center gap-3 px-5 pt-6 pb-2">
        <Link href="/welcome" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <div className="flex items-center gap-2.5">
          <span className="font-heading text-xl font-extrabold text-primary">
            R
          </span>
          <h1 className="font-heading text-lg font-bold">
            Découvrir les événements
          </h1>
        </div>
      </div>

      {/* Info banner */}
      <div className="mx-5 mt-2 flex items-center gap-2.5 rounded-xl bg-primary/8 px-3.5 py-2.5">
        <Info className="h-4.5 w-4.5 shrink-0 text-primary" />
        <p className="text-[13px] font-medium leading-snug text-primary">
          Connecte-toi pour voir tous les détails des événements.
        </p>
      </div>

      {/* Events list */}
      <div className="flex-1 space-y-3 px-5 pt-3 pb-44">
        {upcoming.map((e) => {
          const cat = EventCategory[e.category];
          return (
            <div
              key={e.id}
              className="rounded-2xl border border-border bg-card p-[18px] shadow-sm"
            >
              <div className="flex items-center gap-2">
                <span className="text-lg">{cat?.emoji ?? "🏃"}</span>
                <h3 className="font-heading text-lg font-bold">
                  {e.neighborhood}
                </h3>
              </div>
              <p className="mt-1.5 text-sm text-muted-foreground">
                {formatGuestDate(e.date)}
              </p>
              {e.aperoSmoothieSpot && (
                <div className="mt-2.5 flex items-center gap-2 text-sm text-muted-foreground">
                  <Coffee className="h-4 w-4 text-primary" />
                  <span>Ravito Smoothie : {e.aperoSmoothieSpot}</span>
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Sticky bottom */}
      <div className="fixed bottom-0 left-0 right-0 z-40 border-t border-border bg-card/95 backdrop-blur-sm">
        <div className="mx-auto max-w-lg px-5 py-4">
          <button
            onClick={login}
            className="text-sm font-semibold text-muted-foreground hover:text-foreground"
          >
            Déjà un compte?{" "}
            <span className="text-primary">Se connecter</span>
          </button>
          <Link
            href="/welcome/signup"
            className="mt-2 flex w-full items-center justify-center rounded-xl bg-primary py-4 text-base font-bold text-primary-foreground"
          >
            Créer mon compte
          </Link>
        </div>
      </div>
    </div>
  );
}
