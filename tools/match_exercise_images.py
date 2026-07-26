#!/usr/bin/env python3
"""将中文动作名高置信匹配到 Everkinetic（CC-BY-SA 4.0）示意图并下载。

规则：
- 仅使用 tools/curated/exercise_aliases.json 的人工映射；
- confidence < minConfidenceToShipImage → 不配图（宁缺毋滥）；
- 自动模糊匹配默认关闭，避免错图。
"""

from __future__ import annotations

import json
import hashlib
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CACHE = Path(__file__).resolve().parent / "cache"
CURATED = Path(__file__).resolve().parent / "curated"
SEED = ROOT / "app" / "assets" / "seed"
IMG_DIR = ROOT / "app" / "assets" / "exercises" / "images"

EVERKINETIC_JSON = CACHE / "everkinetic_exercises.json"
SVG_BASE = (
    "https://raw.githubusercontent.com/everkinetic/data/main/dist/svg/"
)
PNG_BASE = (
    "https://raw.githubusercontent.com/everkinetic/data/main/dist/png/"
)
ALIASES = CURATED / "exercise_aliases.json"


def load_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def download(url: str, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 100:
        return True
    try:
        req = urllib.request.Request(
            url, headers={"User-Agent": "workout-app-seed-builder/1.0"}
        )
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()
        if len(data) < 100:
            return False
        dest.write_bytes(data)
        return True
    except Exception as e:
        print(f"  download fail {url}: {e}", file=sys.stderr)
        return False


def main() -> int:
    if not EVERKINETIC_JSON.exists():
        print("缺少 cache/everkinetic_exercises.json，请先拉取", file=sys.stderr)
        return 1

    ek = {e["name"]: e for e in load_json(EVERKINETIC_JSON)}
    aliases = load_json(ALIASES)
    min_c = float(aliases.get("minConfidenceToShipImage", 0.85))
    matches = aliases.get("matches", {})

    exercises_path = SEED / "exercises.json"
    if not exercises_path.exists():
        print("缺少 exercises.json，请先运行 build_seed.py 或 import_excel.py", file=sys.stderr)
        return 1

    root = load_json(exercises_path)
    exercises = root.get("exercises", [])
    by_name = {e["name"]: e for e in exercises}

    manifest: dict[str, dict] = {
        "version": 1,
        "license": "CC-BY-SA-4.0",
        "source": "https://github.com/everkinetic/data",
        "policy": "only high-confidence curated aliases; unmatched stay null",
        "items": {},
        "unmatched": [],
        "skippedLowConfidence": [],
    }

    shipped = 0
    for zh_name, meta in sorted(matches.items()):
        conf = float(meta.get("confidence", 0))
        slug = meta.get("everkinetic")
        if conf < min_c:
            manifest["skippedLowConfidence"].append(
                {"name": zh_name, "everkinetic": slug, "confidence": conf}
            )
            continue
        if zh_name not in by_name:
            # 仍可写入 manifest，供后续 seed 合并后使用
            pass
        ek_ex = ek.get(slug)
        if not ek_ex:
            print(f"Everkinetic 缺少 slug={slug}（映射自 {zh_name}）", file=sys.stderr)
            manifest["unmatched"].append({"name": zh_name, "reason": "missing_slug"})
            continue

        id_num = ek_ex.get("id_num") or str(ek_ex.get("id")).zfill(4)
        # 优先 PNG（Flutter Image.asset 原生支持）；SVG 仅作后备
        local_name = f"ek_{slug}.png"
        dest = IMG_DIR / local_name
        used = None
        for kind in ("tension", "relaxation"):
            if download(PNG_BASE + f"{id_num}-{kind}.png", dest):
                used = f"png/{id_num}-{kind}.png"
                break
        if used is None:
            local_name = f"ek_{slug}.svg"
            dest = IMG_DIR / local_name
            for kind in ("tension", "relaxation"):
                if download(SVG_BASE + f"{id_num}-{kind}.svg", dest):
                    used = f"svg/{id_num}-{kind}.svg"
                    break
        if used is None:
            manifest["unmatched"].append({"name": zh_name, "reason": "download_failed"})
            continue

        # 清理另一后缀残留
        for other in (IMG_DIR / f"ek_{slug}.png", IMG_DIR / f"ek_{slug}.svg"):
            if other != dest and other.exists():
                other.unlink()

        rel = f"assets/exercises/images/{local_name}"
        entry = {
            "exerciseName": zh_name,
            "everkineticSlug": slug,
            "everkineticIdNum": id_num,
            "confidence": conf,
            "assetPath": rel,
            "license": "CC-BY-SA-4.0",
            "attribution": "Everkinetic open data (CC-BY-SA 4.0)",
            "sourceUrl": f"https://github.com/everkinetic/data ({used})",
            "sha256": hashlib.sha256(dest.read_bytes()).hexdigest()[:16],
        }
        manifest["items"][zh_name] = entry
        if zh_name in by_name:
            by_name[zh_name]["imagePath"] = rel
            by_name[zh_name]["imageLicense"] = "CC-BY-SA-4.0"
            by_name[zh_name]["imageSource"] = "everkinetic"
            by_name[zh_name]["imageAttribution"] = entry["attribution"]
        shipped += 1
        print(f"OK  {zh_name} -> {slug} ({rel})")

    # 清理未匹配动作的错误残留图字段
    for e in exercises:
        if e["name"] not in manifest["items"]:
            e.pop("imagePath", None)
            e.pop("imageLicense", None)
            e.pop("imageSource", None)
            e.pop("imageAttribution", None)
            if e["name"] not in matches:
                manifest["unmatched"].append(
                    {"name": e["name"], "reason": "no_alias"}
                )

    # 去重 unmatched
    seen = set()
    uniq = []
    for u in manifest["unmatched"]:
        key = (u["name"], u.get("reason"))
        if key in seen:
            continue
        seen.add(key)
        uniq.append(u)
    manifest["unmatched"] = uniq

    root["exercises"] = exercises
    exercises_path.write_text(
        json.dumps(root, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    out_manifest = SEED / "exercise_images.json"
    out_manifest.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(
        f"shipped images: {shipped}; unmatched: {len(manifest['unmatched'])}; "
        f"low-confidence skipped: {len(manifest['skippedLowConfidence'])}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
