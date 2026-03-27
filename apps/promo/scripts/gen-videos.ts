/**
 * Generate video clips with Kling via fal.ai.
 * Run AFTER validating proto images: npm run gen:videos
 * Output: public/01-intro/videos/clip1.mp4 ... clip5.mp4
 */

import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();

fal.config({ credentials: process.env.FAL_KEY });

const OUTPUT_DIR = path.join(__dirname, "../public/01-intro/videos");

const KLING_MODEL = "fal-ai/kling-video/v3/standard/text-to-video";

const CLIPS = [
  {
    id: "clip1",
    duration: "5",
    description: "Groupe arrive au Parc La Fontaine",
    prompt:
      "A diverse group of 5 friendly runners arriving and greeting each other at Parc La Fontaine Montreal, early morning golden hour, casual athletic wear, warm smiles, cinematic 9:16 vertical video, shallow depth of field, Montreal park setting, soft natural light, smooth camera movement",
  },
  {
    id: "clip2",
    duration: "5",
    description: "Course de groupe, canal Lachine",
    prompt:
      "Group of 5 runners jogging together along Canal Lachine Montreal, side angle cinematic shot, golden hour sunrise, athletic wear, motion blur on feet, energetic and natural, smooth tracking camera, vertical 9:16 framing, warm cinematic tones, urban Montreal landscape",
  },
  {
    id: "clip3",
    duration: "5",
    description: "Deux coureurs qui rient en courant",
    prompt:
      "Two runners laughing while jogging side by side in a Montreal urban park, candid natural moment, morning light, athletic gear, genuine joy and connection, smooth handheld camera, vertical 9:16, golden bokeh background, cinematic look",
  },
  {
    id: "clip4",
    duration: "5",
    description: "Post-course, groupe qui reprend son souffle",
    prompt:
      "Group of 4 runners stopped after a run in Montreal park, catching breath and chatting naturally, leaning on park bench, athletic wear, post-run glow, warm morning light, candid documentary style, vertical 9:16, slow gentle camera drift",
  },
  {
    id: "clip5",
    duration: "5",
    description: "Café terrasse Plateau, tenues de course",
    prompt:
      "A group of four young adults two women and two men in running gear gathered around a small outdoor cafe terrace, classic Montreal Plateau-Mont-Royal red brick triplex buildings and red exterior metal staircases visible in background, bistro metal chairs, coffee cups on table, morning golden light, animated group conversation and laughter, post-run glow, natural candid energy, cinematic warm film look, vertical 9:16 framing, shallow depth of field",
  },
];

async function downloadFile(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    const protocol = url.startsWith("https") ? https : http;
    protocol
      .get(url, (response) => {
        response.pipe(file);
        file.on("finish", () => {
          file.close();
          resolve();
        });
      })
      .on("error", (err) => {
        fs.unlink(dest, () => {});
        reject(err);
      });
  });
}

async function generateClip(clip: (typeof CLIPS)[0]): Promise<void> {
  console.log(`\n🎬 Generating ${clip.id}: ${clip.description}`);
  console.log(`   Model: ${KLING_MODEL}`);
  console.log(`   Duration: ${clip.duration}s`);

  try {
    const result = await fal.subscribe(KLING_MODEL, {
      input: {
        prompt: clip.prompt,
        duration: clip.duration,
        aspect_ratio: "9:16",
        generate_audio: false,
        negative_prompt: "blur, distorted, low quality, shaky camera, unrealistic",
        cfg_scale: 0.5,
      },
      logs: true,
      onQueueUpdate: (update) => {
        if (update.status === "IN_PROGRESS") {
          const logs = (update as { logs?: { message: string }[] }).logs;
          if (logs?.length) {
            process.stdout.write(`   ⏳ ${logs[logs.length - 1].message}\r`);
          }
        }
      },
    });

    const output = result.data as { video?: { url: string } };
    const videoUrl = output.video?.url;

    if (videoUrl) {
      const destPath = path.join(OUTPUT_DIR, `${clip.id}.mp4`);
      await downloadFile(videoUrl, destPath);
      console.log(`\n   ✅ Saved to ${destPath}`);
    } else {
      console.error(`\n   ❌ No video returned for ${clip.id}`, result);
    }
  } catch (err) {
    console.error(`\n   ❌ Error generating ${clip.id}:`, err);
  }
}

async function main() {
  console.log("🎬 Run Date — Kling video clip generation");
  console.log(`📁 Output: ${OUTPUT_DIR}`);
  console.log("⚠️  Make sure you validated proto images first!\n");

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  // Generate clips sequentially (Kling queue can be slow)
  for (const clip of CLIPS) {
    await generateClip(clip);
  }

  console.log("\n✅ All clips generated!");
  console.log("💡 Replace placeholder colors in RunScene.tsx with <Video> components.");
}

main().catch(console.error);
