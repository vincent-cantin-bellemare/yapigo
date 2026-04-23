"use client";

import { useState, useMemo } from "react";
import Image from "next/image";
import { currentUser } from "@/lib/data";
import { cn } from "@/lib/utils";
import {
  User,
  Settings,
  Bell,
  Cake,
  Mail,
  Eye,
  Megaphone,
  MapPin,
  Sparkles,
  Plus,
  Trash2,
  Star,
  PauseCircle,
  AlertTriangle,
  Check,
  Info,
} from "lucide-react";
import { AppBar } from "@/components/shared/app-bar";

const genders = ["Homme", "Femme", "Non-binaire"];
const orientations = [
  "Hétérosexuel(le)",
  "Homosexuel(le)",
  "Bisexuel(le)",
  "Pansexuel(le)",
  "Autre",
  "Préfère ne pas dire",
];
const allIntentions = [
  "Faire de nouveaux amis",
  "Me remettre en forme",
  "Performer",
  "Découvrir des quartiers",
  "Rencontrer quelqu'un",
];
const montrealNeighborhoods = [
  "Le Plateau-Mont-Royal",
  "Rosemont",
  "Villeray",
  "Mile-End",
  "Outremont",
  "Hochelaga",
  "Verdun",
  "Griffintown",
  "Le Sud-Ouest",
  "Lachine",
  "Ahuntsic",
  "Saint-Laurent",
  "NDG",
  "Westmount",
  "Pointe-Saint-Charles",
];
const visibilityOptions = [
  {
    key: "public",
    emoji: "🌐",
    label: "Public",
    desc: "Visible sur le site web, tout le monde peut consulter ton profil.",
  },
  {
    key: "internal",
    emoji: "👥",
    label: "Interne",
    desc: "Seulement les membres de la communauté Run Date peuvent te voir.",
  },
  {
    key: "private",
    emoji: "🔒",
    label: "Privé",
    desc: "Seuls les membres de tes événements peuvent voir ton profil.",
  },
];

const notifItems = [
  { key: "new_event", label: "Nouvel événement", desc: "Une activité est créée près de chez toi" },
  { key: "match_request", label: "Demande de connexion", desc: "Quelqu'un veut te connaître!" },
  { key: "messaging", label: "Messagerie", desc: "Nouveau message de groupe ou privé" },
  { key: "event_change", label: "Changement d'événement", desc: "Modification d'horaire, lieu ou annulation" },
  { key: "group_ready", label: "Formation de groupe", desc: "Ton groupe est prêt!" },
  { key: "spot_freed", label: "Place libérée", desc: "Une place s'est libérée dans un événement" },
  { key: "run_reminder", label: "Rappel avant l'activité", desc: "Quelques heures avant ton activité" },
  { key: "new_members", label: "Nouveaux membres", desc: "Quelqu'un rejoint ton groupe" },
];

export default function EditProfilePage() {
  const u = currentUser;

  const [name, setName] = useState(u.firstName);
  const [bio, setBio] = useState(u.bio ?? "");
  const [city, setCity] = useState(u.city);
  const [neighborhood, setNeighborhood] = useState(u.neighborhood ?? "");
  const [gender, setGender] = useState(u.gender);
  const [orientation, setOrientation] = useState(u.sexualOrientation ?? "");
  const [intentions, setIntentions] = useState<Set<string>>(
    new Set(u.activityGoals),
  );
  const [mainPhoto] = useState(u.photoUrl);
  const [gallery] = useState(u.photoGallery);

  const [visibility, setVisibility] = useState("internal");
  const [socialOptIn, setSocialOptIn] = useState(false);
  const [email, setEmail] = useState("");
  const [emailSaved, setEmailSaved] = useState(false);

  const [notifs, setNotifs] = useState<Record<string, boolean>>(() => {
    const m: Record<string, boolean> = {};
    notifItems.forEach((n) => (m[n.key] = true));
    return m;
  });

  const [saved, setSaved] = useState(false);

  const allPhotos = useMemo(() => {
    const list: (string | null)[] = [mainPhoto ?? null, ...gallery];
    while (list.length < 6) list.push(null);
    return list;
  }, [mainPhoto, gallery]);

  const toggleIntention = (i: string) => {
    setIntentions((prev) => {
      const next = new Set(prev);
      if (next.has(i)) next.delete(i);
      else next.add(i);
      return next;
    });
  };

  const toggleNotif = (key: string) => {
    setNotifs((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="min-h-screen bg-background">
      <AppBar title="Mon profil" backHref="/profile" />

      <div className="mx-auto max-w-lg space-y-9 px-6">
        {/* ═══ SECTION: Profil ═══ */}
        <section>
          <SectionHeader icon={<User className="h-5 w-5 text-primary" />} title="Profil" />

          {/* Photo grid */}
          <div className="mt-4 grid grid-cols-3 gap-2">
            {allPhotos.map((url, i) => (
              <div
                key={i}
                className={cn(
                  "relative aspect-square rounded-xl border bg-muted overflow-hidden",
                  i === 0
                    ? "border-2 border-primary"
                    : "border-border",
                )}
              >
                {url ? (
                  <Image
                    src={url}
                    alt={`Photo ${i + 1}`}
                    fill
                    className="object-cover"
                  />
                ) : (
                  <div className="flex h-full flex-col items-center justify-center text-muted-foreground/50">
                    <Plus className="h-7 w-7" />
                    <span className="mt-1 text-xs font-medium">Ajouter</span>
                  </div>
                )}
                {i === 0 && url && (
                  <span className="absolute left-1.5 top-1.5 rounded-md bg-primary px-1.5 py-0.5 text-[10px] font-bold text-primary-foreground">
                    Principal
                  </span>
                )}
              </div>
            ))}
          </div>

          {/* Name */}
          <FieldGroup label="Prénom" className="mt-6">
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full rounded-xl border border-border bg-card px-4 py-3 text-[15px] outline-none focus:border-primary"
            />
          </FieldGroup>

          {/* Gender */}
          <FieldGroup label="Genre" className="mt-5">
            <div className="flex flex-wrap gap-2">
              {genders.map((g) => (
                <ChipToggle
                  key={g}
                  label={g}
                  selected={gender === g}
                  onToggle={() => setGender(g)}
                />
              ))}
            </div>
          </FieldGroup>

          {/* Orientation */}
          <FieldGroup label="Orientation" className="mt-5">
            <div className="flex flex-wrap gap-2">
              {orientations.map((o) => (
                <ChipToggle
                  key={o}
                  label={o}
                  selected={orientation === o}
                  onToggle={() => setOrientation(o)}
                />
              ))}
            </div>
          </FieldGroup>

          {/* City */}
          <FieldGroup label="Ville" className="mt-5">
            <div className="relative">
              <MapPin className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <input
                value={city}
                onChange={(e) => setCity(e.target.value)}
                placeholder="Recherche ta ville..."
                className="w-full rounded-xl border border-border bg-card py-3 pl-9 pr-4 text-[15px] outline-none focus:border-primary"
              />
            </div>
          </FieldGroup>

          {/* Neighborhood */}
          {city === "Montréal" && (
            <FieldGroup label="Quartier" className="mt-5">
              <p className="mb-2 text-xs text-muted-foreground">
                Optionnel — aide à trouver des événements près de chez toi.
              </p>
              <div className="flex flex-wrap gap-2">
                {montrealNeighborhoods.map((n) => (
                  <ChipToggle
                    key={n}
                    label={n}
                    selected={neighborhood === n}
                    onToggle={() =>
                      setNeighborhood(neighborhood === n ? "" : n)
                    }
                  />
                ))}
              </div>
            </FieldGroup>
          )}

          {/* Intentions */}
          <FieldGroup label="Intentions" className="mt-5">
            <div className="flex flex-wrap gap-2">
              {allIntentions.map((i) => (
                <ChipToggle
                  key={i}
                  label={i}
                  selected={intentions.has(i)}
                  onToggle={() => toggleIntention(i)}
                />
              ))}
            </div>
          </FieldGroup>

          {/* Bio */}
          <FieldGroup label="Bio" className="mt-5">
            <div className="flex items-center justify-between mb-2">
              <span />
              <button className="flex items-center gap-1 text-sm font-semibold text-teal-500 hover:text-teal-600">
                <Sparkles className="h-4 w-4" />
                Régénérer
              </button>
            </div>
            <textarea
              value={bio}
              onChange={(e) => setBio(e.target.value)}
              maxLength={500}
              rows={4}
              placeholder="Parle de toi..."
              className="w-full rounded-xl border border-border bg-card px-4 py-3 text-[15px] outline-none resize-none focus:border-primary"
            />
            <p className="mt-1 text-right text-xs text-muted-foreground">
              {bio.length}/500
            </p>
          </FieldGroup>
        </section>

        {/* ═══ SECTION: Compte ═══ */}
        <section>
          <SectionHeader
            icon={<Settings className="h-5 w-5 text-primary" />}
            title="Compte"
          />

          {/* Birthday */}
          <div className="mt-4 rounded-2xl border border-border bg-card p-4">
            <div className="flex items-center gap-2">
              <Cake className="h-5 w-5 text-primary" />
              <span className="font-heading text-base font-bold">
                Date de naissance
              </span>
            </div>
            <div className="mt-3 rounded-xl border border-primary/25 bg-primary/5 px-4 py-3">
              <p className="font-heading text-lg font-bold">Année 1992</p>
              <p className="text-sm font-semibold text-primary">34 ans</p>
            </div>
            <p className="mt-2 text-sm italic text-muted-foreground">
              Ajoute le mois et le jour pour que la communauté te souhaite bonne
              fête!
            </p>
          </div>

          {/* Email */}
          <div className="mt-5 rounded-2xl border border-border bg-card p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Mail className="h-5 w-5 text-foreground/70" />
                <span className="font-heading text-base font-bold">
                  Courriel
                </span>
              </div>
              <span className="rounded-md bg-muted px-2 py-0.5 text-sm font-semibold text-muted-foreground">
                Facultatif
              </span>
            </div>
            <p className="mt-2 text-sm text-muted-foreground leading-snug">
              Ajoute ton courriel pour recevoir des rappels et récupérer ton
              compte.
            </p>
            <div className="mt-3 flex gap-2.5">
              <input
                type="email"
                value={email}
                onChange={(e) => {
                  setEmail(e.target.value);
                  setEmailSaved(false);
                }}
                placeholder="ton.courriel@exemple.com"
                className="min-w-0 flex-1 rounded-xl border border-border bg-muted/30 px-3.5 py-2.5 text-[15px] outline-none focus:border-teal-500"
              />
              <button
                onClick={() => {
                  if (email.includes("@")) setEmailSaved(true);
                }}
                className="shrink-0 rounded-xl bg-teal-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-teal-600"
              >
                {emailSaved ? (
                  <Check className="h-4 w-4" />
                ) : (
                  "Sauver"
                )}
              </button>
            </div>
          </div>

          {/* Visibility */}
          <div className="mt-5 rounded-2xl border border-border bg-card p-4">
            <div className="flex items-center gap-2">
              <Eye className="h-5 w-5 text-foreground/70" />
              <span className="font-heading text-base font-bold">
                Visibilité du profil
              </span>
            </div>
            <div className="mt-3 space-y-2">
              {visibilityOptions.map((opt) => {
                const sel = visibility === opt.key;
                return (
                  <button
                    key={opt.key}
                    onClick={() => setVisibility(opt.key)}
                    className={cn(
                      "flex w-full items-center gap-3 rounded-xl border px-3.5 py-3 text-left",
                      sel
                        ? "border-teal-500/50 bg-teal-500/10"
                        : "border-border",
                    )}
                  >
                    <span className="text-xl">{opt.emoji}</span>
                    <div className="min-w-0 flex-1">
                      <p
                        className={cn(
                          "text-[15px] font-semibold",
                          sel && "text-teal-600",
                        )}
                      >
                        {opt.label}
                      </p>
                      <p className="text-sm text-muted-foreground leading-snug">
                        {opt.desc}
                      </p>
                    </div>
                    {sel && (
                      <Check className="h-5 w-5 shrink-0 text-teal-500" />
                    )}
                  </button>
                );
              })}
            </div>
          </div>

          {/* Social media opt-in */}
          <div className="mt-5 rounded-2xl border border-border bg-card p-4">
            <div className="flex items-center gap-2">
              <Megaphone className="h-5 w-5 text-foreground/70" />
              <span className="font-heading text-base font-bold">
                Profil mis de l&apos;avant
              </span>
            </div>
            <p className="mt-2 text-sm text-muted-foreground leading-snug">
              En activant cette option, tu acceptes que ton profil puisse être
              sélectionné pour apparaître sur les réseaux sociaux de Run Date.
            </p>
            <button
              onClick={() => setSocialOptIn(!socialOptIn)}
              className={cn(
                "mt-3 flex w-full items-center gap-3 rounded-xl border px-3.5 py-2.5",
                socialOptIn
                  ? "border-teal-500/40 bg-teal-500/8"
                  : "border-border",
              )}
            >
              <Star
                className={cn(
                  "h-5 w-5",
                  socialOptIn
                    ? "fill-teal-500 text-teal-500"
                    : "text-muted-foreground",
                )}
              />
              <span
                className={cn(
                  "flex-1 text-left text-sm font-semibold",
                  socialOptIn && "text-teal-600",
                )}
              >
                J&apos;accepte de figurer comme profil vedette
              </span>
              <div
                className={cn(
                  "h-6 w-11 rounded-full transition-colors",
                  socialOptIn ? "bg-teal-500" : "bg-muted-foreground/30",
                )}
              >
                <div
                  className={cn(
                    "mt-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform",
                    socialOptIn ? "translate-x-[22px]" : "translate-x-0.5",
                  )}
                />
              </div>
            </button>
            {socialOptIn && (
              <div className="mt-2.5 flex items-start gap-2.5 rounded-lg bg-teal-500/5 p-3">
                <Info className="mt-0.5 h-4 w-4 shrink-0 text-teal-500" />
                <p className="text-sm text-teal-600 leading-snug">
                  Merci! Tu pourrais être sélectionné(e) pour inspirer
                  d&apos;autres membres. Tu peux désactiver à tout moment.
                </p>
              </div>
            )}
          </div>
        </section>

        {/* ═══ SECTION: Notifications ═══ */}
        <section>
          <SectionHeader
            icon={<Bell className="h-5 w-5 text-primary" />}
            title="Notifications"
          />

          <div className="mt-4 rounded-2xl border border-border bg-card divide-y divide-border">
            {notifItems.map((item) => (
              <div
                key={item.key}
                className="flex items-center gap-3 px-4 py-3"
              >
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-semibold">{item.label}</p>
                  <p className="text-sm text-muted-foreground">{item.desc}</p>
                </div>
                <button
                  onClick={() => toggleNotif(item.key)}
                  className={cn(
                    "h-6 w-11 shrink-0 rounded-full transition-colors",
                    notifs[item.key]
                      ? "bg-teal-500"
                      : "bg-muted-foreground/30",
                  )}
                >
                  <div
                    className={cn(
                      "mt-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform",
                      notifs[item.key]
                        ? "translate-x-[22px]"
                        : "translate-x-0.5",
                    )}
                  />
                </button>
              </div>
            ))}
          </div>
        </section>

        {/* Save button */}
        <button
          onClick={handleSave}
          className={cn(
            "w-full rounded-xl py-4 text-base font-bold text-white transition-colors",
            saved ? "bg-teal-500" : "bg-primary hover:bg-primary/90",
          )}
        >
          {saved ? "✓ Profil sauvegardé" : "Sauvegarder"}
        </button>

        {/* ═══ SECTION: Zone dangereuse ═══ */}
        <section>
          <div className="rounded-2xl border border-red-200 bg-card dark:border-red-900/40">
            <div className="px-4 pt-4 pb-2">
              <p className="font-heading text-base font-bold text-red-500">
                Zone dangereuse
              </p>
            </div>
            <button className="flex w-full items-center gap-3 px-4 py-3 hover:bg-muted/50">
              <PauseCircle className="h-5 w-5 text-amber-500" />
              <span className="flex-1 text-left text-[15px] font-semibold">
                Suspendre mon compte
              </span>
            </button>
            <button className="flex w-full items-center gap-3 px-4 py-3 hover:bg-muted/50">
              <Trash2 className="h-5 w-5 text-red-500" />
              <span className="flex-1 text-left text-[15px] font-semibold">
                Supprimer mon compte
              </span>
            </button>
          </div>
        </section>
      </div>
    </div>
  );
}

function SectionHeader({
  icon,
  title,
}: {
  icon: React.ReactNode;
  title: string;
}) {
  return (
    <div className="flex items-center gap-2.5">
      {icon}
      <span className="font-heading text-xl font-extrabold">{title}</span>
      <div className="ml-3 h-px flex-1 bg-border" />
    </div>
  );
}

function FieldGroup({
  label,
  className,
  children,
}: {
  label: string;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <div className={className}>
      <p className="mb-2 text-sm font-semibold">{label}</p>
      {children}
    </div>
  );
}

function ChipToggle({
  label,
  selected,
  onToggle,
}: {
  label: string;
  selected: boolean;
  onToggle: () => void;
}) {
  return (
    <button
      onClick={onToggle}
      className={cn(
        "rounded-lg border px-3 py-2 text-sm font-semibold transition-colors",
        selected
          ? "border-primary bg-primary text-primary-foreground"
          : "border-border bg-card hover:bg-muted",
      )}
    >
      {label}
    </button>
  );
}
