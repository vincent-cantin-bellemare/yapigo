"use client";

import { useState, useMemo } from "react";
import { mockUsers, currentUser } from "@/lib/data";
import { BadgeLevel, EventCategory } from "@/lib/types";
import type { User } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { UserProfileSheet } from "@/components/shared/user-profile-sheet";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Search, MapPin, Star } from "lucide-react";

export default function MembersPage() {
  const [search, setSearch] = useState("");
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [sheetOpen, setSheetOpen] = useState(false);

  const otherUsers = useMemo(
    () => mockUsers.filter((u) => u.id !== currentUser.id),
    [],
  );

  const filtered = useMemo(() => {
    if (!search) return otherUsers;
    const q = search.toLowerCase();
    return otherUsers.filter(
      (u) =>
        u.firstName.toLowerCase().includes(q) ||
        u.lastName.toLowerCase().includes(q) ||
        u.city.toLowerCase().includes(q) ||
        (u.neighborhood?.toLowerCase().includes(q) ?? false),
    );
  }, [otherUsers, search]);

  return (
    <div>
      <header className="bg-gradient-to-r from-navy-blue to-navy px-6 pb-4 pt-12 text-white">
        <h1 className="font-heading text-2xl font-bold">Membres</h1>
        <p className="mt-1 text-sm text-white/70">
          {otherUsers.length} coureurs dans la communauté
        </p>
        <div className="relative mt-3">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/60" />
          <input
            type="text"
            placeholder="Rechercher un membre..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full rounded-xl bg-white/15 py-2.5 pl-10 pr-4 text-sm text-white placeholder:text-white/50 backdrop-blur-sm focus:bg-white/20 focus:outline-none"
          />
        </div>
      </header>

      <div className="mx-auto max-w-2xl px-4 py-4">
        {/* Sports in common */}
        <section className="mb-6">
          <h2 className="font-heading text-lg font-bold">
            Sports en commun avec toi
          </h2>
          <div className="mt-2 flex gap-2 overflow-x-auto pb-2">
            {currentUser.activities.map((a) => (
              <Badge key={a.category} variant="outline" className="shrink-0">
                {EventCategory[a.category].emoji}{" "}
                {EventCategory[a.category].label}
              </Badge>
            ))}
          </div>
        </section>

        {/* Members list */}
        <div className="space-y-3">
          {filtered.map((user) => {
            const badge = BadgeLevel[user.badge];
            const commonActivities = user.activities.filter((a) =>
              currentUser.activities.some((ca) => ca.category === a.category),
            );

            return (
              <Card
                key={user.id}
                className="cursor-pointer hover:bg-accent/50 transition-colors"
                onClick={() => {
                  setSelectedUser(user);
                  setSheetOpen(true);
                }}
              >
                <CardContent className="flex items-center gap-4 p-4">
                  <UserAvatar
                    photoUrl={user.photoUrl}
                    firstName={user.firstName}
                    lastName={user.lastName}
                    size="lg"
                  />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center gap-2">
                      <h3 className="truncate font-heading font-bold">
                        {user.firstName} {user.lastName[0]}.
                      </h3>
                      <span className="text-sm">{badge.icon}</span>
                      {user.isVerified && (
                        <span className="text-xs text-primary">✓</span>
                      )}
                    </div>
                    <div className="flex items-center gap-1 text-sm text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5" />
                      <span className="truncate">
                        {user.neighborhood ?? user.city}
                      </span>
                      <span>&middot;</span>
                      <span>{user.age} ans</span>
                    </div>
                    {commonActivities.length > 0 && (
                      <div className="mt-1 flex gap-1">
                        {commonActivities.map((a) => (
                          <span key={a.category} className="text-sm">
                            {EventCategory[a.category].emoji}
                          </span>
                        ))}
                        <span className="text-xs text-muted-foreground">
                          en commun
                        </span>
                      </div>
                    )}
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    {user.averageRating && (
                      <div className="flex items-center gap-1 text-sm">
                        <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                        <span>{user.averageRating.toFixed(1)}</span>
                      </div>
                    )}
                    <span className="text-xs text-muted-foreground">
                      {user.totalActivities} activités
                    </span>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>

      <UserProfileSheet
        user={selectedUser}
        open={sheetOpen}
        onOpenChange={setSheetOpen}
      />
    </div>
  );
}
