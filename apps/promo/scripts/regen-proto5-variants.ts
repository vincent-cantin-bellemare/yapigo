import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();
fal.config({ credentials: process.env.FAL_KEY });

const BASE =
  "A group of four young adults, two women and two men, in running gear gathered around a small outdoor cafe terrace, classic Montreal Plateau-Mont-Royal red brick triplex buildings and colorful red exterior metal staircases in background, bistro metal chairs, coffee cups and lattes, morning golden light, post-run glow, mixed gender group, cinematic warm film photography";

const VARIANTS = [
  {
    id: "proto5b",
    extra:
      "wide shot showing the full Montreal street with parked cars and trees, group seated close together laughing loudly, very social energy",
  },
  {
    id: "proto5c",
    extra:
      "closer shot, one person standing leaning on their chair gesturing while talking, others smiling and listening, very animated and natural candid moment",
  },
  {
    id: "proto5d",
    extra:
      "golden hour warm backlight, one person checking their running watch, others chatting with coffees raised, relaxed and happy, slight lens flare",
  },
  {
    id: "proto5e",
    extra:
      "overhead slight angle showing the table with coffees and phones, people leaning in toward each other in conversation, lively group dynamic, autumn leaves on the ground",
  },
];

async function downloadFile(url: string, dest: string): Promise<void> {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    const protocol = url.startsWith("https") ? https : http;
    protocol
      .get(url, (response) => {
        response.pipe(file);
        file.on("finish", () => { file.close(); resolve(); });
      })
      .on("error", reject);
  });
}

async function main() {
  console.log("📸 Génération de 4 variantes proto5...\n");

  for (const v of VARIANTS) {
    console.log(`🎨 ${v.id}...`);
    const result = await fal.subscribe("fal-ai/flux/schnell", {
      input: {
        prompt: `${BASE}, ${v.extra}`,
        image_size: { width: 720, height: 1280 },
        num_inference_steps: 4,
        num_images: 1,
        enable_safety_checker: false,
      },
    });
    const url = (result.data as { images: { url: string }[] }).images[0].url;
    const dest = `public/01-intro/images/${v.id}.jpg`;
    await downloadFile(url, dest);
    console.log(`   ✅ ${dest}`);
  }

  console.log("\n✅ 4 variantes générées — proto5b à proto5e");
  console.log("La version originale est toujours proto5.jpg");
}

main().catch(console.error);
