import { Composition, registerRoot } from "remotion";
import { RunDateIntro } from "./videos/01-rundate-intro/RunDateIntro";

// 37.5 seconds × 30fps = 1125 frames
const DURATION_FRAMES = 1125;
const FPS = 30;
const WIDTH = 1080;
const HEIGHT = 1920;

export const RemotionRoot = () => {
  return (
    <Composition
      id="RunDateIntro"
      component={RunDateIntro}
      durationInFrames={DURATION_FRAMES}
      fps={FPS}
      width={WIDTH}
      height={HEIGHT}
    />
  );
};

registerRoot(RemotionRoot);
