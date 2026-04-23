"use client";

import { use, useMemo } from "react";
import Link from "next/link";
import { mockEvents } from "@/lib/data";
import { EventCategory, getPriceLabel } from "@/lib/types";
import { Button } from "@/components/ui/button";
import { CheckCircle, ArrowRight, Info } from "lucide-react";

function generateConfirmationCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 8; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

interface Props {
  params: Promise<{ id: string }>;
}

export default function PaymentConfirmedPage({ params }: Props) {
  const { id } = use(params);
  const event = mockEvents.find((e) => e.id === id);
  const confirmationCode = useMemo(() => generateConfirmationCode(), []);

  const cat = event ? EventCategory[event.category] : null;
  const priceLabel = event ? getPriceLabel(event) : "";

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col items-center px-6 py-10">
      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-500/20">
        <CheckCircle className="h-10 w-10 text-emerald-600" />
      </div>

      <h1 className="mt-6 font-heading text-2xl font-extrabold">
        Paiement confirmé!
      </h1>
      <p className="mt-2 text-center text-muted-foreground">
        Ton inscription sera finalisée après les prochaines étapes
      </p>

      {event && (
        <div className="mt-8 w-full rounded-2xl border bg-card p-5 shadow-sm">
          <div className="space-y-3 text-sm">
            <div className="flex justify-between">
              <span className="text-muted-foreground">Activité</span>
              <span className="font-semibold">
                {cat?.emoji} {cat?.label}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Lieu</span>
              <span className="font-semibold">
                {event.neighborhood}, {event.city}
              </span>
            </div>
            <div className="flex justify-between border-t pt-3">
              <span className="text-muted-foreground">Montant</span>
              <span className="font-heading font-bold text-primary">
                {priceLabel}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Confirmation</span>
              <span className="font-mono text-sm font-bold tracking-wider">
                {confirmationCode}
              </span>
            </div>
          </div>
        </div>
      )}

      <div className="mt-6 flex w-full items-start gap-3 rounded-2xl border border-amber-200 bg-amber-50 p-4 dark:border-amber-500/20 dark:bg-amber-500/10">
        <Info className="mt-0.5 h-5 w-5 shrink-0 text-amber-600" />
        <p className="text-sm leading-relaxed text-amber-800 dark:text-amber-300">
          Annulation gratuite 48h avant. Remboursement de 50% entre 24h et
          48h. Aucun remboursement moins de 24h avant l&apos;activité.
        </p>
      </div>

      <div className="mt-10 flex w-full flex-col gap-3">
        <Link href={`/events/${id}/apply`}>
          <Button className="w-full py-6 text-base font-bold" size="lg">
            Continuer l&apos;inscription
            <ArrowRight className="ml-2 h-5 w-5" />
          </Button>
        </Link>
      </div>
    </div>
  );
}
