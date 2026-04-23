"use client";

import { useState, useMemo } from "react";
import { mockEvents } from "@/lib/data";
import { getEventStatus } from "@/lib/types";
import { EventCard } from "@/components/shared/event-card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Search, SlidersHorizontal } from "lucide-react";

type Tab = "upcoming" | "registered" | "past";

export default function EventsPage() {
  const [activeTab, setActiveTab] = useState<Tab>("upcoming");
  const [search, setSearch] = useState("");

  const categorized = useMemo(() => {
    const upcoming = mockEvents.filter((e) => getEventStatus(e) !== "past");
    const registered = mockEvents.filter(
      (e) => e.registrationStatus === "confirmed" && getEventStatus(e) !== "past",
    );
    const past = mockEvents.filter((e) => getEventStatus(e) === "past");
    return { upcoming, registered, past };
  }, []);

  const filtered = useMemo(() => {
    const list = categorized[activeTab];
    if (!search) return list;
    const q = search.toLowerCase();
    return list.filter(
      (e) =>
        e.neighborhood.toLowerCase().includes(q) ||
        e.city.toLowerCase().includes(q),
    );
  }, [categorized, activeTab, search]);

  return (
    <div>
      <header className="bg-gradient-to-r from-ocean to-deep-teal px-6 pb-4 pt-12 text-white">
        <h1 className="font-heading text-2xl font-bold">Activités</h1>
        <div className="relative mt-3">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/60" />
          <input
            type="text"
            placeholder="Rechercher un quartier..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            aria-label="Rechercher un quartier"
            className="w-full rounded-xl bg-white/15 py-2.5 pl-10 pr-10 text-sm text-white placeholder:text-white/50 backdrop-blur-sm focus:bg-white/20 focus:outline-none"
          />
          <button className="absolute right-3 top-1/2 -translate-y-1/2" aria-label="Filtres">
            <SlidersHorizontal className="h-4 w-4 text-white/60" />
          </button>
        </div>
      </header>

      <div className="mx-auto max-w-4xl px-4 py-4">
        <Tabs
          value={activeTab}
          onValueChange={(v) => setActiveTab(v as Tab)}
        >
          <TabsList className="w-full">
            <TabsTrigger value="upcoming" className="flex-1">
              Prochains
              <Badge variant="secondary" className="ml-1.5 text-xs">
                {categorized.upcoming.length}
              </Badge>
            </TabsTrigger>
            <TabsTrigger value="registered" className="flex-1">
              Inscrits
              <Badge variant="secondary" className="ml-1.5 text-xs">
                {categorized.registered.length}
              </Badge>
            </TabsTrigger>
            <TabsTrigger value="past" className="flex-1">
              Passés
              <Badge variant="secondary" className="ml-1.5 text-xs">
                {categorized.past.length}
              </Badge>
            </TabsTrigger>
          </TabsList>

          <TabsContent value={activeTab} className="mt-4">
            {filtered.length === 0 ? (
              <div className="py-12 text-center text-muted-foreground">
                <p className="text-lg">Aucune activité trouvée</p>
                <p className="mt-1 text-sm">
                  Essaie un autre quartier ou reviens plus tard
                </p>
              </div>
            ) : (
              <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
                {filtered.map((event) => (
                  <EventCard key={event.id} event={event} />
                ))}
              </div>
            )}
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
