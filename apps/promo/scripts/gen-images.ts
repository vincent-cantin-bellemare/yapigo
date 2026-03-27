/**
 * Generate prototype images with fal.ai (fast model) for visual direction validation.
 * Run: npm run gen:images
 * Output: public/01-intro/images/proto1.jpg ... proto5.jpg
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

// Prompts for each Kling clip we'll generate later
// Generated in 9:16 portrait format for mobile preview
const PROMPTS = [
  {
    id: "proto1",
    description: "Clip 1 — Groupe arrive au parc",
    prompt:
      "A diverse group of 5 runners (3 women, 2 men, ages 25-35) arriving and greeting each other at Parc La Fontaine Montreal, early morning golden hour light, casual athletic wear with teal accents, warm smiles, cinematic photography, shallow depth of field, urban park setting, Montreal autumn trees",
  },
  {
    id: "proto2",
    description: "Clip 2 — Course de groupe, canal Lachine",
    prompt:
      "Group of 5 runners jogging together along Canal Lachine Montreal, side angle cinematic shot, golden hour sunrise light, athletic wear, Montreal urban landscape in background, motion blur on feet, energetic but natural, film photography look, warm tones",
  },
  {
    id: "proto3",
    description: "Clip 3 — Rires en courant",
    prompt:
      "Two runners laughing while jogging in a Montreal urban park, candid natural moment, morning light, athletic gear, genuine joy and connection, blurred park background, cinematic portrait, golden hour, shallow depth of field",
  },
  {
    id: "proto4",
    description: "Clip 4 — Post-course, souffles",
    prompt:
      "Group of 4 runners stopped after a run in a Montreal park, catching breath, smiling and chatting naturally, leaning on a park bench, athletic wear, post-exercise glow, warm morning light, candid documentary photography style",
  },
  {
    id: "proto5",
    description: "Clip 5 — Café terrasse Plateau",
    prompt:
      "Three young adults in running gear sitting at a small outdoor cafe terrace on a typical Montreal Plateau-Mont-Royal street, classic red brick triplex buildings and colorful exterior staircases visible in the background, authentic Montreal neighbourhood, bistro metal chairs and small round table, coffee cups and lattes, morning golden light, laughing and relaxed post-run conversation, shallow depth of field, cinematic warm film photography, no American-style storefronts",
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

async function generateImage(prompt: {
  id: string;
  description: string;
  prompt: string;
}): Promise<void> {
  console.log(`\n📸 Generating ${prompt.id}: ${prompt.description}`);
  console.log(`   Prompt: ${prompt.prompt.substring(0, 80)}...`);

  try {
    const result = await fal.subscribe("fal-ai/flux/schnell", {
      input: {
        prompt: prompt.prompt,
        image_size: { width: 720, height: 1280 },
        num_inference_steps: 4,
        num_images: 1,
        enable_safety_checker: false,
      },
      logs: false,
    });

    const output = result.data as { images: { url: string }[] };

    if (output.images && output.images.length > 0) {
      const imageUrl = output.images[0].url;
      const destPath = path.join(OUTPUT_DIR, `${prompt.id}.jpg`);
      await downloadFile(imageUrl, destPath);
      console.log(`   ✅ Saved to ${destPath}`);
    } else {
      console.error(`   ❌ No image returned for ${prompt.id}`);
    }
  } catch (err) {
    console.error(`   ❌ Error generating ${prompt.id}:`, err);
  }
}

async function main() {
  console.log("🎨 Run Date — Proto image generation (Flux Schnell via fal.ai)");
  console.log(`📁 Output: ${OUTPUT_DIR}\n`);

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  for (const prompt of PROMPTS) {
    await generateImage(prompt);
  }

  console.log("\n✅ All proto images generated!");
  console.log("👀 Review them in public/01-intro/images/ before generating Kling clips.");
}

main().catch(console.error);
