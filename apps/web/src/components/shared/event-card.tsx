import Link from "next/link";
import {
  Card,
  CardContent,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  type KaiEvent,
  IntensityLevel,
  DistanceLabel,
  getPriceLabel,
  getEventStatus,
  getSpotsRemaining,
} from "@/lib/types";
import { cn } from "@/lib/utils";

interface EventCardProps {
  event: KaiEvent;
  compact?: boolean;
}

export function EventCard({ event, compact }: EventCardProps) {
  const status = getEventStatus(event);
  const spots = getSpotsRemaining(event);
  const intensity = IntensityLevel[event.intensityLevel];
  const distance = DistanceLabel[event.distanceLabel];
  const fillPercent = Math.round(
    (event.totalRegistered / event.maxCapacity) * 100,
  );

  return (
    <Link href={`/events/${event.id}`}>
      <Card className="transition-shadow hover:shadow-md">
        <CardContent className={cn("space-y-3", compact ? "p-3" : "p-4")}>
          <div className="flex items-start justify-between">
            <div>
              <h3 className="font-heading text-lg font-bold leading-tight">
                {event.neighborhood}
              </h3>
              <p className="text-sm text-muted-foreground">
                {event.city} &middot;{" "}
                {new Date(event.date).toLocaleDateString("fr-CA", {
                  weekday: "short",
                  day: "numeric",
                  month: "short",
                  hour: "2-digit",
                  minute: "2-digit",
                })}
              </p>
            </div>
            <Badge
              variant={event.price ? "default" : "secondary"}
              className="shrink-0"
            >
              {getPriceLabel(event)}
            </Badge>
          </div>

          <div className="flex flex-wrap items-center gap-2 text-sm">
            <span>
              {intensity.emoji} {intensity.label}
            </span>
            <span className="text-muted-foreground">&middot;</span>
            <span>
              {distance.emoji} {distance.label}
            </span>
            {event.aperoSmoothieSpot && (
              <>
                <span className="text-muted-foreground">&middot;</span>
                <span>🥤 {event.aperoSmoothieSpot}</span>
              </>
            )}
          </div>

          {!compact && (
            <div className="space-y-1.5">
              <div className="flex items-center justify-between text-sm">
                <span className="text-muted-foreground">
                  {event.totalRegistered}/{event.maxCapacity} inscrits
                </span>
                {status === "upcoming" && spots <= 5 && spots > 0 && (
                  <span className="font-medium text-orange-500">
                    {spots} place{spots > 1 ? "s" : ""} restante
                    {spots > 1 ? "s" : ""}
                  </span>
                )}
                {event.isConfirmed && (
                  <Badge variant="outline" className="text-xs text-emerald-600">
                    Confirmé
                  </Badge>
                )}
              </div>
              <div className="h-1.5 overflow-hidden rounded-full bg-muted">
                <div
                  className={cn(
                    "h-full rounded-full transition-all",
                    fillPercent >= 90
                      ? "bg-orange-500"
                      : fillPercent >= 50
                        ? "bg-primary"
                        : "bg-teal",
                  )}
                  style={{ width: `${Math.min(fillPercent, 100)}%` }}
                />
              </div>
            </div>
          )}
        </CardContent>
      </Card>
    </Link>
  );
}
