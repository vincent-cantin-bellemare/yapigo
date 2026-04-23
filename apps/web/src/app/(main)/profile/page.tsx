import Link from "next/link";
import { currentUser } from "@/lib/data";
import { BadgeLevel, EventCategory } from "@/lib/types";
import { UserAvatar } from "@/components/shared/user-avatar";
import { ClickableUser } from "@/components/shared/clickable-user";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import {
  Edit,
  Eye,
  Shield,
  CreditCard,
  Link2,
  HelpCircle,
  Globe,
  Moon,
  ChevronRight,
  MapPin,
  Star,
  TrendingUp,
  Award,
} from "lucide-react";

const menuSections = [
  {
    title: "Compte",
    items: [
      { label: "Modifier le profil", icon: Edit, href: "/profile/edit" },
      { label: "Vérifier mon identité", icon: Shield, href: "#" },
      { label: "Inviter un ami", icon: Link2, href: "#" },
    ],
  },
  {
    title: "Facturation",
    items: [{ label: "Factures et paiement", icon: CreditCard, href: "#" }],
  },
  {
    title: "Connexions",
    items: [{ label: "Strava", icon: Link2, href: "#", connected: true }],
  },
  {
    title: "Aide",
    items: [
      { label: "Aide et infos légales", icon: HelpCircle, href: "#" },
      { label: "Langue", icon: Globe, href: "#" },
      { label: "Thème", icon: Moon, href: "#" },
    ],
  },
];

export default function ProfilePage() {
  const badge = BadgeLevel[currentUser.badge];
  const nextBadge = (() => {
    const keys = Object.keys(BadgeLevel) as (keyof typeof BadgeLevel)[];
    const idx = keys.indexOf(currentUser.badge);
    return idx < keys.length - 1 ? BadgeLevel[keys[idx + 1]] : null;
  })();
  const xpProgress = nextBadge
    ? ((currentUser.xp - badge.minXp) / (nextBadge.minXp - badge.minXp)) * 100
    : 100;

  return (
    <div>
      {/* Profile Header */}
      <section className="bg-gradient-to-br from-navy via-navy-blue to-ocean px-6 pb-8 pt-12 text-white">
        <div className="mx-auto flex max-w-2xl items-center gap-5">
          <UserAvatar
            photoUrl={currentUser.photoUrl}
            firstName={currentUser.firstName}
            lastName={currentUser.lastName}
            size="xl"
            className="border-2 border-white/30"
          />
          <div className="min-w-0 flex-1">
            <h1 className="truncate font-heading text-2xl font-bold">
              {currentUser.firstName} {currentUser.lastName}
            </h1>
            <div className="mt-1 flex items-center gap-2 text-sm text-white/70">
              <MapPin className="h-3.5 w-3.5" />
              <span>{currentUser.neighborhood ?? currentUser.city}</span>
              {currentUser.isVerified && (
                <Badge
                  variant="secondary"
                  className="bg-white/20 text-xs text-white"
                >
                  Vérifié ✓
                </Badge>
              )}
            </div>
            <div className="mt-2 flex items-center gap-2">
              <Badge
                variant="secondary"
                className="bg-white/20 text-white"
              >
                {badge.icon} {badge.label}
              </Badge>
              <span className="text-xs text-white/50">
                {currentUser.xp} XP
              </span>
            </div>
          </div>
        </div>

        {/* Preview profile button */}
        <div className="mx-auto mt-4 max-w-2xl">
          <ClickableUser user={currentUser} className="flex w-full items-center justify-center gap-2 rounded-xl bg-white/15 py-2.5 text-sm font-semibold text-white hover:bg-white/20 transition-colors" isOwnProfile>
            <Eye className="h-4 w-4" />
            Aperçu de mon profil
          </ClickableUser>
        </div>
      </section>

      <div className="mx-auto max-w-2xl px-4 py-6 space-y-6">
        {/* XP Progress */}
        {nextBadge && (
          <Card>
            <CardContent className="p-4">
              <div className="flex items-center justify-between text-sm">
                <span className="font-medium">
                  {badge.icon} {badge.label}
                </span>
                <span className="text-muted-foreground">
                  {nextBadge.icon} {nextBadge.label}
                </span>
              </div>
              <div className="mt-2 h-2 overflow-hidden rounded-full bg-muted">
                <div
                  className="h-full rounded-full bg-gradient-to-r from-teal to-primary"
                  style={{ width: `${xpProgress}%` }}
                />
              </div>
              <p className="mt-1 text-xs text-muted-foreground">
                {nextBadge.minXp - currentUser.xp} XP restants pour{" "}
                {nextBadge.label}
              </p>
            </CardContent>
          </Card>
        )}

        {/* Stats */}
        <div className="grid grid-cols-3 gap-3">
          <Card>
            <CardContent className="flex flex-col items-center p-3 text-center">
              <TrendingUp className="h-5 w-5 text-primary" />
              <p className="mt-1 font-heading text-lg font-bold">
                {currentUser.totalKm}
              </p>
              <p className="text-xs text-muted-foreground">km parcourus</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="flex flex-col items-center p-3 text-center">
              <Award className="h-5 w-5 text-primary" />
              <p className="mt-1 font-heading text-lg font-bold">
                {currentUser.totalActivities}
              </p>
              <p className="text-xs text-muted-foreground">activités</p>
            </CardContent>
          </Card>
          <Card>
            <CardContent className="flex flex-col items-center p-3 text-center">
              <Star className="h-5 w-5 fill-amber-400 text-amber-400" />
              <p className="mt-1 font-heading text-lg font-bold">
                {currentUser.averageRating?.toFixed(1) ?? "—"}
              </p>
              <p className="text-xs text-muted-foreground">note moyenne</p>
            </CardContent>
          </Card>
        </div>

        {/* Bio */}
        {currentUser.bio && (
          <Card>
            <CardContent className="p-4">
              <h3 className="font-heading font-bold">Bio</h3>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                {currentUser.bio}
              </p>
            </CardContent>
          </Card>
        )}

        {/* Activities */}
        <Card>
          <CardContent className="p-4">
            <h3 className="font-heading font-bold">Mes activités</h3>
            <div className="mt-2 flex flex-wrap gap-2">
              {currentUser.activities.map((a) => (
                <Badge key={a.category} variant="outline">
                  {EventCategory[a.category].emoji}{" "}
                  {EventCategory[a.category].label}
                </Badge>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Menu Sections */}
        {menuSections.map((section) => (
          <Card key={section.title}>
            <CardContent className="p-0">
              <h3 className="px-4 pt-4 font-heading text-sm font-bold text-muted-foreground uppercase tracking-wider">
                {section.title}
              </h3>
              <div className="mt-2">
                {section.items.map((item, i) => {
                  const Icon = item.icon;
                  return (
                    <div key={item.label}>
                      {i > 0 && <Separator className="mx-4" />}
                      <Link
                        href={item.href}
                        className="flex items-center gap-3 px-4 py-3 hover:bg-muted/50"
                      >
                        <Icon className="h-5 w-5 text-muted-foreground" />
                        <span className="flex-1 text-sm">{item.label}</span>
                        {"connected" in item && item.connected && (
                          <Badge
                            variant="secondary"
                            className="text-xs text-emerald-600"
                          >
                            Connecté
                          </Badge>
                        )}
                        <ChevronRight className="h-4 w-4 text-muted-foreground" />
                      </Link>
                    </div>
                  );
                })}
              </div>
            </CardContent>
          </Card>
        ))}

        <p className="pb-4 text-center text-xs text-muted-foreground">
          Run Date v3.2.2 (69) — rundate.app
        </p>
      </div>
    </div>
  );
}
