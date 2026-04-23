"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { cn } from "@/lib/utils";

interface AppBarProps {
  title: string;
  backHref?: string;
  onBack?: () => void;
  actions?: React.ReactNode;
  variant?: "flat" | "gradient";
  className?: string;
}

export function AppBar({
  title,
  backHref,
  onBack,
  actions,
  variant = "flat",
  className,
}: AppBarProps) {
  const router = useRouter();

  const handleBack = () => {
    if (onBack) {
      onBack();
    } else if (backHref) {
      return;
    } else {
      router.back();
    }
  };

  const backButton = backHref ? (
    <Link
      href={backHref}
      className={cn(
        "rounded-lg p-2 transition-colors",
        variant === "gradient"
          ? "text-white/80 hover:text-white"
          : "hover:bg-accent",
      )}
      aria-label="Retour"
    >
      <ArrowLeft className="h-5 w-5" />
    </Link>
  ) : (
    <button
      onClick={handleBack}
      className={cn(
        "rounded-lg p-2 transition-colors",
        variant === "gradient"
          ? "text-white/80 hover:text-white"
          : "hover:bg-accent",
      )}
      aria-label="Retour"
    >
      <ArrowLeft className="h-5 w-5" />
    </button>
  );

  return (
    <div
      className={cn(
        "flex items-center gap-3 px-4 pb-4 pt-6",
        variant === "gradient" && "text-white",
        className,
      )}
    >
      {backButton}
      <h1
        className={cn(
          "flex-1 text-center font-heading text-lg font-bold",
          !actions && "pr-9",
        )}
      >
        {title}
      </h1>
      {actions ?? <div className="w-9" />}
    </div>
  );
}
