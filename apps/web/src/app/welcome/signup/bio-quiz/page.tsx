"use client";

import { useState, useCallback, useRef, useEffect } from "react";
import { useRouter } from "next/navigation";
import { cn } from "@/lib/utils";
import { ArrowLeft, X, Check, ChevronUp, ChevronDown } from "lucide-react";

// ── Question types ──────────────────────────────────────────────────────────

interface QuizQuestion {
  title: string;
  subtitle?: string;
  emoji?: string;
  options?: { label: string; hint?: string }[];
  isTextInput?: boolean;
  textHint?: string;
  multiSelectKey?: string;
  scrollMin?: number;
  scrollMax?: number;
  scrollStep?: number;
  scrollUnit?: string;
}

// ── Phase 1: 10 questions ───────────────────────────────────────────────────

const phase1: QuizQuestion[] = [
  {
    title: "Tu fais quoi dans la vie?",
    subtitle: "Ça aide à briser la glace!",
    emoji: "💼",
    isTextInput: true,
    textHint: "Ex: Designer, enseignante, pompier...",
  },
  {
    title: "Tes sports plein air?",
    subtitle: "Sélectionne tes activités et ton niveau!",
    emoji: "🏔️",
    multiSelectKey: "sports",
  },
  {
    title: "Tes passe-temps?",
    subtitle: "Sélectionne tout ce qui te ressemble!",
    emoji: "🎨",
    multiSelectKey: "hobbies",
  },
  {
    title: "En bougeant, t'écoutes quoi?",
    subtitle: "Ta playlist d'activité, ça te définit!",
    emoji: "🎧",
    multiSelectKey: "music",
  },
  {
    title: "Tes types de films/séries?",
    subtitle: "Netflix & chill, mais quoi exactement?",
    emoji: "🎬",
    multiSelectKey: "films",
  },
  {
    title: "Ton activité parfaite, c'est...?",
    subtitle: "Ça définit ton style sportif!",
    emoji: "🎯",
    options: [
      { label: "5 km — court, intense et je rentre pour le brunch 🥞", hint: "Efficace et réaliste, qualité avant quantité" },
      { label: "10 km — le sweet spot, assez pour se sentir vivant 💪", hint: "Équilibré et solide, le juste milieu parfait" },
      { label: "21 km — demi-marathon, j'aime souffrir juste assez 🔥", hint: "Ambitieux et discipliné, tu te dépasses" },
      { label: "42 km — marathon, c'est un mode de vie 🏅", hint: "Déterminé et endurant, rien ne t'arrête" },
      { label: "Ultra + — pourquoi s'arrêter? 🦸", hint: "Tu repousses toutes les limites, respect" },
      { label: "Aucun intérêt, je bouge pour le social! 🥳", hint: "Le fun d'abord, la distance on s'en fout!" },
    ],
  },
  {
    title: "De la bouette sur les mollets, c'est sexy?",
    subtitle: "La question que personne ose poser 😏",
    emoji: "🦵",
    options: [
      { label: "Absolument, c'est un look! L'aventure c'est la vie 🏆", hint: "Traileur dans l'âme, la nature c'est ton gym" },
      { label: "Bof, je préfère rester propre et sentir bon 🧼", hint: "Clean et soigné, rien de mal là-dedans" },
      { label: "Seulement si l'autre personne en a aussi 😏", hint: "Romantique et complice, tu veux partager l'expérience" },
      { label: "Ça dépend du contexte... et de la bouette 🤔", hint: "Flexible et pragmatique, toujours nuancé" },
    ],
  },
  {
    title: "Tu as des animaux de compagnie?",
    subtitle: "Les sportifs à quatre pattes comptent aussi!",
    emoji: "🐾",
    options: [
      { label: "Un chien — mon partner d'activité! 🐕", hint: "Un vrai duo sportif, fidèle compagnon" },
      { label: "Un chat — il me juge quand je sors bouger 🐈", hint: "L'indépendance, ça se respecte" },
      { label: "Plusieurs! C'est un zoo chez nous 🦜", hint: "Coeur grand comme ça, amour illimité" },
      { label: "Pas encore, mais j'en veux un jour 🥺", hint: "Bientôt dans ta famille!" },
      { label: "Non, je suis team liberté totale 🦅", hint: "Léger et libre de voyager" },
    ],
  },
  {
    title: "Et côté famille?",
    subtitle: "Pas de jugement, juste pour mieux te connaître!",
    emoji: "👨‍👩‍👧",
    options: [
      { label: "J'ai des enfants, ma plus belle aventure! 👶", hint: "Parent fier, la famille c'est sacré" },
      { label: "Pas encore, mais c'est dans les plans 🍼", hint: "Tu planifies l'avenir avec optimisme" },
      { label: "Pas d'enfants, et c'est mon choix ✨", hint: "Tu sais ce que tu veux, et c'est parfait" },
      { label: "On verra ce que la vie décide 🤷", hint: "Ouvert et flexible, la vie est pleine de surprises" },
    ],
  },
  {
    title: "Ta plus grosse distance en une activité?",
    subtitle: "En une seule journée, ton record perso!",
    emoji: "📏",
    scrollMin: 2,
    scrollMax: 100,
    scrollStep: 1,
    scrollUnit: "km",
  },
];

// ── Phase 2: 10 questions ───────────────────────────────────────────────────

const phase2: QuizQuestion[] = [
  {
    title: "T'es sur Strava ou une app de sport?",
    subtitle: "On juge pas... ok, un peu 📊",
    emoji: "📱",
    options: [
      { label: "Strava évidemment, si c'est pas sur Strava c'est pas arrivé 🏆", hint: "Data nerd assumé, tu analyses chaque split" },
      { label: "Garmin Connect, j'ai une montre qui coûte plus cher que mon loyer ⌚", hint: "Équipé et sérieux, ta montre sait tout de toi" },
      { label: "Nike Run Club, le coach me dit que je suis bon 👟", hint: "Motivé par les défis et le coaching" },
      { label: "Apple Watch Fitness, j'ai fermé mes anneaux! ⌚", hint: "Tech-friendly, tu aimes les stats sans te casser la tête" },
      { label: "Aucune app, je cours avec mon instinct 🐺", hint: "Libre et instinctif, pas besoin de données" },
    ],
  },
  {
    title: "Tes compétences utiles?",
    subtitle: "La personne ressource de la gang, c'est toi?",
    emoji: "🛠️",
    multiSelectKey: "skills",
  },
  {
    title: "Les langues que tu parles?",
    subtitle: "Polyglotte ou unilingue assumé?",
    emoji: "🌍",
    multiSelectKey: "languages",
  },
  {
    title: "Tu sais réparer un flat de vélo?",
    subtitle: "Compétence de survie en plein air 🔧",
    emoji: "🚲",
    options: [
      { label: "Oui, les yeux fermés! J'ai ma trousse dans le sac 🔧", hint: "Débrouillard et autonome, on peut compter sur toi" },
      { label: "En théorie... j'ai vu un YouTube une fois 📱", hint: "Autodidacte moderne, tu te formes sur le tas" },
      { label: "Non, j'appelle un ami ou je marche 📞", hint: "Honnête et social, tu sais demander de l'aide" },
      { label: "C'est quoi un flat? 🤔", hint: "Charmant dans ta candeur, on va t'apprendre!" },
    ],
  },
  {
    title: "Tu bouges l'hiver?",
    subtitle: "Ça sépare les vrais des prétendants ❄️",
    emoji: "🥶",
    options: [
      { label: "Oui, -20 et je suis dehors! Crampons et tuque, c'est la base ❄️", hint: "Guerrier nordique, rien ne t'arrête" },
      { label: "Quand ça fond un peu, genre -5 max 🌡️", hint: "Raisonnable et adaptable, tu choisis tes batailles" },
      { label: "Non, l'hiver c'est gym ou Netflix 🛋️", hint: "Tu sais quand te reposer, et c'est correct" },
      { label: "J'ai essayé une fois... plus jamais, mes poumons s'en souviennent 😰", hint: "Au moins t'as essayé, c'est l'intention qui compte!" },
    ],
  },
  {
    title: "Tes futurs beaux-parents vont t'aimer pour...?",
    subtitle: "Fais bonne impression, on écoute 😏",
    emoji: "👨‍👩‍👦",
    options: [
      { label: "Je fais la vaisselle sans qu'on me le demande 🍽️", hint: "Serviable et attentionné, le gendre/bru parfait" },
      { label: "Je répare tout ce qui est brisé dans la maison 🔧", hint: "Manuel et débrouillard, tu vaux de l'or" },
      { label: "Je cuisine mieux que leur enfant, désolé 👨‍🍳", hint: "Foodie et généreux, tu gagnes par l'estomac" },
      { label: "Je ris à toutes leurs jokes, même les poches 😂", hint: "Diplomate naturel, tu charmes tout le monde" },
      { label: "Mon salaire. Soyons honnêtes. 💰", hint: "Au moins t'es honnête, on respecte ça" },
    ],
  },
  {
    title: "Tu arrêtes au stop en bougeant?",
    subtitle: "Le grand débat de la communauté sportive 🛑",
    emoji: "🚦",
    options: [
      { label: "Évidemment, la loi c'est la loi! 🛑", hint: "Citoyen modèle, tu respectes les règles" },
      { label: "Je ralentis... genre un petit peu 🏃", hint: "Compromis acceptable, effort minimum" },
      { label: "Stop? Quel stop? Je suis dans ma zone 💨", hint: "Inarrêtable, ta foulée c'est sacré" },
      { label: "Ça dépend s'il y a des chars 👀", hint: "Pragmatique et honnête, survie d'abord" },
    ],
  },
  {
    title: "En voyage, t'es plutôt...?",
    subtitle: "Ça en dit long sur ta personnalité!",
    emoji: "✈️",
    options: [
      { label: "Backpack et hostel, budget serré, max d'aventures 🎒", hint: "Aventurier et débrouillard, tu voyages léger" },
      { label: "Campervan, la liberté sur quatre roues 🚐", hint: "Libre comme l'air, la route c'est ta maison" },
      { label: "Camping, la nature pis un feu de camp 🏕️", hint: "Plein air dans l'âme, la simplicité te comble" },
      { label: "Hôtel, spa pis room service, je le mérite 🏨", hint: "Tu sais te gâter et tu l'assumes pleinement" },
      { label: "Casanier, je suis bien chez nous! 🏠", hint: "Ton chez-toi c'est ton sanctuaire, et c'est correct" },
    ],
  },
  {
    title: "Dis-nous un fun fact sur toi!",
    subtitle: "Le plus random, le mieux! Ça rend ta bio unique.",
    emoji: "🎲",
    isTextInput: true,
    textHint: "Ex: J'ai déjà fait un demi-marathon en gougounes...",
  },
  {
    title: "T'es compétitif dans le sport?",
    subtitle: "Pas de mauvaise réponse... sauf mentir 🏅",
    emoji: "🏁",
    options: [
      { label: "J'ai un dossard pour chaque fin de semaine! 🏅", hint: "Athlète dans l'âme, tu collectionnes les activités" },
      { label: "Un peu, j'aime me dépasser sans pression 💪", hint: "Équilibré, tu te pousses sans te stresser" },
      { label: "Zéro, je bouge pour le plaisir et la jasette 😊", hint: "Social d'abord, la performance c'est un bonus" },
      { label: "Je compétitionne juste avec moi-même, mon Strava le sait ⏱️", hint: "Introspectif et discipliné, ton pire adversaire c'est toi" },
    ],
  },
];

// ── Multi-select item catalogues ────────────────────────────────────────────

interface MultiSelectItem {
  icon: string;
  label: string;
}

interface MultiSelectConfig {
  items: MultiSelectItem[];
  levels: string[] | null;
}

const sportsItems: MultiSelectItem[] = [
  { icon: "🚴", label: "Vélo" },
  { icon: "🥾", label: "Randonnée" },
  { icon: "🏊", label: "Natation" },
  { icon: "🏃", label: "Course" },
  { icon: "🛶", label: "Kayak" },
  { icon: "⛷️", label: "Ski de fond" },
  { icon: "🛼", label: "Patin à roues alignées" },
  { icon: "🧗", label: "Escalade" },
];

const hobbiesItems: MultiSelectItem[] = [
  { icon: "🍳", label: "Cuisine" },
  { icon: "🌻", label: "Jardinage" },
  { icon: "📖", label: "Lecture" },
  { icon: "🎮", label: "Jeux vidéo" },
  { icon: "📸", label: "Photographie" },
  { icon: "🔨", label: "Bricolage / DIY" },
  { icon: "✈️", label: "Voyage" },
  { icon: "🧘", label: "Yoga / Méditation" },
];

const musicItems: MultiSelectItem[] = [
  { icon: "🎵", label: "Pop" },
  { icon: "⚡", label: "Rock" },
  { icon: "🔥", label: "Metal" },
  { icon: "🎤", label: "Hip-hop / Rap" },
  { icon: "🔊", label: "EDM / Électro" },
  { icon: "🌙", label: "R&B / Soul" },
  { icon: "💿", label: "Indie / Alternatif" },
  { icon: "🌾", label: "Country / Folk" },
  { icon: "🎻", label: "Classique" },
  { icon: "🎙️", label: "Podcasts" },
  { icon: "👂", label: "Rien, juste le bruit de mes pas" },
];

const filmItems: MultiSelectItem[] = [
  { icon: "💥", label: "Action" },
  { icon: "😂", label: "Comédie" },
  { icon: "🌑", label: "Horreur" },
  { icon: "❤️", label: "Romance" },
  { icon: "🚀", label: "Science-fiction" },
  { icon: "🎥", label: "Documentaire" },
  { icon: "🧠", label: "Thriller" },
  { icon: "🎨", label: "Animation" },
  { icon: "🎭", label: "Drame" },
  { icon: "✨", label: "Fantastique" },
];

const skillsItems: MultiSelectItem[] = [
  { icon: "💻", label: "Informatique / Tech" },
  { icon: "🔧", label: "Bricolage / Réno" },
  { icon: "💰", label: "Finances / Budget" },
  { icon: "🚗", label: "Mécanique" },
  { icon: "📋", label: "Organisation" },
  { icon: "👨‍🍳", label: "Cuisine avancée" },
];

const languageItems: MultiSelectItem[] = [
  { icon: "🇫🇷", label: "Français" },
  { icon: "🇬🇧", label: "Anglais" },
  { icon: "🇪🇸", label: "Espagnol" },
  { icon: "🇨🇳", label: "Mandarin" },
  { icon: "🇸🇦", label: "Arabe" },
  { icon: "🇧🇷", label: "Portugais" },
  { icon: "🇩🇪", label: "Allemand" },
  { icon: "🇮🇹", label: "Italien" },
  { icon: "🇯🇵", label: "Japonais" },
  { icon: "🇰🇷", label: "Coréen" },
];

const proficiencyLevels = ["Débutant", "Avancé", "Expert"];
const hobbyLevels = ["Un peu", "Passionné", "Accro"];
const languageLevels = ["Débutant", "Avancé", "Je maîtrise", "Natif"];

const multiSelectConfig: Record<string, MultiSelectConfig> = {
  sports: { items: sportsItems, levels: proficiencyLevels },
  hobbies: { items: hobbiesItems, levels: hobbyLevels },
  music: { items: musicItems, levels: null },
  films: { items: filmItems, levels: null },
  skills: { items: skillsItems, levels: proficiencyLevels },
  languages: { items: languageItems, levels: languageLevels },
};

// ── Bio generation ──────────────────────────────────────────────────────────

function cleanEmoji(s: string): string {
  return s
    .replace(
      /[^\w\sàâäéèêëïîôùûüÿçÀÂÄÉÈÊËÏÎÔÙÛÜŸÇ°.,!?'''\-—+/]+/g,
      "",
    )
    .trim();
}

function generateBio(
  answers: Record<number, string>,
  phase2Unlocked: boolean,
): string {
  const parts: string[] = [];

  const profession = answers[0];
  const sports = answers[1];
  const hobbies = answers[2];
  const music = answers[3];
  const films = answers[4];
  const idealDistance = answers[5] ? cleanEmoji(answers[5]) : undefined;
  const mud = answers[6] ? cleanEmoji(answers[6]) : undefined;
  const animals = answers[7] ? cleanEmoji(answers[7]) : undefined;
  const children = answers[8] ? cleanEmoji(answers[8]) : undefined;
  const longestRun = answers[9];

  if (profession) parts.push(`${profession}.`);
  if (sports) parts.push(`Sports: ${sports}.`);
  if (hobbies) parts.push(`Passe-temps: ${hobbies}.`);
  if (idealDistance) parts.push(`Activité parfaite: ${idealDistance}.`);
  if (mud) parts.push(`La bouette sur les mollets? ${mud}.`);
  if (music) parts.push(`En bougeant j'écoute: ${music}.`);
  if (films) parts.push(`Films: ${films}.`);
  if (animals) parts.push(`Animaux: ${animals}.`);
  if (children) parts.push(`Famille: ${children}.`);

  if (phase2Unlocked) {
    const p2 = phase1.length;
    const strava = answers[p2] ? cleanEmoji(answers[p2]) : undefined;
    const skills = answers[p2 + 1];
    const languages = answers[p2 + 2];
    const bikeFlat = answers[p2 + 3] ? cleanEmoji(answers[p2 + 3]) : undefined;
    const winter = answers[p2 + 4] ? cleanEmoji(answers[p2 + 4]) : undefined;
    const beauxParents = answers[p2 + 5]
      ? cleanEmoji(answers[p2 + 5])
      : undefined;
    const stopSign = answers[p2 + 6]
      ? cleanEmoji(answers[p2 + 6])
      : undefined;
    const travel = answers[p2 + 7] ? cleanEmoji(answers[p2 + 7]) : undefined;
    const funFact = answers[p2 + 8];
    const competitive = answers[p2 + 9]
      ? cleanEmoji(answers[p2 + 9])
      : undefined;

    if (strava) parts.push(`App de sport: ${strava}.`);
    if (skills) parts.push(`Compétences: ${skills}.`);
    if (languages) parts.push(`Langues: ${languages}.`);
    if (bikeFlat) parts.push(`Réparer un flat de vélo? ${bikeFlat}.`);
    if (winter) parts.push(`Bouger l'hiver? ${winter}.`);
    if (beauxParents)
      parts.push(`Les beaux-parents vont l'aimer pour: ${beauxParents}.`);
    if (stopSign)
      parts.push(`Arrêter au stop en bougeant? ${stopSign}.`);
    if (travel) parts.push(`En voyage: ${travel}.`);
    if (funFact) parts.push(`Fun fact: ${funFact}.`);
    if (competitive) parts.push(`Compétitif? ${competitive}.`);
  }

  if (longestRun) parts.push(`Record perso: ${longestRun} en une journée.`);

  return parts.join(" ");
}

function scrollPickerComment(val: number): string {
  if (val <= 5) return "Tout le monde commence quelque part!";
  if (val <= 10) return "Solide, le 10 km c'est un classique!";
  if (val <= 21) return "Demi-marathon? Tu te laisses pas impressionner!";
  if (val <= 42) return "Marathonien! Tu fais partie du club select.";
  return "Ultra sportif! On s'incline devant toi. 🙇";
}

// ── Views ───────────────────────────────────────────────────────────────────

type ViewState =
  | { type: "quiz" }
  | { type: "result"; bio: string };

export default function BioQuizPage() {
  const router = useRouter();
  const [view, setView] = useState<ViewState>({ type: "quiz" });
  const [currentPage, setCurrentPage] = useState(0);
  const [phase2Unlocked, setPhase2Unlocked] = useState(false);
  const [answers, setAnswers] = useState<Record<number, string>>({});
  const [multiSelections, setMultiSelections] = useState<
    Record<number, Record<string, string>>
  >({});
  const [editableBio, setEditableBio] = useState("");

  const activeQuestions = phase2Unlocked
    ? [...phase1, ...phase2]
    : [...phase1];

  const totalPages = phase2Unlocked
    ? phase1.length + phase2.length + 1
    : phase1.length + 1;

  const isCheckpointPage =
    currentPage === phase1.length && !phase2Unlocked;

  const progress = (() => {
    const answered = Object.keys(answers).length;
    const total = phase2Unlocked
      ? phase1.length + phase2.length
      : phase1.length;
    return Math.min(answered / total, 1);
  })();

  const phase2QuestionIndex =
    phase2Unlocked && currentPage >= phase1.length
      ? currentPage - phase1.length + 1
      : -1;

  const goToPage = useCallback((page: number) => {
    setCurrentPage(page);
  }, []);

  const goNext = useCallback(() => {
    setCurrentPage((p) => Math.min(p + 1, totalPages - 1));
  }, [totalPages]);

  const goBack = useCallback(() => {
    if (currentPage > 0) setCurrentPage((p) => p - 1);
    else router.back();
  }, [currentPage, router]);

  const setAnswer = useCallback(
    (qi: number, value: string) => {
      setAnswers((prev) => ({ ...prev, [qi]: value }));
    },
    [],
  );

  const selectOption = useCallback(
    (qi: number, option: string) => {
      setAnswer(qi, option);
      setTimeout(goNext, 350);
    },
    [setAnswer, goNext],
  );

  const updateMultiSelectAnswer = useCallback(
    (qi: number) => {
      setMultiSelections((prev) => {
        const selections = prev[qi] || {};
        const q = activeQuestions[qi];
        if (!q) return prev;
        const config = multiSelectConfig[q.multiSelectKey || ""];
        if (!config) return prev;
        const hasLevels = config.levels !== null;

        if (Object.keys(selections).length === 0) {
          setAnswers((a) => {
            const next = { ...a };
            delete next[qi];
            return next;
          });
        } else {
          const parts = Object.entries(selections)
            .map(([k, v]) => (hasLevels ? `${k} (${v})` : k))
            .join(", ");
          setAnswers((a) => ({ ...a, [qi]: parts }));
        }
        return prev;
      });
    },
    [activeQuestions],
  );

  const finishPhase1 = useCallback(() => {
    const bio = generateBio(answers, false);
    setEditableBio(bio);
    setView({ type: "result", bio });
  }, [answers]);

  const startPhase2 = useCallback(() => {
    setPhase2Unlocked(true);
    setTimeout(() => goToPage(phase1.length), 50);
  }, [goToPage]);

  const finishAll = useCallback(() => {
    const bio = generateBio(answers, phase2Unlocked);
    setEditableBio(bio);
    setView({ type: "result", bio });
  }, [answers, phase2Unlocked]);

  const acceptBio = useCallback(
    (bio: string) => {
      sessionStorage.setItem("generated_bio", bio);
      router.back();
    },
    [router],
  );

  // ── Result screen ─────────────────────────────────────────────────────────

  if (view.type === "result") {
    return (
      <div className="flex min-h-screen flex-col bg-background">
        <div className="flex items-center px-2 pt-4">
          <button
            onClick={() => setView({ type: "quiz" })}
            className="p-3"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="flex-1 text-center font-heading text-lg font-bold">
            Ta bio
          </h1>
          <div className="w-11" />
        </div>

        <div className="flex-1 px-6 pt-6 pb-8">
          <div className="flex items-center gap-2.5 rounded-xl bg-teal-500/10 px-4 py-3">
            <span className="text-xl">✨</span>
            <p className="text-sm leading-snug">
              Voici ta bio générée! Tu peux la modifier à ta guise.
            </p>
          </div>

          <textarea
            value={editableBio}
            onChange={(e) => setEditableBio(e.target.value)}
            maxLength={500}
            rows={8}
            className="mt-6 w-full rounded-2xl border border-border bg-card px-5 py-4 text-[15px] leading-relaxed outline-none focus:border-primary focus:ring-1 focus:ring-primary"
          />
          <p className="mt-1 text-right text-xs text-muted-foreground">
            {editableBio.length}/500
          </p>

          <button
            onClick={() => acceptBio(editableBio)}
            className="mt-8 w-full rounded-xl bg-primary py-4 font-heading text-base font-bold text-primary-foreground"
          >
            C&apos;est moi! ✨
          </button>
          <button
            onClick={() => setView({ type: "quiz" })}
            className="mt-3 w-full py-2 text-sm text-muted-foreground"
          >
            Retour aux questions
          </button>
        </div>
      </div>
    );
  }

  // ── Check if we're at the checkpoint to auto-finish ───────────────────────

  const atCheckpoint = isCheckpointPage && currentPage === phase1.length;
  const atPhase2End =
    phase2Unlocked && currentPage === phase1.length + phase2.length;

  // ── Quiz screen ───────────────────────────────────────────────────────────

  return (
    <div className="flex min-h-screen flex-col bg-background">
      {/* Header */}
      <div className="flex items-center px-2 pt-4">
        {currentPage === 0 ? (
          <button onClick={() => router.back()} className="p-3">
            <X className="h-5 w-5" />
          </button>
        ) : (
          <button onClick={goBack} className="p-3">
            <ArrowLeft className="h-5 w-5" />
          </button>
        )}
        <div className="flex-1" />
        <button onClick={goNext} className="px-3 py-2 text-sm text-muted-foreground">
          Passer
        </button>
      </div>

      {/* Progress */}
      <div className="px-6 pt-1">
        <div className="h-1 overflow-hidden rounded-full bg-muted">
          <div
            className="h-full rounded-full bg-primary transition-all duration-400"
            style={{ width: `${progress * 100}%` }}
          />
        </div>
        <p className="mt-1.5 text-center text-sm text-muted-foreground">
          {phase2Unlocked && phase2QuestionIndex > 0
            ? `Question ${phase2QuestionIndex}/${phase2.length} — Dernier sprint!`
            : `${Object.keys(answers).length} / ${phase2Unlocked ? phase1.length + phase2.length : phase1.length} réponses`}
        </p>
      </div>

      {/* Content */}
      <div className="flex flex-1 flex-col overflow-y-auto px-6 pt-6 pb-6">
        {atCheckpoint && (
          <CheckpointView
            count={phase1.length}
            onFinish={finishPhase1}
            onContinue={startPhase2}
          />
        )}

        {atPhase2End && <AutoFinish onFinish={finishAll} />}

        {!atCheckpoint && !atPhase2End && currentPage < activeQuestions.length && (
          <QuestionView
            qi={currentPage}
            question={activeQuestions[currentPage]}
            answer={answers[currentPage]}
            multiSelection={multiSelections[currentPage] || {}}
            setAnswer={setAnswer}
            selectOption={selectOption}
            setMultiSelections={setMultiSelections}
            updateMultiSelectAnswer={updateMultiSelectAnswer}
            goNext={goNext}
          />
        )}
      </div>
    </div>
  );
}

// ── Checkpoint component ────────────────────────────────────────────────────

function CheckpointView({
  count,
  onFinish,
  onContinue,
}: {
  count: number;
  onFinish: () => void;
  onContinue: () => void;
}) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center text-center">
      <div className="flex h-20 w-20 items-center justify-center rounded-full bg-teal-500/15">
        <Check className="h-11 w-11 text-teal-500" />
      </div>
      <h2 className="mt-5 font-heading text-2xl font-extrabold">
        {count} questions complétées!
      </h2>
      <p className="mt-2.5 max-w-xs text-[15px] leading-snug text-muted-foreground">
        On a assez pour te connaître... ou tu veux qu&apos;on creuse un peu
        plus?
      </p>
      <div className="mt-10 w-full max-w-sm space-y-3">
        <button
          onClick={onFinish}
          className="w-full rounded-xl bg-primary py-4 font-heading text-base font-bold text-primary-foreground"
        >
          C&apos;est assez, génère ma bio!
        </button>
        <button
          onClick={onContinue}
          className="w-full rounded-xl border-2 border-primary py-4 font-heading text-base font-bold text-primary"
        >
          Dernière ligne droite! 10 questions finales 🏁
        </button>
        <p className="text-sm italic text-muted-foreground">
          Promis, c&apos;est les dernières. Après ça, ta bio sera encore
          plus complète!
        </p>
      </div>
    </div>
  );
}

// ── Auto finish (phase 2 end) ───────────────────────────────────────────────

function AutoFinish({ onFinish }: { onFinish: () => void }) {
  useEffect(() => {
    onFinish();
  }, [onFinish]);

  return (
    <div className="flex flex-1 items-center justify-center">
      <div className="h-10 w-10 animate-spin rounded-full border-4 border-primary border-t-transparent" />
    </div>
  );
}

// ── Question view ───────────────────────────────────────────────────────────

function QuestionView({
  qi,
  question,
  answer,
  multiSelection,
  setAnswer,
  selectOption,
  setMultiSelections,
  updateMultiSelectAnswer,
  goNext,
}: {
  qi: number;
  question: QuizQuestion;
  answer?: string;
  multiSelection: Record<string, string>;
  setAnswer: (qi: number, value: string) => void;
  selectOption: (qi: number, option: string) => void;
  setMultiSelections: React.Dispatch<
    React.SetStateAction<Record<number, Record<string, string>>>
  >;
  updateMultiSelectAnswer: (qi: number) => void;
  goNext: () => void;
}) {
  if (question.multiSelectKey) {
    return (
      <MultiSelectView
        qi={qi}
        question={question}
        selection={multiSelection}
        setMultiSelections={setMultiSelections}
        updateMultiSelectAnswer={updateMultiSelectAnswer}
        goNext={goNext}
      />
    );
  }

  if (question.scrollMin !== undefined && question.scrollMax !== undefined) {
    return (
      <ScrollPickerView
        qi={qi}
        question={question}
        answer={answer}
        setAnswer={setAnswer}
        goNext={goNext}
      />
    );
  }

  return (
    <div className="flex flex-1 flex-col">
      {question.emoji && (
        <span className="text-[40px]">{question.emoji}</span>
      )}
      <h2 className="mt-3 font-heading text-2xl font-extrabold leading-tight">
        {question.title}
      </h2>
      {question.subtitle && (
        <p className="mt-1.5 text-sm text-muted-foreground">
          {question.subtitle}
        </p>
      )}

      <div className="mt-7 flex flex-1 flex-col">
        {question.isTextInput ? (
          <TextInputView
            qi={qi}
            question={question}
            answer={answer}
            setAnswer={setAnswer}
            goNext={goNext}
          />
        ) : question.options ? (
          <OptionsView
            qi={qi}
            options={question.options}
            selected={answer}
            onSelect={selectOption}
          />
        ) : null}
      </div>
    </div>
  );
}

// ── Text input ──────────────────────────────────────────────────────────────

function TextInputView({
  qi,
  question,
  answer,
  setAnswer,
  goNext,
}: {
  qi: number;
  question: QuizQuestion;
  answer?: string;
  setAnswer: (qi: number, value: string) => void;
  goNext: () => void;
}) {
  return (
    <>
      <input
        type="text"
        value={answer || ""}
        onChange={(e) => setAnswer(qi, e.target.value)}
        placeholder={question.textHint || ""}
        className="w-full rounded-2xl border border-border bg-card px-5 py-4 text-lg outline-none focus:border-primary focus:ring-1 focus:ring-primary"
        autoFocus
      />
      <div className="mt-auto pt-8">
        <button
          onClick={goNext}
          className="w-full rounded-xl bg-primary py-4 font-heading text-base font-bold text-primary-foreground"
        >
          Continuer
        </button>
      </div>
    </>
  );
}

// ── Single-select options ───────────────────────────────────────────────────

function OptionsView({
  qi,
  options,
  selected,
  onSelect,
}: {
  qi: number;
  options: { label: string; hint?: string }[];
  selected?: string;
  onSelect: (qi: number, option: string) => void;
}) {
  return (
    <div className="space-y-2.5 overflow-y-auto">
      {options.map((opt, i) => {
        const sel = selected === opt.label;
        return (
          <button
            key={i}
            onClick={() => onSelect(qi, opt.label)}
            className={cn(
              "flex w-full items-center gap-3 rounded-2xl border px-5 py-3.5 text-left transition-colors",
              sel
                ? "border-primary bg-primary/10"
                : "border-border bg-card hover:border-primary/30",
            )}
          >
            <div className="min-w-0 flex-1">
              <p
                className={cn(
                  "text-[15px]",
                  sel ? "font-semibold text-primary" : "",
                )}
              >
                {opt.label}
              </p>
              {opt.hint && (
                <p className="mt-0.5 text-sm italic text-muted-foreground">
                  {opt.hint}
                </p>
              )}
            </div>
            {sel && <Check className="h-5 w-5 shrink-0 text-primary" />}
          </button>
        );
      })}
    </div>
  );
}

// ── Multi-select ────────────────────────────────────────────────────────────

function MultiSelectView({
  qi,
  question,
  selection,
  setMultiSelections,
  updateMultiSelectAnswer,
  goNext,
}: {
  qi: number;
  question: QuizQuestion;
  selection: Record<string, string>;
  setMultiSelections: React.Dispatch<
    React.SetStateAction<Record<number, Record<string, string>>>
  >;
  updateMultiSelectAnswer: (qi: number) => void;
  goNext: () => void;
}) {
  const config = multiSelectConfig[question.multiSelectKey || ""];
  if (!config) return null;

  const { items, levels } = config;

  const toggle = (label: string) => {
    setMultiSelections((prev) => {
      const current = { ...(prev[qi] || {}) };
      if (current[label] !== undefined) {
        delete current[label];
      } else {
        current[label] = levels ? (levels.length > 1 ? levels[1] : levels[0]) : "";
      }
      return { ...prev, [qi]: current };
    });
    setTimeout(() => updateMultiSelectAnswer(qi), 0);
  };

  const setLevel = (label: string, lvl: string) => {
    setMultiSelections((prev) => {
      const current = { ...(prev[qi] || {}) };
      current[label] = lvl;
      return { ...prev, [qi]: current };
    });
    setTimeout(() => updateMultiSelectAnswer(qi), 0);
  };

  const hasSelections = Object.keys(selection).length > 0;

  return (
    <div className="flex flex-1 flex-col">
      {question.emoji && (
        <span className="text-[40px]">{question.emoji}</span>
      )}
      <h2 className="mt-3 font-heading text-2xl font-extrabold leading-tight">
        {question.title}
      </h2>
      {question.subtitle && (
        <p className="mt-1.5 text-sm text-muted-foreground">
          {question.subtitle}
        </p>
      )}

      <div className="mt-5 flex-1 space-y-2 overflow-y-auto">
        {items.map((item) => {
          const isSelected = selection[item.label] !== undefined;
          const currentLevel = selection[item.label];

          return (
            <div
              key={item.label}
              className={cn(
                "rounded-2xl border px-4 py-3 transition-colors",
                isSelected
                  ? "border-primary bg-primary/8"
                  : "border-border bg-card",
              )}
            >
              <button
                onClick={() => toggle(item.label)}
                className="flex w-full items-center gap-3"
              >
                <span className="text-xl">{item.icon}</span>
                <span
                  className={cn(
                    "flex-1 text-left text-base",
                    isSelected ? "font-semibold text-primary" : "",
                  )}
                >
                  {item.label}
                </span>
                {isSelected && (
                  <Check className="h-5 w-5 shrink-0 text-primary" />
                )}
              </button>

              {isSelected && levels && (
                <div className="mt-2.5 flex gap-1.5">
                  {levels.map((lvl) => {
                    const active = currentLevel === lvl;
                    return (
                      <button
                        key={lvl}
                        onClick={() => setLevel(item.label, lvl)}
                        className={cn(
                          "flex-1 rounded-lg py-1.5 text-sm font-medium transition-colors",
                          active
                            ? "bg-primary text-primary-foreground"
                            : "bg-muted text-muted-foreground hover:bg-muted/80",
                        )}
                      >
                        {lvl}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>

      <div className="pt-4">
        <button
          onClick={goNext}
          disabled={!hasSelections}
          className={cn(
            "w-full rounded-xl py-4 font-heading text-base font-bold transition-colors",
            hasSelections
              ? "bg-primary text-primary-foreground"
              : "bg-muted-foreground/30 text-muted-foreground cursor-not-allowed",
          )}
        >
          Continuer
        </button>
      </div>
    </div>
  );
}

// ── Scroll picker ───────────────────────────────────────────────────────────

function ScrollPickerView({
  qi,
  question,
  answer,
  setAnswer,
  goNext,
}: {
  qi: number;
  question: QuizQuestion;
  answer?: string;
  setAnswer: (qi: number, value: string) => void;
  goNext: () => void;
}) {
  const min = question.scrollMin!;
  const max = question.scrollMax!;
  const step = question.scrollStep || 1;
  const unit = question.scrollUnit || "";

  const currentVal = answer
    ? parseInt(answer.replace(/[^0-9]/g, ""), 10) || min
    : min + Math.floor((max - min) / 3);

  const increment = () => {
    const next = Math.min(currentVal + step, max);
    setAnswer(qi, `${next} ${unit}`);
  };

  const decrement = () => {
    const next = Math.max(currentVal - step, min);
    setAnswer(qi, `${next} ${unit}`);
  };

  const handleSlider = (e: React.ChangeEvent<HTMLInputElement>) => {
    setAnswer(qi, `${e.target.value} ${unit}`);
  };

  return (
    <div className="flex flex-1 flex-col">
      {question.emoji && (
        <span className="text-[40px]">{question.emoji}</span>
      )}
      <h2 className="mt-3 font-heading text-2xl font-extrabold leading-tight">
        {question.title}
      </h2>
      {question.subtitle && (
        <p className="mt-1.5 text-sm text-muted-foreground">
          {question.subtitle}
        </p>
      )}

      <div className="mt-8 flex flex-1 flex-col items-center justify-center">
        <button
          onClick={increment}
          className="flex h-12 w-12 items-center justify-center rounded-full border border-border bg-card"
        >
          <ChevronUp className="h-6 w-6" />
        </button>

        <div className="my-4 flex items-baseline gap-2 rounded-2xl border border-primary/30 bg-primary/8 px-10 py-5">
          <span className="font-heading text-5xl font-extrabold text-primary">
            {currentVal}
          </span>
          <span className="text-xl font-semibold text-primary/70">{unit}</span>
        </div>

        <button
          onClick={decrement}
          className="flex h-12 w-12 items-center justify-center rounded-full border border-border bg-card"
        >
          <ChevronDown className="h-6 w-6" />
        </button>

        <input
          type="range"
          min={min}
          max={max}
          step={step}
          value={currentVal}
          onChange={handleSlider}
          className="mt-6 w-full max-w-xs accent-primary"
        />
        <div className="flex w-full max-w-xs justify-between text-xs text-muted-foreground">
          <span>
            {min} {unit}
          </span>
          <span>
            {max} {unit}
          </span>
        </div>

        {answer && (
          <p className="mt-4 text-sm italic text-muted-foreground">
            {scrollPickerComment(currentVal)}
          </p>
        )}
      </div>

      <div className="pt-4">
        <button
          onClick={() => {
            if (!answer) setAnswer(qi, `${currentVal} ${unit}`);
            goNext();
          }}
          className="w-full rounded-xl bg-primary py-4 font-heading text-base font-bold text-primary-foreground"
        >
          Continuer
        </button>
      </div>
    </div>
  );
}
