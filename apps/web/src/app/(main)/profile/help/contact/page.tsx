"use client";

import { useState } from "react";
import Link from "next/link";
import { Send, CheckCircle } from "lucide-react";
import { AppBar } from "@/components/shared/app-bar";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { currentUser } from "@/lib/data";

type ContactSubject =
  | "newMeetingPoint"
  | "becomeOrganizer"
  | "reportBug"
  | "suggestion"
  | "other";

const subjectLabels: Record<ContactSubject, string> = {
  newMeetingPoint: "Proposer un nouveau point de départ",
  becomeOrganizer: "Devenir Organisateur",
  reportBug: "Signaler un problème",
  suggestion: "Suggestion",
  other: "Autre",
};

export default function ContactPage() {
  const [subject, setSubject] = useState<ContactSubject>("other");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const canSubmit = message.trim().length > 0;

  function handleSubmit() {
    if (!canSubmit) return;
    setSubmitted(true);
  }

  if (submitted) {
    return (
      <div className="min-h-screen bg-background">
        <AppBar title="Nous contacter" backHref="/profile/help" />
        <div className="flex flex-col items-center gap-4 px-6 py-20">
          <div className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-900/30">
            <CheckCircle className="h-8 w-8 text-emerald-600" />
          </div>
          <h3 className="font-heading text-lg font-bold">Message envoyé!</h3>
          <p className="text-center text-sm text-muted-foreground">
            Merci pour ton message. On te revient bientôt!
          </p>
          <Link
            href="/profile/help"
            className="mt-4 inline-flex items-center gap-2 rounded-md border border-border px-6 py-3 text-sm font-bold hover:bg-accent"
          >
            Retour
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <AppBar title="Nous contacter" backHref="/profile/help" />

      <div className="mx-auto max-w-lg space-y-5 px-5">
        <div className="space-y-3 rounded-xl bg-muted/50 p-4">
          <div>
            <Label className="text-xs text-muted-foreground">Nom</Label>
            <p className="text-sm font-medium">
              {currentUser.firstName} {currentUser.lastName}
            </p>
          </div>
          <div>
            <Label className="text-xs text-muted-foreground">Téléphone</Label>
            <p className="text-sm font-medium">{currentUser.phone}</p>
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="contact-email">Courriel (optionnel)</Label>
          <Input
            id="contact-email"
            type="email"
            placeholder="ton@courriel.com"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        <div className="space-y-2">
          <Label>Sujet</Label>
          <div className="flex flex-wrap gap-2">
            {(Object.keys(subjectLabels) as ContactSubject[]).map((key) => (
              <button
                key={key}
                onClick={() => setSubject(key)}
                className={cn(
                  "rounded-full px-3 py-1.5 text-sm font-medium transition-colors",
                  subject === key
                    ? "bg-primary text-primary-foreground"
                    : "bg-muted text-muted-foreground hover:bg-muted/80",
                )}
              >
                {subjectLabels[key]}
              </button>
            ))}
          </div>
        </div>

        <div className="space-y-2">
          <Label htmlFor="contact-message">
            Message <span className="text-destructive">*</span>
          </Label>
          <textarea
            id="contact-message"
            rows={5}
            maxLength={1000}
            placeholder="Écris ton message ici…"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            className="w-full rounded-xl border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
          />
          <p className="text-right text-xs text-muted-foreground">
            {message.length}/1000
          </p>
        </div>

        <Button
          onClick={handleSubmit}
          disabled={!canSubmit}
          className="w-full gap-2"
        >
          <Send className="h-4 w-4" />
          Envoyer
        </Button>
      </div>
    </div>
  );
}
