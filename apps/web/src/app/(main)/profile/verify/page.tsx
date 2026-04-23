"use client";

import { useState } from "react";
import Link from "next/link";
import { cn } from "@/lib/utils";
import {
  ArrowLeft,
  Camera,
  CalendarCheck,
  CheckCircle,
} from "lucide-react";

const slots = [
  "Lundi 10h00 - 10h15",
  "Lundi 14h00 - 14h15",
  "Mardi 11h00 - 11h15",
  "Mardi 16h00 - 16h15",
  "Mercredi 9h00 - 9h15",
  "Jeudi 13h00 - 13h15",
];

type VerifyState = "verified" | "picker" | "booked";

export default function VerifyPage() {
  const [state, setState] = useState<VerifyState>("picker");
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);

  const handleConfirm = () => {
    if (selectedSlot) setState("booked");
  };

  return (
    <div className="min-h-screen bg-background pb-32">
      <div className="flex items-center gap-3 px-5 pt-6 pb-4">
        <Link href="/profile" className="text-foreground">
          <ArrowLeft className="h-5 w-5" />
        </Link>
        <h1 className="font-heading text-lg font-bold">
          Vérifier mon compte
        </h1>
      </div>

      <div className="mx-auto max-w-lg px-5">
        {state === "verified" && (
          <div className="flex flex-col items-center py-16 text-center">
            <CheckCircle className="h-20 w-20 text-teal-500" />
            <h2 className="mt-5 font-heading text-xl font-extrabold">
              Ton compte est déjà vérifié!
            </h2>
            <p className="mt-2 text-muted-foreground">
              Tu as le badge vérifié sur ton profil.
            </p>
          </div>
        )}

        {state === "picker" && (
          <div className="rounded-2xl border border-border p-5">
            <div className="flex flex-col items-center text-center">
              <Camera className="h-14 w-14 text-primary" />
              <h2 className="mt-4 font-heading text-xl font-extrabold">
                Vérifie ton identité
              </h2>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                Choisis un créneau pour un appel FaceTime rapide (~2 min) avec
                un membre de l&apos;équipe. On vérifie juste que tu es bien la
                personne sur ta photo de profil!
              </p>
            </div>

            <div className="mt-6 space-y-2">
              {slots.map((slot) => (
                <button
                  key={slot}
                  onClick={() => setSelectedSlot(slot)}
                  className={cn(
                    "flex w-full items-center gap-3 rounded-xl border px-4 py-3 text-left transition-colors",
                    selectedSlot === slot
                      ? "border-primary bg-primary/5"
                      : "border-border hover:bg-accent/50",
                  )}
                >
                  <div
                    className={cn(
                      "flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2",
                      selectedSlot === slot
                        ? "border-primary bg-primary"
                        : "border-muted-foreground/30",
                    )}
                  >
                    {selectedSlot === slot && (
                      <div className="h-2 w-2 rounded-full bg-white" />
                    )}
                  </div>
                  <span className="text-[15px] font-semibold">{slot}</span>
                </button>
              ))}
            </div>

            <button
              onClick={handleConfirm}
              disabled={!selectedSlot}
              className={cn(
                "mt-6 w-full rounded-xl py-3.5 text-sm font-bold text-white transition-colors",
                selectedSlot
                  ? "bg-primary hover:bg-primary/90"
                  : "bg-muted-foreground/30 cursor-not-allowed",
              )}
            >
              Confirmer le créneau
            </button>
          </div>
        )}

        {state === "booked" && (
          <div className="flex flex-col items-center py-16 text-center">
            <CalendarCheck className="h-20 w-20 text-primary" />
            <h2 className="mt-5 font-heading text-xl font-extrabold">
              Rendez-vous confirmé!
            </h2>
            <p className="mt-3 text-[15px] font-semibold text-primary">
              {selectedSlot}
            </p>
            <p className="mt-2 text-muted-foreground">
              Tu recevras un lien FaceTime par notification.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
