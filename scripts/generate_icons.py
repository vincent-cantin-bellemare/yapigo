#!/usr/bin/env python3
"""
Generate custom icons/illustrations for RunDate app
using fal.ai's nano-banana-pro model.
"""

import os
import sys
import json
import time
import urllib.request
import urllib.error

FAL_KEY = os.environ.get(
    "FAL_KEY",
    "96f71f8f-27cd-4028-9901-b3293fae57de:53cb4cd3161ac5ab7ac9adb4fdf61028",
)

ENDPOINT = "https://queue.fal.run/fal-ai/nano-banana-pro"

STYLE_PREFIX = (
    "Minimal flat vector icon, very simple shapes, bold outlines, "
    "designed to be recognizable at very small sizes (32x32 pixels). "
    "Maximum 3-4 colors from this palette: teal (#00D4AA), navy (#1B2A4A), "
    "cyan (#00BCD4), cream (#FBF7F2). "
    "No fine details, no gradients, no shadows, no texture. "
    "Solid white background, no text, no watermark. "
    "Think app icon or emoji replacement — chunky, bold, iconic. "
)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
ASSETS_BASE = os.path.join(PROJECT_ROOT, "apps", "mobile", "assets")


# ---------------------------------------------------------------------------
# Image definitions — grouped by category
# ---------------------------------------------------------------------------

MASCOTS = {
    "output_dir": os.path.join(ASSETS_BASE, "icons"),
    "aspect_ratio": "1:1",
    "images": {
        "lievre": (
            "Simple icon of a RUNNING HARE (rabbit) seen from the SIDE in full body profile. "
            "Very long upright ears clearly visible, leaping forward mid-run. "
            "The long ears are the key recognizable feature — they must be prominent. "
            "Chunky bold shapes, very minimal. Teal hare, navy outline."
        ),
        "king": (
            "Simple icon of a male face silhouette in PROFILE VIEW (side view facing right), "
            "short hair, strong jaw, wearing a bold crown on top. "
            "Minimal geometric shapes, bold thick outline. "
            "Navy silhouette, teal crown, same style as a female profile icon."
        ),
        "queen": (
            "Simple icon of a female face silhouette with ponytail wearing a small tiara. "
            "Minimal geometric shapes, bold thick outline. "
            "Navy silhouette, teal tiara with tiny sparkle dots."
        ),
        "crown": (
            "Simple icon of a royal crown, front view, 3 points. "
            "Chunky bold shape, very minimal. Teal and gold tones. "
            "A tiny running shoe silhouette in the center jewel spot."
        ),
        "runner": (
            "Simple icon of a person RUNNING, full body in dynamic mid-stride pose. "
            "Arms and legs in motion, leaning forward. Like an athletic pictogram. "
            "Bold thick outline, navy silhouette with teal motion lines behind."
        ),
        "inscription_confirmee": (
            "Simple icon of a bold checkmark inside a circle with tiny confetti pieces around it. "
            "Chunky bold shapes, very minimal. Cyan circle, navy checkmark, teal confetti."
        ),
        "evenement_gratuit": (
            "Simple icon of a price tag with a zero or dollar sign crossed out. "
            "Chunky bold shapes, very minimal. Cyan tag, navy text/cross."
        ),
        "communaute": (
            "Simple icon of a camera/photo frame with a tiny heart in the lens. "
            "Chunky bold shapes, very minimal. Navy camera body, teal heart/lens."
        ),
        "nouveaux_membres": (
            "Simple icon of a sprouting seedling or a small plant with a star above it. "
            "Represents new growth / new beginnings. "
            "Chunky bold shapes, very minimal. Cyan plant, teal star."
        ),
        "groupes_bientot": (
            "Simple icon of 3-4 running person silhouettes grouped together in a cluster, "
            "with a small clock/timer symbol floating above the group. "
            "Represents 'groups forming soon'. Chunky bold shapes, very minimal. "
            "Navy silhouettes, teal clock hands."
        ),
    },
}

DISTANCE_ICONS = {
    "output_dir": os.path.join(ASSETS_BASE, "icons"),
    "aspect_ratio": "1:1",
    "images": {
        "cafe_creme": (
            "Simple icon of a small coffee cup with steam, cozy and short distance feel. "
            "Chunky bold shapes, very minimal. Teal cup, navy steam."
        ),
        "tour_quartier": (
            "Simple icon of 2-3 small houses/buildings side by side with a winding path. "
            "Chunky bold shapes, very minimal. Navy buildings, cyan path."
        ),
        "demi_folie": (
            "Simple icon of a running shoe with a lightning bolt through it, "
            "energetic mid-distance vibe, slightly crazy fun feeling. "
            "Chunky bold shapes, very minimal. Teal shoe, navy lightning bolt."
        ),
        "marathon_jasette": (
            "Simple icon of a speech bubble with a running shoe inside it. "
            "Chunky bold shapes, very minimal. Navy bubble, teal shoe."
        ),
        "ultra_social": (
            "Simple icon of a globe/earth with tiny running footprints around it. "
            "Chunky bold shapes, very minimal. Navy globe, teal footprints."
        ),
    },
}

PACE_MASCOTS = {
    "output_dir": os.path.join(ASSETS_BASE, "pace"),
    "aspect_ratio": "1:1",
    "images": {
        "tortue": (
            "Simple icon of a cute turtle head with a tiny coffee cup. "
            "Chunky bold shapes, very minimal. Cyan turtle, navy outline."
        ),
        "canard": (
            "Simple icon of a duck head with a backwards baseball cap. "
            "Chunky bold shapes, very minimal. Teal duck, navy cap."
        ),
        "renard": (
            "Simple icon of a fox head with tiny sunglasses. "
            "Chunky bold shapes, very minimal. Teal/cyan fox, navy sunglasses."
        ),
        "chevreuil": (
            "Simple icon of a deer head with small antlers and a GPS watch. "
            "Chunky bold shapes, very minimal. Navy deer, cyan antlers."
        ),
        "road_runner": (
            "Simple icon of a running shoe with flame trails behind it. "
            "Chunky bold shapes, very minimal. Navy shoe, teal flames."
        ),
    },
}

BADGES = {
    "output_dir": os.path.join(ASSETS_BASE, "badges"),
    "aspect_ratio": "1:1",
    "images": {
        "curieux": (
            "Simple circular badge icon: a bold eye symbol inside a circle. "
            "Very minimal, 2 colors. Teal circle, navy eye. Thin ribbon at bottom."
        ),
        "social": (
            "Simple circular badge icon: a waving hand symbol inside a circle. "
            "Very minimal, 2 colors. Cyan circle, navy hand. Thin ribbon at bottom."
        ),
        "habitue": (
            "Simple circular badge icon: a bold star symbol inside a circle. "
            "Very minimal, 2 colors. Gold/teal circle, navy star. Thin ribbon at bottom."
        ),
        "populaire": (
            "Simple circular badge icon: a bold flame symbol inside a circle. "
            "Very minimal, 2 colors. Teal circle, navy flame. Thin ribbon at bottom."
        ),
        "legende": (
            "Simple circular badge icon: a bold crown with tiny wings inside a circle. "
            "Very minimal, 2 colors. Gold circle, navy crown. Thin ribbon at bottom."
        ),
    },
}

NEIGHBORHOODS = {
    "output_dir": os.path.join(ASSETS_BASE, "neighborhoods"),
    "aspect_ratio": "21:9",
    "images": {
        "hochelaga": (
            "The Montreal Olympic Stadium (Stade Olympique) with its iconic inclined tower, "
            "seen from a slight angle on a beautiful day. Watercolor illustration style, "
            "warm and inviting atmosphere, soft sky, trees in foreground."
        ),
        "plateau": (
            "Colorful Montreal Plateau spiral staircases on a typical residential street, "
            "vibrant doors in different colors, tree-lined street. "
            "Watercolor illustration style, charming neighborhood feel."
        ),
        "mile_end": (
            "Montreal Mile End neighborhood: iconic bagel shop facade with a colorful "
            "street art mural on the adjacent building. Hipster vibe, bikes parked outside. "
            "Watercolor illustration style, artsy and vibrant."
        ),
        "villeray": (
            "Montreal Jean-Talon Market (Marché Jean-Talon) with colorful produce stalls, "
            "awnings, and bustling atmosphere. Fresh fruits and flowers visible. "
            "Watercolor illustration style, lively and warm."
        ),
        "rosemont": (
            "Montreal Botanical Garden (Jardin botanique) with lush greenery, "
            "Chinese garden pagoda visible in background, flower beds in foreground. "
            "Watercolor illustration style, serene and beautiful."
        ),
        "verdun": (
            "Verdun urban beach and waterfront promenade along the St. Lawrence river, "
            "people walking and jogging, trees and modern buildings in background. "
            "Watercolor illustration style, refreshing summer feel."
        ),
        "griffintown": (
            "Montreal Lachine Canal in Griffintown with converted industrial loft buildings, "
            "cyclists on the path, modern condos mixed with old brick factories. "
            "Watercolor illustration style, urban renewal vibe."
        ),
        "vieux_port": (
            "Montreal Jacques-Cartier Bridge and the Old Port Clock Tower (Tour de l'Horloge), "
            "seen from the waterfront with boats in the harbor. "
            "Watercolor illustration style, majestic and iconic."
        ),
    },
}

ONBOARDING = {
    "output_dir": os.path.join(ASSETS_BASE, "onboarding"),
    "aspect_ratio": "1:1",
    "images": {
        "onboarding_quartier": (
            "A warm illustrated map pin dropping onto a colorful neighborhood, "
            "with tiny houses, trees, and winding streets radiating outward. "
            "Cozy, local, inviting feeling. Bird's-eye view perspective."
        ),
        "onboarding_group": (
            "Six diverse people standing in a circle facing each other, smiling, "
            "wearing running clothes, connected by a subtle glowing ring around them. "
            "Teamwork and connection feeling. Warm lighting, friendly energy."
        ),
        "onboarding_apero": (
            "A cheerful scene of friends clinking smoothie glasses together after a run. "
            "Colorful drinks, happy faces, outdoor terrace with string lights. "
            "Celebration, social bonding, warm evening glow."
        ),
    },
}

COMPANIONS = {
    "output_dir": os.path.join(ASSETS_BASE, "companions"),
    "aspect_ratio": "1:1",
    "images": {
        "toutou": (
            "Simple icon of a happy dog face with tongue out and a tiny bandana. "
            "Chunky bold shapes, very minimal. Teal dog, navy outline."
        ),
        "maman": (
            "Simple icon of a woman's face with glasses and a heart above her head. "
            "Chunky bold shapes, very minimal. Navy face, teal heart."
        ),
        "poussette": (
            "Simple icon of a baby stroller seen from the side, sporty style. "
            "Chunky bold shapes, very minimal. Navy stroller, cyan wheels."
        ),
        "solo": (
            "Simple icon of a single person silhouette with a thumbs up. "
            "Chunky bold shapes, very minimal. Navy silhouette, teal thumb."
        ),
    },
}

EMPTY_STATES = {
    "output_dir": os.path.join(ASSETS_BASE, "empty"),
    "aspect_ratio": "1:1",
    "images": {
        "no_events": (
            "Simple icon of a pair of running shoes with a question mark above. "
            "Chunky bold shapes, very minimal. Navy shoes, teal question mark."
        ),
        "no_messages": (
            "Simple icon of an empty speech bubble with dotted outline. "
            "Chunky bold shapes, very minimal. Navy dotted bubble, teal dots."
        ),
        "no_notifications": (
            "Simple icon of a sleeping bell with a tiny night cap and ZZZ. "
            "Chunky bold shapes, very minimal. Navy bell, cyan cap, teal ZZZ."
        ),
    },
}

APERO = {
    "output_dir": os.path.join(ASSETS_BASE, "icons"),
    "aspect_ratio": "16:9",
    "images": {
        "apero_smoothie": (
            "Simple wide icon of 3-4 stick figure people clinking smoothie glasses together. "
            "Chunky bold shapes, very minimal, celebratory gesture. "
            "Navy figures, teal and cyan glasses, simple cheers pose."
        ),
    },
}

WAITING_STEPS = {
    "output_dir": os.path.join(ASSETS_BASE, "icons"),
    "aspect_ratio": "1:1",
    "images": {
        "step_inscription": (
            "Simple icon of a clipboard with a bold checkmark being written by a pencil. "
            "Signup / registration concept. "
            "Chunky bold shapes, very minimal. Teal clipboard, navy checkmark and pencil."
        ),
        "step_groupe": (
            "Simple icon of 3 people silhouettes standing together in a tight group, "
            "like a team being formed. Chunky bold shapes, very minimal. "
            "Navy silhouettes, teal accent on the middle person."
        ),
        "step_parcours": (
            "Simple icon of a RUNNING HARE (rabbit) with long ears holding a small map. "
            "Route planning concept. Chunky bold shapes, very minimal. "
            "Teal hare, navy map outline."
        ),
        "step_rencontre": (
            "Simple icon of a map pin / location marker with 2-3 small people gathered around it. "
            "Meeting point concept, gathering spot. Chunky bold shapes, very minimal. "
            "Teal map pin, navy people silhouettes."
        ),
        "step_course": (
            "Simple icon of two people running side by side with a small speech bubble between them. "
            "Running and chatting concept. Chunky bold shapes, very minimal. "
            "Navy runners, teal speech bubble."
        ),
        "step_ravito": (
            "Simple icon of a smoothie cup with a straw and a small heart above it. "
            "Post-run refreshment / social concept. Chunky bold shapes, very minimal. "
            "Cyan cup, teal heart, navy straw."
        ),
    },
}

ALL_CATEGORIES = [
    MASCOTS, DISTANCE_ICONS, PACE_MASCOTS, BADGES, NEIGHBORHOODS,
    ONBOARDING, COMPANIONS, EMPTY_STATES, APERO, WAITING_STEPS,
]


# ---------------------------------------------------------------------------
# API helpers
# ---------------------------------------------------------------------------

def submit_request(prompt: str, aspect_ratio: str = "1:1") -> str:
    """Submit an image generation request and return the request_id."""
    payload = json.dumps({
        "prompt": STYLE_PREFIX + prompt,
        "num_images": 1,
        "aspect_ratio": aspect_ratio,
        "output_format": "png",
        "resolution": "1K",
    }).encode()

    req = urllib.request.Request(
        ENDPOINT,
        data=payload,
        headers={
            "Authorization": f"Key {FAL_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as resp:
        data = json.loads(resp.read())
    return data["request_id"]


def poll_result(request_id: str, max_wait: int = 120) -> dict:
    """Poll for the completed result."""
    status_url = f"{ENDPOINT}/requests/{request_id}/status"
    result_url = f"{ENDPOINT}/requests/{request_id}"

    for _ in range(max_wait):
        req = urllib.request.Request(
            status_url,
            headers={"Authorization": f"Key {FAL_KEY}"},
        )
        with urllib.request.urlopen(req) as resp:
            status = json.loads(resp.read())

        if status.get("status") == "COMPLETED":
            req2 = urllib.request.Request(
                result_url,
                headers={"Authorization": f"Key {FAL_KEY}"},
            )
            with urllib.request.urlopen(req2) as resp2:
                return json.loads(resp2.read())

        if status.get("status") in ("FAILED",):
            raise RuntimeError(f"Request {request_id} failed: {status}")

        time.sleep(2)

    raise TimeoutError(f"Request {request_id} timed out after {max_wait*2}s")


BIREFNET_SYNC = "https://fal.run/fal-ai/birefnet/v2"


def download_image(url, dest):
    """Download an image from URL to local path."""
    urllib.request.urlretrieve(url, dest)


def remove_background_birefnet(source_path, dest_path):
    """Use fal.ai BiRefNet to cleanly remove background with proper alpha."""
    import base64
    with open(source_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()
    image_uri = f"data:image/png;base64,{b64}"

    payload = json.dumps({
        "image_url": image_uri,
        "model": "General Use (Light)",
        "operating_resolution": "1024x1024",
        "output_format": "png",
        "refine_foreground": True,
    }).encode()

    req = urllib.request.Request(
        BIREFNET_SYNC,
        data=payload,
        headers={
            "Authorization": f"Key {FAL_KEY}",
            "Content-Type": "application/json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        result = json.loads(resp.read())

    img_url = result["image"]["url"]
    download_image(img_url, dest_path)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def generate_category(category, only_names=None, skip_birefnet=False):
    """Generate all images in a category (or a subset)."""
    out_dir = category["output_dir"]
    aspect = category["aspect_ratio"]
    os.makedirs(out_dir, exist_ok=True)

    # Source directory mirrors output but under assets/source/
    cat_name = os.path.basename(out_dir)
    source_dir = os.path.join(ASSETS_BASE, "source", cat_name)
    os.makedirs(source_dir, exist_ok=True)

    images = category["images"]
    if only_names:
        images = {k: v for k, v in images.items() if k in only_names}

    for name, prompt in images.items():
        source_path = os.path.join(source_dir, f"{name}.png")
        final_path = os.path.join(out_dir, f"{name}.png")

        # Step 1: Generate source if needed
        if not os.path.exists(source_path):
            print(f"  [generate] {name} ({aspect})...")
            try:
                rid = submit_request(prompt, aspect)
                print(f"  [poll] waiting for {name} (id={rid})...")
                result = poll_result(rid)
                img_url = result["images"][0]["url"]
                download_image(img_url, source_path)
                print(f"  [source] {source_path}")
            except Exception as e:
                print(f"  [ERROR] generating {name}: {e}", file=sys.stderr)
                continue
        else:
            print(f"  [source exists] {source_path}")

        # Step 2: Apply BiRefNet for clean transparency
        if skip_birefnet:
            if not os.path.exists(final_path):
                import shutil
                shutil.copy2(source_path, final_path)
            print(f"  [copy] {final_path} (no birefnet)")
        elif not os.path.exists(final_path):
            print(f"  [birefnet] removing background for {name}...")
            try:
                remove_background_birefnet(source_path, final_path)
                print(f"  [done] {final_path} (transparent)")
            except Exception as e:
                print(f"  [ERROR] birefnet {name}: {e}", file=sys.stderr)
                import shutil
                shutil.copy2(source_path, final_path)
                print(f"  [fallback] copied source as-is")
        else:
            print(f"  [skip] {final_path} already exists")


def main():
    args = sys.argv[1:]
    birefnet_only = "--birefnet-only" in args
    skip_birefnet = "--no-birefnet" in args
    filter_names = [a for a in args if not a.startswith("--")]

    if birefnet_only:
        print("Mode: BiRefNet only (reprocessing existing sources)")
    if filter_names:
        print(f"Generating only: {filter_names}")

    for cat in ALL_CATEGORIES:
        cat_name = os.path.basename(cat["output_dir"])
        subset = cat["images"]
        if filter_names:
            subset = {k: v for k, v in subset.items() if k in filter_names}
        if not subset:
            continue
        print(f"\n=== {cat_name} ({len(subset)} images) ===")
        generate_category(
            cat,
            list(subset.keys()) if filter_names else None,
            skip_birefnet=skip_birefnet,
        )

    print("\nAll done!")


if __name__ == "__main__":
    main()
