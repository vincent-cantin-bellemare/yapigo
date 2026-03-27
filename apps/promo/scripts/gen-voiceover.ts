/**
 * Generate voiceover with ElevenLabs via fal.ai.
 * Uses the cheapest available model for prototyping.
 * Run: npm run gen:voiceover
 * Output: public/01-intro/audio/voiceover.mp3
 */

import { fal } from "@fal-ai/client";
import * as fs from "fs";
import * as path from "path";
import * as https from "https";
import * as http from "http";
import { config } from "dotenv";

config();

fal.config({ credentials: process.env.FAL_KEY });

const OUTPUT_DIR = path.join(__dirname, "../public/01-intro/audio");

// Full voiceover script — Quebec French, casual, complicit tone
const VOICEOVER_TEXT = `T'as déjà matché avec quelqu'un... jasé pendant trois jours... pour finalement se voir une fois... une vraie perte de temps?

Ouin. Nous autres aussi.

Run Date, c'est différent. Tu t'inscris à une sortie. Tu arrives dans un parc. Y'a d'autres coureurs.

Vous partez ensemble. Cinq kilomètres plus tard — tu sais si t'as cliqué avec quelqu'un ou pas. Pas besoin de swiper pour le deviner.

Après la course, retrouvez-vous sur l'app. Envoyez un message. Planifiez la prochaine sortie.

Fais le premier pas. Le deuxième, vous le ferez ensemble.`;

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
  console.log("🎙️ Run Date — Voiceover generation (ElevenLabs via fal.ai)");

  if (!fs.existsSync(OUTPUT_DIR)) {
    fs.mkdirSync(OUTPUT_DIR, { recursive: true });
  }

  console.log("\nText:");
  console.log(VOICEOVER_TEXT);
  console.log("\nGenerating...");

  try {
    // List available voices first to pick the best French one
    // Using fal.ai's ElevenLabs TTS endpoint
    // turbo-v2.5 — cheapest + fastest, good for prototyping
    // Charlotte voice — warm, conversational French
    const result = await fal.subscribe("fal-ai/elevenlabs/tts/turbo-v2.5", {
      input: {
        text: VOICEOVER_TEXT,
        voice: "Charlotte",
        language_code: "fr",
        stability: 0.5,
        similarity_boost: 0.75,
        style: 0.2,
        speed: 0.95,
      },
      logs: true,
    });

    const output = result.data as { audio?: { url: string }; url?: string };
    const audioUrl = output.audio?.url || output.url;

    if (audioUrl) {
      const destPath = path.join(OUTPUT_DIR, "voiceover.mp3");
      await downloadFile(audioUrl, destPath);
      console.log(`\n✅ Voiceover saved to ${destPath}`);
      console.log("💡 Uncomment the <Audio> line in RunDateIntro.tsx to use it.");
    } else {
      console.error("❌ No audio URL returned:", result);
    }
  } catch (err) {
    console.error("❌ Error generating voiceover:", err);
    console.log("\n💡 Tip: Check available voices at https://fal.ai/models/fal-ai/elevenlabs/tts");
  }
}

main().catch(console.error);
