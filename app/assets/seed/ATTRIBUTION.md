# 数据集与配图归属

本目录 seed 由 `tools/import_excel.py` + `tools/build_seed.py` 生成。

## 文本与规则

- 训练分化 / 饮食餐序 / 部分动作与有氧表：仓库内 `健身资料.xlsx`（个人整理资料）
- 补充动作、瑜伽序列、Zone2/NEAT 规则：`tools/curated/` 自编（公开指南摘要 + 解剖学常识）
- 有氧活动量原则参考 WHO 公众事实页；蛋白区间参考 ISSN 公开立场摘要（见 cardio.json / diet_rules.json citations）
- 饮食宏量与餐食克数建议另参考（仅摘要，**未**捆绑版权 PDF）：
  - ISSN Protein and Exercise：https://jissn.biomedcentral.com/articles/10.1186/s12970-017-0177-8
  - WHO 脂肪与碳水公开更新：https://www.who.int/news/item/17-07-2023-who-updates-guidelines-on-fats-and-carbohydrates
  - 中国居民膳食指南（2022）公开图文：https://www.cnsoc.org/notice/442220200.html
  - ACSM/Academy 运动营养联合立场公开摘要：https://pubmed.ncbi.nlm.nih.gov/26920240/
- 鸡蛋/牛奶/鸡胸等 staples：`tools/curated/diet_staples.json`（对齐 sheet19 瘦肉率 0.2）
- **未**抓取薄荷健康等商业 App 食物库
- **未**收录任何版权膳食 PDF 全文

## 动作示意图

- 来源：[Everkinetic open data](https://github.com/everkinetic/data)
- 许可：Creative Commons Attribution-ShareAlike 4.0 (CC-BY-SA 4.0)
- 匹配策略：仅 `tools/curated/exercise_aliases.json` 高置信人工映射；
  未达阈值或不确信 → **不配图**（错图比无图更糟）
- **未使用** yuhonas/free-exercise-db 图片（仓库文本 Unlicense，但图片版权不明确）

当前配图数量：65

- T杆俯身划船: `assets/exercises/images/ek_t-bar-rows.png` ← t-bar-rows (confidence 1.0)
- 俯卧撑: `assets/exercises/images/ek_push-ups.png` ← push-ups (confidence 1.0)
- 俯卧撑（脚垫高20cm）: `assets/exercises/images/ek_push-up-feet-elevated.png` ← push-up-feet-elevated (confidence 0.95)
- 倒蹬机: `assets/exercises/images/ek_leg-press.png` ← leg-press (confidence 0.95)
- 双杠臂屈伸（上身前趴30-60°）: `assets/exercises/images/ek_chest-dips.png` ← chest-dips (confidence 0.95)
- 史密斯深蹲: `assets/exercises/images/ek_smith-machine-squats.png` ← smith-machine-squats (confidence 1.0)
- 哈克机: `assets/exercises/images/ek_hack-squat-machine.png` ← hack-squat-machine (confidence 1.0)
- 哑铃/弹力带侧平举: `assets/exercises/images/ek_lateral-dumbbell-raises.png` ← lateral-dumbbell-raises (confidence 0.95)
- 哑铃/弹力带前平举: `assets/exercises/images/ek_front-dumbbell-raise.png` ← front-dumbbell-raise (confidence 0.95)
- 哑铃/弹力带推举: `assets/exercises/images/ek_one-arm-dumbbell-shoulder-press.png` ← one-arm-dumbbell-shoulder-press (confidence 0.9)
- 哑铃/弹力带提拉: `assets/exercises/images/ek_dumbbell-upright-rows.png` ← dumbbell-upright-rows (confidence 0.95)
- 哑铃/弹力带颈后臂屈伸: `assets/exercises/images/ek_seated-two-arm-triceps-extension-with-dumbbell.png` ← seated-two-arm-triceps-extension-with-dumbbell (confidence 0.85)
- 哑铃/龙门架侧平举: `assets/exercises/images/ek_lateral-dumbbell-raises.png` ← lateral-dumbbell-raises (confidence 0.95)
- 哑铃仰卧臂屈伸: `assets/exercises/images/ek_lying-triceps-extension-with-dumbbells.png` ← lying-triceps-extension-with-dumbbells (confidence 0.95)
- 哑铃俯身飞鸟: `assets/exercises/images/ek_bent-over-rear-deltoid-raise-with-head-on-bench.png` ← bent-over-rear-deltoid-raise-with-head-on-bench (confidence 0.9)
- 哑铃卧推: `assets/exercises/images/ek_bench-press-dumbbell.png` ← bench-press-dumbbell (confidence 1.0)
- 哑铃卧推（下斜推）: `assets/exercises/images/ek_decline-dumbbell-bench-press.png` ← decline-dumbbell-bench-press (confidence 1.0)
- 哑铃弯举: `assets/exercises/images/ek_biceps-curl-with-dumbbell.png` ← biceps-curl-with-dumbbell (confidence 1.0)
- 哑铃深蹲（又叫高脚杯深蹲）: `assets/exercises/images/ek_squats-using-dumbbells.png` ← squats-using-dumbbells (confidence 0.9)
- 哑铃硬拉: `assets/exercises/images/ek_dumbbell-dead-lifts.png` ← dumbbell-dead-lifts (confidence 1.0)
- 哑铃箭步蹲（单腿动作 无需大哑铃）: `assets/exercises/images/ek_dumbbell-lunges.png` ← dumbbell-lunges (confidence 1.0)
- 哑铃颈后臂屈伸: `assets/exercises/images/ek_seated-two-arm-triceps-extension-with-dumbbell.png` ← seated-two-arm-triceps-extension-with-dumbbell (confidence 0.9)
- 器械/哑铃/史密斯推举: `assets/exercises/images/ek_seated-military-press.png` ← seated-military-press (confidence 0.85)
- 器械下拉: `assets/exercises/images/ek_v-bar-pull-down.png` ← v-bar-pull-down (confidence 0.9)
- 器械弯举: `assets/exercises/images/ek_biceps-curl-with-machine.png` ← biceps-curl-with-machine (confidence 0.95)
- 器械推胸（上斜推）: `assets/exercises/images/ek_smith-machine-incline-bench-press.png` ← smith-machine-incline-bench-press (confidence 0.85)
- 器械推胸（下斜推）: `assets/exercises/images/ek_decline-chest-press.png` ← decline-chest-press (confidence 0.95)
- 器械推胸（水平推）: `assets/exercises/images/ek_machine-bench-press.png` ← machine-bench-press (confidence 0.95)
- 器械腿屈伸: `assets/exercises/images/ek_leg-extensions.png` ← leg-extensions (confidence 1.0)
- 器械腿弯举: `assets/exercises/images/ek_lying-leg-curl-machine.png` ← lying-leg-curl-machine (confidence 0.95)
- 坐姿器械/绳索划船（水平开肘）: `assets/exercises/images/ek_seated-cable-rows.png` ← seated-cable-rows (confidence 0.85)
- 坐姿器械划船: `assets/exercises/images/ek_seated-cable-rows.png` ← seated-cable-rows (confidence 0.9)
- 平板卷腹: `assets/exercises/images/ek_crunches.png` ← crunches (confidence 1.0)
- 引体向上: `assets/exercises/images/ek_pull-ups.png` ← pull-ups (confidence 1.0)
- 引体向上（可用弹力带减重）: `assets/exercises/images/ek_pull-ups.png` ← pull-ups (confidence 0.95)
- 弹力带反向飞鸟: `assets/exercises/images/ek_back-flys-exercise-band.png` ← back-flys-exercise-band (confidence 0.95)
- 弹力带夹胸（水平夹）: `assets/exercises/images/ek_crossover-bands.png` ← crossover-bands (confidence 0.9)
- 弹力带弯举: `assets/exercises/images/ek_quick-alternating-biceps-curls-with-band.png` ← quick-alternating-biceps-curls-with-band (confidence 0.9)
- 杠铃/哑铃/史密斯卧推（上斜推）: `assets/exercises/images/ek_incline-bench-press.png` ← incline-bench-press (confidence 0.9)
- 杠铃/哑铃/史密斯卧推（下斜推）: `assets/exercises/images/ek_decline-barbell-bench-press.png` ← decline-barbell-bench-press (confidence 0.9)
- 杠铃/哑铃/史密斯卧推（水平推）: `assets/exercises/images/ek_bench-press.png` ← bench-press (confidence 0.9)
- 杠铃/哑铃/史密斯窄距卧推: `assets/exercises/images/ek_close-grip-barbell-bench-press.png` ← close-grip-barbell-bench-press (confidence 0.95)
- 杠铃/哑铃片前平举: `assets/exercises/images/ek_front-dumbbell-raise.png` ← front-dumbbell-raise (confidence 0.9)
- 杠铃仰卧臂屈伸: `assets/exercises/images/ek_lying-triceps-press-with-barbell.png` ← lying-triceps-press-with-barbell (confidence 0.9)
- 杠铃俯身划船: `assets/exercises/images/ek_reverse-grips-bent-over-barbell-rows.png` ← reverse-grips-bent-over-barbell-rows (confidence 0.85)
- 杠铃卧推（上斜推）: `assets/exercises/images/ek_incline-bench-press.png` ← incline-bench-press (confidence 0.95)
- 杠铃弯举: `assets/exercises/images/ek_biceps-curls-with-barbell.png` ← biceps-curls-with-barbell (confidence 1.0)
- 杠铃提拉: `assets/exercises/images/ek_upright-barbell-rows.png` ← upright-barbell-rows (confidence 0.95)
- 杠铃深蹲: `assets/exercises/images/ek_barbell-squat.png` ← barbell-squat (confidence 1.0)
- 澳式划船（桌下水平划船）: `assets/exercises/images/ek_body-row.png` ← body-row (confidence 0.95)
- 牧师椅弯举: `assets/exercises/images/ek_preacher-curl-with-barbell.png` ← preacher-curl-with-barbell (confidence 0.95)
- 窄距俯卧撑: `assets/exercises/images/ek_close-triceps-pushup.png` ← close-triceps-pushup (confidence 0.9)
- 箭步蹲: `assets/exercises/images/ek_barbell-lunges.png` ← barbell-lunges (confidence 0.85)
- 罗马尼亚/传统硬拉: `assets/exercises/images/ek_barbell-dead-lifts.png` ← barbell-dead-lifts (confidence 0.9)
- 蝴蝶机夹胸: `assets/exercises/images/ek_dumbbell-flys.png` ← dumbbell-flys (confidence 0.85)
- 集中弯举: `assets/exercises/images/ek_concentration-curls-with-dumbbell.png` ← concentration-curls-with-dumbbell (confidence 1.0)
- 高位下拉: `assets/exercises/images/ek_underhand-pull-down.png` ← underhand-pull-down (confidence 0.85)
- 高脚杯深蹲: `assets/exercises/images/ek_squats-using-dumbbells.png` ← squats-using-dumbbells (confidence 0.85)
- 龙门架反向飞鸟: `assets/exercises/images/ek_seated-rear-lateral-cable-raise.png` ← seated-rear-lateral-cable-raise (confidence 0.85)
- 龙门架夹胸（上斜夹）: `assets/exercises/images/ek_incline-cable-flys.png` ← incline-cable-flys (confidence 0.9)
- 龙门架夹胸（完全下夹）: `assets/exercises/images/ek_cable-crossover.png` ← cable-crossover (confidence 0.85)
- 龙门架夹胸（水平夹）: `assets/exercises/images/ek_cable-crossover.png` ← cable-crossover (confidence 0.9)
- 龙门架直杆下压: `assets/exercises/images/ek_triceps-pushdown-with-v-bar-and-cable.png` ← triceps-pushdown-with-v-bar-and-cable (confidence 0.95)
- 龙门架直臂下压: `assets/exercises/images/ek_straight-arm-push-down.png` ← straight-arm-push-down (confidence 0.95)
- 龙门架绳索臂屈伸: `assets/exercises/images/ek_triceps-pushdown-with-rope-and-cable.png` ← triceps-pushdown-with-rope-and-cable (confidence 0.95)

未配图动作数：31
