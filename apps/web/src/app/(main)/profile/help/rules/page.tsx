"use client";

import Link from "next/link";
import { ArrowLeft } from "lucide-react";

const rules = [
  {
    emoji: "⏰",
    title: "Ponctualité",
    body: "On attend maximum 10 minutes après l'heure prévue. Arrive à l'heure pour ne pas retarder ton groupe! Si tu as un empêchement, préviens dans le chat de groupe.",
  },
  {
    emoji: "👥",
    title: "Personne seul à la queue",
    body: "On ne laisse jamais quelqu'un seul à l'arrière. Si tu vois quelqu'un qui a de la difficulté, ralentis ou accompagne-le. L'esprit d'équipe, c'est la base!",
  },
  {
    emoji: "🔄",
    title: "Les rapides font des loops",
    body: "T'es plus vite que le groupe? Parfait! Fais des allers-retours pour encourager les autres au lieu de foncer tout seul devant. Ça garde le groupe uni!",
  },
  {
    emoji: "⚡",
    title: "Respect du niveau annoncé",
    body: "Le niveau d'intensité affiché dans l'activité est là pour une raison. Choisis le niveau qui te correspond vraiment pour que tout le monde passe un bon moment.",
  },
  {
    emoji: "❤️",
    title: "Bienveillance",
    body: "Tout le monde est bienvenu, peu importe le niveau, l'âge ou l'expérience. On encourage, on motive, on ne juge pas. Run Date c'est zéro pression!",
  },
  {
    emoji: "☕",
    title: "Ravito Smoothie",
    body: "Le café après, c'est pas optionnel! C'est le moment de jaser, de connaître ton groupe et de créer des liens. Reste au moins 15-20 minutes au Ravito.",
  },
  {
    emoji: "🛡️",
    title: "Sécurité",
    body: "On bouge dans des endroits éclairés et sécuritaires. Suis les consignes de l'Organisateur, reste avec ton groupe et signale tout problème immédiatement.",
  },
  {
    emoji: "🤝",
    title: "Respect des autres",
    body: "On est là pour se rencontrer dans le respect. Aucune forme de harcèlement, discrimination ou comportement inapproprié ne sera tolérée. En cas de problème, signale-le immédiatement.",
  },
];

export default function RulesPage() {
  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="flex items-center gap-3 px-5 pt-6 pb-4">
        <Link href="/profile/help" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="font-heading text-lg font-bold">
          Règles de la communauté
        </h1>
      </div>

      <div className="mx-auto max-w-lg space-y-3 px-5">
        {rules.map((rule, i) => (
          <div
            key={i}
            className="rounded-2xl border border-border p-4"
          >
            <div className="flex items-center gap-3">
              <span className="text-2xl">{rule.emoji}</span>
              <h2 className="font-heading text-base font-bold">
                {rule.title}
              </h2>
            </div>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
              {rule.body}
            </p>
          </div>
        ))}
      </div>
    </div>
  );
}
