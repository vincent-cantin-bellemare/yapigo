"use client";

import { useState, useRef, useCallback, useEffect } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import { PersonStanding, Users, Coffee } from "lucide-react";

const pages = [
  {
    Icon: PersonStanding,
    title: "Choisis ton quartier",
    subtitle:
      "Plateau, Mile-End, Griffintown...\nTrouve une course près de chez toi et découvre qui court dans ton coin!",
    bg: "from-blue-500/20 to-cyan-500/20",
  },
  {
    Icon: Users,
    title: "Cours avec des nouvelles personnes",
    subtitle:
      "Pas de jumelage — on court tous ensemble, chacun à son rythme.\nOn se retrouve tous au même point à l'arrivée!",
    bg: "from-violet-500/20 to-pink-500/20",
  },
  {
    Icon: Coffee,
    title: "L'Apéro Ravito",
    subtitle:
      "Après la course, on se retrouve dans un café pour mieux se connaître.\nC'est là que la magie opère!",
    bg: "from-amber-500/20 to-orange-500/20",
  },
];

export default function WelcomePage() {
  const { isLoggedIn, login } = useAuth();
  const router = useRouter();
  const [current, setCurrent] = useState(0);
  const scrollRef = useRef<HTMLDivElement>(null);
  const isLast = current === pages.length - 1;

  useEffect(() => {
    if (isLoggedIn) router.replace("/");
  }, [isLoggedIn, router]);

  const handleScroll = useCallback(() => {
    const el = scrollRef.current;
    if (!el) return;
    const idx = Math.round(el.scrollLeft / el.clientWidth);
    setCurrent(idx);
  }, []);

  const goNext = () => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollTo({
      left: (current + 1) * el.clientWidth,
      behavior: "smooth",
    });
  };

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.addEventListener("scroll", handleScroll, { passive: true });
    return () => el.removeEventListener("scroll", handleScroll);
  }, [handleScroll]);

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Header */}
      <div className="flex items-center px-5 pt-6 pb-2">
        <div className="w-14" />
        <div className="flex-1 flex justify-center">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/logo_rundate.png"
            alt="Run Date"
            className="h-14 object-contain dark:hidden"
          />
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/logo_rundate_white.png"
            alt="Run Date"
            className="hidden h-14 object-contain dark:block"
          />
        </div>
        <Link
          href="/welcome/events"
          className="w-14 text-right text-[15px] text-muted-foreground hover:text-foreground"
        >
          Passer
        </Link>
      </div>

      {/* Carousel */}
      <div className="flex flex-1 flex-col justify-center overflow-hidden">
        <div
          ref={scrollRef}
          className="flex snap-x snap-mandatory overflow-x-auto scrollbar-none"
          style={{ scrollSnapType: "x mandatory" }}
        >
          {pages.map((page, i) => (
            <div
              key={i}
              className="flex w-full shrink-0 snap-center flex-col items-center px-10"
            >
              <div
                className={cn(
                  "flex h-44 w-44 items-center justify-center rounded-3xl bg-gradient-to-br",
                  page.bg,
                )}
              >
                <page.Icon className="h-20 w-20 text-primary" strokeWidth={1.5} />
              </div>

              <h2 className="mt-8 text-center font-heading text-2xl font-extrabold leading-tight">
                {page.title}
              </h2>
              <p className="mt-4 max-w-sm text-center text-base leading-relaxed text-muted-foreground whitespace-pre-line">
                {page.subtitle}
              </p>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom section: dots + buttons + demo */}
      <div className="mx-auto w-full max-w-lg px-6 pb-6 pt-4 space-y-4">
        {/* Dots */}
        <div className="flex items-center justify-center gap-3">
          {pages.map((_, i) => (
            <div
              key={i}
              className={cn(
                "h-2 w-2 rounded-full transition-all",
                i === current
                  ? "w-5 bg-primary"
                  : "bg-muted-foreground/25",
              )}
            />
          ))}
        </div>

        {/* Buttons */}
        {isLast ? (
          <div className="space-y-2">
            <Link
              href="/welcome/events"
              className="flex w-full items-center justify-center rounded-xl bg-primary py-4 text-base font-bold text-primary-foreground"
            >
              Découvrir les événements
            </Link>
            <Link
              href="/welcome/signup"
              className="flex w-full items-center justify-center rounded-xl border border-primary py-4 text-base font-bold text-primary"
            >
              Créer mon compte
            </Link>
          </div>
        ) : (
          <button
            onClick={goNext}
            className="flex w-full items-center justify-center rounded-xl bg-primary py-4 text-base font-bold text-primary-foreground"
          >
            Suivant
          </button>
        )}

        {/* Demo toggle row */}
        <div className="flex items-center justify-center gap-2 rounded-full bg-muted/60 px-4 py-2">
          <span className="rounded bg-amber-500 px-1.5 py-0.5 text-[10px] font-extrabold tracking-wider text-white">
            DEMO
          </span>
          <span className="text-sm text-muted-foreground">Non connecté</span>
          <button
            onClick={login}
            className="ml-1 rounded-full bg-primary px-3 py-1 text-xs font-semibold text-primary-foreground"
          >
            Se connecter
          </button>
        </div>
      </div>
    </div>
  );
}
