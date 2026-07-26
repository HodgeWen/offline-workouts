#!/usr/bin/env python3
"""合并 Excel seed + curated 数据，写出 app/assets/seed/ 并更新 meta。

流程建议：
1) python3 tools/import_excel.py   # 可选，刷新 Excel 派生
2) python3 tools/build_seed.py     # 合并 curated / yoga / cardio
3) python3 tools/match_exercise_images.py
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SEED = ROOT / "app" / "assets" / "seed"
CURATED = Path(__file__).resolve().parent / "curated"


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def dump(path: Path, data) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {path.relative_to(ROOT)}")


def merge_exercises() -> dict:
    base = load(SEED / "exercises.json")
    extra = load(CURATED / "extra_exercises.json")
    by_name = {e["name"]: e for e in base.get("exercises", [])}

    added = 0
    for e in extra.get("exercises", []):
        name = e["name"]
        if name in by_name:
            # 保留 Excel 条目，补充缺失字段
            cur = by_name[name]
            for k in ("nameEn", "cues", "id", "anatomyNote", "muscles", "joints"):
                if k in e and (k not in cur or not cur.get(k)):
                    cur[k] = e[k]
            if cur.get("source") == "excel":
                cur["source"] = "excel+curated"
            continue
        item = {
            "name": name,
            "region": e.get("region", ""),
            "joints": e.get("joints", []),
            "equipmentTags": e.get("equipmentTags", []),
            "templateIds": e.get("templateIds", []),
            "source": e.get("source", "curated"),
            "regions": e.get("regions", [e.get("region", "")]),
            "muscles": e.get("muscles", []),
            "anatomyNote": e.get("anatomyNote", ""),
        }
        if e.get("nameEn"):
            item["nameEn"] = e["nameEn"]
        if e.get("cues"):
            item["cues"] = e["cues"]
        if e.get("id"):
            item["id"] = e["id"]
        by_name[name] = item
        added += 1

    exercises = list(by_name.values())
    exercises.sort(key=lambda x: (x.get("region") or "", x.get("name") or ""))
    print(f"exercises: {len(exercises)} (added curated {added})")
    return {"version": 2, "exercises": exercises, "source": "excel+curated"}


def merge_cardio() -> dict:
    base = load(SEED / "cardio.json")
    enrich = load(CURATED / "cardio_enrichment.json")
    items = list(base.get("items", []))
    seen = {i.get("name") for i in items}
    for it in enrich.get("extraItems", []):
        if it["name"] in seen:
            continue
        items.append(
            {
                "name": it["name"],
                "category": it.get("category", ""),
                "kcalPerKgPerHour": it.get("kcalPerKgPerHour", 0),
                "mets": it.get("mets"),
                "source": it.get("source", "curated"),
                "note": it.get("note", ""),
            }
        )
        seen.add(it["name"])
    print(f"cardio items: {len(items)}")
    return {
        "version": 2,
        "items": items,
        "programmingRules": enrich.get("programmingRules", {}),
        "citations": enrich.get("citations", []),
        "source": "excel+curated",
    }


def build_yoga() -> dict:
    yoga = load(CURATED / "yoga_sequences.json")
    poses = {p["id"]: p for p in yoga.get("poses", [])}
    sequences = []
    for seq in yoga.get("sequences", []):
        resolved = []
        for pid in seq.get("poseIds", []):
            if pid not in poses:
                print(f"warning: missing pose {pid}", file=sys.stderr)
                continue
            resolved.append(poses[pid])
        sequences.append(
            {
                **{k: v for k, v in seq.items() if k != "poseIds"},
                "poses": resolved,
            }
        )
    print(f"yoga sequences: {len(sequences)}; poses: {len(poses)}")
    return {
        "version": 1,
        "source": yoga.get("source", "curated"),
        "licenseNote": yoga.get("licenseNote", ""),
        "guidelines": yoga.get("guidelines", {}),
        "poses": list(poses.values()),
        "sequences": sequences,
    }


def enrich_foods() -> dict:
    """合并 Excel 食物率 + curated staples（鸡蛋/牛奶/鸡胸等）。"""
    foods = load(SEED / "foods.json")
    staples = load(CURATED / "diet_staples.json")
    by_name = {f["name"]: f for f in foods.get("foods", [])}
    for f in staples.get("foods", []):
        by_name[f["name"]] = f
    # 生米称重提示补强
    if "生米" in by_name:
        note = by_name["生米"].get("note") or ""
        if "2–2.5" not in note:
            by_name["生米"]["note"] = (
                (note + "；" if note else "")
                + "称生重时用此率，煮熟后约 2–2.5 倍重量"
            ).strip("；")
    foods["version"] = max(int(foods.get("version", 1)), 2)
    foods["foods"] = list(by_name.values())
    return foods


def enrich_diet_rules() -> dict:
    diet = load(SEED / "diet_rules.json")
    enrich = load(CURATED / "cardio_enrichment.json")
    diet["version"] = max(int(diet.get("version", 1)), 4)
    # 清理旧版「食物1–7」雾化文案
    for goal_slots in (diet.get("mealTemplates") or {}).values():
        for tpl in goal_slots.values():
            for key in ("trainingDayMeals", "restDayMeals"):
                for meal in tpl.get(key) or []:
                    if meal.get("note") == "食物 1–7 任选等价互换":
                        meal["note"] = "主食+瘦肉按克数等价互换（见今日饮食方案）"
    diet["proteinGuidance"] = {
        "issnRangeGPerKg": [1.4, 2.0],
        "appDefaultGPerKg": {"cut": 1.8, "bulk": 1.6},
        "note": (
            "默认处方：减脂约 1.8 g/kg、增肌约 1.6 g/kg（一般训练者）；"
            "ISSN 立场陈述支持多数锻炼者 1.4–2.0 g/kg/day；"
            "不作为全员默认更高蛋白。"
            "碳水：减脂练日约 3.0、增肌练日约 4.5 g/kg。"
        ),
        "citations": [
            {
                "topic": "蛋白摄入区间（健身人群）",
                "org": "ISSN Position Stand: Protein and Exercise",
                "summary": "多数锻炼者 1.4–2.0 g/kg/day；本 App 默认 1.6/1.8。",
                "url": "https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8",
            }
        ],
    }
    diet["mealBuilder"] = {
        "carbStaples": ["米饭（一般）", "馒头/花卷/馍/馕", "速食燕麦片（生）", "生米"],
        "postCarbStaples": ["米饭（一般）", "馒头/花卷/馍/馕", "生米"],
        "breakfastCarbStaples": ["馒头/花卷/馍/馕", "速食燕麦片（生）", "米饭（一般）"],
        "proteinStaples": [
            "鸡胸肉（生）",
            "牛瘦肉（生）",
            "瘦肉（家禽家畜生肉）",
            "瘦肉（一般的熟肉）",
            "鸡蛋",
            "牛奶",
        ],
        "fatGuideZh": (
            "全天脂肪约 {fatG}g：烹调油分到各餐（常见参考 25–30g/日），"
            "其余来自蛋黄、奶与肉类本身。优先不饱和植物油，少油炸。"
        ),
        "weighTipZh": (
            "称重提示：生米≠米饭。生米碳水率约 0.75，一般软硬米饭约 0.30；"
            "熟重大约是生重的 2–2.5 倍。瘦肉优先按生重称。"
        ),
        "tips": [
            "同一餐内「等价」食物任选其一即可，不必全吃。",
            "蛋白按克数优先吃满；主食可按饿感微调约 ±10%。",
        ],
    }
    diet["fatGuidance"] = {
        "plainZh": (
            "脂肪是激素与脂溶性维生素所必需。力量训练者用全日脂肪克数配额落地；"
            "烹调油约 25–30g/日（中国居民膳食指南 2022）作参考；"
            "WHO 建议成人总脂肪宜不超过总能量约 30%，并以不饱和脂肪为主。"
        ),
    }
    diet["citations"] = [
        {
            "topic": "蛋白与抗阻训练",
            "org": "ISSN",
            "summary": "1.4–2.0 g/kg/day 蛋白对多数锻炼者充足。",
            "url": "https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8",
        },
        {
            "topic": "总脂肪与脂肪质量",
            "org": "WHO",
            "summary": "成人总脂肪宜 ≤30% 能量；以不饱和脂肪为主。",
            "url": "https://www.who.int/news/item/17-07-2023-who-updates-guidelines-on-fats-and-carbohydrates",
        },
        {
            "topic": "中国居民膳食指南（油盐奶）",
            "org": "中国营养学会",
            "summary": "烹调油约 25–30g/日；奶及奶制品约 300ml/日当量。",
            "url": "https://www.cnsoc.org/notice/442220200.html",
        },
        {
            "topic": "运动表现营养（公开摘要）",
            "org": "ACSM / Academy joint position (PubMed)",
            "summary": "训练者营养应个体化；公开摘要强调碳水供能与蛋白分布。",
            "url": "https://pubmed.ncbi.nlm.nih.gov/26920240/",
        },
    ]
    diet["cardioProgramming"] = enrich.get("programmingRules", {})
    # 减脂休息日蛋白不低于 1.8（与默认 cut 一致）
    try:
        cut_rest = diet["macroPerKg"]["cut"]["rest"]
        if float(cut_rest.get("protein", 0)) < 1.8:
            cut_rest["protein"] = 1.8
    except Exception:
        pass
    return diet


def write_attribution(image_manifest: dict | None) -> None:
    lines = [
        "# 数据集与配图归属",
        "",
        "本目录 seed 由 `tools/import_excel.py` + `tools/build_seed.py` 生成。",
        "",
        "## 文本与规则",
        "",
        "- 训练分化 / 饮食餐序 / 部分动作与有氧表：仓库内 `健身资料.xlsx`（个人整理资料）",
        "- 补充动作、瑜伽序列、Zone2/NEAT 规则：`tools/curated/` 自编（公开指南摘要 + 解剖学常识）",
        "- 有氧活动量原则参考 WHO 公众事实页；蛋白区间参考 ISSN 公开立场摘要（见 cardio.json / diet_rules.json citations）",
        "- 饮食宏量与餐食克数建议另参考（仅摘要，**未**捆绑版权 PDF）：",
        "  - ISSN Protein and Exercise：https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8",
        "  - WHO 脂肪与碳水公开更新：https://www.who.int/news/item/17-07-2023-who-updates-guidelines-on-fats-and-carbohydrates",
        "  - 中国居民膳食指南（2022）公开图文：https://www.cnsoc.org/notice/442220200.html",
        "  - ACSM/Academy 运动营养联合立场公开摘要：https://pubmed.ncbi.nlm.nih.gov/26920240/",
        "- 鸡蛋/牛奶/鸡胸等 staples：`tools/curated/diet_staples.json`（对齐 sheet19 瘦肉率 0.2）",
        "- **未**抓取薄荷健康等商业 App 食物库",
        "- **未**收录任何版权膳食 PDF 全文",
        "",
        "## 动作示意图",
        "",
        "- 来源：[Everkinetic open data](https://github.com/everkinetic/data)",
        "- 许可：Creative Commons Attribution-ShareAlike 4.0 (CC-BY-SA 4.0)",
        "- 匹配策略：仅 `tools/curated/exercise_aliases.json` 高置信人工映射；",
        "  未达阈值或不确信 → **不配图**（错图比无图更糟）",
        "- **未使用** yuhonas/free-exercise-db 图片（仓库文本 Unlicense，但图片版权不明确）",
        "",
    ]
    if image_manifest:
        items = image_manifest.get("items", {})
        lines.append(f"当前配图数量：{len(items)}")
        lines.append("")
        for name, ent in sorted(items.items()):
            lines.append(
                f"- {name}: `{ent.get('assetPath')}` ← {ent.get('everkineticSlug')} "
                f"(confidence {ent.get('confidence')})"
            )
        lines.append("")
        lines.append(f"未配图动作数：{len(image_manifest.get('unmatched', []))}")
    path = SEED / "ATTRIBUTION.md"
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {path.relative_to(ROOT)}")


def main() -> int:
    if not (SEED / "exercises.json").exists():
        print("请先运行 tools/import_excel.py", file=sys.stderr)
        return 1

    exercises = merge_exercises()
    dump(SEED / "exercises.json", exercises)

    cardio = merge_cardio()
    dump(SEED / "cardio.json", cardio)

    yoga = build_yoga()
    dump(SEED / "yoga.json", yoga)

    diet = enrich_diet_rules()
    dump(SEED / "diet_rules.json", diet)

    foods = enrich_foods()
    dump(SEED / "foods.json", foods)

    image_manifest = None
    img_path = SEED / "exercise_images.json"
    if img_path.exists():
        image_manifest = load(img_path)

    meta = {
        "seedVersion": 5,
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "generatedBy": "tools/build_seed.py",
        "sources": [
            {"id": "excel", "path": "健身资料.xlsx"},
            {"id": "curated", "path": "tools/curated/"},
            {
                "id": "everkinetic",
                "url": "https://github.com/everkinetic/data",
                "license": "CC-BY-SA-4.0",
                "usedFor": "exercise illustrations (high-confidence matches only)",
            },
            {
                "id": "who_physical_activity",
                "url": "https://www.who.int/news-room/fact-sheets/detail/physical-activity",
                "usedFor": "adult aerobic volume guidance summary",
            },
            {
                "id": "issn_protein_2017",
                "url": "https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8",
                "usedFor": "protein g/kg range summary for diet seed",
            },
            {
                "id": "who_fats_carbs_2023",
                "url": "https://www.who.int/news/item/17-07-2023-who-updates-guidelines-on-fats-and-carbohydrates",
                "usedFor": "public fat quality / total fat guidance summary",
            },
            {
                "id": "cns_dietary_guidelines_2022",
                "url": "https://www.cnsoc.org/notice/442220200.html",
                "usedFor": "cooking oil / dairy plain-language guidance",
            },
        ],
        "stats": {
            "exercises": len(exercises["exercises"]),
            "cardioItems": len(cardio["items"]),
            "yogaSequences": len(yoga["sequences"]),
            "yogaPoses": len(yoga["poses"]),
            "images": len(image_manifest.get("items", {})) if image_manifest else 0,
            "foods": len(foods.get("foods", [])),
        },
        "notes": [
            "yoga 为 curated 真实序列（含体式与时长）。",
            "图片宁缺毋滥：见 exercise_images.json unmatched。",
            "diet mealBuilder：宏量→常见主食/蛋白克数；含 ISSN/WHO/膳食指南公开引用。",
        ],
    }
    dump(SEED / "meta.json", meta)
    write_attribution(image_manifest)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
