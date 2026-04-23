"use client";

import { useState, useMemo, useCallback } from "react";
import Image from "next/image";
import { mockUsers, currentUser } from "@/lib/data";
import { BadgeLevel, EventCategory } from "@/lib/types";
import type { User, EventCategoryKey } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { cn } from "@/lib/utils";
import {
  Search,
  MapPin,
  Star,
  ChevronRight,
  ChevronDown,
  ArrowUpDown,
  X,
  Sparkles,
  SearchX,
  Shield,
} from "lucide-react";

type SortMode = "recentActivity" | "totalActivities";

const SORT_LABELS: Record<SortMode, string> = {
  recentActivity: "Récents",
  totalActivities: "Plus d'activités",
};

const GENDER_OPTIONS = ["Homme", "Femme"];

const ALL_CITIES = Array.from(new Set(mockUsers.map((u) => u.city))).sort();

export default function MembersPage() {
  const [search, setSearch] = useState("");
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  const [filterGender, setFilterGender] = useState<string | null>(null);
  const [filterCity, setFilterCity] = useState<string | null>(null);
  const [filterActivity, setFilterActivity] = useState<EventCategoryKey | null>(
    null,
  );
  const [sort, setSort] = useState<SortMode>("recentActivity");

  const [openPicker, setOpenPicker] = useState<string | null>(null);

  const hasActiveFilters =
    filterGender !== null || filterCity !== null || filterActivity !== null;

  const clearFilters = useCallback(() => {
    setFilterGender(null);
    setFilterCity(null);
    setFilterActivity(null);
    setSearch("");
  }, []);

  const otherUsers = useMemo(
    () => mockUsers.filter((u) => u.id !== currentUser.id),
    [],
  );

  const discoveryUsers = useMemo(() => {
    return otherUsers
      .filter((u) =>
        u.activities.some((a) =>
          currentUser.activities.some((ca) => ca.category === a.category),
        ),
      )
      .slice(0, 5);
  }, [otherUsers]);

  const filtered = useMemo(() => {
    let users = [...otherUsers];

    if (search) {
      const q = search.toLowerCase();
      users = users.filter(
        (u) =>
          u.firstName.toLowerCase().includes(q) ||
          u.lastName.toLowerCase().includes(q) ||
          u.city.toLowerCase().includes(q) ||
          (u.neighborhood?.toLowerCase().includes(q) ?? false),
      );
    }

    if (filterGender) {
      users = users.filter((u) => u.gender === filterGender);
    }
    if (filterCity) {
      users = users.filter((u) => u.city === filterCity);
    }
    if (filterActivity) {
      users = users.filter((u) =>
        u.activities.some((a) => a.category === filterActivity),
      );
    }

    if (sort === "totalActivities") {
      users.sort((a, b) => b.totalActivities - a.totalActivities);
    } else {
      users.sort((a, b) => {
        const da = a.lastActivityDate
          ? new Date(a.lastActivityDate).getTime()
          : 0;
        const db = b.lastActivityDate
          ? new Date(b.lastActivityDate).getTime()
          : 0;
        return db - da;
      });
    }

    return users;
  }, [otherUsers, search, filterGender, filterCity, filterActivity, sort]);

  const openProfile = useCallback((user: User) => {
    setSelectedUser(user);
    setSheetOpen(true);
  }, []);

  const isOnline = (user: User) => {
    if (!user.lastSeenDate) return false;
    return (
      Date.now() - new Date(user.lastSeenDate).getTime() < 24 * 60 * 60 * 1000
    );
  };

  return (
    <div
      className="min-h-screen bg-background"
      onClick={() => openPicker && setOpenPicker(null)}
    >
      {/* Title */}
      <div className="px-5 pt-8 pb-0">
        <h1 className="font-heading text-[28px] font-extrabold">Membres</h1>
      </div>

      {/* Search */}
      <div className="px-5 pt-4 pb-2">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <input
            type="text"
            placeholder="Rechercher un membre..."
            aria-label="Rechercher un membre"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-[14px] border-none bg-card py-3 pl-10 pr-10 text-[15px] placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/30"
          />
          {search && (
            <button
              onClick={() => setSearch("")}
              className="absolute right-3 top-1/2 -translate-y-1/2 text-muted-foreground hover:text-foreground"
            >
              <X className="h-4 w-4" />
            </button>
          )}
        </div>
      </div>

      {/* Filter chips */}
      <div className="flex gap-2 overflow-x-auto px-5 py-1 scrollbar-none">
        {hasActiveFilters && (
          <button
            onClick={(e) => {
              e.stopPropagation();
              clearFilters();
            }}
            className="shrink-0 rounded-full bg-destructive/10 px-3.5 py-2 text-[13px] font-semibold text-destructive"
          >
            Effacer
          </button>
        )}

        {/* Gender filter */}
        <FilterChip
          label={filterGender ?? "Genre"}
          active={filterGender !== null}
          isOpen={openPicker === "gender"}
          onToggle={(e) => {
            e.stopPropagation();
            setOpenPicker(openPicker === "gender" ? null : "gender");
          }}
          options={GENDER_OPTIONS}
          selected={filterGender}
          onSelect={(v) => {
            setFilterGender(filterGender === v ? null : v);
            setOpenPicker(null);
          }}
        />

        {/* City filter */}
        <FilterChip
          label={filterCity ?? "Quartier"}
          active={filterCity !== null}
          isOpen={openPicker === "city"}
          onToggle={(e) => {
            e.stopPropagation();
            setOpenPicker(openPicker === "city" ? null : "city");
          }}
          options={ALL_CITIES}
          selected={filterCity}
          onSelect={(v) => {
            setFilterCity(filterCity === v ? null : v);
            setOpenPicker(null);
          }}
        />

        {/* Activity filter */}
        <div className="relative shrink-0" onClick={(e) => e.stopPropagation()}>
          <button
            onClick={() =>
              setOpenPicker(openPicker === "activity" ? null : "activity")
            }
            className={cn(
              "flex items-center gap-1 rounded-full border px-3.5 py-2 text-[13px] font-semibold transition-colors",
              filterActivity
                ? "border-primary bg-primary/10 text-primary"
                : "border-border bg-card text-foreground",
            )}
          >
            {filterActivity
              ? `${EventCategory[filterActivity].emoji} ${EventCategory[filterActivity].label}`
              : "Sport"}
            <ChevronDown className="h-4 w-4" />
          </button>
          {openPicker === "activity" && (
            <div className="absolute left-0 top-full z-50 mt-1 max-h-72 w-56 overflow-y-auto rounded-xl border bg-popover p-1 shadow-lg">
              {(
                Object.keys(EventCategory) as EventCategoryKey[]
              ).map((key) => (
                <button
                  key={key}
                  onClick={() => {
                    setFilterActivity(filterActivity === key ? null : key);
                    setOpenPicker(null);
                  }}
                  className={cn(
                    "flex w-full items-center gap-2.5 rounded-lg px-3 py-2 text-left text-sm transition-colors hover:bg-accent",
                    filterActivity === key && "font-bold",
                  )}
                >
                  <span className="text-lg">
                    {EventCategory[key].emoji}
                  </span>
                  <span className="flex-1">{EventCategory[key].label}</span>
                  {filterActivity === key && (
                    <span className="text-primary">✓</span>
                  )}
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Sort chip */}
        <button
          onClick={(e) => {
            e.stopPropagation();
            const modes: SortMode[] = ["recentActivity", "totalActivities"];
            const next = modes[(modes.indexOf(sort) + 1) % modes.length];
            setSort(next);
          }}
          className="flex shrink-0 items-center gap-1.5 rounded-full border border-border bg-card px-3.5 py-2 text-[13px] font-semibold text-foreground transition-colors"
        >
          <ArrowUpDown className="h-3.5 w-3.5 text-muted-foreground" />
          {SORT_LABELS[sort]}
        </button>
      </div>

      {/* Discovery section */}
      {discoveryUsers.length > 0 && !search && !hasActiveFilters && (
        <section className="mt-5">
          <div className="flex items-center gap-2 px-5 pb-3">
            <Sparkles className="h-5 w-5 text-primary" />
            <h2 className="font-heading text-lg font-bold">
              Sports en commun
            </h2>
          </div>
          <div className="flex gap-3 overflow-x-auto px-5 pb-2 scrollbar-none">
            {discoveryUsers.map((user) => (
              <DiscoveryCard
                key={user.id}
                user={user}
                online={isOnline(user)}
                onTap={() => openProfile(user)}
              />
            ))}
          </div>
        </section>
      )}

      {/* Members count */}
      <div className="px-5 pt-5 pb-2">
        <p className="text-sm font-semibold text-muted-foreground">
          {filtered.length} membre{filtered.length > 1 ? "s" : ""}
        </p>
      </div>

      {/* Members list */}
      {filtered.length > 0 ? (
        <div className="px-5">
          {filtered.map((user, i) => (
            <div key={user.id}>
              {i > 0 && <div className="mx-1 h-px bg-border/50" />}
              <MemberRow
                user={user}
                online={isOnline(user)}
                onTap={() => openProfile(user)}
              />
            </div>
          ))}
        </div>
      ) : (
        <div className="flex flex-col items-center justify-center px-6 py-20">
          <SearchX className="h-14 w-14 text-muted-foreground/40" />
          <p className="mt-3 text-base text-muted-foreground">
            Aucun membre trouvé
          </p>
          <button
            onClick={clearFilters}
            className="mt-2 text-sm font-medium text-primary hover:underline"
          >
            Effacer les filtres
          </button>
        </div>
      )}

      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
    </div>
  );
}

/* ─── Filter Chip with Dropdown ─── */

function FilterChip({
  label,
  active,
  isOpen,
  onToggle,
  options,
  selected,
  onSelect,
}: {
  label: string;
  active: boolean;
  isOpen: boolean;
  onToggle: (e: React.MouseEvent) => void;
  options: string[];
  selected: string | null;
  onSelect: (v: string) => void;
}) {
  return (
    <div className="relative shrink-0" onClick={(e) => e.stopPropagation()}>
      <button
        onClick={onToggle}
        className={cn(
          "flex items-center gap-1 rounded-full border px-3.5 py-2 text-[13px] font-semibold transition-colors",
          active
            ? "border-primary bg-primary/10 text-primary"
            : "border-border bg-card text-foreground",
        )}
      >
        {label}
        <ChevronDown className="h-4 w-4" />
      </button>
      {isOpen && (
        <div className="absolute left-0 top-full z-50 mt-1 min-w-[160px] rounded-xl border bg-popover p-1 shadow-lg">
          {options.map((opt) => (
            <button
              key={opt}
              onClick={() => onSelect(opt)}
              className={cn(
                "flex w-full items-center justify-between rounded-lg px-3 py-2 text-left text-sm transition-colors hover:bg-accent",
                selected === opt && "font-bold",
              )}
            >
              {opt}
              {selected === opt && (
                <span className="text-primary">✓</span>
              )}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

/* ─── Discovery Card ─── */

function DiscoveryCard({
  user,
  online,
  onTap,
}: {
  user: User;
  online: boolean;
  onTap: () => void;
}) {
  const hasPhoto = !!user.photoUrl;

  return (
    <button
      onClick={onTap}
      className="w-40 shrink-0 overflow-hidden rounded-2xl border border-border/50 bg-card text-left"
    >
      {/* Photo area */}
      <div className="relative h-[130px] w-full">
        {hasPhoto ? (
          <Image
            src={user.photoUrl!}
            alt={user.firstName}
            fill
            className="object-cover"
          />
        ) : (
          <div className="flex h-full w-full items-center justify-center bg-primary/10">
            <span className="font-heading text-4xl font-bold text-primary/60">
              {user.firstName[0]}
            </span>
          </div>
        )}
        {/* Gradient overlay with name */}
        <div className="absolute inset-x-0 bottom-0 bg-gradient-to-t from-black/60 via-black/20 to-transparent px-2.5 pb-2 pt-5">
          <p className="text-sm font-bold text-white drop-shadow">
            {user.firstName}, {user.age}
          </p>
        </div>
        {user.isVerified && (
          <div className="absolute right-2 top-2 rounded-full bg-white/30 p-0.5 backdrop-blur-sm">
            <Shield className="h-3.5 w-3.5 text-white" />
          </div>
        )}
        {online && (
          <div className="absolute left-2 top-2 h-2.5 w-2.5 rounded-full border-[1.5px] border-white bg-emerald-500" />
        )}
      </div>
      {/* Bottom info */}
      <div className="space-y-1 px-2.5 py-2">
        <div className="flex items-center gap-1 text-muted-foreground">
          <MapPin className="h-3 w-3" />
          <span className="truncate text-[11px]">
            {user.neighborhood ?? user.city}
          </span>
        </div>
        {user.activities.length > 0 && (
          <p className="truncate text-xs">
            {user.activities.map((a) => EventCategory[a.category].emoji).join(" ")}
          </p>
        )}
      </div>
    </button>
  );
}

/* ─── Member Row ─── */

function MemberRow({
  user,
  online,
  onTap,
}: {
  user: User;
  online: boolean;
  onTap: () => void;
}) {
  const badge = BadgeLevel[user.badge];

  return (
    <button
      onClick={onTap}
      className="flex w-full items-center gap-3.5 rounded-2xl px-1 py-2.5 text-left transition-colors hover:bg-accent/50"
    >
      {/* Avatar with online indicator */}
      <div className="relative shrink-0">
        <UserAvatar
          photoUrl={user.photoUrl}
          firstName={user.firstName}
          lastName={user.lastName}
          size="lg"
          className="h-[72px] w-[72px] text-base"
        />
        {online && (
          <div className="absolute bottom-0.5 right-0.5 h-3.5 w-3.5 rounded-full border-2 border-background bg-emerald-500" />
        )}
      </div>

      {/* Info */}
      <div className="min-w-0 flex-1 space-y-0.5">
        {/* Name row */}
        <div className="flex items-center gap-1.5">
          <span className="truncate text-base font-bold">
            {user.firstName}, {user.age}
          </span>
          {user.isVerified && (
            <Shield className="h-4 w-4 shrink-0 text-teal-500" />
          )}
          <span className="shrink-0 text-sm">{badge.icon}</span>
        </div>

        {/* Location */}
        <div className="flex items-center gap-1 text-muted-foreground">
          <MapPin className="h-3.5 w-3.5 shrink-0" />
          <span className="truncate text-[13px]">
            {user.neighborhood ?? user.city}
          </span>
        </div>

        {/* Activities */}
        {user.activities.length > 0 && (
          <p className="truncate text-sm">
            {user.activities
              .map((a) => EventCategory[a.category].emoji)
              .join(" ")}
          </p>
        )}

        {/* Stats row */}
        <div className="flex items-center gap-1.5">
          <span className="text-xs text-muted-foreground">
            {user.totalActivities} activité
            {user.totalActivities > 1 ? "s" : ""}
          </span>
          {user.averageRating != null && (
            <>
              <span className="text-xs text-muted-foreground">·</span>
              <Star className="h-3.5 w-3.5 shrink-0 fill-amber-400 text-amber-400" />
              <span className="text-xs font-semibold text-amber-500">
                {user.averageRating.toFixed(1)}
              </span>
            </>
          )}
          {user.isOrganizer && (
            <span className="ml-1 inline-flex items-center gap-1 rounded-lg bg-teal-500/10 px-1.5 py-0.5 text-[11px] font-semibold text-teal-600">
              <Shield className="h-3 w-3" />
              Organisateur
            </span>
          )}
        </div>

        {/* Bio */}
        {user.bio && (
          <p className="truncate text-xs italic text-muted-foreground/70">
            &laquo; {user.bio} &raquo;
          </p>
        )}
      </div>

      <ChevronRight className="h-5 w-5 shrink-0 text-muted-foreground/40" />
    </button>
  );
}
