import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { colors, gradients } from "../../../../design-system/colors";
import { fonts, fontSizes } from "../../../../design-system/typography";

// Timing constants (frames at 30fps) — 3s text-only (90 frames)
const LABEL_IN = 5;
const HEADLINE_IN = 25;
const SUBLINE_IN = 55;

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const labelOpacity = interpolate(frame, [LABEL_IN, LABEL_IN + 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const labelY = interpolate(frame, [LABEL_IN, LABEL_IN + 12], [14, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const headProgress = spring({
    frame: frame - HEADLINE_IN,
    fps,
    config: { damping: 10, stiffness: 160 },
  });
  const headScale = interpolate(headProgress, [0, 1], [0.8, 1]);
  const headOpacity = interpolate(frame - HEADLINE_IN, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const subOpacity = interpolate(frame, [SUBLINE_IN, SUBLINE_IN + 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const subY = interpolate(frame, [SUBLINE_IN, SUBLINE_IN + 12], [18, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ background: gradients.darkToBlack }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&family=DM+Sans:wght@300;400;500&display=swap');`}</style>

      <AbsoluteFill
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "flex-start",
          justifyContent: "center",
          padding: "0 80px",
          gap: 16,
        }}
      >
        {/* Small label */}
        <div
          style={{
            fontFamily: fonts.body,
            fontSize: fontSizes.body,
            color: "rgba(255,255,255,0.4)",
            letterSpacing: 3,
            textTransform: "uppercase",
            opacity: labelOpacity,
            transform: `translateY(${labelY}px)`,
          }}
        >
          Application de dating.
        </div>

        {/* Headline */}
        <div
          style={{
            fontFamily: fonts.title,
            fontSize: fontSizes.hero,
            fontWeight: 900,
            color: colors.teal,
            lineHeight: 1,
            opacity: headOpacity,
            transform: `scale(${headScale})`,
            transformOrigin: "left center",
          }}
        >
          Perte de temps...
        </div>

        {/* Sub-line */}
        <div
          style={{
            fontFamily: fonts.title,
            fontSize: fontSizes.h1,
            fontWeight: 800,
            color: colors.white,
            lineHeight: 1.1,
            opacity: subOpacity,
            transform: `translateY(${subY}px)`,
          }}
        >
          Tu cherches une alternative ?
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
