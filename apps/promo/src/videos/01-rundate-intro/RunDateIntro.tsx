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
// Act 1   — Text only (direct)    :  0s–4.5s     →  135 frames
// AppCard — "Tu t'inscris"        :  3s–5.5s     →   75 frames
// Trans 1 — Ripple (lieu proche)  :  5.5s–8s     →   75 frames
// Clip 1  — Groupe au parc        :  8s–10s      →   60 frames
// Trans 2 — Duo GPS routes        : 10s–13s      →   90 frames
// Clip 2  — Course canal          : 13s–15s      →   60 frames
// Trans 3 — Pace bar 5-10km       : 15s–18s      →   90 frames
// Clip 3  — Rires                 : 18s–20s      →   60 frames
// Trans 4 — Steam (café)          : 20s–23.5s    →  105 frames
// Clip 4  — Café terrasse         : 23.5s–25.5s  →   60 frames (clipIndex 4)
// Trans 5 — EKG (connexion)       : 25.5s–28s    →   75 frames
// Clip 5  — Post-course           : 28s–30s      →   60 frames (clipIndex 3)
// CTA     — Logo + tagline        : 30s–36.5s    →  195 frames
//
// Total: 135+75+75+60+90+60+90+60+105+60+75+60+195 = 1140 frames = 38s

const T = {
  act1:    { start: 0,   dur: 135 },
  appcard: { start: 135, dur: 75  },
  trans1:  { start: 210, dur: 75  },
  clip1:   { start: 285, dur: 60  },
  trans2:  { start: 345, dur: 90  },
  clip2:   { start: 435, dur: 60  },
  trans3:  { start: 495, dur: 90  },
  clip3:   { start: 585, dur: 60  },
  trans4:  { start: 645, dur: 105 },
  clip4:   { start: 750, dur: 60  },
  trans5:  { start: 810, dur: 75  },
  clip5:   { start: 885, dur: 60  },
  cta:     { start: 945, dur: 195 },
} as const;

export const TOTAL_FRAMES = T.cta.start + T.cta.dur; // 1140 = 38s

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
          text="Un parc près de chez toi."
          subtitle="Un groupe t'attend."
        />
      </Sequence>

      <Sequence from={T.clip1.start} durationInFrames={T.clip1.dur}>
        <RunScene clipIndex={0} />
      </Sequence>

      <Sequence from={T.trans2.start} durationInFrames={T.trans2.dur}>
        <TransitionDuoRun
          text="Vous partez courir."
          subtitle="Le trajet s'adapte au groupe."
        />
      </Sequence>

      <Sequence from={T.clip2.start} durationInFrames={T.clip2.dur}>
        <RunScene clipIndex={1} />
      </Sequence>

      <Sequence from={T.trans3.start} durationInFrames={T.trans3.dur}>
        <TransitionPaceBar number="5–10 km" label="une heure ensemble" />
      </Sequence>

      <Sequence from={T.clip3.start} durationInFrames={T.clip3.dur}>
        <RunScene clipIndex={2} />
      </Sequence>

      <Sequence from={T.trans4.start} durationInFrames={T.trans4.dur}>
        <TransitionSteam
          text="La course est finie."
          subtitle="La conversation commence."
        />
      </Sequence>

      <Sequence from={T.clip4.start} durationInFrames={T.clip4.dur}>
        <RunScene clipIndex={4} />
      </Sequence>

      <Sequence from={T.trans5.start} durationInFrames={T.trans5.dur}>
        <TransitionEKG
          text="Le feeling est là ?"
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
