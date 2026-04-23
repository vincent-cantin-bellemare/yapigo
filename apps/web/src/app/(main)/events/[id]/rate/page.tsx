"use client";

import React, { useState, use, useCallback } from "react";
import { useRouter } from "next/navigation";
import { mockEvents, mockUsers, currentUser } from "@/lib/data";
import { UserAvatar } from "@/components/shared/user-avatar";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
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
  Star,
  CheckCircle,
  AlertTriangle,
  Heart,
  X,
  Eye,
  EyeOff,
} from "lucide-react";

const groupMembers = mockUsers
  .filter((u) => u.id !== currentUser.id)
  .slice(0, 6);

const experienceRows = [
  { key: "activity", label: "L'activité" },
  { key: "group", label: "Groupe" },
  { key: "smoothie", label: "Ravito Smoothie" },
] as const;

interface Props {
  params: Promise<{ id: string }>;
}

function StarRating({
  value,
  onChange,
  size = "md",
}: {
  value: number;
  onChange: (v: number) => void;
  size?: "sm" | "md" | "lg";
}) {
  const sizeClass = size === "lg" ? "h-9 w-9" : size === "sm" ? "h-5 w-5" : "h-7 w-7";
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4, 5].map((star) => (
        <button key={star} onClick={() => onChange(star)} type="button">
          <Star
            className={cn(
              sizeClass,
              "transition-colors",
              star <= value
                ? "fill-amber-400 text-amber-400"
                : "text-muted-foreground/30",
            )}
          />
        </button>
      ))}
    </div>
  );
}

export default function RateEventPage({ params }: Props) {
  const { id } = use(params);
  const router = useRouter();
  const event = mockEvents.find((e) => e.id === id);

  const TOTAL_STEPS = 2 + groupMembers.length + 1; // event + experience + members + thank you
  const [step, setStep] = useState(0);

  const [eventRating, setEventRating] = useState(0);
  const [eventComment, setEventComment] = useState("");

  const [expRatings, setExpRatings] = useState<Record<string, number>>({});
  const [expComment, setExpComment] = useState("");

  const [memberRatings, setMemberRatings] = useState<Record<string, number>>(
    {},
  );
  const [memberComments, setMemberComments] = useState<
    Record<string, string>
  >({});
  const [memberVisibility, setMemberVisibility] = useState<
    Record<string, "public" | "private">
  >({});

  const [reportOpen, setReportOpen] = useState(false);
  const [reportTarget, setReportTarget] = useState<string | null>(null);

  const setExpRating = useCallback((key: string, val: number) => {
    setExpRatings((prev) => ({ ...prev, [key]: val }));
  }, []);

  const goNext = useCallback(() => {
    if (step < TOTAL_STEPS - 1) setStep(step + 1);
  }, [step, TOTAL_STEPS]);

  const goBack = useCallback(() => {
    if (step > 0) setStep(step - 1);
    else router.back();
  }, [step, router]);

  const canAdvance = (() => {
    if (step === 0) return eventRating > 0;
    if (step === 1) return Object.values(expRatings).some((v) => v > 0);
    if (step >= 2 && step < 2 + groupMembers.length) {
      const member = groupMembers[step - 2];
      return (memberRatings[member.id] ?? 0) > 0;
    }
    return true;
  })();

  const isMemberStep = step >= 2 && step < 2 + groupMembers.length;
  const isLastStep = step === TOTAL_STEPS - 1;

  if (!event) {
    router.replace("/events");
    return null;
  }

  return (
    <div className="flex min-h-[calc(100dvh-5rem)] flex-col">
      <div className="shrink-0 px-4 pt-4">
        <div className="flex items-center">
          <button onClick={goBack} className="rounded-lg p-2 hover:bg-accent">
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center font-heading text-lg font-bold">
            Évaluation
          </h1>
          <div className="w-9" />
        </div>

        {!isLastStep && (
          <div className="mt-3 space-y-2 px-2">
            <p className="text-sm font-semibold text-muted-foreground">
              Étape {step + 1}/{TOTAL_STEPS - 1}
            </p>
            <Progress
              value={((step + 1) / (TOTAL_STEPS - 1)) * 100}
              className="h-1"
            />
          </div>
        )}
      </div>

      <div className="flex-1 overflow-y-auto px-6 pb-8 pt-6">
        {step === 0 && (
          <div className="space-y-6">
            <div>
              <h2 className="font-heading text-2xl font-bold">
                Comment était cette activité?
              </h2>
              <p className="mt-1 text-sm text-muted-foreground">
                {event.neighborhood}
              </p>
            </div>
            <div className="flex justify-center">
              <StarRating
                value={eventRating}
                onChange={setEventRating}
                size="lg"
              />
            </div>
            <textarea
              value={eventComment}
              onChange={(e) => setEventComment(e.target.value)}
              placeholder="Un commentaire? (optionnel)"
              className="w-full resize-none rounded-xl border bg-card p-4 text-sm placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/30"
              rows={3}
            />
          </div>
        )}

        {step === 1 && (
          <div className="space-y-6">
            <div>
              <h2 className="font-heading text-2xl font-bold">
                L&apos;expérience
              </h2>
            </div>
            <div className="space-y-4">
              {experienceRows.map((row) => (
                <div
                  key={row.key}
                  className="flex items-center justify-between rounded-xl border bg-card px-4 py-3"
                >
                  <span className="text-sm font-semibold">{row.label}</span>
                  <StarRating
                    value={expRatings[row.key] ?? 0}
                    onChange={(v) => setExpRating(row.key, v)}
                    size="sm"
                  />
                </div>
              ))}
            </div>
            <textarea
              value={expComment}
              onChange={(e) => setExpComment(e.target.value)}
              placeholder="Un commentaire? (optionnel)"
              className="w-full resize-none rounded-xl border bg-card p-4 text-sm placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/30"
              rows={3}
            />
          </div>
        )}

        {isMemberStep && (() => {
          const member = groupMembers[step - 2];
          const visibility = memberVisibility[member.id] ?? "public";
          return (
            <div className="space-y-6">
              <div className="flex flex-col items-center gap-3">
                <UserAvatar
                  photoUrl={member.photoUrl}
                  firstName={member.firstName}
                  lastName={member.lastName}
                  size="xl"
                />
                <div className="text-center">
                  <p className="font-heading text-lg font-bold">
                    {member.firstName}
                  </p>
                  <p className="text-sm text-muted-foreground">
                    {member.age} ans
                  </p>
                </div>
              </div>

              <div className="flex justify-center">
                <StarRating
                  value={memberRatings[member.id] ?? 0}
                  onChange={(v) =>
                    setMemberRatings((prev) => ({
                      ...prev,
                      [member.id]: v,
                    }))
                  }
                  size="lg"
                />
              </div>

              <textarea
                value={memberComments[member.id] ?? ""}
                onChange={(e) =>
                  setMemberComments((prev) => ({
                    ...prev,
                    [member.id]: e.target.value,
                  }))
                }
                placeholder="Un commentaire? (optionnel)"
                className="w-full resize-none rounded-xl border bg-card p-4 text-sm placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/30"
                rows={3}
              />

              <div className="flex gap-2">
                <button
                  onClick={() =>
                    setMemberVisibility((prev) => ({
                      ...prev,
                      [member.id]: "public",
                    }))
                  }
                  className={cn(
                    "flex flex-1 items-center justify-center gap-2 rounded-xl border px-3 py-2.5 text-sm font-semibold transition-all",
                    visibility === "public"
                      ? "border-primary bg-primary/5 text-primary"
                      : "border-border text-muted-foreground",
                  )}
                >
                  <Eye className="h-4 w-4" />
                  Public
                </button>
                <button
                  onClick={() =>
                    setMemberVisibility((prev) => ({
                      ...prev,
                      [member.id]: "private",
                    }))
                  }
                  className={cn(
                    "flex flex-1 items-center justify-center gap-2 rounded-xl border px-3 py-2.5 text-sm font-semibold transition-all",
                    visibility === "private"
                      ? "border-primary bg-primary/5 text-primary"
                      : "border-border text-muted-foreground",
                  )}
                >
                  <EyeOff className="h-4 w-4" />
                  Privé
                </button>
              </div>

              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setReportTarget(member.id);
                    setReportOpen(true);
                  }}
                  className="flex flex-1 items-center justify-center gap-2 rounded-xl border border-red-200 px-3 py-2.5 text-sm font-semibold text-red-500 hover:bg-red-50 dark:border-red-500/30 dark:hover:bg-red-500/10"
                >
                  <AlertTriangle className="h-4 w-4" />
                  Signaler
                </button>
                <button className="flex flex-1 items-center justify-center gap-2 rounded-xl border border-pink-200 px-3 py-2.5 text-sm font-semibold text-pink-500 hover:bg-pink-50 dark:border-pink-500/30 dark:hover:bg-pink-500/10">
                  <Heart className="h-4 w-4" />
                  J&apos;aimerais te connaître 💌
                </button>
              </div>
            </div>
          );
        })()}

        {isLastStep && (
          <div className="flex flex-1 flex-col items-center justify-center py-12">
            <div className="flex h-20 w-20 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-500/20">
              <CheckCircle className="h-10 w-10 text-emerald-600" />
            </div>
            <h2 className="mt-6 font-heading text-2xl font-extrabold">
              Merci pour tes évaluations!
            </h2>
            <p className="mt-2 text-center text-muted-foreground">
              Tes retours aident la communauté à s&apos;améliorer
            </p>
          </div>
        )}
      </div>

      {!isLastStep && (
        <div className="shrink-0 px-6 pb-6 pt-2">
          <div className="flex gap-3">
            {isMemberStep && (
              <Button
                variant="outline"
                onClick={goNext}
                className="flex-1 py-5 text-base"
              >
                Passer
              </Button>
            )}
            <Button
              onClick={goNext}
              disabled={!canAdvance}
              className={cn(
                "py-5 text-base font-bold",
                isMemberStep ? "flex-1" : "w-full",
              )}
            >
              Suivant
            </Button>
          </div>
        </div>
      )}

      {isLastStep && (
        <div className="shrink-0 px-6 pb-6 pt-2">
          <Button
            onClick={() => router.push("/")}
            className="w-full py-5 text-base font-bold"
            size="lg"
          >
            Terminé
          </Button>
        </div>
      )}

      <Drawer open={reportOpen} onOpenChange={setReportOpen}>
        <DrawerContent>
          <DrawerHeader className="relative">
            <DrawerClose asChild>
              <button className="absolute right-4 top-4 rounded-lg p-1 hover:bg-accent">
                <X className="h-5 w-5" />
              </button>
            </DrawerClose>
            <DrawerTitle className="text-lg font-bold">
              Signaler un comportement
            </DrawerTitle>
            <DrawerDescription>
              {reportTarget &&
                `Signaler ${groupMembers.find((m) => m.id === reportTarget)?.firstName}`}
            </DrawerDescription>
          </DrawerHeader>
          <div className="space-y-2 px-4">
            {[
              "Comportement inapproprié",
              "Harcèlement",
              "Propos offensants",
              "Ne s'est pas présenté(e)",
              "Autre",
            ].map((reason) => (
              <button
                key={reason}
                onClick={() => {
                  setReportOpen(false);
                }}
                className="w-full rounded-xl border bg-card px-4 py-3 text-left text-sm font-semibold hover:bg-accent"
              >
                {reason}
              </button>
            ))}
          </div>
          <DrawerFooter>
            <DrawerClose asChild>
              <Button variant="ghost" className="w-full">
                Annuler
              </Button>
            </DrawerClose>
          </DrawerFooter>
        </DrawerContent>
      </Drawer>
    </div>
  );
}
