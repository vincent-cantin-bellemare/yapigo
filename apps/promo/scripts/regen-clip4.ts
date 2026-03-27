/**
 * Regenerate clip4 in proper vertical 9:16 format via Kling 3.0.
 * Run: npx tsx scripts/regen-clip4.ts
 */

import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();

fal.config({ credentials: process.env.FAL_KEY });

const OUTPUT = path.join(__dirname, "../public/01-intro/videos/clip4.mp4");
const KLING_MODEL = "fal-ai/kling-video/v3/standard/text-to-video";

const PROMPT = [
  "Vertical portrait video, 9:16 aspect ratio, shot on smartphone.",
  "A group of 4 young adults in running gear stopped after their run in a green Montreal park,",
  "catching their breath and chatting naturally, leaning against a park bench,",
  "athletic wear, post-run glow and smiles, water bottles in hand,",
  "warm golden morning light filtering through trees,",
  "candid documentary style, slow gentle camera drift forward,",
  "shallow depth of field, cinematic warm film tones,",
  "tall vertical framing showing full bodies and park environment above.",
].join(" ");

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

async function main() {
  console.log("🎬 Regenerating clip4 (post-run group, vertical)");
  console.log(`   Model: ${KLING_MODEL}`);
  console.log(`   Output: ${OUTPUT}\n`);

  const result = await fal.subscribe(KLING_MODEL, {
    input: {
      prompt: PROMPT,
      duration: "5",
      aspect_ratio: "9:16",
      generate_audio: false,
      negative_prompt:
        "horizontal, landscape, 16:9, blur, distorted, low quality, shaky camera, unrealistic",
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
    await downloadFile(videoUrl, OUTPUT);
    console.log(`\n   ✅ Saved to ${OUTPUT}`);
  } else {
    console.error("\n   ❌ No video returned", result);
  }
}

main().catch(console.error);
