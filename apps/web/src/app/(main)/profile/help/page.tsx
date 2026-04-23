"use client";

import Link from "next/link";
import { AppBar } from "@/components/shared/app-bar";
import {
  HelpCircle,
  MessageSquare,
  FileText,
  Shield,
  Users,
  ChevronRight,
} from "lucide-react";

const links = [
  {
    Icon: HelpCircle,
    label: "FAQ",
    href: "/profile/help/faq",
  },
  {
    Icon: MessageSquare,
    label: "Nous contacter",
    href: "/profile/help/contact",
  },
  {
    Icon: FileText,
    label: "Conditions d'utilisation",
    href: "/profile/help/terms",
  },
  {
    Icon: Shield,
    label: "Politique de confidentialité",
    href: "/profile/help/privacy",
  },
  {
    Icon: Users,
    label: "Règles de la communauté",
    href: "/profile/help/rules",
  },
];

export default function HelpPage() {
  return (
    <div className="min-h-screen bg-background">
      <AppBar title="Aide & infos" backHref="/profile" />

      <div className="mx-auto max-w-lg px-5">
        <div className="overflow-hidden rounded-2xl border border-border">
          {links.map((item, i) => (
            <Link
              key={i}
              href={item.href}
              className="flex items-center gap-4 px-[18px] py-3.5 hover:bg-accent/50 transition-colors"
            >
              <item.Icon className="h-6 w-6 text-foreground/70" />
              <span className="flex-1 text-[15px] font-semibold">
                {item.label}
              </span>
              <ChevronRight className="h-5 w-5 text-muted-foreground/50" />
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
