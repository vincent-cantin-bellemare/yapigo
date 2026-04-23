"use client";

import { useState, useRef, useCallback, useEffect } from "react";
import { useRouter, usePathname } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";
import {
  ArrowLeft,
  X,
  Check,
  Lock,
  MapPin,
  Camera,
  Sparkles,
  FileText,
  Shield,
  PersonStanding,
  Users,
  Dumbbell,
  Search as SearchIcon,
  Heart,
  Compass,
  Target,
} from "lucide-react";

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

const provinces = [
  { code: "QC", name: "Québec", available: true },
  { code: "ON", name: "Ontario", available: false },
  { code: "BC", name: "Colombie-Britannique", available: false },
  { code: "AB", name: "Alberta", available: false },
  { code: "MB", name: "Manitoba", available: false },
  { code: "SK", name: "Saskatchewan", available: false },
  { code: "NB", name: "Nouveau-Brunswick", available: false },
  { code: "NS", name: "Nouvelle-Écosse", available: false },
  { code: "PE", name: "Île-du-Prince-Édouard", available: false },
  { code: "NL", name: "Terre-Neuve-et-Labrador", available: false },
];

const quickCities = [
  "Montréal",
  "Québec",
  "Laval",
  "Longueuil",
  "Gatineau",
  "Sherbrooke",
];

const allCities = [
  { name: "Montréal", region: "Montréal" },
  { name: "Laval", region: "Laval" },
  { name: "Longueuil", region: "Montérégie" },
  { name: "Brossard", region: "Montérégie" },
  { name: "Boucherville", region: "Montérégie" },
  { name: "Saint-Bruno-de-Montarville", region: "Montérégie" },
  { name: "Terrebonne", region: "Lanaudière" },
  { name: "Blainville", region: "Laurentides" },
  { name: "Repentigny", region: "Lanaudière" },
  { name: "Châteauguay", region: "Montérégie" },
  { name: "Saint-Jean-sur-Richelieu", region: "Montérégie" },
  { name: "Saint-Jérôme", region: "Laurentides" },
  { name: "Mascouche", region: "Lanaudière" },
  { name: "Mirabel", region: "Laurentides" },
  { name: "Sainte-Thérèse", region: "Laurentides" },
  { name: "Candiac", region: "Montérégie" },
  { name: "Chambly", region: "Montérégie" },
  { name: "Varennes", region: "Montérégie" },
  { name: "Sainte-Julie", region: "Montérégie" },
  { name: "Beloeil", region: "Montérégie" },
  { name: "Mont-Saint-Hilaire", region: "Montérégie" },
  { name: "Dorval", region: "Montréal" },
  { name: "Pointe-Claire", region: "Montréal" },
  { name: "Dollard-Des Ormeaux", region: "Montréal" },
  { name: "Kirkland", region: "Montréal" },
  { name: "Saint-Eustache", region: "Laurentides" },
  { name: "Deux-Montagnes", region: "Laurentides" },
  { name: "Boisbriand", region: "Laurentides" },
  { name: "Rosemère", region: "Laurentides" },
  { name: "L'Assomption", region: "Lanaudière" },
  { name: "Joliette", region: "Lanaudière" },
  { name: "Vaudreuil-Dorion", region: "Montérégie" },
  { name: "Québec", region: "Capitale-Nationale" },
  { name: "Lévis", region: "Chaudière-Appalaches" },
  { name: "Beauport", region: "Capitale-Nationale" },
  { name: "Charlesbourg", region: "Capitale-Nationale" },
  { name: "Sainte-Foy", region: "Capitale-Nationale" },
  { name: "Cap-Rouge", region: "Capitale-Nationale" },
  { name: "L'Ancienne-Lorette", region: "Capitale-Nationale" },
  { name: "Gatineau", region: "Outaouais" },
  { name: "Chelsea", region: "Outaouais" },
  { name: "Cantley", region: "Outaouais" },
  { name: "Sherbrooke", region: "Estrie" },
  { name: "Magog", region: "Estrie" },
  { name: "Granby", region: "Montérégie" },
  { name: "Trois-Rivières", region: "Mauricie" },
  { name: "Shawinigan", region: "Mauricie" },
  { name: "Drummondville", region: "Centre-du-Québec" },
  { name: "Victoriaville", region: "Centre-du-Québec" },
  { name: "Saguenay", region: "Saguenay–Lac-Saint-Jean" },
  { name: "Alma", region: "Saguenay–Lac-Saint-Jean" },
  { name: "Rimouski", region: "Bas-Saint-Laurent" },
  { name: "Rivière-du-Loup", region: "Bas-Saint-Laurent" },
  { name: "Rouyn-Noranda", region: "Abitibi-Témiscamingue" },
  { name: "Val-d'Or", region: "Abitibi-Témiscamingue" },
  { name: "Baie-Comeau", region: "Côte-Nord" },
  { name: "Sept-Îles", region: "Côte-Nord" },
  { name: "Mont-Tremblant", region: "Laurentides" },
  { name: "Saint-Sauveur", region: "Laurentides" },
  { name: "Bromont", region: "Estrie" },
  { name: "Saint-Georges", region: "Chaudière-Appalaches" },
  { name: "Saint-Hyacinthe", region: "Montérégie" },
  { name: "Sorel-Tracy", region: "Montérégie" },
  { name: "La Prairie", region: "Montérégie" },
  { name: "Saint-Constant", region: "Montérégie" },
  { name: "Saint-Lambert", region: "Montérégie" },
];

function normalizeSearch(s: string): string {
  return s
    .toLowerCase()
    .replace(/[éèêë]/g, "e")
    .replace(/[àâ]/g, "a")
    .replace(/[ôö]/g, "o")
    .replace(/[îï]/g, "i")
    .replace(/[ùû]/g, "u")
    .replace(/ç/g, "c")
    .replace(/[-']/g, " ");
}

const goalsList = [
  { icon: Heart, label: "Rencontrer quelqu'un de spécial" },
  { icon: PersonStanding, label: "Trouver un partenaire de course" },
  { icon: Users, label: "Faire de nouveaux amis coureurs" },
  { icon: Compass, label: "Découvrir de nouveaux quartiers en courant" },
  { icon: Dumbbell, label: "Me motiver à courir plus souvent" },
];

const genders = ["Homme", "Femme", "Non-binaire"];
const orientations = [
  "Hétérosexuel(le)",
  "Homosexuel(le)",
  "Bisexuel(le)",
  "Pansexuel(le)",
  "Autre",
  "Préfère ne pas dire",
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

const yearFunFacts: Record<number, string> = {
  1970: "le premier Marathon de New York a eu lieu 🏃",
  1977: "Star Wars est sorti — que la Force soit avec ton cardio ⭐",
  1979: "le Walkman de Sony est sorti — sport + musique = toi 🎧",
  1984: "le Macintosh est sorti — et Big Brother nous regarde 👁️",
  1989: "le Game Boy est sorti — Tetris > Netflix 🎮",
  1990: "le World Wide Web a été créé — et la procrastination aussi 🕸️",
  1992: "le premier SMS a été envoyé — \"Merry Christmas\" 💬",
  1995: "Java et JavaScript sont nés — non, c'est pas la même chose ☕",
  1998: "Google a été fondé — avant ça, on demandait à sa mère 🔍",
  2000: "la clé USB est apparue — adieu les disquettes! 💾",
  2004: "Facebook est né dans un dortoir — et ta vie privée est morte 👤",
  2005: "YouTube est lancé — \"Me at the zoo\" 🎬",
  2007: "le premier iPhone est sorti — Steve Jobs avait raison 📱",
  2008: "Spotify a été lancé — tes playlists d'activité t'attendent 🎶",
};

type StepId =
  | "phone"
  | "otp"
  | "name"
  | "gender"
  | "orientation"
  | "age"
  | "province"
  | "city"
  | "neighborhood"
  | "goals"
  | "photo"
  | "bio"
  | "selfie"
  | "visibility"
  | "language"
  | "terms"
  | "welcome";

export default function SignupWizardPage() {
  const { login } = useAuth();
  const router = useRouter();
  const pathname = usePathname();

  const [phone, setPhone] = useState("");
  const [otp, setOtp] = useState("");
  const [name, setName] = useState("");
  const [gender, setGender] = useState<string | null>(null);
  const [orientation, setOrientation] = useState<string | null>(null);
  const [birthYear, setBirthYear] = useState(1996);
  const [province, setProvince] = useState<string | null>(null);
  const [city, setCity] = useState<string | null>(null);
  const [neighborhood, setNeighborhood] = useState<string | null>(null);
  const [goals, setGoals] = useState<Set<string>>(new Set());
  const [visibility, setVisibility] = useState("internal");
  const [language, setLanguage] = useState("fr");
  const [termsAccepted, setTermsAccepted] = useState(false);
  const [generatedBio, setGeneratedBio] = useState("");

  useEffect(() => {
    const stored = sessionStorage.getItem("generated_bio");
    if (stored) {
      setGeneratedBio(stored);
      sessionStorage.removeItem("generated_bio");
    }
  }, [pathname]);

  const showNeighborhood = city === "Montréal";

  const allSteps: StepId[] = [
    "phone",
    "otp",
    "name",
    "gender",
    "orientation",
    "age",
    "province",
    "city",
    ...(showNeighborhood ? (["neighborhood"] as StepId[]) : []),
    "goals",
    "photo",
    "bio",
    "selfie",
    "visibility",
    "language",
    "terms",
    "welcome",
  ];

  const [stepIndex, setStepIndex] = useState(0);
  const currentStep = allSteps[stepIndex] ?? "phone";
  const totalSteps = allSteps.length;
  const isLastStep = stepIndex === totalSteps - 1;
  const age = new Date().getFullYear() - birthYear;

  const canContinue = (() => {
    switch (currentStep) {
      case "phone":
        return phone.replace(/\D/g, "").length >= 10;
      case "otp":
        return otp.length >= 4;
      case "name":
        return name.trim().length > 0;
      case "goals":
        return goals.size > 0;
      case "terms":
        return termsAccepted;
      default:
        return true;
    }
  })();

  const goNext = useCallback(() => {
    setStepIndex((i) => Math.min(i + 1, totalSteps - 1));
  }, [totalSteps]);

  const goBack = () => {
    if (stepIndex > 0) setStepIndex((i) => i - 1);
    else router.push("/welcome");
  };

  const autoAdvance = useCallback(
    (delay = 300) => {
      setTimeout(goNext, delay);
    },
    [goNext],
  );

  const progress = ((stepIndex + 1) / totalSteps) * 100;

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Header */}
      <div className="flex items-center px-2 pt-4">
        {stepIndex === 0 ? (
          <button onClick={goBack} className="p-3">
            <X className="h-5 w-5" />
          </button>
        ) : !isLastStep ? (
          <button onClick={goBack} className="p-3">
            <ArrowLeft className="h-5 w-5" />
          </button>
        ) : (
          <div className="w-11" />
        )}
        <div className="flex-1" />
        {currentStep === "phone" && (
          <div className="mr-2 flex items-center gap-0.5 rounded-lg bg-muted px-1 py-0.5">
            <button
              onClick={() => setLanguage("fr")}
              className={cn(
                "rounded-md px-2.5 py-1 text-sm font-semibold",
                language === "fr"
                  ? "bg-primary/15 text-primary"
                  : "text-muted-foreground",
              )}
            >
              FR
            </button>
            <span className="text-muted-foreground/40">|</span>
            <button
              onClick={() => setLanguage("en")}
              className={cn(
                "rounded-md px-2.5 py-1 text-sm font-semibold",
                language === "en"
                  ? "bg-primary/15 text-primary"
                  : "text-muted-foreground",
              )}
            >
              EN
            </button>
          </div>
        )}
        {["photo", "bio", "selfie"].includes(currentStep) && (
          <button
            onClick={goNext}
            className="mr-2 px-3 py-1 text-sm text-muted-foreground"
          >
            Passer
          </button>
        )}
      </div>

      {/* Progress bar */}
      {!isLastStep && (
        <div className="px-6 pt-1">
          <div className="h-1 overflow-hidden rounded-full bg-muted">
            <div
              className="h-full rounded-full bg-primary transition-all duration-400"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>
      )}

      {/* Step content */}
      <div className="flex flex-1 flex-col px-6 pt-8 pb-6">
        {currentStep === "phone" && (
          <StepLayout title="Ton numéro">
            <p className="text-sm text-muted-foreground leading-snug">
              On utilise ton numéro pour vérifier ton identité. C&apos;est notre
              façon de s&apos;assurer que chaque membre est une vraie personne.
            </p>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="514 555 1234"
              className="mt-6 w-full border-b-2 border-border bg-transparent pb-3 text-2xl font-medium outline-none focus:border-primary"
            />
            <div className="mt-3 flex items-center gap-1.5 text-sm font-medium text-teal-500">
              <Lock className="h-4 w-4" />
              Ton numéro ne sera jamais partagé.
            </div>
            <div className="mt-auto pt-8">
              <WizardButton disabled={!canContinue} onClick={goNext}>
                Continuer
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "otp" && (
          <StepLayout title="Entre le code reçu">
            <input
              type="text"
              inputMode="numeric"
              maxLength={4}
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
              className="mt-4 w-full text-center text-4xl font-semibold tracking-[16px] border-b-2 border-border bg-transparent pb-3 outline-none focus:border-primary"
              autoFocus
            />
            <button className="mt-6 text-sm font-medium text-primary">
              Renvoyer le code
            </button>
            <div className="mt-auto pt-8">
              <WizardButton disabled={!canContinue} onClick={goNext}>
                Valider
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "name" && (
          <StepLayout title="Comment on t'appelle?">
            <input
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ton prénom"
              className="mt-4 w-full border-b-2 border-border bg-transparent pb-3 text-2xl outline-none focus:border-primary"
              autoFocus
            />
            <div className="mt-auto pt-8">
              <WizardButton disabled={!canContinue} onClick={goNext}>
                Continuer
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "gender" && (
          <StepLayout title="Tu es...">
            <div className="space-y-3">
              {genders.map((g) => (
                <SelectionCard
                  key={g}
                  label={g}
                  selected={gender === g}
                  onSelect={() => {
                    setGender(g);
                    autoAdvance();
                  }}
                />
              ))}
            </div>
          </StepLayout>
        )}

        {currentStep === "orientation" && (
          <StepLayout title="Tu te définis comment?">
            <div className="space-y-3">
              {orientations.map((o) => (
                <SelectionCard
                  key={o}
                  label={o}
                  selected={orientation === o}
                  onSelect={() => {
                    setOrientation(o);
                    autoAdvance();
                  }}
                />
              ))}
            </div>
          </StepLayout>
        )}

        {currentStep === "age" && (
          <StepLayout title="Ton année de naissance?">
            <div className="flex flex-col items-center">
              <p className="text-5xl font-extrabold text-primary">{age} ans</p>
              <p className="mt-2 text-[15px] text-muted-foreground">
                Né(e) en {birthYear}
              </p>
              {yearFunFacts[birthYear] && (
                <div className="mt-4 rounded-xl border border-teal-500/25 bg-teal-500/10 px-4 py-3 text-center">
                  <p className="text-sm leading-snug">
                    Savais-tu qu&apos;en {birthYear},{" "}
                    {yearFunFacts[birthYear]}
                  </p>
                  <p className="mt-1 text-sm italic text-muted-foreground">
                    Ça ne te rajeunit pas, hein? 😏
                  </p>
                </div>
              )}
              <div className="mt-6 w-full">
                <input
                  type="range"
                  min={1946}
                  max={2008}
                  value={birthYear}
                  onChange={(e) => setBirthYear(Number(e.target.value))}
                  className="w-full accent-primary"
                />
                <div className="flex justify-between text-xs text-muted-foreground">
                  <span>1946</span>
                  <span>2008</span>
                </div>
              </div>
            </div>
            <div className="mt-auto pt-8">
              <WizardButton onClick={goNext}>Continuer</WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "province" && (
          <StepLayout title="Dans quelle province habites-tu?">
            <div className="space-y-2 overflow-y-auto">
              {provinces.map((p) => (
                <button
                  key={p.code}
                  disabled={!p.available}
                  onClick={() => {
                    setProvince(p.code);
                    autoAdvance(250);
                  }}
                  className={cn(
                    "flex w-full items-center gap-4 rounded-xl border px-5 py-4",
                    province === p.code
                      ? "border-primary bg-primary/8"
                      : p.available
                        ? "border-border bg-card"
                        : "border-border/50 opacity-50",
                  )}
                >
                  <span
                    className={cn(
                      "flex h-10 w-10 items-center justify-center rounded-lg text-[13px] font-extrabold",
                      province === p.code
                        ? "bg-primary/15 text-primary"
                        : "bg-muted text-foreground",
                    )}
                  >
                    {p.code}
                  </span>
                  <span
                    className={cn(
                      "flex-1 text-left text-base",
                      province === p.code ? "font-bold" : "",
                    )}
                  >
                    {p.name}
                  </span>
                  {!p.available && (
                    <span className="rounded-lg bg-muted px-2 py-1 text-xs text-muted-foreground">
                      🔧 Bientôt
                    </span>
                  )}
                  {province === p.code && (
                    <Check className="h-5 w-5 text-primary" />
                  )}
                </button>
              ))}
            </div>
          </StepLayout>
        )}

        {currentStep === "city" && (
          <StepLayout title="Tu habites où?">
            <div className="flex flex-wrap gap-2">
              {quickCities.map((c) => (
                <button
                  key={c}
                  onClick={() => {
                    setCity(c);
                    autoAdvance();
                  }}
                  className={cn(
                    "flex items-center gap-2 rounded-full border px-3 py-2 text-sm font-semibold",
                    city === c
                      ? "border-primary bg-primary/12 text-primary"
                      : "border-border bg-card",
                  )}
                >
                  <MapPin className="h-3.5 w-3.5" />
                  {c}
                  {city === c && <Check className="h-3.5 w-3.5" />}
                </button>
              ))}
            </div>
            {city && (
              <div className="mt-4 flex items-center gap-2.5 rounded-xl border border-teal-500/30 bg-teal-500/10 px-3.5 py-2.5">
                <Check className="h-4 w-4 text-teal-500" />
                <span className="text-sm font-semibold text-teal-600">
                  Des événements sont organisés dans ta ville!
                </span>
              </div>
            )}
          </StepLayout>
        )}

        {currentStep === "neighborhood" && (
          <StepLayout title="Quel est ton quartier?">
            <p className="text-sm text-muted-foreground leading-snug">
              Optionnel — ça nous aide à te proposer des activités près de chez
              toi.
            </p>
            <div className="mt-4 flex flex-wrap gap-2">
              {montrealNeighborhoods.map((n) => (
                <button
                  key={n}
                  onClick={() =>
                    setNeighborhood(neighborhood === n ? null : n)
                  }
                  className={cn(
                    "rounded-xl border px-3.5 py-2.5 text-sm font-medium",
                    neighborhood === n
                      ? "border-primary border-2 bg-primary/12 font-bold text-primary"
                      : "border-border bg-card",
                  )}
                >
                  {n}
                </button>
              ))}
            </div>
            <div className="mt-auto pt-8">
              <WizardButton onClick={goNext}>
                {neighborhood ? "Continuer" : "Passer"}
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "goals" && (
          <StepLayout title="Qu'est-ce que tu cherches?">
            <p className="text-sm text-muted-foreground leading-snug">
              Sélectionne tout ce qui s&apos;applique. Ça nous aide à trouver
              ton match parfait!
            </p>
            <div className="mt-5 space-y-2.5">
              {goalsList.map((g) => {
                const sel = goals.has(g.label);
                return (
                  <button
                    key={g.label}
                    onClick={() => {
                      setGoals((prev) => {
                        const next = new Set(prev);
                        if (next.has(g.label)) next.delete(g.label);
                        else next.add(g.label);
                        return next;
                      });
                    }}
                    className={cn(
                      "flex w-full items-center gap-3.5 rounded-xl border px-[18px] py-4",
                      sel
                        ? "border-primary bg-primary/8"
                        : "border-border bg-card",
                    )}
                  >
                    <g.icon
                      className={cn(
                        "h-6 w-6",
                        sel ? "text-primary" : "text-muted-foreground",
                      )}
                    />
                    <span
                      className={cn(
                        "flex-1 text-left text-base",
                        sel ? "font-semibold text-primary" : "",
                      )}
                    >
                      {g.label}
                    </span>
                    {sel && <Check className="h-5 w-5 text-primary" />}
                  </button>
                );
              })}
            </div>
            <div className="mt-auto pt-8">
              <WizardButton disabled={!canContinue} onClick={goNext}>
                Continuer
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "photo" && (
          <StepLayout title="Ta photo de profil">
            <div className="flex flex-col items-center pt-8">
              <div className="flex h-40 w-40 items-center justify-center rounded-full border-[3px] border-primary bg-muted">
                <Camera className="h-12 w-12 text-primary" />
              </div>
              <h3 className="mt-6 font-heading text-xl font-bold">
                Ajoute ta meilleure photo!
              </h3>
              <p className="mt-2 text-center text-sm text-muted-foreground leading-snug">
                Les profils avec photo reçoivent 3x plus de connexions. Montre
                ton plus beau sourire!
              </p>
            </div>
            <div className="mt-auto pt-8 space-y-2">
              <WizardButton onClick={goNext}>Continuer</WizardButton>
              <button
                onClick={goNext}
                className="w-full py-2 text-sm text-muted-foreground"
              >
                Passer cette étape
              </button>
            </div>
          </StepLayout>
        )}

        {currentStep === "bio" && (
          <StepLayout title="Ta bio">
            {generatedBio ? (
              <>
                <div className="flex items-center gap-2.5 rounded-xl bg-teal-500/10 px-3.5 py-3">
                  <Check className="h-5 w-5 shrink-0 text-teal-500" />
                  <p className="text-sm leading-snug font-medium text-teal-600">
                    Bio générée avec succès!
                  </p>
                </div>
                <div className="mt-4 rounded-2xl border border-border bg-card px-4 py-3">
                  <p className="text-[15px] leading-relaxed text-foreground/80">
                    {generatedBio.length > 200
                      ? `${generatedBio.slice(0, 200)}...`
                      : generatedBio}
                  </p>
                </div>
                <button
                  onClick={() => router.push("/welcome/signup/bio-quiz")}
                  className="mt-3 text-sm font-medium text-primary"
                >
                  Refaire le quiz
                </button>
              </>
            ) : (
              <>
                <div className="flex items-center gap-2.5 rounded-xl bg-teal-500/10 px-3.5 py-3">
                  <Sparkles className="h-5 w-5 shrink-0 text-teal-500" />
                  <p className="text-sm leading-snug">
                    Réponds à quelques questions fun et on génère ta bio
                    automatiquement!
                  </p>
                </div>
                <button
                  onClick={() => router.push("/welcome/signup/bio-quiz")}
                  className="mt-7 flex w-full items-center justify-center gap-2 rounded-xl border-2 border-teal-500 py-3.5 font-heading text-[15px] font-bold text-teal-500"
                >
                  <Sparkles className="h-4 w-4" />
                  Générer ma bio en 2 min ✨
                </button>
              </>
            )}
            <div className="mt-auto pt-8 space-y-2">
              <WizardButton onClick={goNext}>Continuer</WizardButton>
              <button
                onClick={goNext}
                className="w-full py-2 text-sm text-muted-foreground"
              >
                Passer cette étape
              </button>
            </div>
          </StepLayout>
        )}

        {currentStep === "selfie" && (
          <StepLayout title="Selfie de vérification">
            <div className="flex flex-col items-center pt-8">
              <div className="flex h-[120px] w-[100px] items-center justify-center rounded-[50px] border-[3px] border-teal-500 bg-muted">
                <Camera className="h-12 w-12 text-teal-500" />
              </div>
              <h3 className="mt-6 font-heading text-xl font-bold">
                Confirme ton identité
              </h3>
              <p className="mt-2 text-center text-sm text-muted-foreground leading-snug">
                Ce selfie n&apos;est pas public. Il sert uniquement à vérifier
                que tu es une vraie personne.
              </p>
              <div className="mt-4 flex items-center gap-1.5 text-sm font-medium text-teal-500">
                <Lock className="h-4 w-4" />
                Jamais partagé ni visible sur ton profil
              </div>
            </div>
            <div className="mt-auto pt-8 space-y-2">
              <WizardButton onClick={goNext}>Continuer</WizardButton>
              <button
                onClick={goNext}
                className="w-full py-2 text-sm text-muted-foreground"
              >
                Passer cette étape
              </button>
            </div>
          </StepLayout>
        )}

        {currentStep === "visibility" && (
          <StepLayout title="Qui peut voir ton profil?">
            <div className="space-y-3">
              {visibilityOptions.map((opt) => {
                const sel = visibility === opt.key;
                return (
                  <button
                    key={opt.key}
                    onClick={() => {
                      setVisibility(opt.key);
                      autoAdvance();
                    }}
                    className={cn(
                      "flex w-full items-center gap-3.5 rounded-2xl border px-3.5 py-3.5 text-left",
                      sel
                        ? "border-teal-500/50 bg-teal-500/10"
                        : "border-border bg-card",
                    )}
                  >
                    <span className="text-[22px]">{opt.emoji}</span>
                    <div className="min-w-0 flex-1">
                      <p
                        className={cn(
                          "font-heading text-base font-bold",
                          sel && "text-teal-600",
                        )}
                      >
                        {opt.label}
                      </p>
                      <p className="text-sm text-muted-foreground leading-snug">
                        {opt.desc}
                      </p>
                    </div>
                    {sel && <Check className="h-5 w-5 text-teal-500" />}
                  </button>
                );
              })}
            </div>
          </StepLayout>
        )}

        {currentStep === "language" && (
          <StepLayout title="Dans quelle langue veux-tu utiliser Run Date?">
            <div className="space-y-3">
              {[
                { key: "fr", emoji: "🇫🇷", label: "Français" },
                { key: "en", emoji: "🇬🇧", label: "English" },
              ].map((opt) => {
                const sel = language === opt.key;
                return (
                  <button
                    key={opt.key}
                    onClick={() => {
                      setLanguage(opt.key);
                      autoAdvance();
                    }}
                    className={cn(
                      "flex w-full items-center gap-3.5 rounded-2xl border px-6 py-5",
                      sel
                        ? "border-2 border-primary bg-primary/8"
                        : "border-border bg-card",
                    )}
                  >
                    <span className="text-2xl">{opt.emoji}</span>
                    <span
                      className={cn(
                        "flex-1 text-left font-heading text-lg",
                        sel ? "font-bold text-primary" : "",
                      )}
                    >
                      {opt.label}
                    </span>
                    {sel && <Check className="h-5 w-5 text-primary" />}
                  </button>
                );
              })}
            </div>
          </StepLayout>
        )}

        {currentStep === "terms" && (
          <StepLayout title="Avant de commencer">
            <div className="space-y-3">
              <TermsLink label="Conditions d'utilisation" />
              <TermsLink label="Politique de confidentialité" />
              <TermsLink label="Règles de la communauté" />
            </div>
            <button
              onClick={() => setTermsAccepted(!termsAccepted)}
              className={cn(
                "mt-6 flex w-full items-center gap-3 rounded-xl border p-3.5",
                termsAccepted
                  ? "border-2 border-primary bg-primary/5"
                  : "border-border",
              )}
            >
              <div
                className={cn(
                  "flex h-6 w-6 shrink-0 items-center justify-center rounded-md border-2",
                  termsAccepted
                    ? "border-primary bg-primary"
                    : "border-muted-foreground/30",
                )}
              >
                {termsAccepted && (
                  <Check className="h-4 w-4 text-primary-foreground" />
                )}
              </div>
              <span className="text-left text-[15px] leading-snug">
                J&apos;accepte les conditions d&apos;utilisation et la politique
                de confidentialité
              </span>
            </button>
            <div className="mt-auto pt-8">
              <WizardButton disabled={!canContinue} onClick={goNext}>
                Créer mon compte
              </WizardButton>
            </div>
          </StepLayout>
        )}

        {currentStep === "welcome" && (
          <div className="flex flex-1 flex-col items-center justify-center text-center">
            <div className="flex h-[130px] w-[130px] items-center justify-center rounded-full border-[3px] border-primary/50 bg-gradient-to-br from-primary/20 to-teal-500/15 shadow-[0_0_30px_rgba(var(--primary),0.2)]">
              <span className="font-heading text-5xl font-extrabold text-primary">
                {name ? name[0].toUpperCase() : "?"}
              </span>
            </div>
            <h2 className="mt-9 font-heading text-3xl font-extrabold">
              Bienvenue {name || "toi"}!
            </h2>
            <p className="mt-3.5 text-base text-muted-foreground/75 leading-relaxed">
              Ton profil est créé.
              <br />
              Il est temps de trouver ton premier Run Date!
            </p>
            <div className="mt-8 flex items-center gap-6">
              <WelcomeStat value="3 run dates" label="cette semaine" />
              <div className="h-8 w-px bg-border" />
              <WelcomeStat value="120+" label="coureurs" />
              <div className="h-8 w-px bg-border" />
              <WelcomeStat value="6" label="quartiers" />
            </div>
            <div className="mt-auto w-full pt-10">
              <button
                onClick={() => {
                  login();
                  router.replace("/");
                }}
                className="w-full rounded-2xl bg-primary py-[18px] font-heading text-[17px] font-bold text-primary-foreground"
              >
                Trouver mon premier Run Date
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function StepLayout({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-1 flex-col">
      <h2 className="font-heading text-2xl font-extrabold leading-tight">
        {title}
      </h2>
      <div className="mt-8 flex flex-1 flex-col">{children}</div>
    </div>
  );
}

function WizardButton({
  children,
  onClick,
  disabled,
}: {
  children: React.ReactNode;
  onClick: () => void;
  disabled?: boolean;
}) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={cn(
        "w-full rounded-xl py-4 text-base font-bold text-primary-foreground transition-colors",
        disabled
          ? "bg-muted-foreground/30 text-muted-foreground cursor-not-allowed"
          : "bg-primary hover:bg-primary/90",
      )}
    >
      {children}
    </button>
  );
}

function SelectionCard({
  label,
  selected,
  onSelect,
}: {
  label: string;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      onClick={onSelect}
      className={cn(
        "flex w-full items-center rounded-2xl border px-6 py-5",
        selected
          ? "border-2 border-primary bg-primary/8"
          : "border-border bg-card",
      )}
    >
      <span
        className={cn(
          "flex-1 text-left font-heading text-lg",
          selected ? "font-bold text-primary" : "",
        )}
      >
        {label}
      </span>
      {selected && <Check className="h-5 w-5 text-primary" />}
    </button>
  );
}

function TermsLink({ label }: { label: string }) {
  return (
    <button className="flex items-center gap-3 text-left">
      <FileText className="h-5 w-5 text-foreground/70" />
      <span className="text-base text-foreground/70 underline">{label}</span>
    </button>
  );
}

function WelcomeStat({ value, label }: { value: string; label: string }) {
  return (
    <div className="text-center">
      <p className="font-heading text-base font-extrabold">{value}</p>
      <p className="text-[11px] text-muted-foreground">{label}</p>
    </div>
  );
}
