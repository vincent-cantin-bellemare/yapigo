"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  Home,
  Calendar,
  Users,
  MessageSquare,
  User,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { cn } from "@/lib/utils";

const navItems = [
  { href: "/", icon: Home, label: "Accueil" },
  { href: "/events", icon: Calendar, label: "Activités" },
  { href: "/members", icon: Users, label: "Membres" },
  { href: "/activity", icon: MessageSquare, label: "Activité", badge: 10 },
  { href: "/profile", icon: User, label: "Profil" },
] as const;

function isActive(pathname: string, href: string): boolean {
  if (href === "/") return pathname === "/";
  return pathname.startsWith(href);
}

export function DesktopNav() {
  const pathname = usePathname();

  return (
    <nav className="sticky top-0 flex h-screen w-56 shrink-0 flex-col border-r border-border bg-card py-6">
      <div className="px-5 pb-6">
        <h1 className="font-heading text-xl font-extrabold text-primary">
          Run Date
        </h1>
      </div>

      <div className="flex flex-1 flex-col gap-1 px-3">
        {navItems.map((item) => {
          const active = isActive(pathname, item.href);
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              aria-label={item.label}
              className={cn(
                "relative flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition-colors",
                active
                  ? "bg-primary/10 text-primary"
                  : "text-muted-foreground hover:bg-accent hover:text-foreground",
              )}
            >
              <Icon className="h-5 w-5" strokeWidth={active ? 2.5 : 2} />
              <span>{item.label}</span>
              {"badge" in item && item.badge > 0 && (
                <Badge
                  variant="default"
                  className="ml-auto flex h-5 min-w-5 items-center justify-center rounded-full px-1.5 text-[10px] font-bold"
                >
                  {item.badge}
                </Badge>
              )}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
