import Link from "next/link";
import { notFound } from "next/navigation";
import { mockEvents, mockUsers } from "@/lib/data";
import {
  IntensityLevel,
  DistanceLabel,
  RecurrenceType,
  getPriceLabel,
  getRecurrenceLabel,
  getSpotsRemaining,
  getNeededForThreshold,
} from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { ClickableUser } from "@/components/shared/clickable-user";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import {
  ArrowLeft,
  Calendar,
  Clock,
  MapPin,
  Users,
  TrendingUp,
  Coffee,
  Share2,
  MessageSquare,
} from "lucide-react";

interface Props {
  params: Promise<{ id: string }>;
}

export default async function EventDetailPage({ params }: Props) {
  const { id } = await params;
  const event = mockEvents.find((e) => e.id === id);

  if (!event) notFound();

  const intensity = IntensityLevel[event.intensityLevel];
  const distance = DistanceLabel[event.distanceLabel];
  const spots = getSpotsRemaining(event);
  const needed = getNeededForThreshold(event);
  const organizers = event.organizerIds
    .map((oid) => mockUsers.find((u) => u.id === oid))
    .filter(Boolean);
  const fillPercent = Math.round(
    (event.totalRegistered / event.maxCapacity) * 100,
  );
  const isPast = new Date(event.date) < new Date();
  const isRegistered = event.registrationStatus === "confirmed";

  return (
    <div>
      {/* Header */}
      <section className="relative bg-gradient-to-br from-teal via-cyan to-ocean px-6 pb-8 pt-12 text-white">
        <Link
          href="/events"
          className="mb-4 inline-flex items-center gap-1 text-sm text-white/80 hover:text-white"
        >
          <ArrowLeft className="h-4 w-4" />
          Retour
        </Link>

        <h1 className="font-heading text-3xl font-extrabold">
          {event.neighborhood}
        </h1>
        <p className="mt-1 text-white/80">{event.city}</p>

        <div className="mt-4 flex flex-wrap gap-2">
          <Badge className="bg-white/20 text-white">
            {intensity.emoji} {intensity.label}
          </Badge>
          <Badge className="bg-white/20 text-white">
            {distance.emoji} {distance.label}
          </Badge>
          {event.recurrence !== "oneTime" && (
            <Badge className="bg-white/20 text-white">
              🔄 {getRecurrenceLabel(event)}
            </Badge>
          )}
          <Badge className="bg-white/20 text-white">
            {getPriceLabel(event)}
          </Badge>
        </div>
      </section>

      <div className="mx-auto max-w-2xl space-y-4 px-4 py-6">
        {/* Date & Time */}
        <Card>
          <CardContent className="flex items-center gap-4 p-4">
            <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-primary/10">
              <Calendar className="h-6 w-6 text-primary" />
            </div>
            <div>
              <p className="font-heading font-bold">
                {new Date(event.date).toLocaleDateString("fr-CA", {
                  weekday: "long",
                  day: "numeric",
                  month: "long",
                  year: "numeric",
                })}
              </p>
              <p className="text-sm text-muted-foreground">
                <Clock className="mr-1 inline h-3.5 w-3.5" />
                {new Date(event.date).toLocaleTimeString("fr-CA", {
                  hour: "2-digit",
                  minute: "2-digit",
                })}
                {" · "}Date limite:{" "}
                {new Date(event.deadline).toLocaleDateString("fr-CA", {
                  day: "numeric",
                  month: "short",
                })}
              </p>
            </div>
          </CardContent>
        </Card>

        {/* Registration Gauge */}
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <h3 className="font-heading font-bold">Inscriptions</h3>
              <span className="text-sm text-muted-foreground">
                {event.totalRegistered}/{event.maxCapacity}
              </span>
            </div>
            <div className="mt-2 h-3 overflow-hidden rounded-full bg-muted">
              <div
                className="h-full rounded-full bg-gradient-to-r from-teal to-primary transition-all"
                style={{ width: `${Math.min(fillPercent, 100)}%` }}
              />
            </div>
            <div className="mt-2 flex justify-between text-xs text-muted-foreground">
              <span>
                {event.isConfirmed ? (
                  <span className="font-medium text-emerald-600">
                    ✓ Activité confirmée
                  </span>
                ) : (
                  `${needed} de plus pour confirmer`
                )}
              </span>
              <span>{spots} places restantes</span>
            </div>

            {/* Gender split */}
            <div className="mt-3 flex gap-4 text-sm">
              <span>
                👨 {event.menCount} ({event.totalRegistered > 0 ? Math.round((event.menCount / event.totalRegistered) * 100) : 0}%)
              </span>
              <span>
                👩 {event.womenCount} ({event.totalRegistered > 0 ? Math.round((event.womenCount / event.totalRegistered) * 100) : 0}%)
              </span>
              {event.totalRegistered - event.menCount - event.womenCount > 0 && (
                <span>
                  🧑 {event.totalRegistered - event.menCount - event.womenCount}
                </span>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Organizers */}
        {organizers.length > 0 && (
          <Card>
            <CardContent className="p-4">
              <h3 className="font-heading font-bold">
                Organisé par
              </h3>
              <div className="mt-3 space-y-3">
                {organizers.map(
                  (org) =>
                    org && (
                      <ClickableUser
                        key={org.id}
                        user={org}
                        className="flex items-center gap-3 w-full text-left hover:bg-accent/50 rounded-lg p-1 -m-1 transition-colors"
                      >
                        <UserAvatar
                          photoUrl={org.photoUrl}
                          firstName={org.firstName}
                          lastName={org.lastName}
                          size="md"
                        />
                        <div>
                          <p className="font-medium">
                            {org.firstName} {org.lastName[0]}.
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {org.totalActivities} activités organisées
                          </p>
                        </div>
                      </ClickableUser>
                    ),
                )}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Smoothie Spot */}
        {event.aperoSmoothieSpot && (
          <Card>
            <CardContent className="flex items-center gap-4 p-4">
              <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-amber-50 dark:bg-amber-500/10">
                <Coffee className="h-6 w-6 text-amber-600" />
              </div>
              <div>
                <h3 className="font-heading font-bold">Ravito / Apéro</h3>
                <p className="text-sm text-muted-foreground">
                  {event.aperoSmoothieSpot}
                </p>
              </div>
            </CardContent>
          </Card>
        )}

        {/* How it works */}
        <Card>
          <CardContent className="p-4">
            <h3 className="font-heading font-bold">Comment ça marche</h3>
            <div className="mt-3 space-y-3 text-sm">
              {[
                { step: "1", text: "Inscris-toi avant la date limite" },
                { step: "2", text: "On forme les groupes selon les affinités" },
                { step: "3", text: "Rendez-vous au point de départ" },
                {
                  step: "4",
                  text: "Courrez ensemble, puis profitez du ravito!",
                },
              ].map((s) => (
                <div key={s.step} className="flex items-start gap-3">
                  <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-primary text-xs font-bold text-white">
                    {s.step}
                  </span>
                  <span className="text-muted-foreground">{s.text}</span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Action buttons */}
        {!isPast && (
          <div className="sticky bottom-20 flex gap-3 rounded-xl border border-border bg-card p-4 shadow-lg">
            {isRegistered ? (
              <>
                <Button className="flex-1" variant="outline">
                  <MessageSquare className="mr-2 h-4 w-4" />
                  Chat de groupe
                </Button>
                <Button variant="outline" size="icon">
                  <Share2 className="h-4 w-4" />
                </Button>
              </>
            ) : (
              <>
                <Link
                  href={`/events/${event.id}/apply`}
                  className="inline-flex flex-1 items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-bold text-white hover:bg-primary/90"
                >
                  {event.price
                    ? `S'inscrire · ${getPriceLabel(event)}`
                    : "S'inscrire gratuitement"}
                </Link>
                <Button variant="outline" size="icon">
                  <Share2 className="h-4 w-4" />
                </Button>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
