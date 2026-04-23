"use client";

import { useState, useRef, useCallback, useEffect } from "react";
import Image from "next/image";
import { cn } from "@/lib/utils";

const slides = [
  {
    image: "/images/carousel/carousel_01_activity.png",
    title: "Trouve ton Run Date",
    description:
      "Choisis une course près de chez toi et rencontre quelqu'un qui partage ta passion.",
  },
  {
    image: "/images/carousel/carousel_02_meetup.png",
    title: "Rejoins le groupe",
    description:
      "On se retrouve au point de rencontre. L'organisateur fait les présentations.",
  },
  {
    image: "/images/carousel/carousel_03_activity.png",
    title: "On court ensemble!",
    description:
      "On court en duo ou en groupe, à ton rythme. L'important, c'est la connexion.",
  },
  {
    image: "/images/carousel/carousel_04_ravito.png",
    title: "L'Apéro Smoothie",
    description:
      "Après la course, on jase autour d'un smoothie. C'est là que la magie opère!",
  },
];

export function WaitingCarousel() {
  const [currentPage, setCurrentPage] = useState(0);
  const scrollRef = useRef<HTMLDivElement>(null);
  const isScrollingRef = useRef(false);

  const handleScroll = useCallback(() => {
    if (isScrollingRef.current) return;
    const el = scrollRef.current;
    if (!el) return;
    const idx = Math.round(el.scrollLeft / el.clientWidth);
    const clamped = Math.max(0, Math.min(idx, slides.length - 1));
    if (clamped !== currentPage) {
      setCurrentPage(clamped);
    }
  }, [currentPage]);

  const goToPage = useCallback((index: number) => {
    const el = scrollRef.current;
    if (!el) return;
    isScrollingRef.current = true;
    el.scrollTo({ left: index * el.clientWidth, behavior: "smooth" });
    setCurrentPage(index);
    setTimeout(() => {
      isScrollingRef.current = false;
    }, 400);
  }, []);

  useEffect(() => {
    const el = scrollRef.current;
    if (!el) return;
    el.scrollLeft = 0;
  }, []);

  return (
    <div className="space-y-3">
      {/* Swipeable slides */}
      <div
        ref={scrollRef}
        onScroll={handleScroll}
        className="flex snap-x snap-mandatory overflow-x-auto scrollbar-none"
      >
        {slides.map((slide, i) => (
          <div key={i} className="w-full shrink-0 snap-start px-0.5">
            <div className="relative h-[220px] overflow-hidden rounded-2xl">
              <Image
                src={slide.image}
                alt={slide.title}
                fill
                className="object-cover"
                priority={i === 0}
              />
              {/* Gradient overlay */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent" />

              {/* Page indicator badge */}
              <div className="absolute left-3 top-3 rounded-full bg-primary px-2.5 py-0.5 text-xs font-bold text-white">
                {i + 1}/{slides.length}
              </div>

              {/* Text content */}
              <div className="absolute inset-x-0 bottom-0 p-4">
                <h3 className="font-heading text-lg font-extrabold text-white">
                  {slide.title}
                </h3>
                <p className="mt-1 text-sm leading-snug text-white/85">
                  {slide.description}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Dot indicators */}
      <div className="flex justify-center gap-2">
        {slides.map((_, i) => (
          <button
            key={i}
            onClick={() => goToPage(i)}
            className={cn(
              "h-2 rounded-full transition-all duration-300",
              currentPage === i
                ? "w-6 bg-primary"
                : "w-2 bg-muted-foreground/30",
            )}
          />
        ))}
      </div>
    </div>
  );
}
