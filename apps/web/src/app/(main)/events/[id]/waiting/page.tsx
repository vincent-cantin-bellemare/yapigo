"use client";

import React, { useState, useEffect, use, useCallback } from "react";
import Link from "next/link";
import { mockEvents } from "@/lib/data";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ArrowLeft, Target } from "lucide-react";
import { useRouter } from "next/navigation";

const questions = [
  {
    id: "q1",
    category: "Intensité",
    text: "À quel rythme tu bouges en général?",
    options: ["Balade", "Tranquille", "Modérée", "Rapide", "Intense"],
  },
  {
    id: "q2",
    category: "Motivation",
    text: "Tu fais du sport surtout pour...?",
    options: [
      "Te remettre en forme",
      "Rencontrer du monde",
      "Le café ou l'apéro après",
      "Un défi perso",
    ],
  },
  {
    id: "q3",
    category: "Musique",
    text: "Ambiance sonore pour ta prochaine sortie?",
    options: [
      "Quelque chose d'épique (rock / hip-hop)",
      "Pop feel-good",
      "Électro / house",
      "Podcast ou silence, je focus",
    ],
  },
  {
    id: "q4",
    category: "Flirt",
    text: "Ton move quand t'es à bout de souffle devant quelqu'un de cute?",
    options: [
      "Je souris et je ralentis un peu, zen",
      "Je fais semblant d'être en échauffement",
      "Je dis un joke sur mon souffle court",
      "Je change de voie, crise d'anxiété 😅",
    ],
  },
  {
    id: "q5",
    category: "Humeur",
    text: "Comment tu te sens avant une activité avec des inconnus?",
    options: [
      "Pumped!",
      "Un peu nerveux mais excité",
      "Chill total",
      "J'ai besoin de café d'abord",
    ],
  },
  {
    id: "q6",
    category: "Social",
    text: "Après la sortie, tu veux surtout...?",
    options: [
      "Un smoothie en groupe",
      "Échanger les Insta",
      "Rentrer et binge-watcher",
      "Planifier la prochaine sortie",
    ],
  },
  {
    id: "q7",
    category: "Style",
    text: "En un mot, ton vibe sportif c'est...?",
    options: [
      "Compétitif mais fair-play",
      "Social et relaxe",
      "Aventurier",
      "Zen et mindful",
    ],
  },
];

const tips = [
  "Hydrate-toi avant! 💧",
  "Étire-toi le matin — tes genoux te remercieront 🧘",
  "Arrive 5 min avant au point de départ 📍",
  "Le rythme du groupe, c'est le rythme de jasette 💬",
  "85% des participants Run Date reviennent la semaine suivante 🔁",
];

interface Props {
  params: Promise<{ id: string }>;
}

export default function WaitingPage({ params }: Props) {
  const { id } = use(params);
  const router = useRouter();
  const event = mockEvents.find((e) => e.id === id);

  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [currentTip, setCurrentTip] = useState(0);
  const [pulseVisible, setPulseVisible] = useState(true);

  const answeredCount = Object.keys(answers).length;
  const profileCompletion = Math.min(100, 60 + answeredCount * 5);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentTip((prev) => (prev + 1) % tips.length);
    }, 10000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setPulseVisible((prev) => !prev);
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleAnswer = useCallback(
    (option: string) => {
      const q = questions[currentQuestion];
      setAnswers((prev) => ({ ...prev, [q.id]: option }));
      setTimeout(() => {
        if (currentQuestion < questions.length - 1) {
          setCurrentQuestion((prev) => prev + 1);
        }
      }, 300);
    },
    [currentQuestion],
  );

  if (!event) {
    router.replace("/events");
    return null;
  }

  const q = questions[currentQuestion];
  const allAnswered = currentQuestion >= questions.length - 1 && answers[q.id];

  const circumference = 2 * Math.PI * 54;
  const offset = circumference - (profileCompletion / 100) * circumference;

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col">
      <div className="shrink-0 px-4 pt-4">
        <div className="flex items-center">
          <button
            onClick={() => router.back()}
            className="rounded-lg p-2 hover:bg-accent"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center font-heading text-lg font-bold">
            En attente
          </h1>
          <div className="w-9" />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-6 pb-8 pt-6">
        <div className="flex items-center justify-center gap-2">
          <div
            className={cn(
              "h-3 w-3 rounded-full bg-emerald-500 transition-opacity duration-500",
              pulseVisible ? "opacity-100" : "opacity-30",
            )}
          />
          <h2 className="font-heading text-xl font-bold">
            En attente de ton groupe…
          </h2>
        </div>

        <div className="mt-8 flex justify-center">
          <div className="relative flex h-36 w-36 items-center justify-center">
            <svg className="absolute inset-0 -rotate-90" viewBox="0 0 120 120">
              <circle
                cx="60"
                cy="60"
                r="54"
                fill="none"
                stroke="currentColor"
                strokeWidth="6"
                className="text-muted"
              />
              <circle
                cx="60"
                cy="60"
                r="54"
                fill="none"
                stroke="currentColor"
                strokeWidth="6"
                strokeDasharray={circumference}
                strokeDashoffset={offset}
                strokeLinecap="round"
                className="text-primary transition-all duration-700"
              />
            </svg>
            <div className="text-center">
              <p className="font-heading text-3xl font-bold">
                {profileCompletion}%
              </p>
              <p className="text-xs text-muted-foreground">Profil</p>
            </div>
          </div>
        </div>

        {!allAnswered && (
          <div className="mt-8 space-y-4">
            <div className="rounded-2xl border bg-card p-5 shadow-sm">
              <div className="mb-3 flex items-center gap-2">
                <span className="rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-semibold text-primary">
                  {q.category}
                </span>
                <span className="text-xs text-muted-foreground">
                  {currentQuestion + 1}/{questions.length}
                </span>
              </div>
              <p className="font-heading text-base font-bold">{q.text}</p>
              <div className="mt-4 flex flex-wrap gap-2">
                {q.options.map((option) => {
                  const selected = answers[q.id] === option;
                  return (
                    <button
                      key={option}
                      onClick={() => handleAnswer(option)}
                      className={cn(
                        "rounded-full border px-4 py-2 text-sm font-semibold transition-all",
                        selected
                          ? "border-primary bg-primary/10 text-primary"
                          : "border-border hover:border-primary/30",
                      )}
                    >
                      {option}
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {allAnswered && (
          <div className="mt-8 rounded-2xl border bg-emerald-50 p-5 text-center dark:bg-emerald-500/10">
            <p className="font-heading text-base font-bold text-emerald-700 dark:text-emerald-300">
              Tu as répondu à toutes les questions! 🎉
            </p>
            <p className="mt-1 text-sm text-emerald-600 dark:text-emerald-400">
              Ton profil est plus complet maintenant
            </p>
          </div>
        )}

        <div className="mt-6 rounded-xl bg-muted/50 p-4 text-center">
          <p
            key={currentTip}
            className="animate-in fade-in text-sm text-muted-foreground"
          >
            {tips[currentTip]}
          </p>
        </div>
      </div>

      <div className="shrink-0 px-6 pb-6 pt-2">
        <Link href={`/events/${id}/match-reveal`}>
          <Button className="w-full py-5 text-base font-bold" size="lg">
            <Target className="mr-2 h-5 w-5" />
            Simuler la formation du groupe 🎯
          </Button>
        </Link>
      </div>
    </div>
  );
}
