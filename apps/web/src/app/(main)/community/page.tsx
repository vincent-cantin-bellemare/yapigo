"use client";

import { useState, useMemo } from "react";
import Image from "next/image";
import { mockEventPhotos, mockEvents } from "@/lib/data";
import { EventCategory } from "@/lib/types";
import type { EventPhoto } from "@/lib/types";
import { cn } from "@/lib/utils";
import {
  Heart,
  MessageCircle,
  Share2,
  TreePine,
  Camera,
  ImageOff,
  MoreHorizontal,
} from "lucide-react";

function timeAgo(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const hours = Math.floor(diff / 3600_000);
  if (hours < 1) return "maintenant";
  if (hours < 24) return `il y a ${hours}h`;
  const days = Math.floor(hours / 24);
  if (days < 7) return `il y a ${days}j`;
  return `il y a ${Math.floor(days / 7)} sem.`;
}

function eventLabel(eventId: string): string {
  const event = mockEvents.find((e) => e.id === eventId);
  if (!event) return "";
  const cat = EventCategory[event.category];
  return `${cat?.emoji ?? ""} ${event.neighborhood}`;
}

function randomCount(seed: string, max: number): number {
  let hash = 0;
  for (let i = 0; i < seed.length; i++) {
    hash = (hash * 31 + seed.charCodeAt(i)) & 0x7fffffff;
  }
  return (hash % max) + 3;
}

export default function CommunityPage() {
  const photos = useMemo(
    () =>
      [...mockEventPhotos].sort(
        (a, b) =>
          new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime(),
      ),
    [],
  );

  if (photos.length === 0) {
    return (
      <div className="flex min-h-[60vh] flex-col items-center justify-center px-8 text-center">
        <ImageOff className="h-14 w-14 text-muted-foreground/50" />
        <p className="mt-3 text-base text-muted-foreground">
          Aucune photo pour le moment
        </p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <div className="px-5 pt-8 pb-2">
        <h1 className="text-center font-heading text-xl font-bold">
          Communauté
        </h1>
      </div>

      <div className="mx-auto max-w-lg space-y-4 px-4 pb-32 pt-2">
        {photos.map((photo) => (
          <PhotoCard key={photo.id} photo={photo} />
        ))}
      </div>

      {/* FAB */}
      <button className="fixed bottom-24 right-5 z-30 flex h-14 w-14 items-center justify-center rounded-full bg-teal-500 text-white shadow-lg hover:bg-teal-600">
        <Camera className="h-6 w-6" />
      </button>
    </div>
  );
}

function PhotoCard({ photo }: { photo: EventPhoto }) {
  const [liked, setLiked] = useState(false);
  const likeBase = randomCount(photo.id + "l", 13);
  const commentCount = randomCount(photo.id + "c", 9);
  const likeCount = likeBase + (liked ? 1 : 0);
  const label = eventLabel(photo.eventId);

  return (
    <div className="overflow-hidden rounded-2xl border border-border bg-card shadow-sm">
      {/* Header */}
      <div className="flex items-center gap-2.5 px-3.5 py-3">
        <div className="flex h-9 w-9 items-center justify-center rounded-full bg-teal-500/20 font-heading text-base font-bold text-teal-600">
          {photo.userName[0]}
        </div>
        <div className="min-w-0 flex-1">
          <p className="text-[15px] font-semibold">{photo.userName}</p>
          <p className="text-sm text-muted-foreground">
            {timeAgo(photo.timestamp)}
          </p>
        </div>
        <MoreHorizontal className="h-5 w-5 text-muted-foreground" />
      </div>

      {/* Photo */}
      <div className="relative aspect-[4/3] w-full bg-muted">
        <Image
          src={photo.photoUrl}
          alt={photo.description ?? "Photo communauté"}
          fill
          className="object-cover"
        />
      </div>

      {/* Actions + info */}
      <div className="px-3.5 py-3">
        <div className="flex items-center gap-4">
          <button
            onClick={() => setLiked(!liked)}
            className="flex items-center gap-1"
          >
            <Heart
              className={cn(
                "h-[22px] w-[22px]",
                liked
                  ? "fill-red-500 text-red-500"
                  : "text-foreground/60",
              )}
            />
            <span className="text-sm font-semibold text-foreground/70">
              {likeCount}
            </span>
          </button>
          <button className="flex items-center gap-1">
            <MessageCircle className="h-5 w-5 text-foreground/60" />
            <span className="text-sm font-semibold text-foreground/70">
              {commentCount}
            </span>
          </button>
          <button>
            <Share2 className="h-5 w-5 text-foreground/60" />
          </button>
        </div>

        {label && (
          <div className="mt-2 flex items-center gap-1 text-sm text-muted-foreground">
            <TreePine className="h-3.5 w-3.5 text-teal-500" />
            <span>{label}</span>
          </div>
        )}

        {photo.description && (
          <p className="mt-1.5 text-sm leading-snug text-foreground/80">
            {photo.description}
          </p>
        )}
      </div>
    </div>
  );
}
