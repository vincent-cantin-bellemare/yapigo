import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
} from "remotion";
import { colors, gradients } from "../../../../design-system/colors";
import { fonts, fontSizes } from "../../../../design-system/typography";

// Timing constants (frames at 30fps) — compressed to 6s (180 frames)
const PHONE_SLIDE_IN = 0;
const SHOW_PROFILE = 8;
const SWIPE_RIGHT = 25;
const MATCH_FLASH = 40;
const CHAT_VIEW = 55;
const MSG1_APPEAR = 62;
const MSG2_APPEAR = 78;
const READ_RECEIPT = 92;
const TYPING_IN = 106;
const TYPING_OUT = 126;
const PUNCHLINE = 140;

// Fake avatar colors
const AVATAR_GRADIENT = "linear-gradient(135deg, #667eea 0%, #764ba2 100%)";

const PhoneMockup: React.FC<{ opacity: number; translateY: number; children: React.ReactNode }> = ({
  opacity, translateY, children
}) => (
  <div style={{
    width: 340,
    height: 620,
    backgroundColor: "#0A0A0A",
    borderRadius: 44,
    border: "3px solid #2A2A2A",
    overflow: "hidden",
    opacity,
    transform: `translateY(${translateY}px)`,
    boxShadow: "0 40px 80px rgba(0,0,0,0.8), inset 0 1px 0 rgba(255,255,255,0.05)",
    position: "relative",
    flexShrink: 0,
  }}>
    {/* Notch */}
    <div style={{
      position: "absolute", top: 0, left: "50%", transform: "translateX(-50%)",
      width: 120, height: 28, backgroundColor: "#0A0A0A",
      borderRadius: "0 0 20px 20px", zIndex: 10,
    }} />
    {children}
  </div>
);

const ProfileCard: React.FC<{ opacity: number; swipeX: number }> = ({ opacity, swipeX }) => (
  <div style={{
    position: "absolute", inset: 0,
    display: "flex", flexDirection: "column",
    backgroundColor: "#111",
    opacity,
    transform: `translateX(${swipeX}px) rotate(${swipeX * 0.05}deg)`,
  }}>
    {/* Fake profile photo */}
    <div style={{
      flex: 1,
      background: "linear-gradient(160deg, #2d5a4a 0%, #1a3a2a 100%)",
      display: "flex", alignItems: "flex-end", padding: 20,
    }}>
      {/* Silhouette */}
      <div style={{
        width: "100%", height: "70%",
        display: "flex", alignItems: "flex-end", justifyContent: "center",
        opacity: 0.4,
      }}>
        <div style={{ fontSize: 120 }}>🏃</div>
      </div>
    </div>
    <div style={{
      padding: "16px 20px 24px",
      background: "linear-gradient(to top, #111 0%, transparent 100%)",
      position: "absolute", bottom: 0, left: 0, right: 0,
    }}>
      <div style={{ fontFamily: fonts.title, fontSize: 26, fontWeight: 800, color: "#fff" }}>
        Mathieu, 28
      </div>
      <div style={{ fontFamily: fonts.body, fontSize: 14, color: "rgba(255,255,255,0.6)", marginTop: 4 }}>
        📍 Montréal · 3 km
      </div>
    </div>
    {/* Swipe indicator */}
    {swipeX > 30 && (
      <div style={{
        position: "absolute", top: 60, left: 20,
        border: "3px solid #00D4AA", borderRadius: 8,
        padding: "4px 12px",
        transform: `rotate(-15deg)`,
        opacity: Math.min((swipeX - 30) / 60, 1),
      }}>
        <span style={{ color: "#00D4AA", fontFamily: fonts.title, fontWeight: 800, fontSize: 20 }}>LIKE</span>
      </div>
    )}
  </div>
);

const ChatView: React.FC<{
  showMsg1: boolean;
  showMsg2: boolean;
  showRead: boolean;
  showTyping: boolean;
  typingOpacity: number;
}> = ({ showMsg1, showMsg2, showRead, showTyping, typingOpacity }) => (
  <div style={{
    position: "absolute", inset: 0,
    backgroundColor: "#111",
    display: "flex", flexDirection: "column",
  }}>
    {/* Chat header */}
    <div style={{
      padding: "40px 16px 12px",
      borderBottom: "1px solid #222",
      display: "flex", alignItems: "center", gap: 12,
    }}>
      <div style={{
        width: 40, height: 40, borderRadius: "50%",
        background: AVATAR_GRADIENT,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 16, color: "#fff", fontWeight: 700, fontFamily: fonts.title,
      }}>M</div>
      <div>
        <div style={{ fontFamily: fonts.title, fontWeight: 700, color: "#fff", fontSize: 15 }}>Mathieu</div>
        <div style={{ fontFamily: fonts.body, fontSize: 11, color: "#00D4AA" }}>En ligne</div>
      </div>
    </div>

    {/* Messages */}
    <div style={{ flex: 1, padding: "16px 16px 0", display: "flex", flexDirection: "column", justifyContent: "flex-end", gap: 8 }}>
      {showMsg1 && (
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <div style={{
            backgroundColor: "#00D4AA", color: "#fff",
            padding: "10px 14px", borderRadius: "18px 18px 4px 18px",
            fontFamily: fonts.body, fontSize: 15, maxWidth: "75%",
          }}>
            Salut! 👋
          </div>
        </div>
      )}
      {showMsg2 && (
        <div style={{ display: "flex", justifyContent: "flex-end" }}>
          <div style={{
            backgroundColor: "#00D4AA", color: "#fff",
            padding: "10px 14px", borderRadius: "18px 18px 4px 18px",
            fontFamily: fonts.body, fontSize: 15, maxWidth: "75%",
          }}>
            Ça va? 😊
          </div>
        </div>
      )}
      {showRead && (
        <div style={{
          textAlign: "right",
          fontFamily: fonts.body, fontSize: 11,
          color: "rgba(255,255,255,0.35)",
        }}>
          Lu à 14h32 ✓✓
        </div>
      )}
      {showTyping && (
        <div style={{ display: "flex", alignItems: "center", gap: 8, opacity: typingOpacity }}>
          <div style={{
            width: 32, height: 32, borderRadius: "50%",
            background: AVATAR_GRADIENT, flexShrink: 0,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 12, color: "#fff", fontWeight: 700,
          }}>M</div>
          <div style={{
            backgroundColor: "#222",
            padding: "10px 14px", borderRadius: "18px 18px 18px 4px",
            display: "flex", gap: 4, alignItems: "center",
          }}>
            {[0, 1, 2].map(i => (
              <div key={i} style={{
                width: 6, height: 6, borderRadius: "50%",
                backgroundColor: "rgba(255,255,255,0.5)",
              }} />
            ))}
          </div>
        </div>
      )}
    </div>

    {/* Input bar */}
    <div style={{
      padding: "12px 16px 24px",
      borderTop: "1px solid #222",
      display: "flex", alignItems: "center", gap: 10,
    }}>
      <div style={{
        flex: 1, backgroundColor: "#1A1A1A", borderRadius: 20,
        padding: "10px 16px",
        fontFamily: fonts.body, fontSize: 14, color: "rgba(255,255,255,0.2)",
      }}>
        Message...
      </div>
    </div>
  </div>
);

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Phone slide in
  const phoneProgress = spring({ frame: frame - PHONE_SLIDE_IN, fps, config: { damping: 16, stiffness: 140 } });
  const phoneY = interpolate(phoneProgress, [0, 1], [300, 0]);
  const phoneOpacity = interpolate(frame, [0, 20], [0, 1], { extrapolateRight: "clamp" });

  // Swipe animation
  const swipeProgress = spring({ frame: frame - SWIPE_RIGHT, fps, config: { damping: 12, stiffness: 200 } });
  const swipeX = frame >= SWIPE_RIGHT ? interpolate(swipeProgress, [0, 1], [0, 500]) : 0;
  const profileVisible = frame < MATCH_FLASH;
  const chatVisible = frame >= CHAT_VIEW;

  // Match flash
  // Gap = 20 frames → use ±6 to stay strictly monotonic
  const matchOpacity = frame >= MATCH_FLASH && frame < CHAT_VIEW
    ? interpolate(frame, [MATCH_FLASH, MATCH_FLASH + 6, CHAT_VIEW - 6, CHAT_VIEW], [0, 1, 1, 0], { extrapolateRight: "clamp" })
    : 0;

  // Chat states
  const showMsg1 = frame >= MSG1_APPEAR;
  const showMsg2 = frame >= MSG2_APPEAR;
  const showRead = frame >= READ_RECEIPT;
  const showTyping = frame >= TYPING_IN && frame < TYPING_OUT;
  const typingOpacity = frame >= TYPING_IN
    ? interpolate(frame, [TYPING_IN, TYPING_IN + 8, TYPING_OUT - 8, TYPING_OUT], [0, 1, 1, 0], { extrapolateRight: "clamp" })
    : 0;

  // Punchline
  const punchlineProgress = spring({ frame: frame - PUNCHLINE, fps, config: { damping: 10, stiffness: 160 } });
  const punchlineScale = interpolate(punchlineProgress, [0, 1], [0.8, 1]);
  const punchlineOpacity = interpolate(frame - PUNCHLINE, [0, 10], [0, 1], { extrapolateRight: "clamp" });

  // Phone fade out before punchline
  const phoneFade = interpolate(frame, [PUNCHLINE - 15, PUNCHLINE], [1, 0], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });

  return (
    <AbsoluteFill style={{ background: gradients.darkToBlack }}>
      <style>{`@import url('https://fonts.googleapis.com/css2?family=Nunito:wght@400;700;800;900&family=DM+Sans:wght@300;400;500&display=swap');`}</style>

      {/* Background label */}
      {frame < PUNCHLINE && (
        <div style={{
          position: "absolute", top: 100, left: 0, right: 0,
          textAlign: "center",
          fontFamily: fonts.body, fontSize: fontSizes.caption,
          color: "rgba(255,255,255,0.2)",
          letterSpacing: 3, textTransform: "uppercase",
        }}>
          Les apps de rencontre...
        </div>
      )}

      {/* Phone */}
      {frame < PUNCHLINE && (
        <div style={{
          position: "absolute", inset: 0,
          display: "flex", alignItems: "center", justifyContent: "center",
          opacity: phoneFade,
        }}>
          <PhoneMockup opacity={phoneOpacity} translateY={phoneY}>
            {/* Profile card */}
            {profileVisible && frame >= SHOW_PROFILE && (
              <ProfileCard opacity={1} swipeX={swipeX} />
            )}

            {/* Match flash */}
            {matchOpacity > 0 && (
              <div style={{
                position: "absolute", inset: 0,
                background: "linear-gradient(135deg, #00D4AA22 0%, #00D4AA44 100%)",
                display: "flex", flexDirection: "column",
                alignItems: "center", justifyContent: "center",
                opacity: matchOpacity,
              }}>
                <div style={{ fontSize: 48 }}>🎉</div>
                <div style={{
                  fontFamily: fonts.title, fontWeight: 900,
                  fontSize: 22, color: "#00D4AA", marginTop: 12,
                }}>C'est un match!</div>
              </div>
            )}

            {/* Chat view */}
            {chatVisible && (
              <ChatView
                showMsg1={showMsg1}
                showMsg2={showMsg2}
                showRead={showRead}
                showTyping={showTyping}
                typingOpacity={typingOpacity}
              />
            )}
          </PhoneMockup>
        </div>
      )}

      {/* Punchline */}
      {frame >= PUNCHLINE && (
        <AbsoluteFill style={{
          display: "flex", flexDirection: "column",
          alignItems: "flex-start", justifyContent: "center",
          padding: "0 80px",
        }}>
          <div style={{
            fontFamily: fonts.title,
            opacity: punchlineOpacity,
            transform: `scale(${punchlineScale})`,
            transformOrigin: "left center",
          }}>
            <div style={{ fontSize: fontSizes.hero, fontWeight: 900, color: colors.teal, lineHeight: 1 }}>
              Perte de temps...
            </div>
            <div style={{ fontSize: fontSizes.h1, fontWeight: 800, color: colors.white, lineHeight: 1.1, marginTop: 12 }}>
              Tu cherches une alternative ?
            </div>
          </div>
        </AbsoluteFill>
      )}
    </AbsoluteFill>
  );
};
