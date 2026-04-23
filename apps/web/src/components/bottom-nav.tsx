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

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 border-t border-border bg-card/92 backdrop-blur-xl supports-[backdrop-filter]:bg-card/80">
      <div className="mx-auto flex h-16 max-w-2xl items-center justify-around px-2">
        {navItems.map((item) => {
          const active = isActive(pathname, item.href);
          const Icon = item.icon;

          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "relative flex flex-col items-center gap-0.5 px-3 py-1.5 transition-colors",
                active
                  ? "text-primary"
                  : "text-muted-foreground hover:text-foreground",
              )}
            >
              <span className="relative">
                <Icon
                  className={cn(
                    "h-6 w-6 transition-transform",
                    active && "scale-110",
                  )}
                  strokeWidth={active ? 2.5 : 2}
                />
                {"badge" in item && item.badge > 0 && (
                  <Badge
                    variant="default"
                    className="absolute -right-3 -top-2 flex h-4 min-w-4 items-center justify-center rounded-full px-1 text-[10px] font-bold"
                  >
                    {item.badge}
                  </Badge>
                )}
              </span>
              {active && (
                <span className="mt-0.5 h-1 w-1 rounded-full bg-primary" />
              )}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
