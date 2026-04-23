"use client";

import { cn } from "@/lib/utils";
import { AppBar } from "@/components/shared/app-bar";
import {
  CreditCard,
  ExternalLink,
} from "lucide-react";

const invoices = [
  {
    description: "Run Date — Plateau Mont-Royal",
    date: "15 mars 2026",
    amount: "12$",
    status: "Payé" as const,
  },
  {
    description: "Run Date — Mile-End",
    date: "8 mars 2026",
    amount: "12$",
    status: "Payé" as const,
  },
  {
    description: "Run Date — Rosemont",
    date: "1 mars 2026",
    amount: "15$",
    status: "Remboursé" as const,
  },
];

const statusStyles = {
  Payé: "bg-teal-500/10 text-teal-600 border-teal-500/30",
  "En attente": "bg-amber-500/10 text-amber-600 border-amber-500/30",
  Remboursé: "bg-blue-500/10 text-blue-600 border-blue-500/30",
} as const;

export default function BillingPage() {
  return (
    <div className="min-h-screen bg-background">
      <AppBar title="Factures & paiements" backHref="/profile" />

      <div className="mx-auto max-w-lg space-y-6 px-5">
        {/* Payment method */}
        <section>
          <h2 className="font-heading text-base font-bold">
            Moyen de paiement
          </h2>

          <div className="mt-3 overflow-hidden rounded-2xl bg-gradient-to-br from-teal-500 to-navy p-5 text-white shadow-lg">
            <div className="flex items-start justify-between">
              <CreditCard className="h-8 w-8 opacity-80" />
              <span className="rounded-md bg-white/20 px-2 py-0.5 text-xs font-bold backdrop-blur-sm">
                Par défaut
              </span>
            </div>
            <p className="mt-6 font-mono text-lg tracking-[0.15em]">
              •••• •••• •••• 4242
            </p>
            <div className="mt-4 flex items-end justify-between">
              <div>
                <p className="text-[10px] uppercase tracking-wider opacity-60">
                  Expiration
                </p>
                <p className="text-sm font-semibold">08/27</p>
              </div>
              <span className="text-xl font-extrabold italic tracking-wide">
                VISA
              </span>
            </div>
          </div>

          <div className="mt-3 flex gap-2">
            <button className="flex-1 rounded-xl border border-border py-2.5 text-sm font-semibold hover:bg-accent/50 transition-colors">
              Modifier
            </button>
            <button className="flex-1 rounded-xl border border-red-200 py-2.5 text-sm font-semibold text-red-500 hover:bg-red-50 dark:border-red-900/40 dark:hover:bg-red-900/10 transition-colors">
              Supprimer
            </button>
          </div>
        </section>

        {/* Invoice history */}
        <section>
          <h2 className="font-heading text-base font-bold">
            Historique des factures
          </h2>

          <div className="mt-3 divide-y divide-border rounded-2xl border border-border">
            {invoices.map((inv, i) => (
              <div key={i} className="px-4 py-3.5">
                <div className="flex items-start justify-between gap-3">
                  <div className="min-w-0 flex-1">
                    <p className="text-[15px] font-semibold">
                      {inv.description}
                    </p>
                    <p className="mt-0.5 text-sm text-muted-foreground">
                      {inv.date}
                    </p>
                  </div>
                  <div className="flex flex-col items-end gap-1.5">
                    <span className="text-[15px] font-bold">{inv.amount}</span>
                    <span
                      className={cn(
                        "rounded-full border px-2 py-0.5 text-xs font-semibold",
                        statusStyles[inv.status],
                      )}
                    >
                      {inv.status}
                    </span>
                  </div>
                </div>
                <button className="mt-2 flex items-center gap-1 text-sm font-semibold text-primary hover:underline">
                  <ExternalLink className="h-3.5 w-3.5" />
                  Voir sur Stripe
                </button>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
