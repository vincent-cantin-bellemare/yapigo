"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import {
  UserPlus,
  Loader2,
  CheckCircle,
} from "lucide-react";
import { AppBar } from "@/components/shared/app-bar";

type Method = "email" | "phone";

export default function InvitePage() {
  const [method, setMethod] = useState<Method>("email");
  const [contact, setContact] = useState("");
  const [message, setMessage] = useState("");
  const [sending, setSending] = useState(false);
  const [sent, setSent] = useState(false);

  const isValid =
    method === "email"
      ? /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(contact)
      : /^[\d+\-() ]{7,}$/.test(contact);

  const handleSend = async () => {
    if (!isValid || sending) return;
    setSending(true);
    await new Promise((r) => setTimeout(r, 800));
    setSending(false);
    setSent(true);
  };

  return (
    <div className="min-h-screen bg-background">
      <AppBar title="Inviter un ami" backHref="/profile" />

      <div className="mx-auto max-w-lg px-5">
        {sent ? (
          <div className="flex flex-col items-center py-16 text-center">
            <CheckCircle className="h-20 w-20 text-teal-500" />
            <h2 className="mt-5 font-heading text-xl font-extrabold">
              Invitation envoyée!
            </h2>
            <p className="mt-2 text-muted-foreground">
              Ton ami recevra l&apos;invitation sous peu.
            </p>
            <button
              onClick={() => {
                setSent(false);
                setContact("");
                setMessage("");
              }}
              className="mt-6 rounded-xl border border-border px-6 py-2.5 text-sm font-semibold hover:bg-accent/50 transition-colors"
            >
              Inviter quelqu&apos;un d&apos;autre
            </button>
          </div>
        ) : (
          <div className="rounded-2xl border border-border p-5">
            <div className="flex flex-col items-center text-center">
              <UserPlus className="h-14 w-14 text-primary" />
              <h2 className="mt-4 font-heading text-xl font-extrabold">
                Invite un ami à bouger!
              </h2>
              <p className="mt-2 text-sm leading-relaxed text-muted-foreground">
                Partage l&apos;expérience Run Date avec un ami. Bouger
                ensemble, c&apos;est toujours mieux!
              </p>
            </div>

            {/* Method toggle */}
            <div className="mt-6 flex rounded-xl bg-muted p-1">
              {(["email", "phone"] as const).map((m) => (
                <button
                  key={m}
                  onClick={() => {
                    setMethod(m);
                    setContact("");
                  }}
                  className={cn(
                    "flex-1 rounded-lg py-2 text-sm font-semibold transition-colors",
                    method === m
                      ? "bg-card text-foreground shadow-sm"
                      : "text-muted-foreground",
                  )}
                >
                  {m === "email" ? "Courriel" : "Téléphone"}
                </button>
              ))}
            </div>

            {/* Contact input */}
            <div className="mt-4">
              <input
                type={method === "email" ? "email" : "tel"}
                value={contact}
                onChange={(e) => setContact(e.target.value)}
                placeholder={
                  method === "email"
                    ? "ami@exemple.com"
                    : "+1 (514) 000-0000"
                }
                className="w-full rounded-xl border border-border bg-card px-4 py-3 text-[15px] outline-none focus:border-primary"
              />
            </div>

            {/* Optional message */}
            <div className="mt-4">
              <textarea
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Message personnalisé (optionnel)"
                rows={3}
                className="w-full rounded-xl border border-border bg-card px-4 py-3 text-[15px] outline-none resize-none focus:border-primary"
              />
            </div>

            <button
              onClick={handleSend}
              disabled={!isValid || sending}
              className={cn(
                "mt-5 flex w-full items-center justify-center gap-2 rounded-xl py-3.5 text-sm font-bold text-white transition-colors",
                isValid && !sending
                  ? "bg-primary hover:bg-primary/90"
                  : "bg-muted-foreground/30 cursor-not-allowed",
              )}
            >
              {sending ? (
                <Loader2 className="h-5 w-5 animate-spin" />
              ) : (
                "Envoyer l'invitation"
              )}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
