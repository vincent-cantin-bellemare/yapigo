"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import { ChevronDown } from "lucide-react";
import { AppBar } from "@/components/shared/app-bar";

const faqs = [
  {
    q: "C'est quoi Run Date?",
    a: "Run Date c'est une app sociale sportive qui te jumelle avec d'autres personnes pour bouger ensemble. On mise sur le sport comme prétexte social — pas de pression, pas de compétition, juste du fun!",
  },
  {
    q: "Comment ça marche la mise en groupe?",
    a: "Tu t'inscris à une activité et notre algorithme te place dans un sous-groupe de 4-6 personnes en fonction de ton niveau, ton âge, tes intérêts et ton quartier. Le but : que tu te retrouves avec des gens qui te ressemblent!",
  },
  {
    q: "C'est quoi un point de départ?",
    a: "C'est le lieu de rencontre où ton sous-groupe se rejoint avant l'activité. Chaque sous-groupe a son propre point de départ dans le même quartier pour garder ça intime.",
  },
  {
    q: "C'est quoi le Ravito Smoothie?",
    a: "C'est le moment social après l'activité! Tout le monde se rejoint dans un café ou resto partenaire pour jaser, prendre un smoothie ou un café. C'est souvent là que les vraies connexions se créent!",
  },
  {
    q: "Comment marchent les sous-groupes?",
    a: "Chaque activité regroupe entre 20-60 personnes, divisées en sous-groupes de 4-6. Chaque sous-groupe a son propre point de départ et avance à son rythme. Après l'activité, tous les sous-groupes se rejoignent au Ravito Smoothie!",
  },
  {
    q: "C'est quoi un Organisateur?",
    a: "L'Organisateur c'est la personne ressource sur le terrain. Il accueille les participants, s'assure que tout le monde est à l'aise, gère le déroulement de l'activité et anime le Ravito Smoothie. C'est un bénévole passionné de la communauté!",
  },
  {
    q: "C'est quoi le système de badges?",
    a: "Plus tu participes, plus tu débloques des badges! Voici les niveaux :\n\n🌱 Rookie — 0 activité\n🏃 Jogger — 1 activité\n⚡ Pacer — 3 activités\n🔥 Strider — 5 activités\n👟 Racer — 10 activités\n🏅 Marathoner — 20 activités\n🦄 Ultrarunner — 50 activités\n👑 Legend — 100 activités",
  },
  {
    q: "Est-ce que je peux choisir les membres de mon groupe?",
    a: "Non, la magie de Run Date c'est justement la surprise! Notre algorithme fait le travail pour te matcher avec les bonnes personnes. C'est comme ça qu'on crée de vraies nouvelles connexions!",
  },
  {
    q: "C'est quoi les différents niveaux d'intensité?",
    a: "On a cinq niveaux pour que tout le monde trouve sa place :\n\n🐢 Chill — Marche tranquille, 6:30+/km\n🚶 Relax — Marche rapide / jog léger, 6:00-6:30/km\n🏃 Modéré — Jogging confortable, 5:30-6:00/km\n🔥 Intense — Course soutenue, 5:00-5:30/km\n⚡ Beast — Course rapide, < 5:00/km",
  },
  {
    q: "Est-ce gratuit?",
    a: "L'inscription et la participation de base sont gratuites. Certaines activités spéciales ou premium peuvent avoir un coût pour couvrir les frais (lieu, matériel, etc.). Le prix est toujours affiché clairement avant l'inscription.",
  },
  {
    q: "Comment signaler un comportement inapproprié?",
    a: "Dans le chat de groupe, tu peux signaler un message ou un membre directement. Tu peux aussi nous contacter via la section Aide. On prend la sécurité de la communauté très au sérieux et chaque signalement est traité rapidement.",
  },
];

export default function FaqPage() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <div className="min-h-screen bg-background">
      <AppBar title="FAQ" backHref="/profile/help" />

      <div className="mx-auto max-w-lg px-5">
        <div className="divide-y divide-border rounded-2xl border border-border">
          {faqs.map((faq, i) => (
            <div key={i}>
              <button
                onClick={() => setOpenIndex(openIndex === i ? null : i)}
                className="flex w-full items-center gap-3 px-4 py-3.5 text-left"
              >
                <span className="flex-1 text-[15px] font-semibold">
                  {faq.q}
                </span>
                <ChevronDown
                  className={cn(
                    "h-5 w-5 shrink-0 text-muted-foreground transition-transform duration-200",
                    openIndex === i && "rotate-180",
                  )}
                />
              </button>
              {openIndex === i && (
                <div className="px-4 pb-4">
                  <p className="whitespace-pre-line text-sm leading-relaxed text-muted-foreground">
                    {faq.a}
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
