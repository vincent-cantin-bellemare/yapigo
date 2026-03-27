import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  Img,
  staticFile,
  spring,
  interpolate,
} from "remotion";
import { colors, gradients } from "../../../../design-system/colors";
import { fonts, fontSizes } from "../../../../design-system/typography";

// Animate each word with a staggered spring
const AnimatedWords: React.FC<{
  words: string[];
  startFrame: number;
  stagger: number;
  fontSize: number;
  color: string;
  fontWeight: number;
  textAlign?: "center" | "left" | "right";
}> = ({ words, startFrame, stagger, fontSize, color, fontWeight, textAlign = "center" }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  return (
    <div style={{
      display: "flex",
      flexWrap: "wrap",
      justifyContent: textAlign === "center" ? "center" : "flex-start",
      gap: "0 10px",
      lineHeight: 1.3,
    }}>
      {words.map((word, i) => {
        const wordFrame = frame - (startFrame + i * stagger);
        const progress = spring({
          frame: wordFrame,
          fps,
          config: { damping: 14, stiffness: 200, mass: 0.7 },
        });
        const opacity = interpolate(wordFrame, [0, 8], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
        const y = interpolate(progress, [0, 1], [24, 0]);

        return (
          <span
            key={i}
            style={{
              fontFamily: fonts.title,
              fontSize,
              fontWeight,
              color,
              opacity,
              transform: `translateY(${y}px)`,
              display: "inline-block",
              whiteSpace: "pre",
            }}
          >
            {word}{i < words.length - 1 ? " " : ""}
          </span>
        );
      })}
    </div>
  );
};

// iOS-style app icon with spring pop-in animation
const AppIcon: React.FC<{ frame: number; startFrame: number }> = ({ frame, startFrame }) => {
  const { fps } = useVideoConfig();
  const progress = spring({
    frame: frame - startFrame,
    fps,
    config: { damping: 10, stiffness: 220, mass: 0.6 },
  });
  const scale = interpolate(progress, [0, 1], [0, 1]);
  const opacity = interpolate(frame - startFrame, [0, 8], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div style={{
      opacity,
      transform: `scale(${scale})`,
      marginBottom: 10,
    }}>
      <Img
        src={staticFile("logos/rundate_appicon_1024.png")}
        style={{
          width: 96,
          height: 96,
          borderRadius: "22%",
          boxShadow: "0 8px 32px rgba(0,0,0,0.5), 0 2px 8px rgba(0,212,170,0.3)",
          display: "block",
        }}
      />
    </div>
  );
};

export const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Logo animation
  const logoProgress = spring({ frame: frame - 5, fps, config: { damping: 16, stiffness: 140 } });
  const logoOpacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
  const logoScale = interpolate(logoProgress, [0, 1], [0.88, 1]);

  // URL + icon fade in
  const urlOpacity = interpolate(frame, [95, 115], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  // Tagline
  const LINE1_WORDS = ["Fais", "le", "premier", "pas."];
  const LINE2_WORDS = ["Le", "deuxième,", "vous", "le", "ferez", "ensemble."];
  const LINE1_START = 35;
  const LINE2_START = 65;

  // Domain line
  const DOMAIN_START = 95;

  return (
    <AbsoluteFill
      style={{
        background: gradients.tealToNavy,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 0,
        padding: "0 60px",
      }}
    >
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&family=DM+Sans:wght@300;400&display=swap');`}</style>

      {/* Logo — display large so H.264 preserves text sharpness */}
      <div style={{ opacity: logoOpacity, transform: `scale(${logoScale})`, marginBottom: 48 }}>
        <Img src={staticFile("logos/rundate_white_clean.png")} style={{ width: 960, objectFit: "contain" }} />
      </div>

      {/* Tagline — word by word */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6, textAlign: "center" }}>
        <AnimatedWords words={LINE1_WORDS} startFrame={LINE1_START} stagger={5}
          fontSize={fontSizes.h2} fontWeight={800} color={colors.white} />
        <AnimatedWords words={LINE2_WORDS} startFrame={LINE2_START} stagger={4}
          fontSize={fontSizes.h3} fontWeight={400} color={"rgba(255,255,255,0.85)"} />
      </div>

      {/* URL + App icon */}
      <div style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 16,
        marginTop: 48,
        opacity: urlOpacity,
      }}>
        <AppIcon frame={frame} startFrame={DOMAIN_START - 10} />
        <div style={{
          fontFamily: fonts.body,
          fontSize: fontSizes.caption,
          fontWeight: 300,
          color: "rgba(255,255,255,0.55)",
          letterSpacing: "3px",
        }}>
          rundate.app
        </div>
      </div>
    </AbsoluteFill>
  );
};
