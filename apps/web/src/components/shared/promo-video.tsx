"use client";

import { useState, useRef, useEffect } from "react";
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from "@/components/ui/dialog";
import { Play, Pause, X } from "lucide-react";

export function PromoVideo() {
  const [open, setOpen] = useState(false);
  const [playing, setPlaying] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    if (!open) {
      setPlaying(false);
      if (videoRef.current) {
        videoRef.current.pause();
        videoRef.current.currentTime = 0;
      }
    }
  }, [open]);

  const togglePlayback = () => {
    const video = videoRef.current;
    if (!video) return;
    if (video.paused) {
      video.play();
      setPlaying(true);
    } else {
      video.pause();
      setPlaying(false);
    }
  };

  return (
    <>
      <button
        onClick={() => setOpen(true)}
        className="relative mt-4 flex h-[200px] w-full items-center justify-center overflow-hidden rounded-2xl bg-gradient-to-br from-teal via-cyan to-navy shadow-lg transition-transform active:scale-[0.98]"
      >
        <div className="flex flex-col items-center gap-3">
          <div className="flex h-16 w-16 items-center justify-center rounded-full border-2 border-white/50 bg-white/20 transition-colors hover:bg-white/30">
            <Play className="h-8 w-8 fill-white text-white" />
          </div>
          <span className="text-sm font-semibold text-white">
            Regarder la vidéo
          </span>
        </div>
        <div className="absolute bottom-3 right-3.5 rounded-lg bg-black/40 px-2.5 py-1 text-xs font-semibold text-white">
          0:38
        </div>
      </button>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-lg overflow-hidden rounded-2xl p-0 sm:max-w-xl">
          <DialogTitle className="sr-only">Vidéo promo Run Date</DialogTitle>
          <div className="relative bg-black">
            <video
              ref={videoRef}
              src="/video/promo_intro.mp4"
              className="w-full"
              playsInline
              onEnded={() => setPlaying(false)}
              onClick={togglePlayback}
            />
            {!playing && (
              <button
                onClick={togglePlayback}
                className="absolute inset-0 flex items-center justify-center bg-black/30 transition-colors hover:bg-black/20"
              >
                <div className="flex h-16 w-16 items-center justify-center rounded-full border-2 border-white/50 bg-white/20">
                  <Play className="h-8 w-8 fill-white text-white" />
                </div>
              </button>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
