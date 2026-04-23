"use client";

import { use } from "react";
import Link from "next/link";
import { mockEvents, mockUsers, currentUser } from "@/lib/data";
import { UserAvatar } from "@/components/shared/user-avatar";
import { Button } from "@/components/ui/button";
import { CheckCircle, Home, ArrowRight, Send, Clock } from "lucide-react";

interface Props {
  params: Promise<{ id: string }>;
}

export default function ConfirmedPage({ params }: Props) {
  const { id } = use(params);
  const event = mockEvents.find((e) => e.id === id);

  const pastPartners = mockUsers
    .filter((u) => u.id !== currentUser.id)
    .slice(0, 4);

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col items-center px-6 py-10">
      {/* Success animation */}
      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-500/20">
        <CheckCircle className="h-10 w-10 text-emerald-600" />
      </div>

      <h1 className="mt-6 font-heading text-2xl font-extrabold">
        Inscription confirmée!
      </h1>
      <p className="mt-2 text-center text-muted-foreground">
        {event
          ? `On se voit à ${event.neighborhood} le ${new Date(event.date).toLocaleDateString("fr-CA", { weekday: "long", day: "numeric", month: "long" })}!`
          : "On se voit bientôt sur le parcours!"}
      </p>

      {/* Invite past partners */}
      {pastPartners.length > 0 && (
        <div className="mt-10 w-full max-w-md">
          <h2 className="font-heading text-lg font-bold">
            Invite tes anciens partenaires!
          </h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Tu as déjà couru avec ces personnes — invite-les à rejoindre
            l&apos;événement!
          </p>

          <div className="mt-4 space-y-3">
            {pastPartners.map((u) => (
              <div
                key={u.id}
                className="flex items-center gap-3 rounded-xl border bg-card p-3"
              >
                <UserAvatar
                  photoUrl={u.photoUrl}
                  firstName={u.firstName}
                  lastName={u.lastName}
                  size="md"
                />
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{u.firstName}</p>
                  <p className="truncate text-xs text-muted-foreground">
                    {u.totalActivities} activités
                  </p>
                </div>
                <Button size="sm" variant="outline" className="gap-1.5">
                  <Send className="h-3.5 w-3.5" />
                  Inviter
                </Button>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Action buttons */}
      <div className="mt-10 flex w-full max-w-md flex-col gap-3">
        {event && (
          <Link
            href={`/events/${id}/waiting`}
            className="inline-flex w-full items-center justify-center gap-2 rounded-md bg-primary px-6 py-3 text-sm font-bold text-primary-foreground hover:bg-primary/90"
          >
            <Clock className="h-4 w-4" />
            Salle d&apos;attente
          </Link>
        )}
        <Link
          href="/"
          className="inline-flex w-full items-center justify-center gap-2 rounded-md border border-border px-6 py-3 text-sm font-bold hover:bg-accent"
        >
          <Home className="h-4 w-4" />
          Retour à l&apos;accueil
        </Link>
        {event && (
          <Link
            href={`/events/${id}`}
            className="inline-flex w-full items-center justify-center gap-2 rounded-md border border-border px-6 py-3 text-sm font-bold hover:bg-accent"
          >
            Voir la fiche de l&apos;événement
            <ArrowRight className="h-4 w-4" />
          </Link>
        )}
      </div>
    </div>
  );
}
