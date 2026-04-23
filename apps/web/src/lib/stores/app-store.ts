import { create } from "zustand";

type Locale = "fr" | "en";

interface AppState {
  locale: Locale;
  demoMode: boolean;
  setLocale: (locale: Locale) => void;
  setDemoMode: (value: boolean) => void;
  toggleDemoMode: () => void;
}

export const useAppStore = create<AppState>((set) => ({
  locale: "fr",
  demoMode: false,
  setLocale: (locale) => set({ locale }),
  setDemoMode: (value) => set({ demoMode: value }),
  toggleDemoMode: () => set((state) => ({ demoMode: !state.demoMode })),
}));
