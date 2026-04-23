import Link from "next/link";
import Image from "next/image";
import {
  type KaiEvent,
  IntensityLevel,
  DistanceLabel,
  EventCategory,
  getPriceLabel,
  getEventStatus,
  getSpotsRemaining,
} from "@/lib/types";
import { mockUsers } from "@/lib/data";
import { UserAvatar } from "./user-avatar";
import { cn } from "@/lib/utils";

const neighborhoodImages: Record<string, string> = {
  hochelaga: "/images/neighborhoods/hochelaga.png",
  plateau: "/images/neighborhoods/plateau.png",
  "mile-end": "/images/neighborhoods/mile_end.png",
  "mile end": "/images/neighborhoods/mile_end.png",
  villeray: "/images/neighborhoods/villeray.png",
  rosemont: "/images/neighborhoods/rosemont.png",
  verdun: "/images/neighborhoods/verdun.png",
  griffintown: "/images/neighborhoods/griffintown.png",
  "vieux-port": "/images/neighborhoods/vieux_port.png",
  "vieux port": "/images/neighborhoods/vieux_port.png",
  "vieux-montréal": "/images/neighborhoods/vieux_port.png",
};

function getNeighborhoodImage(neighborhood: string): string | null {
  const normalized = neighborhood.toLowerCase();
  for (const [key, path] of Object.entries(neighborhoodImages)) {
    if (normalized.includes(key)) return path;
  }
  return null;
}

interface EventCardProps {
  event: KaiEvent;
  compact?: boolean;
}

export function EventCard({ event, compact }: EventCardProps) {
  const status = getEventStatus(event);
  const spots = getSpotsRemaining(event);
  const intensity = IntensityLevel[event.intensityLevel];
  const distance = DistanceLabel[event.distanceLabel];
  const bannerSrc = getNeighborhoodImage(event.neighborhood);
  const isRegistered = event.registrationStatus === "confirmed";

  const organizers = event.organizerIds
    .map((id) => mockUsers.find((u) => u.id === id))
    .filter(Boolean) as (typeof mockUsers)[number][];

  const menFlex = Math.max(1, Math.round(event.menCount));
  const womenFlex = Math.max(1, Math.round(event.womenCount));

  return (
    <Link href={`/events/${event.id}`} className="block">
      <div
        className={cn(
          "overflow-hidden rounded-2xl border bg-card transition-shadow hover:shadow-md",
          isRegistered ? "border-teal/40" : "border-border",
        )}
      >
        {/* Neighborhood banner */}
        {bannerSrc && (
          <div className="relative h-[140px] w-full">
            <Image
              src={bannerSrc}
              alt={event.neighborhood}
              fill
              className="object-cover"
            />
          </div>
        )}

        {/* Card body */}
        <div className={cn("space-y-2.5", compact ? "p-3" : "p-5")}>
          {/* Title + registered badge */}
          <div className="flex items-center justify-between">
            <h3 className="font-heading text-xl font-bold leading-tight">
              {event.neighborhood}
            </h3>
            {isRegistered && (
              <span className="inline-flex items-center gap-1 rounded-full bg-teal/15 px-2.5 py-1 text-xs font-bold text-teal">
                ✓ Inscrit
              </span>
            )}
          </div>

          {/* Date */}
          <div className="flex items-center gap-1.5 text-sm">
            <span className="text-muted-foreground">📅</span>
            <span className="font-semibold">
              {new Date(event.date).toLocaleDateString("fr-CA", {
                weekday: "long",
                day: "numeric",
                month: "short",
                hour: "2-digit",
                minute: "2-digit",
              })}
            </span>
          </div>

          {/* Category */}
          <div className="flex items-center gap-1.5 text-[13px] text-muted-foreground">
            <span>{EventCategory[event.category]?.emoji}</span>
            <span className="font-semibold">
              {EventCategory[event.category]?.label}
            </span>
          </div>

          {/* Organizers */}
          {organizers.length > 0 && (
            <div className="flex items-center gap-1.5">
              <div className="flex -space-x-2">
                {organizers.slice(0, 2).map((org) => (
                  <UserAvatar
                    key={org.id}
                    photoUrl={org.photoUrl}
                    firstName={org.firstName}
                    lastName={org.lastName}
                    size="xs"
                    className="border-2 border-card"
                  />
                ))}
              </div>
              <span className="truncate text-[13px] text-muted-foreground">
                Organisé par{" "}
                {organizers.map((o) => o.firstName).join(" & ")}
              </span>
            </div>
          )}

          {/* Registrations + price */}
          <div className="flex items-center gap-1.5 text-sm">
            <span className="text-muted-foreground">👥</span>
            <span className="font-semibold">
              {event.totalRegistered} inscrits
            </span>
            <span
              className={cn(
                "ml-2 rounded-lg px-2 py-0.5 text-[13px] font-bold",
                event.price
                  ? "bg-amber-500/12 text-amber-600"
                  : "bg-teal/12 text-teal",
              )}
            >
              {getPriceLabel(event)}
            </span>
          </div>

          {/* Gender ratio bar */}
          {!compact && (
            <div className="flex items-center gap-2">
              <span className="w-9 text-right text-sm font-semibold text-navy">
                {event.menCount}
              </span>
              <div className="flex h-2.5 flex-1 overflow-hidden rounded-md">
                <div
                  className="bg-navy"
                  style={{
                    flex: menFlex,
                  }}
                />
                <div
                  className="bg-primary"
                  style={{
                    flex: womenFlex,
                  }}
                />
              </div>
              <span className="w-9 text-sm font-semibold text-primary">
                {event.womenCount}
              </span>
            </div>
          )}

          {/* Spots warning + countdown */}
          {!compact && (
            <div className="flex items-center justify-between text-xs">
              {spots <= 5 && spots > 0 && status === "upcoming" ? (
                <span className="font-semibold text-orange-500">
                  {spots} place{spots > 1 ? "s" : ""} restante
                  {spots > 1 ? "s" : ""}
                </span>
              ) : (
                <span />
              )}
              {event.aperoSmoothieSpot && (
                <span className="text-muted-foreground">
                  🥤 {event.aperoSmoothieSpot}
                </span>
              )}
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
