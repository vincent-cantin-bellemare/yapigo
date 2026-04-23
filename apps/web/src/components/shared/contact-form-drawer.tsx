"use client";

import { useState } from "react";
import {
  Drawer,
  DrawerContent,
  DrawerHeader,
  DrawerTitle,
  DrawerFooter,
} from "@/components/ui/drawer";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";
import { currentUser } from "@/lib/data";
import { Send, CheckCircle } from "lucide-react";

export type ContactSubject =
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

interface ContactFormDrawerProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  preselectedSubject?: ContactSubject;
}

export function ContactFormDrawer({
  open,
  onOpenChange,
  preselectedSubject,
}: ContactFormDrawerProps) {
  const [subject, setSubject] = useState<ContactSubject>(
    preselectedSubject ?? "other",
  );
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const canSubmit = message.trim().length > 0;

  function handleSubmit() {
    if (!canSubmit) return;
    setSubmitted(true);
    setTimeout(() => {
      setSubmitted(false);
      setEmail("");
      setMessage("");
      onOpenChange(false);
    }, 2000);
  }

  function handleOpenChange(open: boolean) {
    if (!open) {
      setSubmitted(false);
      setEmail("");
      setMessage("");
    }
    if (preselectedSubject && !open) {
      setSubject(preselectedSubject);
    }
    onOpenChange(open);
  }

  if (submitted) {
    return (
      <Drawer open={open} onOpenChange={handleOpenChange}>
        <DrawerContent className="mx-auto max-w-lg rounded-t-3xl">
          <div className="flex flex-col items-center gap-4 px-6 py-12">
            <div className="flex h-16 w-16 items-center justify-center rounded-full bg-emerald-100 dark:bg-emerald-900/30">
              <CheckCircle className="h-8 w-8 text-emerald-600" />
            </div>
            <h3 className="font-heading text-lg font-bold">Message envoyé!</h3>
            <p className="text-center text-sm text-muted-foreground">
              Merci pour ton message. On te revient bientôt!
            </p>
          </div>
        </DrawerContent>
      </Drawer>
    );
  }

  return (
    <Drawer open={open} onOpenChange={handleOpenChange}>
      <DrawerContent className="mx-auto max-h-[90vh] max-w-lg rounded-t-3xl">
        <DrawerHeader className="text-left">
          <DrawerTitle className="font-heading text-lg font-extrabold">
            Nous contacter
          </DrawerTitle>
        </DrawerHeader>

        <div className="flex-1 space-y-5 overflow-y-auto px-4 pb-4">
          {/* Read-only user info */}
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

          {/* Email (optional) */}
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

          {/* Subject selection */}
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

          {/* Message */}
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
        </div>

        <DrawerFooter>
          <Button
            onClick={handleSubmit}
            disabled={!canSubmit}
            className="w-full gap-2"
          >
            <Send className="h-4 w-4" />
            Envoyer
          </Button>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}
