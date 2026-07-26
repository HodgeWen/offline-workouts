#!/usr/bin/env python3
"""轻量校验：别名 slug 存在于 Everkinetic，且置信阈值逻辑正确。"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CACHE = ROOT / "cache" / "everkinetic_exercises.json"
ALIASES = ROOT / "curated" / "exercise_aliases.json"


def main() -> int:
    ek = {e["name"] for e in json.loads(CACHE.read_text(encoding="utf-8"))}
    aliases = json.loads(ALIASES.read_text(encoding="utf-8"))
    min_c = float(aliases.get("minConfidenceToShipImage", 0.85))
    bad = 0
    for name, meta in aliases["matches"].items():
        slug = meta["everkinetic"]
        conf = float(meta["confidence"])
        if slug not in ek:
            print(f"FAIL missing slug {slug} for {name}")
            bad += 1
        if conf >= min_c and conf < 0:
            print(f"FAIL bad confidence {name}")
            bad += 1
    # 跪姿俯卧撑应被阈值挡住
    knee = aliases["matches"].get("跪姿俯卧撑", {})
    if float(knee.get("confidence", 1)) >= min_c:
        print("FAIL knee push-up should be below ship threshold")
        bad += 1
    if bad:
        return 1
    print(f"OK aliases={len(aliases['matches'])} minConfidence={min_c}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
