import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  OffthreadVideo,
  staticFile,
  interpolate,
  spring,
} from "remotion";
import { colors } from "../../../../design-system/colors";
import { fonts, fontSizes } from "../../../../design-system/typography";

const CLIPS = [
  {
    id: "clip1",
    file: "01-intro/videos/clip1.mp4",
    placeholderColor: "#1A3020",
    caption: "Tu t'inscris à une sortie.",
    captionStart: 20,
  },
  {
    id: "clip2",
    file: "01-intro/videos/clip2.mp4",
    placeholderColor: "#0D2030",
    caption: "Vous partez ensemble.",
    captionStart: 15,
  },
  {
    id: "clip3",
    file: "01-intro/videos/clip3.mp4",
    placeholderColor: "#1E2A10",
    caption: "",
    captionStart: 15,
  },
  {
    id: "clip4",
    file: "01-intro/videos/clip4.mp4",
    placeholderColor: "#1A1A30",
    caption: "",
    captionStart: 15,
  },
  {
    id: "clip5",
    file: "01-intro/videos/clip5.mp4",
    placeholderColor: "#2A1A10",
    caption: "",
    captionStart: 15,
  },
] as const;

// Each RunScene renders exactly one clip — Sequence resets frame to 0 locally
export const RunScene: React.FC<{ clipIndex: number }> = ({ clipIndex }) => {
  const clip = CLIPS[clipIndex];
  const frame = useCurrentFrame(); // 0 → 149
  const { fps } = useVideoConfig();

  const CLIP_DURATION = 150;

  // Fade in first 20 frames
  const fadeIn = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });
  // Fade out last 20 frames
  const fadeOut = interpolate(frame, [CLIP_DURATION - 20, CLIP_DURATION], [1, 0], {
    extrapolateLeft: "clamp", extrapolateRight: "clamp",
  });
  const opacity = Math.min(fadeIn, fadeOut);

  // Caption spring
  const captionFrame = frame - clip.captionStart;
  const captionSpring = spring({
    frame: captionFrame,
    fps,
    config: { damping: 14, stiffness: 180 },
  });
  const captionY = interpolate(captionSpring, [0, 1], [40, 0]);
  const captionOpacity = interpolate(captionFrame, [0, 10], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ opacity, backgroundColor: clip.placeholderColor }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@800;900&family=DM+Sans:wght@400&display=swap');`}</style>

      {/* Video — frame 0 of file aligns with frame 0 of this Sequence */}
      <AbsoluteFill>
        <OffthreadVideo
          src={staticFile(clip.file)}
          style={{ width: "100%", height: "100%", objectFit: "cover" }}
          muted
        />
      </AbsoluteFill>

      {/* Bottom gradient vignette */}
      <AbsoluteFill style={{
        background: "linear-gradient(to top, rgba(0,0,0,0.65) 0%, transparent 45%)",
        pointerEvents: "none",
      }} />

      {/* Caption */}
      {captionFrame >= 0 && (
        <div style={{
          position: "absolute",
          bottom: 180,
          left: 60,
          right: 60,
          fontFamily: fonts.title,
          fontSize: fontSizes.h2,
          fontWeight: 800,
          color: colors.white,
          opacity: captionOpacity,
          transform: `translateY(${captionY}px)`,
          lineHeight: 1.2,
          textShadow: "0 2px 20px rgba(0,0,0,0.8)",
          whiteSpace: "pre-line",
        }}>
          {clip.caption}
        </div>
      )}
    </AbsoluteFill>
  );
};
