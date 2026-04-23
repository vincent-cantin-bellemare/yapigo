"use client";

import { useState, useCallback, useEffect } from "react";
import { Dialog, DialogContent, DialogTitle } from "@/components/ui/dialog";
import { ChevronLeft, ChevronRight, X } from "lucide-react";
import type { EventPhoto } from "@/lib/types";

interface PhotoGalleryViewerProps {
  photos: EventPhoto[];
  initialIndex: number;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function PhotoGalleryViewer({
  photos,
  initialIndex,
  open,
  onOpenChange,
}: PhotoGalleryViewerProps) {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);

  useEffect(() => {
    if (open) setCurrentIndex(initialIndex);
  }, [open, initialIndex]);

  const goNext = useCallback(() => {
    setCurrentIndex((i) => (i + 1) % photos.length);
  }, [photos.length]);

  const goPrev = useCallback(() => {
    setCurrentIndex((i) => (i - 1 + photos.length) % photos.length);
  }, [photos.length]);

  useEffect(() => {
    if (!open) return;
    function onKey(e: KeyboardEvent) {
      if (e.key === "ArrowRight") goNext();
      else if (e.key === "ArrowLeft") goPrev();
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, goNext, goPrev]);

  if (photos.length === 0) return null;
  const photo = photos[currentIndex];
  if (!photo) return null;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl gap-0 overflow-hidden rounded-2xl border-0 bg-black p-0">
        <DialogTitle className="sr-only">
          Photo par {photo.userName}
        </DialogTitle>

        {/* Top bar */}
        <div className="absolute inset-x-0 top-0 z-10 flex items-center justify-between bg-gradient-to-b from-black/60 to-transparent px-4 py-3">
          <span className="text-sm font-medium text-white">
            {currentIndex + 1} / {photos.length}
          </span>
          <button
            onClick={() => onOpenChange(false)}
            className="rounded-full p-1 text-white/80 transition-colors hover:text-white"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        {/* Image */}
        <div className="relative flex min-h-[300px] items-center justify-center sm:min-h-[400px]">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={photo.photoUrl}
            alt={photo.description ?? `Photo par ${photo.userName}`}
            className="max-h-[70vh] w-full object-contain"
          />

          {photos.length > 1 && (
            <>
              <button
                onClick={goPrev}
                className="absolute left-2 top-1/2 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white/80 transition-colors hover:bg-black/60 hover:text-white"
              >
                <ChevronLeft className="h-5 w-5" />
              </button>
              <button
                onClick={goNext}
                className="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-black/40 p-2 text-white/80 transition-colors hover:bg-black/60 hover:text-white"
              >
                <ChevronRight className="h-5 w-5" />
              </button>
            </>
          )}
        </div>

        {/* Bottom info */}
        <div className="bg-gradient-to-t from-black/60 to-transparent px-4 py-3">
          <p className="text-sm font-semibold text-white">{photo.userName}</p>
          {photo.description && (
            <p className="mt-0.5 text-xs text-white/70">{photo.description}</p>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
