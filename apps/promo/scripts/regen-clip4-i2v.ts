/**
 * Regenerate clip4 using Kling image-to-video (i2v).
 * Uses proto4.jpg as the source frame so Kling preserves the portrait orientation.
 * Run: npx tsx scripts/regen-clip4-i2v.ts
 */

import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();

fal.config({ credentials: process.env.FAL_KEY });

const PROTO_IMAGE = path.join(__dirname, "../public/01-intro/images/proto4.jpg");
const OUTPUT = path.join(__dirname, "../public/01-intro/videos/clip4.mp4");
const KLING_I2V = "fal-ai/kling-video/v2/master/image-to-video";

const PROMPT =
  "A diverse group of 4 runners standing and chatting naturally in a Montreal park after finishing a run, " +
  "catching their breath with warm smiles, post-run glow, water bottles in hand, " +
  "golden autumn morning light filtering through maple trees, " +
  "candid gentle camera drift forward, shallow depth of field, cinematic warm tones, " +
  "people subtly moving — breathing, laughing, shifting weight — natural energy.";

async function downloadFile(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    const protocol = url.startsWith("https") ? https : http;
    protocol
      .get(url, (response) => {
        response.pipe(file);
        file.on("finish", () => { file.close(); resolve(); });
      })
      .on("error", (err) => { fs.unlink(dest, () => {}); reject(err); });
  });
}

async function main() {
  console.log("🎬 Regenerating clip4 via Kling image-to-video");
  console.log(`   Source image: ${PROTO_IMAGE}`);
  console.log(`   Model: ${KLING_I2V}\n`);

  // Upload the source image to fal.ai storage
  console.log("   📤 Uploading proto4.jpg to fal.ai storage...");
  const imageBuffer = fs.readFileSync(PROTO_IMAGE);
  const imageFile = new File([imageBuffer], "proto4.jpg", { type: "image/jpeg" });
  const imageUrl = await fal.storage.upload(imageFile);
  console.log(`   ✅ Uploaded: ${imageUrl}\n`);

  const result = await fal.subscribe(KLING_I2V, {
    input: {
      image_url: imageUrl,
      prompt: PROMPT,
      duration: "5",
      negative_prompt: "wide, landscape, horizontal, blur, distorted, low quality, shaky",
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
