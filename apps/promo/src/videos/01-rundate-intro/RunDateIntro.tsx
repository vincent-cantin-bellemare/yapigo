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
// Act 1   — Chat mockup (fast)    :  0s–6s       →  180 frames
// AppCard — "Tu t'inscris"        :  6s–8s       →   60 frames
// Trans 1 — Ripple (lieu proche)  :  8s–10s      →   60 frames
// Clip 1  — Groupe au parc        : 10s–12s      →   60 frames
// Trans 2 — Duo GPS routes        : 12s–14.5s    →   75 frames
// Clip 2  — Course canal          : 14.5s–16.5s  →   60 frames
// Trans 3 — Pace bar 5-10km       : 16.5s–19s    →   75 frames
// Clip 3  — Rires                 : 19s–21s      →   60 frames
// Trans 4 — Steam (café)          : 21s–23s      →   60 frames
// Clip 4  — Café terrasse         : 23s–25s      →   60 frames (clipIndex 4)
// Trans 5 — EKG (connexion)       : 25s–27s      →   60 frames
// Clip 5  — Post-course           : 27s–29s      →   60 frames (clipIndex 3)
// CTA     — Logo + tagline        : 29s–35.5s    →  195 frames
//
// Total: 180+60+60+60+75+60+75+60+60+60+60+60+195 = 1065 frames = 35.5s

const T = {
  act1:    { start: 0,   dur: 180 },
  appcard: { start: 180, dur: 60  },
  trans1:  { start: 240, dur: 60  },
  clip1:   { start: 300, dur: 60  },
  trans2:  { start: 360, dur: 75  },
  clip2:   { start: 435, dur: 60  },
  trans3:  { start: 495, dur: 75  },
  clip3:   { start: 570, dur: 60  },
  trans4:  { start: 630, dur: 60  },
  clip4:   { start: 690, dur: 60  },
  trans5:  { start: 750, dur: 60  },
  clip5:   { start: 810, dur: 60  },
  cta:     { start: 870, dur: 195 },
} as const;

export const TOTAL_FRAMES = T.cta.start + T.cta.dur; // 1065 = 35.5s

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
        <TransitionPaceBar number="5–10 km" label="ou plus pour les plus motivés" />
      </Sequence>

      <Sequence from={T.clip3.start} durationInFrames={T.clip3.dur}>
        <RunScene clipIndex={2} />
      </Sequence>

      <Sequence from={T.trans4.start} durationInFrames={T.trans4.dur}>
        <TransitionSteam
          text="Et si t'as aimé courir..."
          subtitle="Choisis ton drink préféré."
        />
      </Sequence>

      <Sequence from={T.clip4.start} durationInFrames={T.clip4.dur}>
        <RunScene clipIndex={4} />
      </Sequence>

      <Sequence from={T.trans5.start} durationInFrames={T.trans5.dur}>
        <TransitionEKG
          text="Connecte avec le groupe."
          subtitle="Retrouve-les sur l'application."
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
