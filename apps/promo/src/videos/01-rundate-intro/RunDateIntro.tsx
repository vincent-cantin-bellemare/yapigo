import { AbsoluteFill, Sequence } from "remotion";
import { ProblemScene } from "./scenes/ProblemScene";
import { RunScene } from "./scenes/RunScene";
import { CtaScene } from "./scenes/CtaScene";
import {
  TransitionAppCard,
  TransitionRipple,
  TransitionDuoRun,
  TransitionPaceBar,
  TransitionSteam,
  TransitionEKG,
} from "./scenes/TransitionScene";

// ─── Timing at 30fps ──────────────────────────────────────────────────────────
// Act 1   — Chat mockup (fast)    :  0s–4s       →  120 frames  (compressed)
// AppCard — "Tu t'inscris"        :  4s–6.5s     →   75 frames
// Trans 1 — Ripple (lieu proche)  :  6.5s–9s     →   75 frames
// Clip 1  — Groupe au parc        :  9s–11s      →   60 frames
// Trans 2 — Duo GPS routes        : 11s–14s      →   90 frames
// Clip 2  — Course canal          : 14s–16s      →   60 frames
// Trans 3 — Pace bar 5-10km       : 16s–19s      →   90 frames
// Clip 3  — Rires                 : 19s–21s      →   60 frames
// Trans 4 — Steam (café)          : 21s–24.5s    →  105 frames  (extended)
// Clip 4  — Café terrasse         : 24.5s–26.5s  →   60 frames (clipIndex 4)
// Trans 5 — EKG (connexion)       : 26.5s–29s    →   75 frames
// Clip 5  — Post-course           : 29s–31s      →   60 frames (clipIndex 3)
// CTA     — Logo + tagline        : 31s–37.5s    →  195 frames
//
// Total: 120+75+75+60+90+60+90+60+105+60+75+60+195 = 1125 frames = 37.5s

const T = {
  act1:    { start: 0,   dur: 120 },
  appcard: { start: 120, dur: 75  },
  trans1:  { start: 195, dur: 75  },
  clip1:   { start: 270, dur: 60  },
  trans2:  { start: 330, dur: 90  },
  clip2:   { start: 420, dur: 60  },
  trans3:  { start: 480, dur: 90  },
  clip3:   { start: 570, dur: 60  },
  trans4:  { start: 630, dur: 105 },
  clip4:   { start: 735, dur: 60  },
  trans5:  { start: 795, dur: 75  },
  clip5:   { start: 870, dur: 60  },
  cta:     { start: 930, dur: 195 },
} as const;

export const TOTAL_FRAMES = T.cta.start + T.cta.dur; // 1125 = 37.5s

export const RunDateIntro = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A" }}>
      {/* Audio removed — will be re-added once final voiceover is ready */}

      <Sequence from={T.act1.start} durationInFrames={T.act1.dur}>
        <ProblemScene />
      </Sequence>

      <Sequence from={T.appcard.start} durationInFrames={T.appcard.dur}>
        <TransitionAppCard />
      </Sequence>

      <Sequence from={T.trans1.start} durationInFrames={T.trans1.dur}>
        <TransitionRipple
          text="Vous vous rejoignez dans un endroit proche."
        />
      </Sequence>

      <Sequence from={T.clip1.start} durationInFrames={T.clip1.dur}>
        <RunScene clipIndex={0} />
      </Sequence>

      <Sequence from={T.trans2.start} durationInFrames={T.trans2.dur}>
        <TransitionDuoRun
          text="Vous partez ensemble."
          subtitle="Trajet adapté au groupe."
        />
      </Sequence>

      <Sequence from={T.clip2.start} durationInFrames={T.clip2.dur}>
        <RunScene clipIndex={1} />
      </Sequence>

      <Sequence from={T.trans3.start} durationInFrames={T.trans3.dur}>
        <TransitionPaceBar number="5–10 km" label="une heure environ" />
      </Sequence>

      <Sequence from={T.clip3.start} durationInFrames={T.clip3.dur}>
        <RunScene clipIndex={2} />
      </Sequence>

      <Sequence from={T.trans4.start} durationInFrames={T.trans4.dur}>
        <TransitionSteam
          text="Rendez-vous au café du coin."
          subtitle="Choisis ton drink préféré."
        />
      </Sequence>

      <Sequence from={T.clip4.start} durationInFrames={T.clip4.dur}>
        <RunScene clipIndex={4} />
      </Sequence>

      <Sequence from={T.trans5.start} durationInFrames={T.trans5.dur}>
        <TransitionEKG
          text="Retrouve ton team sur l'application."
        />
      </Sequence>

      <Sequence from={T.clip5.start} durationInFrames={T.clip5.dur}>
        <RunScene clipIndex={3} />
      </Sequence>

      <Sequence from={T.cta.start} durationInFrames={T.cta.dur}>
        <CtaScene />
      </Sequence>
    </AbsoluteFill>
  );
};
