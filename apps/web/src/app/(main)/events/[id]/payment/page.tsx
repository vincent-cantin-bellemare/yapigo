"use client";

import React, { useState, use } from "react";
import { useRouter } from "next/navigation";
import { mockEvents } from "@/lib/data";
import {
  EventCategory,
  IntensityLevel,
  getPriceLabel,
} from "@/lib/types";
import { Button } from "@/components/ui/button";
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerDescription,
  DrawerFooter,
  DrawerClose,
} from "@/components/ui/drawer";
import { cn } from "@/lib/utils";
import {
  ArrowLeft,
  MapPin,
  CalendarDays,
  Zap,
  ShieldCheck,
  Lock,
  CreditCard,
  Loader2,
  X,
} from "lucide-react";

interface Props {
  params: Promise<{ id: string }>;
}

export default function PaymentPage({ params }: Props) {
  const { id } = use(params);
  const router = useRouter();
  const event = mockEvents.find((e) => e.id === id);

  const [accepted, setAccepted] = useState(false);
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [processing, setProcessing] = useState(false);

  if (!event) {
    router.replace("/events");
    return null;
  }

  const cat = EventCategory[event.category];
  const intensity = IntensityLevel[event.intensityLevel];
  const priceLabel = getPriceLabel(event);
  const eventDate = new Date(event.date);

  const handlePay = () => {
    setDrawerOpen(true);
  };

  const handleConfirmPayment = () => {
    setProcessing(true);
    setTimeout(() => {
      setProcessing(false);
      setDrawerOpen(false);
      router.push(`/events/${id}/payment/confirmed`);
    }, 2000);
  };

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col px-6 py-6">
      <div className="flex items-center">
        <button
          onClick={() => router.back()}
          className="rounded-lg p-2 hover:bg-accent"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="flex-1 text-center font-heading text-lg font-bold">
          Paiement
        </h1>
        <div className="w-9" />
      </div>

      <div className="mt-6 space-y-4">
        <div className="rounded-2xl border bg-card p-5 shadow-sm">
          <h2 className="font-heading text-base font-bold">Résumé</h2>
          <div className="mt-3 space-y-2.5 text-sm">
            <div className="flex items-center gap-2.5">
              <span className="text-lg">{cat.emoji}</span>
              <span>{cat.label}</span>
            </div>
            <div className="flex items-center gap-2.5 text-muted-foreground">
              <MapPin className="h-4 w-4 shrink-0" />
              <span>{event.neighborhood}, {event.city}</span>
            </div>
            <div className="flex items-center gap-2.5 text-muted-foreground">
              <CalendarDays className="h-4 w-4 shrink-0" />
              <span>
                {eventDate.toLocaleDateString("fr-CA", {
                  weekday: "long",
                  day: "numeric",
                  month: "long",
                })}{" "}
                à{" "}
                {eventDate.toLocaleTimeString("fr-CA", {
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </span>
            </div>
            <div className="flex items-center gap-2.5 text-muted-foreground">
              <Zap className="h-4 w-4 shrink-0" />
              <span>
                {intensity.emoji} {intensity.label}
              </span>
            </div>
            <div className="flex items-center justify-between border-t pt-3">
              <span className="font-semibold">Total</span>
              <span className="font-heading text-lg font-bold text-primary">
                {priceLabel}
              </span>
            </div>
          </div>
        </div>

        <div className="rounded-2xl border bg-card p-5 shadow-sm">
          <h2 className="font-heading text-base font-bold">
            Politique d&apos;annulation
          </h2>
          <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
            Annulation gratuite 48h avant. Remboursement de 50% entre 24h et
            48h. Aucun remboursement moins de 24h avant l&apos;activité.
          </p>
        </div>

        <div className="flex items-start gap-3 rounded-2xl border border-emerald-200 bg-emerald-50 p-4 dark:border-emerald-500/20 dark:bg-emerald-500/10">
          <ShieldCheck className="mt-0.5 h-5 w-5 shrink-0 text-emerald-600" />
          <p className="text-sm leading-relaxed text-emerald-800 dark:text-emerald-300">
            Paiement sécurisé par Stripe. Tes informations bancaires ne sont
            jamais stockées sur nos serveurs.
          </p>
        </div>
      </div>

      <div className="mt-auto space-y-4 pt-8">
        <label className="flex cursor-pointer items-start gap-3">
          <input
            type="checkbox"
            checked={accepted}
            onChange={(e) => setAccepted(e.target.checked)}
            className="mt-1 h-4 w-4 shrink-0 rounded border-border accent-primary"
          />
          <span className="text-sm text-muted-foreground">
            J&apos;accepte les conditions d&apos;annulation et de
            remboursement
          </span>
        </label>

        <Button
          onClick={handlePay}
          disabled={!accepted}
          className="w-full py-6 text-base font-bold"
          size="lg"
        >
          <Lock className="mr-2 h-4 w-4" />
          Payer {priceLabel}
        </Button>
      </div>

      <Drawer open={drawerOpen} onOpenChange={setDrawerOpen}>
        <DrawerContent>
          <DrawerHeader className="relative">
            <DrawerClose asChild>
              <button className="absolute right-4 top-4 rounded-lg p-1 hover:bg-accent">
                <X className="h-5 w-5" />
              </button>
            </DrawerClose>
            <DrawerTitle className="text-lg font-bold">
              Paiement sécurisé
            </DrawerTitle>
            <DrawerDescription>Confirme ton paiement</DrawerDescription>
          </DrawerHeader>

          <div className="space-y-4 px-4">
            <div className="flex items-center gap-3 rounded-xl border bg-muted/50 p-4">
              <CreditCard className="h-6 w-6 text-muted-foreground" />
              <div className="flex-1">
                <p className="text-sm font-semibold">
                  •••• •••• •••• 4242
                </p>
                <p className="text-xs text-muted-foreground">Exp. 12/28</p>
              </div>
            </div>

            <div className="flex items-center justify-between rounded-xl border p-4">
              <span className="text-sm text-muted-foreground">Montant</span>
              <span className="font-heading text-lg font-bold text-primary">
                {priceLabel}
              </span>
            </div>
          </div>

          <DrawerFooter>
            <Button
              onClick={handleConfirmPayment}
              disabled={processing}
              className="w-full py-5 text-base font-bold"
              size="lg"
            >
              {processing ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Traitement…
                </>
              ) : (
                "Confirmer le paiement"
              )}
            </Button>
            <DrawerClose asChild>
              <Button
                variant="ghost"
                className="w-full"
                disabled={processing}
              >
                Annuler
              </Button>
            </DrawerClose>
          </DrawerFooter>
        </DrawerContent>
      </Drawer>
    </div>
  );
}
