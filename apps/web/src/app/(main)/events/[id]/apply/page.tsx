"use client";

import React, {
  useState,
  useRef,
  useCallback,
  useEffect,
  use,
} from "react";
import { useRouter } from "next/navigation";
import { mockEvents, mockUsers, currentUser } from "@/lib/data";
import {
  IntensityLevel,
  DistanceLabel,
  type IntensityLevelKey,
  type DistanceLabelKey,
  getPriceLabel,
} from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { cn } from "@/lib/utils";
import { ArrowLeft, Check, ChevronRight, Pencil } from "lucide-react";

const TOTAL_STEPS = 5;

const companionOptions = [
  {
    id: "dog",
    emoji: "🐕",
    title: "Mon toutou vient avec moi!",
    subtitle: "Ça va me donner des points supplémentaires",
  },
  {
    id: "mom",
    emoji: "👩‍🦳",
    title: "Ma mère! Elle veut me matcher",
    subtitle: "Elle va encourager tout le monde",
  },
  {
    id: "stroller",
    emoji: "👶",
    title: "Mon enfant dans la poussette!",
    subtitle: "Futur champion de course",
  },
  {
    id: "solo",
    emoji: "🏃",
    title: "Juste moi, c'est déjà assez",
    subtitle: "Loup solitaire assumé",
  },
] as const;

interface Props {
  params: Promise<{ id: string }>;
}

export default function ApplyWizardPage({ params }: Props) {
  const { id } = use(params);
  const router = useRouter();
  const event = mockEvents.find((e) => e.id === id);

  const scrollRef = useRef<HTMLDivElement>(null);
  const [currentStep, setCurrentStep] = useState(0);
  const [isAutoAdvancing, setIsAutoAdvancing] = useState(false);

  const [intensity, setIntensity] = useState<IntensityLevelKey | null>(null);
  const [distance, setDistance] = useState<DistanceLabelKey | null>(null);
  const [preferredUsers, setPreferredUsers] = useState<Set<string>>(
    new Set(),
  );
  const [companion, setCompanion] = useState<string | null>(null);

  const scrollToStep = useCallback(
    (step: number) => {
      const el = scrollRef.current;
      if (!el) return;
      el.scrollTo({ left: step * el.clientWidth, behavior: "smooth" });
      setCurrentStep(step);
    },
    [],
  );

  const goNext = useCallback(() => {
    if (currentStep < TOTAL_STEPS - 1) {
      scrollToStep(currentStep + 1);
    }
  }, [currentStep, scrollToStep]);

  const goBack = useCallback(() => {
    if (currentStep > 0) {
      scrollToStep(currentStep - 1);
    } else {
      router.back();
    }
  }, [currentStep, scrollToStep, router]);

  const selectAndAdvance = useCallback(
    (fn: () => void) => {
      if (isAutoAdvancing) return;
      fn();
      setIsAutoAdvancing(true);
      setTimeout(() => {
        goNext();
        setIsAutoAdvancing(false);
      }, 350);
    },
    [isAutoAdvancing, goNext],
  );

  const handleConfirm = useCallback(() => {
    router.push(`/events/${id}/apply/confirmed`);
  }, [router, id]);

  const togglePreferred = useCallback((userId: string) => {
    setPreferredUsers((prev) => {
      const next = new Set(prev);
      if (next.has(userId)) next.delete(userId);
      else next.add(userId);
      return next;
    });
  }, []);

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollLeft = 0;
  }, []);

  const showNextButton = currentStep === 2;
  const otherUsers = mockUsers.filter((u) => u.id !== currentUser.id);

  if (!event) {
    router.replace("/events");
    return null;
  }

  return (
    <div className="flex h-[calc(100dvh-5rem)] flex-col">
      {/* Header */}
      <div className="shrink-0 px-4 pt-4">
        <div className="flex items-center">
          <button onClick={goBack} className="rounded-lg p-2 hover:bg-accent">
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center font-heading text-lg font-bold">
            Inscription
          </h1>
          <div className="w-9" />
        </div>

        {/* Progress */}
        <div className="mt-3 space-y-2 px-2">
          <p className="text-sm font-semibold text-muted-foreground">
            Étape {currentStep + 1}/{TOTAL_STEPS}
          </p>
          <Progress
            value={((currentStep + 1) / TOTAL_STEPS) * 100}
            className="h-1"
          />
          <div className="flex justify-center gap-1.5">
            {Array.from({ length: TOTAL_STEPS }).map((_, i) => (
              <div
                key={i}
                className={cn(
                  "h-1.5 rounded-full transition-all duration-300",
                  i === currentStep
                    ? "w-4 bg-primary"
                    : "w-1.5 bg-muted-foreground/25",
                )}
              />
            ))}
          </div>
        </div>
      </div>

      {/* Swipeable steps */}
      <div
        ref={scrollRef}
        className="flex flex-1 snap-x snap-mandatory overflow-x-auto overflow-y-hidden scrollbar-none"
      >
        {/* Step 1: Intensity */}
        <StepPanel>
          <StepHeader
            title="Quel niveau d'intensité?"
            subtitle="On affichera tes compagnons de groupe — les autres inscrits à ton niveau"
          />
          <div className="space-y-3">
            {(
              Object.entries(IntensityLevel) as [
                IntensityLevelKey,
                (typeof IntensityLevel)[IntensityLevelKey],
              ][]
            ).map(([key, level]) => (
              <OptionCard
                key={key}
                selected={intensity === key}
                onTap={() =>
                  selectAndAdvance(() => setIntensity(key))
                }
              >
                <span className="text-2xl">{level.emoji}</span>
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{level.label}</p>
                  <p className="text-sm text-muted-foreground">
                    {level.description}
                  </p>
                </div>
              </OptionCard>
            ))}
          </div>
        </StepPanel>

        {/* Step 2: Distance */}
        <StepPanel>
          <StepHeader
            title="Quelle distance?"
            subtitle="Choisis ta distance idéale"
          />
          <div className="space-y-3">
            {(
              Object.entries(DistanceLabel) as [
                DistanceLabelKey,
                (typeof DistanceLabel)[DistanceLabelKey],
              ][]
            ).map(([key, dist]) => (
              <OptionCard
                key={key}
                selected={distance === key}
                onTap={() =>
                  selectAndAdvance(() => setDistance(key))
                }
              >
                <span className="text-2xl">{dist.emoji}</span>
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{dist.label}</p>
                  <p className="text-sm text-muted-foreground">
                    {dist.description}
                  </p>
                </div>
              </OptionCard>
            ))}
          </div>
        </StepPanel>

        {/* Step 3: Preferred participants */}
        <StepPanel>
          <StepHeader
            title="Avec qui tu voudrais bouger?"
            subtitle="Sélectionne les personnes avec qui tu aimerais être (optionnel)"
          />
          <div className="flex flex-wrap justify-center gap-3">
            {otherUsers.map((u) => {
              const selected = preferredUsers.has(u.id);
              return (
                <button
                  key={u.id}
                  onClick={() => togglePreferred(u.id)}
                  className={cn(
                    "flex flex-col items-center rounded-xl border-2 p-2.5 transition-all",
                    selected
                      ? "border-primary bg-primary/5"
                      : "border-transparent bg-card shadow-sm",
                  )}
                >
                  <div className="relative">
                    <UserAvatar
                      photoUrl={u.photoUrl}
                      firstName={u.firstName}
                      lastName={u.lastName}
                      size="lg"
                    />
                    {selected && (
                      <div className="absolute -right-1 -top-1 flex h-5 w-5 items-center justify-center rounded-full bg-primary text-white">
                        <Check className="h-3 w-3" />
                      </div>
                    )}
                  </div>
                  <span className="mt-2 w-20 truncate text-center text-sm font-semibold">
                    {u.firstName}
                  </span>
                </button>
              );
            })}
          </div>
        </StepPanel>

        {/* Step 4: Companion */}
        <StepPanel>
          <StepHeader
            title="Tu amènes quelqu'un? 🐕"
            subtitle="On est curieux... tu viens avec qui?"
          />
          <div className="space-y-3">
            {companionOptions.map((opt) => (
              <OptionCard
                key={opt.id}
                selected={companion === opt.id}
                onTap={() =>
                  selectAndAdvance(() => setCompanion(opt.id))
                }
              >
                <span className="text-2xl">{opt.emoji}</span>
                <div className="min-w-0 flex-1">
                  <p className="font-semibold">{opt.title}</p>
                  <p className="text-sm text-muted-foreground">
                    {opt.subtitle}
                  </p>
                </div>
              </OptionCard>
            ))}
          </div>
        </StepPanel>

        {/* Step 5: Confirmation */}
        <StepPanel>
          <StepHeader title="T'es prêt(e)!" />
          <div className="space-y-1 rounded-2xl border bg-card p-5 shadow-sm">
            {event && (
              <SummaryRow
                label="Événement"
                value={`${event.neighborhood} · ${new Date(event.date).getDate()}/${new Date(event.date).getMonth() + 1}`}
              />
            )}
            <SummaryRow
              label="Intensité"
              value={
                intensity
                  ? `${IntensityLevel[intensity].emoji} ${IntensityLevel[intensity].label}`
                  : "—"
              }
              onEdit={() => scrollToStep(0)}
            />
            <SummaryRow
              label="Distance"
              value={
                distance
                  ? `${DistanceLabel[distance].emoji} ${DistanceLabel[distance].label}`
                  : "—"
              }
              onEdit={() => scrollToStep(1)}
            />
            <SummaryRow
              label="Préférences"
              value={
                preferredUsers.size > 0
                  ? mockUsers
                      .filter((u) => preferredUsers.has(u.id))
                      .map((u) => u.firstName)
                      .join(", ")
                  : "Aucune préférence"
              }
              onEdit={() => scrollToStep(2)}
            />
            <SummaryRow
              label="Compagnon"
              value={
                companion === "dog"
                  ? "Mon toutou 🐕"
                  : companion === "mom"
                    ? "Ma mère 👩‍🦳"
                    : companion === "stroller"
                      ? "Bébé en poussette 👶"
                      : "Solo 🏃"
              }
              onEdit={() => scrollToStep(3)}
            />

            <div className="!mt-3 flex items-start gap-2 rounded-xl bg-teal/10 p-3 text-sm">
              <span>🏃</span>
              <p className="text-foreground/80">
                Retrouve-toi sur place avec tout le monde — des
                sous-groupes se forment naturellement selon les rythmes
              </p>
            </div>
          </div>

          <Button
            onClick={handleConfirm}
            className="mt-6 w-full py-6 text-base font-bold"
            size="lg"
          >
            Confirmer mon inscription
          </Button>
          <p className="mt-3 text-center text-sm text-muted-foreground">
            Tu es inscrit(e)! Rendez-vous sur place.
          </p>
        </StepPanel>
      </div>

      {/* Bottom button (only for step 3 - preferred participants) */}
      {showNextButton && (
        <div className="shrink-0 px-6 pb-6 pt-2">
          <Button onClick={goNext} className="w-full py-5 text-base font-bold">
            Suivant
            <ChevronRight className="ml-1 h-5 w-5" />
          </Button>
        </div>
      )}
    </div>
  );
}

function StepPanel({ children }: { children: React.ReactNode }) {
  return (
    <div className="w-full shrink-0 snap-start overflow-y-auto px-6 pb-8 pt-6">
      {children}
    </div>
  );
}

function StepHeader({
  title,
  subtitle,
}: {
  title: string;
  subtitle?: string;
}) {
  return (
    <div className="mb-6">
      <h2 className="font-heading text-2xl font-bold">{title}</h2>
      {subtitle && (
        <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
          {subtitle}
        </p>
      )}
    </div>
  );
}

function OptionCard({
  selected,
  onTap,
  children,
}: {
  selected: boolean;
  onTap: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onTap}
      className={cn(
        "flex w-full items-center gap-3.5 rounded-2xl border-2 px-5 py-4 text-left transition-all",
        selected
          ? "border-primary bg-primary/5"
          : "border-border bg-card shadow-sm hover:border-primary/30",
      )}
    >
      {children}
      <div
        className={cn(
          "flex h-6 w-6 shrink-0 items-center justify-center rounded-full transition-all",
          selected ? "bg-primary text-white" : "bg-transparent",
        )}
      >
        {selected && <Check className="h-4 w-4" />}
      </div>
    </button>
  );
}

function SummaryRow({
  label,
  value,
  onEdit,
}: {
  label: string;
  value: string;
  onEdit?: () => void;
}) {
  const content = (
    <div className="flex items-center gap-2 py-2">
      <span className="w-28 shrink-0 text-sm font-semibold text-muted-foreground">
        {label}
      </span>
      <span className="flex-1 text-sm">{value}</span>
      {onEdit && <Pencil className="h-3.5 w-3.5 text-muted-foreground/50" />}
    </div>
  );

  if (onEdit) {
    return (
      <button onClick={onEdit} className="w-full rounded-lg text-left hover:bg-accent/50">
        {content}
      </button>
    );
  }
  return content;
}
