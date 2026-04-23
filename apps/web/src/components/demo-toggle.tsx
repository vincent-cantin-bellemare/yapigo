"use client";

import { useAuth } from "@/lib/auth-context";
import { cn } from "@/lib/utils";

export function DemoToggle() {
  const { isLoggedIn, toggle } = useAuth();

  return (
    <button
      onClick={toggle}
      className="fixed right-4 top-4 z-[100] flex items-center gap-2 rounded-full border border-border bg-card/95 px-3 py-1.5 shadow-lg backdrop-blur-sm transition-all hover:shadow-xl"
    >
      <span className="rounded bg-amber-500 px-1.5 py-0.5 text-[10px] font-extrabold tracking-wider text-white">
        DEMO
      </span>
      <span className="text-xs font-semibold text-muted-foreground">
        {isLoggedIn ? "Connecté" : "Déconnecté"}
      </span>
      <div
        className={cn(
          "h-5 w-9 rounded-full transition-colors",
          isLoggedIn ? "bg-primary" : "bg-muted-foreground/30",
        )}
      >
        <div
          className={cn(
            "mt-0.5 h-4 w-4 rounded-full bg-white shadow transition-transform",
            isLoggedIn ? "translate-x-[18px]" : "translate-x-0.5",
          )}
        />
      </div>
    </button>
  );
}
