# 离线健身 App

基于 Flutter 的完全离线健身计划应用：问卷 → 规则引擎判定增肌/减脂 → 生成**分化顺序队列**、**有氧/瑜伽策略**与饮食宏量。

训练按模板顺序循环（如 背肩 → 胸肩 → 腿 → …），**不绑定日历日期**；休息日由用户自行安排。「今日」展示下一力量项，并给出可选有氧 / 瑜伽恢复。日历只展示已完成的力量 / 有氧 / 瑜伽 / 休息历史。

## 本机环境（Mac）

先确认工具链：

```bash
flutter doctor -v
```

### 跑 iOS / macOS 前必须完成

本机若 `flutter doctor` 提示 Xcode incomplete / license，按顺序执行（需输入密码）：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
brew install cocoapods
flutter doctor -v
```

### 跑 Android（本机已配置）

| 项 | 路径 |
| --- | --- |
| Android SDK | `/opt/homebrew/share/android-commandlinetools` |
| JDK 17 | `/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home` |

```bash
export JAVA_HOME="/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"
export ANDROID_SDK_ROOT="/opt/homebrew/share/android-commandlinetools"
flutter config --android-sdk "$ANDROID_SDK_ROOT"
flutter config --jdk-dir "$JAVA_HOME"
cd app && flutter pub get && flutter build apk --debug
```

## 刷新数据集

```bash
# 1) 可选：从 Excel 重新抽取基础 seed
python3 tools/import_excel.py

# 2) 合并 curated（补充动作 / 瑜伽 / 有氧规则 / 饮食校验注记）
python3 tools/build_seed.py

# 3) 高置信匹配并下载 Everkinetic 示意图（CC-BY-SA 4.0）
#    需已缓存 tools/cache/everkinetic_exercises.json
python3 tools/match_exercise_images.py

# 4) 校验别名映射
python3 tools/test_image_match.py
```

归属与许可见 `app/assets/seed/ATTRIBUTION.md` 与 `meta.json`。

**图片政策**：只接受 `tools/curated/exercise_aliases.json` 中置信度 ≥ 0.85 的人工映射；未匹配或不确定 → `imagePath` 为空。不使用 free-exercise-db 图片（版权不明确）。

## 运行

```bash
cd app
flutter pub get
# 若改了 Drift 表结构：
dart run build_runner build --delete-conflicting-outputs

flutter test test/planning
flutter analyze
flutter run
```

最低系统：iOS 16+ / Android API 33+。

## 结构

- `tools/import_excel.py` — Excel → `assets/seed/*.json`
- `tools/build_seed.py` — 合并 `tools/curated/`（瑜伽、补充动作、有氧）
- `tools/match_exercise_images.py` — Everkinetic 配图
- `lib/features/planning/domain/` — GoalClassifier / PrescriptionEngine / CardioPolicy / YogaPolicy / PlanComposer / VolumeAdapter
- `lib/core/db/` — Drift 本地库 + seed 导入
- 底部 Tab：今日 / 日历 / 动作库 / 我的

## 算法要点

- **力量**：容量基线 + 动作族继承 + 居家器械过滤 + 反馈渐进（VolumeAdapter）
- **有氧**：减脂 Zone2/LISS 周分钟建议；增肌默认关或短 LISS；不排日历
- **瑜伽**：真实序列；女性默认建议开启为恢复选项；记录进日历 `yoga`
- **饮食**：Mifflin + Excel 系数；有氧日消耗摊入平衡

## 测试

```bash
cd app
flutter test test/planning
flutter analyze
```
