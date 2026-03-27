import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();
fal.config({ credentials: process.env.FAL_KEY });

const PROMPT =
  "A group of four young adults, two women and two men, in running gear gathered around a small outdoor cafe terrace on a typical Montreal Plateau-Mont-Royal street, classic red brick triplex buildings and colorful red exterior metal staircases visible in background, authentic Montreal neighbourhood, bistro metal chairs pulled together, coffee cups and lattes on the table, morning golden light, animated group conversation and laughter, post-run glow, mixed gender group, shallow depth of field, cinematic warm film photography, no American-style storefronts";

async function main() {
  console.log("📸 Régénération proto5 — Café terrasse Plateau montréalais...");

  const result = await fal.subscribe("fal-ai/flux/schnell", {
    input: {
      prompt: PROMPT,
      image_size: { width: 720, height: 1280 },
      num_inference_steps: 4,
      num_images: 1,
      enable_safety_checker: false,
    },
  });

  const url = (result.data as { images: { url: string }[] }).images[0].url;
  const dest = "public/01-intro/images/proto5.jpg";
  const file = fs.createWriteStream(dest);
  const protocol = url.startsWith("https") ? https : http;

  await new Promise<void>((resolve, reject) => {
    protocol.get(url, (response) => {
      response.pipe(file);
      file.on("finish", () => { file.close(); resolve(); });
    }).on("error", reject);
  });

  console.log(`✅ Sauvegardé : ${dest}`);
}

main().catch(console.error);
