import {
  AbsoluteFill,
  Img,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
  staticFile,
} from "remotion";
import { colors, gradients } from "../../../../design-system/colors";
import { fonts, fontSizes } from "../../../../design-system/typography";

const GOOGLE_FONTS = `@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&family=DM+Sans:wght@300;400&display=swap');`;

const fadeIn = (frame: number, startAt: number, duration = 14) =>
  interpolate(frame - startAt, [0, duration], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

const slideUp = (frame: number, startAt: number) => {
  const p = interpolate(frame - startAt, [0, 14], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return interpolate(p, [0, 1], [20, 0]);
};

// ─── Shared text block ────────────────────────────────────────────────────────
const TextBlock: React.FC<{
  text: string;
  subtitle?: string;
  startAt: number;
  frame: number;
}> = ({ text, subtitle, startAt, frame }) => (
  <div style={{ textAlign: "center", padding: "0 80px" }}>
    <div style={{
      fontFamily: fonts.title,
      fontSize: fontSizes.h2,
      fontWeight: 800,
      color: colors.white,
      lineHeight: 1.2,
      opacity: fadeIn(frame, startAt),
      transform: `translateY(${slideUp(frame, startAt)}px)`,
    }}>
      {text}
    </div>
    {subtitle && (
      <div style={{
        fontFamily: fonts.body,
        fontSize: fontSizes.body,
        color: "rgba(255,255,255,0.55)",
        marginTop: 14,
        lineHeight: 1.5,
        opacity: fadeIn(frame, startAt + 10),
        transform: `translateY(${slideUp(frame, startAt + 10)}px)`,
      }}>
        {subtitle}
      </div>
    )}
  </div>
);

// ─── Transition 1: Ripple Drop ────────────────────────────────────────────────
// A GPS pin drops from above, then concentric teal rings expand from impact
export const TransitionRipple: React.FC<{ text: string; subtitle?: string }> = ({ text, subtitle }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const dropProgress = spring({ frame: frame - 2, fps, config: { damping: 12, stiffness: 220, mass: 0.5 } });
  const pinY = interpolate(dropProgress, [0, 1], [-340, 0]);
  const pinOpacity = interpolate(frame, [0, 6], [0, 1], { extrapolateRight: "clamp" });

  const ripples = [
    { delay: 18, maxScale: 3.2, color: colors.teal },
    { delay: 24, maxScale: 4.8, color: colors.tealMid },
    { delay: 30, maxScale: 6.5, color: colors.tealDark },
  ];

  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <style>{GOOGLE_FONTS}</style>

      {ripples.map((r, i) => {
        const { fps: _fps } = { fps };
        const rProgress = spring({ frame: frame - r.delay, fps: _fps, config: { damping: 20, stiffness: 80, mass: 1.2 } });
        const rScale = interpolate(rProgress, [0, 1], [0, r.maxScale]);
        const rOpacity = interpolate(rProgress, [0, 0.3, 1], [0.7, 0.4, 0]);
        return (
          <div key={i} style={{
            position: "absolute",
            width: 80, height: 80,
            borderRadius: "50%",
            border: `2px solid ${r.color}`,
            transform: `scale(${rScale})`,
            opacity: rOpacity,
            pointerEvents: "none",
          }} />
        );
      })}

      <div style={{ transform: `translateY(${pinY}px)`, opacity: pinOpacity, marginBottom: 12 }}>
        <svg width="60" height="76" viewBox="0 0 60 76" fill="none">
          <path d="M30 0C13.43 0 0 13.43 0 30C0 52.5 30 76 30 76C30 76 60 52.5 60 30C60 13.43 46.57 0 30 0Z" fill={colors.teal} />
          <circle cx="30" cy="30" r="12" fill="#0A0A0A" />
        </svg>
      </div>

      <div style={{ width: 8, height: 8, borderRadius: "50%", backgroundColor: colors.teal, opacity: pinOpacity, marginBottom: 32 }} />

      <TextBlock text={text} subtitle={subtitle} startAt={32} frame={frame} />
    </AbsoluteFill>
  );
};

// ─── Transition 2: Duo GPS Routes ─────────────────────────────────────────────
// Two Strava-style GPS route lines draw from left to right side by side,
// each with a glowing "current position" dot at the head
export const TransitionDuoRun: React.FC<{ text: string; subtitle?: string }> = ({ text, subtitle }) => {
  const frame = useCurrentFrame();

  const TRACK_W = 820;

  const r1 = interpolate(frame, [5, 50], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const r2 = interpolate(frame, [10, 55], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  const dot1x = r1 * TRACK_W;
  const dot2x = r2 * (TRACK_W - 40);

  const textStart = 28;

  const Route: React.FC<{ progress: number; dotX: number; color: string; trackW: number; offsetLeft?: number }> = ({
    progress, dotX, color, trackW, offsetLeft = 0,
  }) => (
    <div style={{ position: "relative", height: 6, width: trackW, marginLeft: offsetLeft }}>
      {/* Dashed background track */}
      <div style={{
        position: "absolute", inset: 0,
        backgroundImage: `repeating-linear-gradient(90deg, rgba(255,255,255,0.12) 0px, rgba(255,255,255,0.12) 10px, transparent 10px, transparent 20px)`,
        borderRadius: 3,
      }} />
      {/* Filled route with glow gradient */}
      <div style={{
        position: "absolute", left: 0, top: 0,
        width: dotX,
        height: "100%",
        background: `linear-gradient(90deg, ${color}33 0%, ${color} 100%)`,
        borderRadius: 3,
        boxShadow: `0 0 8px ${color}66`,
        transition: "none",
      }} />
      {/* Leading dot */}
      {progress > 0.01 && (
        <div style={{
          position: "absolute",
          left: dotX - 9,
          top: -6,
          width: 18, height: 18,
          borderRadius: "50%",
          backgroundColor: color,
          boxShadow: `0 0 20px ${color}, 0 0 40px ${color}55`,
        }} />
      )}
    </div>
  );

  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <style>{GOOGLE_FONTS}</style>

      {/* Routes */}
      <div style={{ display: "flex", flexDirection: "column", gap: 36, marginBottom: 56 }}>
        <Route progress={r1} dotX={dot1x} color={colors.teal} trackW={TRACK_W} />
        <Route progress={r2} dotX={dot2x} color={colors.tealMid} trackW={TRACK_W} offsetLeft={40} />
      </div>

      <TextBlock text={text} subtitle={subtitle} startAt={textStart} frame={frame} />
    </AbsoluteFill>
  );
};

// ─── Transition 3: Pace Bar ───────────────────────────────────────────────────
// Distance range stat + a GPS-tracker progress bar
export const TransitionPaceBar: React.FC<{ number: string; label: string }> = ({ number, label }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const numProgress = spring({ frame: frame - 3, fps, config: { damping: 10, stiffness: 160, mass: 0.7 } });
  const numScale = interpolate(numProgress, [0, 1], [0.5, 1]);
  const numOpacity = interpolate(frame, [0, 8], [0, 1], { extrapolateRight: "clamp" });

  const barFill = interpolate(frame, [14, 40], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const barWidth = barFill * 680;

  const cursorBlink = frame > 40 ? Math.round(frame / 7) % 2 : 0;

  const labelOpacity = fadeIn(frame, 34);
  const labelY = slideUp(frame, 34);

  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <style>{GOOGLE_FONTS}</style>

      <div style={{
        fontFamily: fonts.title,
        fontSize: 140,
        fontWeight: 900,
        color: colors.teal,
        lineHeight: 0.9,
        opacity: numOpacity,
        transform: `scale(${numScale})`,
        letterSpacing: "-6px",
        marginBottom: 36,
        textAlign: "center",
      }}>
        {number}
      </div>

      {/* Progress bar */}
      <div style={{ width: 680, height: 5, backgroundColor: "rgba(255,255,255,0.1)", borderRadius: 3, position: "relative", marginBottom: 32 }}>
        <div style={{
          position: "absolute", left: 0, top: 0,
          width: barWidth, height: "100%",
          background: `linear-gradient(90deg, ${colors.teal}, ${colors.tealMid})`,
          borderRadius: 3,
        }} />
        {barFill > 0.01 && (
          <div style={{
            position: "absolute",
            left: barWidth - 7, top: -6,
            width: 16, height: 16,
            borderRadius: "50%",
            backgroundColor: colors.white,
            boxShadow: `0 0 12px ${colors.teal}`,
          }} />
        )}
        {barFill >= 1 && (
          <div style={{
            position: "absolute",
            right: -4, top: -8,
            width: 20, height: 20,
            borderRadius: "50%",
            backgroundColor: colors.teal,
            opacity: cursorBlink,
            boxShadow: `0 0 20px ${colors.teal}`,
          }} />
        )}
      </div>

      <div style={{
        fontFamily: fonts.body,
        fontSize: fontSizes.h3,
        color: "rgba(255,255,255,0.65)",
        opacity: labelOpacity,
        transform: `translateY(${labelY}px)`,
        letterSpacing: "2px",
        textTransform: "uppercase",
        textAlign: "center",
      }}>
        {label}
      </div>
    </AbsoluteFill>
  );
};

// ─── Transition 4: Steam Rise ─────────────────────────────────────────────────
// A minimal SVG cup with animated steam wisps — used for the café moment
export const TransitionSteam: React.FC<{ text: string; subtitle?: string }> = ({ text, subtitle }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const cupProgress = spring({ frame: frame - 2, fps, config: { damping: 14, stiffness: 180 } });
  const cupScale = interpolate(cupProgress, [0, 1], [0.6, 1]);
  const cupOpacity = interpolate(frame, [0, 8], [0, 1], { extrapolateRight: "clamp" });

  const steamWisps = [
    { delay: 12, x: 30, amplitude: 6 },
    { delay: 18, x: 56, amplitude: -8 },
    { delay: 24, x: 82, amplitude: 5 },
  ];

  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <style>{GOOGLE_FONTS}</style>

      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", marginBottom: 44, position: "relative" }}>
        {/* Steam wisps */}
        <div style={{ position: "relative", width: 132, height: 56, marginBottom: 4 }}>
          {steamWisps.map((wisp, i) => {
            const wispProgress = interpolate(frame - wisp.delay, [0, 40], [0, 1], {
              extrapolateLeft: "clamp", extrapolateRight: "clamp",
            });
            const wispY = interpolate(wispProgress, [0, 1], [40, 0]);
            const wispOpacity = interpolate(wispProgress, [0, 0.2, 0.7, 1], [0, 0.9, 0.55, 0]);
            const wispX = wisp.x + Math.sin(wispProgress * Math.PI * 1.5) * wisp.amplitude;

            return (
              <div key={i} style={{ position: "absolute", left: wispX, top: wispY - 6, opacity: wispOpacity }}>
                <svg width="16" height="40" viewBox="0 0 16 40" fill="none">
                  <path
                    d={`M 8,36 Q ${8 + wisp.amplitude},24 8,18 Q ${8 - wisp.amplitude},10 8,0`}
                    stroke="rgba(255,255,255,0.65)"
                    strokeWidth="2.5"
                    strokeLinecap="round"
                    fill="none"
                  />
                </svg>
              </div>
            );
          })}
        </div>

        {/* Cup SVG */}
        <div style={{ opacity: cupOpacity, transform: `scale(${cupScale})` }}>
          <svg width="132" height="118" viewBox="0 0 132 118" fill="none">
            <path d="M 20,20 L 26,98 Q 26,108 38,108 L 94,108 Q 106,108 106,98 L 112,20 Z"
              stroke={colors.white} strokeWidth="4" strokeLinejoin="round" fill="none" />
            <path d="M 16,20 L 116,20" stroke={colors.white} strokeWidth="4" strokeLinecap="round" />
            <path d="M 106,50 Q 130,50 130,68 Q 130,88 106,88"
              stroke={colors.white} strokeWidth="4" strokeLinecap="round" fill="none" />
            <path d="M 22,28 L 110,28 L 108,22 L 24,22 Z" fill={colors.teal} opacity={0.2} />
          </svg>
        </div>
      </div>

      <TextBlock text={text} subtitle={subtitle} startAt={36} frame={frame} />
    </AbsoluteFill>
  );
};

// ─── Transition 5: EKG Flash ──────────────────────────────────────────────────
// ECG line draws across the screen and pulses — used for the connection moment
export const TransitionEKG: React.FC<{ text: string; subtitle?: string }> = ({ text, subtitle }) => {
  const frame = useCurrentFrame();

  const drawProgress = interpolate(frame, [4, 40], [0, 1], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });

  const ekgPath = "M 0,60 L 120,60 L 140,45 L 160,60 L 280,60 L 320,10 L 350,110 L 380,20 L 410,60 L 560,60 L 580,45 L 600,60 L 900,60";
  const pathLength = 1100;
  const dashOffset = interpolate(drawProgress, [0, 1], [pathLength, 0]);

  const peakGlow = interpolate(frame, [28, 36, 50], [0, 1, 0], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });

  const bgOpacity = interpolate(frame, [0, 8], [0, 1], { extrapolateRight: "clamp" });

  return (
    <AbsoluteFill style={{ backgroundColor: "#0A0A0A", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
      <style>{GOOGLE_FONTS}</style>

      <div style={{ opacity: bgOpacity, width: "100%", display: "flex", flexDirection: "column", alignItems: "center" }}>
        <div style={{ width: 900, position: "relative", marginBottom: 44 }}>
          {/* Glow layer */}
          <svg width="900" height="120" viewBox="0 0 900 120" style={{ position: "absolute", top: 0, left: 0, opacity: peakGlow * 0.6, filter: "blur(8px)" }}>
            <path d={ekgPath} stroke={colors.teal} strokeWidth="6" fill="none"
              strokeLinecap="round" strokeLinejoin="round"
              strokeDasharray={pathLength} strokeDashoffset={dashOffset} />
          </svg>
          {/* Main line */}
          <svg width="900" height="120" viewBox="0 0 900 120">
            <path d={ekgPath} stroke={colors.teal} strokeWidth="3" fill="none"
              strokeLinecap="round" strokeLinejoin="round"
              strokeDasharray={pathLength} strokeDashoffset={dashOffset} />
          </svg>
        </div>

        <TextBlock text={text} subtitle={subtitle} startAt={42} frame={frame} />
      </div>
    </AbsoluteFill>
  );
};

// ─── Transition 0: App Card ───────────────────────────────────────────────────
// Brand card with Run Date app icon and "Tu t'inscris sur l'app." text
export const TransitionAppCard: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const iconProgress = spring({
    frame: frame - 4,
    fps,
    config: { damping: 10, stiffness: 200, mass: 0.6 },
  });
  const iconScale = interpolate(iconProgress, [0, 1], [0, 1]);
  const iconOpacity = interpolate(frame, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const textOpacity = fadeIn(frame, 24);
  const textY = slideUp(frame, 24);

  const subtextOpacity = fadeIn(frame, 36);
  const subtextY = slideUp(frame, 36);

  return (
    <AbsoluteFill style={{
      background: gradients.tealToNavy,
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
    }}>
      <style>{GOOGLE_FONTS}</style>

      <div style={{
        opacity: iconOpacity,
        transform: `scale(${iconScale})`,
        marginBottom: 40,
      }}>
        <Img
          src={staticFile("logos/rundate_appicon_1024.png")}
          style={{
            width: 160,
            height: 160,
            borderRadius: "22%",
            boxShadow: "0 12px 48px rgba(0,0,0,0.5), 0 4px 12px rgba(0,212,170,0.25)",
            display: "block",
          }}
        />
      </div>

      <div style={{
        fontFamily: fonts.title,
        fontSize: fontSizes.h1,
        fontWeight: 900,
        color: colors.white,
        textAlign: "center",
        opacity: textOpacity,
        transform: `translateY(${textY}px)`,
        lineHeight: 1.2,
        padding: "0 80px",
      }}>
        Inscris-toi. Choisis ta sortie.
      </div>

      <div style={{
        fontFamily: fonts.body,
        fontSize: fontSizes.body,
        color: "rgba(255,255,255,0.55)",
        textAlign: "center",
        opacity: subtextOpacity,
        transform: `translateY(${subtextY}px)`,
        marginTop: 14,
        letterSpacing: "2px",
        textTransform: "uppercase",
      }}>
        Run Date
      </div>
    </AbsoluteFill>
  );
};

// ─── Legacy exports ───────────────────────────────────────────────────────────
export const TransitionText = TransitionRipple;
export const TransitionStat = TransitionPaceBar;
export const TransitionIris: React.FC = () => null;
export const TransitionIcon = TransitionRipple;
