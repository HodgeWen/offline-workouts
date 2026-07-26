import 'dart:convert';
import 'dart:math' as math;

import 'models.dart';

/// 食物营养率条目（对齐 foods.json / sheet 19）。
class FoodRate {
  const FoodRate({
    required this.name,
    required this.category,
    required this.rate,
    required this.macroHint,
    this.note,
    this.pieceWeightG,
    this.pieceUnit,
  });

  final String name;
  final String category;
  /// 目标宏量占可食部重量的比例（如米饭碳水率 0.3）。
  final double rate;
  final String macroHint; // carb | protein | fat
  final String? note;
  /// 按「枚/个」展示时的单件克数（如鸡蛋约 50g）。
  final double? pieceWeightG;
  final String? pieceUnit;

  factory FoodRate.fromJson(Map<String, dynamic> json) => FoodRate(
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        macroHint: json['macroHint'] as String? ?? 'carb',
        note: json['note'] as String?,
        pieceWeightG: (json['pieceWeightG'] as num?)?.toDouble(),
        pieceUnit: json['pieceUnit'] as String?,
      );
}

/// 某一餐内可互换的食物克数建议。
class MealFoodOption {
  const MealFoodOption({
    required this.name,
    required this.grams,
    required this.macroHint,
    this.pieces,
    this.pieceUnit,
    this.displayOverride,
  });

  final String name;
  final int grams;
  final String macroHint;
  final int? pieces;
  final String? pieceUnit;
  final String? displayOverride;

  /// 中文展示，如「鸡蛋 2枚（约100g）」或「米饭（一般）约280g」。
  String get displayZh {
    if (displayOverride != null && displayOverride!.isNotEmpty) {
      return displayOverride!;
    }
    if (pieces != null && pieceUnit != null) {
      return '$name $pieces$pieceUnit（约${grams}g）';
    }
    return '$name 约${grams}g';
  }
}

/// 可执行的一餐。
class PlannedMeal {
  const PlannedMeal({
    required this.name,
    required this.role,
    required this.carbG,
    required this.proteinG,
    required this.primaryLine,
    required this.equivalents,
    this.tip = '',
  });

  final String name;
  final String role;
  final double carbG;
  final double proteinG;
  /// 主推荐组合（可直接照着做）。
  final String primaryLine;
  /// 等价替换选项（真实食物+克数）。
  final List<String> equivalents;
  final String tip;
}

/// 一日可执行饮食方案。
class DayMealPlan {
  const DayMealPlan({
    required this.macros,
    required this.meals,
    required this.fatGuideZh,
    required this.weighTipZh,
    this.tips = const [],
  });

  final MacroTargets macros;
  final List<PlannedMeal> meals;
  final String fatGuideZh;
  final String weighTipZh;
  final List<String> tips;
}

/// 将宏量配额 × 餐序份额 → 常见主食/蛋白的克数建议（离线、无 LLM）。
class MealPlanBuilder {
  MealPlanBuilder({
    required List<FoodRate> foods,
    Map<String, dynamic>? mealBuilderConfig,
  })  : _byName = {
          for (final f in foods) f.name: _withPieceDefaults(f),
        },
        _config = mealBuilderConfig ?? const {};

  final Map<String, FoodRate> _byName;
  final Map<String, dynamic> _config;

  /// DB 未存 piece 字段时的常用默认（对齐 foods.json curated）。
  static FoodRate _withPieceDefaults(FoodRate f) {
    if (f.pieceWeightG != null) return f;
    if (f.name == '鸡蛋') {
      return FoodRate(
        name: f.name,
        category: f.category,
        rate: f.rate,
        macroHint: f.macroHint,
        note: f.note,
        pieceWeightG: 50,
        pieceUnit: '枚',
      );
    }
    return f;
  }

  static const _defaultCarbStaples = [
    '米饭（一般）',
    '馒头/花卷/馍/馕',
    '速食燕麦片（生）',
    '生米',
  ];

  static const _defaultProteinStaples = [
    '鸡胸肉（生）',
    '瘦肉（家禽家畜生肉）',
    '瘦肉（一般的熟肉）',
    '鸡蛋',
    '牛奶',
  ];

  static const _defaultBreakfastCarbs = [
    '馒头/花卷/馍/馕',
    '速食燕麦片（生）',
    '米饭（一般）',
  ];

  static const _defaultPostCarbs = [
    '米饭（一般）',
    '馒头/花卷/馍/馕',
    '生米',
  ];

  /// 从 foods.json 根对象构建。
  factory MealPlanBuilder.fromFoodsJson(
    String foodsJson, {
    Map<String, dynamic>? mealBuilderConfig,
  }) {
    final root = jsonDecode(foodsJson) as Map<String, dynamic>;
    final list = (root['foods'] as List? ?? [])
        .map((e) => FoodRate.fromJson(e as Map<String, dynamic>))
        .toList();
    return MealPlanBuilder(foods: list, mealBuilderConfig: mealBuilderConfig);
  }

  DayMealPlan build({
    required MacroTargets macros,
    required List<MealSlot> meals,
    required Goal goal,
  }) {
    final planned = <PlannedMeal>[];
    for (final slot in meals) {
      planned.add(_buildMeal(slot: slot, macros: macros));
    }
    return DayMealPlan(
      macros: macros,
      meals: planned,
      fatGuideZh: _fatGuideZh(goal, macros.fatG),
      weighTipZh: _weighTipZh(),
      tips: _tips(goal),
    );
  }

  PlannedMeal _buildMeal({
    required MealSlot slot,
    required MacroTargets macros,
  }) {
    final carbG = _round1(macros.carbG * slot.carbShare);
    final proteinG = _round1(macros.proteinG * slot.proteinShare);
    final isBreakfast = slot.name.contains('早饭');
    final isSnack = slot.role == 'snack' || slot.name.contains('零食');
    final isPost = slot.role == 'post';

    if (isBreakfast) {
      return _breakfastMeal(slot: slot, carbG: carbG, proteinG: proteinG);
    }
    if (isSnack) {
      return _snackMeal(slot: slot, carbG: carbG, proteinG: proteinG);
    }

    final carbNames = isPost ? _carbNames(post: true) : _carbNames(post: false);
    final proteinNames = _proteinNames(preferLeanMeat: true);

    final carbOpts = _optionsFor(carbNames, carbG, 'carb', max: 4);
    final proteinOpts = _optionsFor(proteinNames, proteinG, 'protein', max: 4);

    final primaryCarb = carbOpts.isNotEmpty ? carbOpts.first.displayZh : '主食按配额';
    final primaryProtein =
        proteinOpts.isNotEmpty ? proteinOpts.first.displayZh : '瘦肉按配额';

    final equivalents = <String>[];
    for (var i = 1; i < carbOpts.length; i++) {
      equivalents.add('碳水等价：${carbOpts[i].displayZh}');
    }
    for (var i = 1; i < proteinOpts.length; i++) {
      equivalents.add('蛋白等价：${proteinOpts[i].displayZh}');
    }

    return PlannedMeal(
      name: _cleanMealName(slot.name),
      role: slot.role,
      carbG: carbG,
      proteinG: proteinG,
      primaryLine: '$primaryCarb + $primaryProtein',
      equivalents: equivalents,
      tip: isPost ? '练后优先易消化淀粉+瘦肉，便于恢复。' : '',
    );
  }

  PlannedMeal _breakfastMeal({
    required MealSlot slot,
    required double carbG,
    required double proteinG,
  }) {
    final egg = _byName['鸡蛋'];
    final milk = _byName['牛奶'];
    // 早饭打底：约 2 枚蛋 + 250ml 奶，剩余蛋白用瘦肉补。
    final eggPieces = egg == null ? 0 : _clamp((proteinG * 0.55 / _proteinPerPiece(egg)).round(), 1, 4);
    final eggProtein = egg == null ? 0.0 : eggPieces * _proteinPerPiece(egg);
    final milkMl = milk == null
        ? 0
        : _niceGrams((proteinG * 0.25) / milk.rate, step: 50).clamp(150, 350);
    final milkProtein = milk == null ? 0.0 : milkMl * milk.rate;
    final remainProtein = math.max(0.0, proteinG - eggProtein - milkProtein);

    final carbOpts = _optionsFor(_breakfastCarbNames(), carbG, 'carb', max: 3);
    final meatOpts = remainProtein < 8
        ? const <MealFoodOption>[]
        : _optionsFor(
            ['鸡胸肉（生）', '瘦肉（家禽家畜生肉）', '瘦肉（一般的熟肉）'],
            remainProtein,
            'protein',
            max: 2,
          );

    final parts = <String>[];
    if (egg != null && eggPieces > 0) {
      final g = (eggPieces * (egg.pieceWeightG ?? 50)).round();
      parts.add('鸡蛋 $eggPieces枚（约${g}g）');
    }
    if (milk != null && milkMl > 0) {
      parts.add('牛奶 约${milkMl}ml');
    }
    if (carbOpts.isNotEmpty) {
      parts.add(carbOpts.first.displayZh);
    }
    if (meatOpts.isNotEmpty) {
      parts.add(meatOpts.first.displayZh);
    }

    final equivalents = <String>[];
    for (var i = 1; i < carbOpts.length; i++) {
      equivalents.add('碳水等价：${carbOpts[i].displayZh}');
    }
    if (meatOpts.length > 1) {
      equivalents.add('蛋白等价：${meatOpts[1].displayZh}');
    }
    if (egg != null && eggPieces > 0) {
      // 鸡蛋↔瘦肉粗略互换提示
      final lean = _byName['鸡胸肉（生）'] ?? _byName['瘦肉（家禽家畜生肉）'];
      if (lean != null && lean.rate > 0) {
        final g = _niceGrams(eggProtein / lean.rate);
        equivalents.add('蛋白等价：可用 ${lean.name} 约${g}g 替换鸡蛋');
      }
    }

    return PlannedMeal(
      name: _cleanMealName(slot.name),
      role: slot.role,
      carbG: carbG,
      proteinG: proteinG,
      primaryLine: parts.join(' + '),
      equivalents: equivalents,
      tip: '早饭可用鸡蛋+奶打底，主食任选等价。',
    );
  }

  PlannedMeal _snackMeal({
    required MealSlot slot,
    required double carbG,
    required double proteinG,
  }) {
    final carbOpts = _optionsFor(
      ['馒头/花卷/馍/馕', '速食燕麦片（生）', '米饭（一般）'],
      carbG,
      'carb',
      max: 3,
    );
    final proteinOpts = _optionsFor(
      ['牛奶', '鸡蛋', '瘦肉干', '蛋白粉'],
      proteinG,
      'protein',
      max: 3,
    );
    final primary = [
      if (carbOpts.isNotEmpty) carbOpts.first.displayZh,
      if (proteinOpts.isNotEmpty) proteinOpts.first.displayZh,
    ].join(' + ');
    final equivalents = <String>[
      for (var i = 1; i < carbOpts.length; i++) '碳水等价：${carbOpts[i].displayZh}',
      for (var i = 1; i < proteinOpts.length; i++)
        '蛋白等价：${proteinOpts[i].displayZh}',
    ];
    return PlannedMeal(
      name: _cleanMealName(slot.name),
      role: slot.role,
      carbG: carbG,
      proteinG: proteinG,
      primaryLine: primary.isEmpty ? '少量加餐，可并入正餐' : primary,
      equivalents: equivalents,
      tip: '饿再吃；不饿可并入正餐。',
    );
  }

  List<MealFoodOption> _optionsFor(
    List<String> names,
    double macroG,
    String hint, {
    required int max,
  }) {
    if (macroG <= 0) return const [];
    final out = <MealFoodOption>[];
    for (final name in names) {
      final food = _byName[name];
      if (food == null || food.rate <= 0) continue;
      if (food.macroHint != hint) continue;
      final grams = _niceGrams(macroG / food.rate);
      if (grams <= 0) continue;
      if (food.pieceWeightG != null && food.pieceUnit != null) {
        final pieces = math.max(1, (grams / food.pieceWeightG!).round());
        final actualG = (pieces * food.pieceWeightG!).round();
        out.add(
          MealFoodOption(
            name: food.name,
            grams: actualG,
            macroHint: hint,
            pieces: pieces,
            pieceUnit: food.pieceUnit,
          ),
        );
      } else if (food.name == '牛奶') {
        out.add(
          MealFoodOption(
            name: food.name,
            grams: grams,
            macroHint: hint,
            displayOverride: '牛奶 约${grams}ml',
          ),
        );
      } else if (food.name == '蛋白粉') {
        out.add(
          MealFoodOption(
            name: food.name,
            grams: grams,
            macroHint: hint,
            displayOverride: '蛋白粉 约${grams}g（兑水）',
          ),
        );
      } else {
        out.add(MealFoodOption(name: food.name, grams: grams, macroHint: hint));
      }
      if (out.length >= max) break;
    }
    return out;
  }

  List<String> _carbNames({required bool post}) {
    final key = post ? 'postCarbStaples' : 'carbStaples';
    final fromCfg = (_config[key] as List?)?.cast<String>();
    if (fromCfg != null && fromCfg.isNotEmpty) return fromCfg;
    return post ? _defaultPostCarbs : _defaultCarbStaples;
  }

  List<String> _breakfastCarbNames() {
    final fromCfg = (_config['breakfastCarbStaples'] as List?)?.cast<String>();
    if (fromCfg != null && fromCfg.isNotEmpty) return fromCfg;
    return _defaultBreakfastCarbs;
  }

  List<String> _proteinNames({required bool preferLeanMeat}) {
    final fromCfg = (_config['proteinStaples'] as List?)?.cast<String>();
    if (fromCfg != null && fromCfg.isNotEmpty) return fromCfg;
    return preferLeanMeat ? _defaultProteinStaples : _defaultProteinStaples;
  }

  String _fatGuideZh(Goal goal, double fatG) {
    final fromCfg = _config['fatGuideZh'] as String?;
    if (fromCfg != null && fromCfg.isNotEmpty) {
      return fromCfg.replaceAll('{fatG}', fatG.round().toString());
    }
    final oilG = _niceGrams(fatG * 0.55, step: 5).clamp(15, 45);
    final yolkNote = goal == Goal.cut
        ? '减脂期全蛋可吃，蛋黄也算脂肪；烹调油另计。'
        : '增肌期不必过度忌油，优先不饱和脂肪（如橄榄油/菜籽油）。';
    return '全天脂肪约 ${fatG.round()}g：烹调油约 ${oilG}g（分到各餐），'
        '其余来自蛋黄、奶、肉类本身。$yolkNote'
        '成年人烹调油建议约 25–30g/日作参考（中国居民膳食指南）。';
  }

  String _weighTipZh() {
    final fromCfg = _config['weighTipZh'] as String?;
    if (fromCfg != null && fromCfg.isNotEmpty) return fromCfg;
    return '称重提示：生米≠米饭。生米约 0.75 碳水率，煮成一般软硬米饭约 0.30；'
        '按「生米克数」换算时，熟重大约是生重的 2–2.5 倍。瘦肉优先按生重称。';
  }

  List<String> _tips(Goal goal) {
    final fromCfg = (_config['tips'] as List?)?.cast<String>();
    if (fromCfg != null && fromCfg.isNotEmpty) return fromCfg;
    return [
      '同一餐内「等价」食物任选其一即可，不必全吃。',
      goal == Goal.cut
          ? '减脂：优先吃满蛋白，主食可按饿感微调 ±10%。'
          : '增肌：练后餐主食尽量吃满，有助恢复。',
    ];
  }

  static String _cleanMealName(String raw) {
    return raw
        .replaceAll('=练前餐', '（练前）')
        .replaceAll('=练后餐', '（练后）')
        .replaceAll('=其他餐', '')
        .replaceAll('早饭=其他餐', '早饭')
        .trim();
  }

  static double _proteinPerPiece(FoodRate egg) {
    final w = egg.pieceWeightG ?? 50;
    return w * egg.rate;
  }

  static int _niceGrams(double raw, {int step = 5}) {
    if (raw.isNaN || raw.isInfinite || raw <= 0) return 0;
    final s = step <= 0 ? 5 : step;
    return math.max(s, (raw / s).round() * s);
  }

  static int _clamp(int v, int min, int max) =>
      v < min ? min : (v > max ? max : v);

  static double _round1(double v) => double.parse(v.toStringAsFixed(1));
}

/// 模板 id → 用户可读中文名。
String templateLabelZh(String templateId) {
  return switch (templateId) {
    'home_3day' => '居家三分化',
    'gym_3day' => '健身房三分化',
    'gym_4day_shoulder' => '健身房四分化（含肩）',
    'gym_4day' => '健身房四分化',
    _ when templateId.contains('home') && templateId.contains('3') => '居家三分化',
    _ when templateId.contains('home') && templateId.contains('4') => '居家四分化',
    _ when templateId.contains('4day') => '健身房四分化',
    _ when templateId.contains('3day') => '三分化',
    _ => templateId,
  };
}

String goalLabelZh(Goal goal) => goal == Goal.cut ? '减脂' : '增肌';
