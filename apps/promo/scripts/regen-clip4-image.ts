/**
 * Generate a prototype image for clip4 (post-run group) via Flux Schnell.
 * Run: npx tsx scripts/regen-clip4-image.ts
 */

import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();

fal.config({ credentials: process.env.FAL_KEY });

const OUTPUT_DIR = path.join(__dirname, "../public/01-intro/images");

const PROMPT = [
  "Vertical portrait photo, 9:16 aspect ratio, shot on smartphone.",
  "A group of 4 young adults in running gear stopped after their run in a lush green Montreal park,",
  "catching their breath and chatting naturally, leaning on a park bench,",
  "water bottles in hand, post-run glow and genuine smiles,",
  "warm golden morning light filtering through maple trees,",
  "candid documentary photography style,",
  "shallow depth of field, cinematic warm film tones,",
  "tall vertical framing showing full bodies and park environment.",
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
  console.log("🖼️  Generating proto clip4 image (post-run group, vertical)");

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  const result = await fal.subscribe("fal-ai/flux/schnell", {
    input: {
      prompt: PROMPT,
      image_size: { width: 768, height: 1344 },
      num_images: 1,
    },
    logs: true,
  });

  const output = result.data as { images?: { url: string }[] };
  const imageUrl = output.images?.[0]?.url;

  if (imageUrl) {
    const dest = path.join(OUTPUT_DIR, "proto_clip4.jpg");
    await downloadFile(imageUrl, dest);
    console.log(`✅ Saved to ${dest}`);
  } else {
    console.error("❌ No image returned", result);
  }
}

main().catch(console.error);
