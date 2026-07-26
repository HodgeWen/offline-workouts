import 'dart:convert';

import 'goal_classifier.dart';
import 'models.dart';
import 'prescription_engine.dart';

/// 预置模板 / 饮食规则的轻量视图（由 seed JSON 注入）。
class SplitTemplateView {
  SplitTemplateView({
    required this.id,
    required this.place,
    required this.split,
    required this.days,
  });

  final String id;
  final String place; // gym | home
  final String split; // 3day | 4day
  final List<SplitDayView> days;

  factory SplitTemplateView.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List? ?? [])
        .map((e) => SplitDayView.fromJson(e as Map<String, dynamic>))
        .toList();
    return SplitTemplateView(
      id: json['id'] as String,
      place: json['place'] as String? ?? 'gym',
      split: json['split'] as String? ?? '3day',
      days: days,
    );
  }
}

class SplitDayView {
  SplitDayView({
    required this.id,
    required this.title,
    required this.regions,
    required this.slots,
  });

  final String id;
  final String title;
  final List<String> regions;
  final List<SplitSlotView> slots;

  factory SplitDayView.fromJson(Map<String, dynamic> json) {
    return SplitDayView(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      regions: (json['regions'] as List? ?? []).cast<String>(),
      slots: (json['slots'] as List? ?? [])
          .map((e) => SplitSlotView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SplitSlotView {
  SplitSlotView({
    required this.region,
    required this.pickMin,
    required this.pickMax,
    required this.setsMin,
    required this.setsMax,
    required this.exercises,
  });

  final String region;
  final int pickMin;
  final int pickMax;
  final int setsMin;
  final int setsMax;
  final List<SlotExerciseView> exercises;

  factory SplitSlotView.fromJson(Map<String, dynamic> json) {
    final rule = json['setsRule'] as Map<String, dynamic>? ?? {};
    return SplitSlotView(
      region: json['region'] as String? ?? '',
      pickMin: (rule['pickMin'] as num?)?.toInt() ?? 1,
      pickMax: (rule['pickMax'] as num?)?.toInt() ?? 1,
      setsMin: (rule['setsMin'] as num?)?.toInt() ?? 3,
      setsMax: (rule['setsMax'] as num?)?.toInt() ?? 4,
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => SlotExerciseView.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SlotExerciseView {
  const SlotExerciseView({required this.name, required this.joints});

  final String name;
  final List<String> joints;

  factory SlotExerciseView.fromJson(Map<String, dynamic> json) {
    return SlotExerciseView(
      name: json['name'] as String? ?? '',
      joints: (json['joints'] as List? ?? []).cast<String>(),
    );
  }
}

class DietRulesView {
  DietRulesView(this.raw);

  final Map<String, dynamic> raw;

  double intakeFactor(Goal goal) {
    final m = raw['intakeFactor'] as Map<String, dynamic>? ?? {};
    return (m[goal.name] as num?)?.toDouble() ?? (goal == Goal.cut ? 0.64 : 0.84);
  }

  int strengthKcal(Sex sex, Experience exp) {
    final root = raw['strengthKcal'] as Map<String, dynamic>? ?? {};
    final bySex = root[sex.name] as Map<String, dynamic>? ?? {};
    return (bySex[exp.name] as num?)?.toInt() ?? 150;
  }

  Map<String, double> macroPerKg(Goal goal, {required bool training}) {
    final root = raw['macroPerKg'] as Map<String, dynamic>? ?? {};
    final byGoal = root[goal.name] as Map<String, dynamic>? ?? {};
    final day = byGoal[training ? 'training' : 'rest'] as Map<String, dynamic>? ?? {};
    // 缺省与 seed 一致：减脂 1.8 / 增肌 1.6 g/kg；勿回落到 2.0
    final defaultProtein = goal == Goal.cut ? 1.8 : 1.6;
    final defaultCarb = goal == Goal.cut
        ? (training ? 3.0 : 2.0)
        : (training ? 4.5 : 3.5);
    return {
      'carb': (day['carb'] as num?)?.toDouble() ?? defaultCarb,
      'protein': (day['protein'] as num?)?.toDouble() ?? defaultProtein,
    };
  }

  double fatGuide(Goal goal, Sex sex) {
    final root = raw['fatGuideGrams'] as Map<String, dynamic>? ?? {};
    final byGoal = root[goal.name] as Map<String, dynamic>? ?? {};
    return (byGoal[sex.name] as num?)?.toDouble() ?? 60;
  }

  int get version => (raw['version'] as num?)?.toInt() ?? 0;

  List<MealSlot> meals(Goal goal, TrainingSlot slot, {required bool training}) {
    final templates = raw['mealTemplates'] as Map<String, dynamic>? ?? {};
    final byGoal = templates[goal.name] as Map<String, dynamic>? ?? {};
    final key = _slotKey(slot);
    final tpl = byGoal[key] as Map<String, dynamic>? ??
        byGoal['after_breakfast_early'] as Map<String, dynamic>? ??
        {};
    final list = (tpl[training ? 'trainingDayMeals' : 'restDayMeals'] as List? ?? []);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return MealSlot(
        name: m['name'] as String? ?? '',
        role: m['role'] as String? ?? 'other',
        carbShare: (m['carbShare'] as num?)?.toDouble() ?? 0.25,
        proteinShare: (m['proteinShare'] as num?)?.toDouble() ?? 0.25,
        note: m['note'] as String? ?? '',
      );
    }).toList();
  }

  /// MealPlanBuilder 配置（主食/蛋白清单与文案）。
  Map<String, dynamic> mealBuilderConfig() {
    final cfg = raw['mealBuilder'];
    if (cfg is Map<String, dynamic>) return cfg;
    return const {};
  }

  static String _slotKey(TrainingSlot slot) {
    return switch (slot) {
      TrainingSlot.afterBreakfastEarly => 'after_breakfast_early',
      TrainingSlot.afterBreakfastLate => 'after_breakfast_late',
      TrainingSlot.beforeLunch => 'before_lunch',
      TrainingSlot.afterLunch => 'after_lunch',
      TrainingSlot.beforeDinner => 'before_dinner',
      TrainingSlot.afterDinner => 'after_dinner',
      TrainingSlot.night => 'night',
    };
  }
}

/// 生成「顺序队列」训练计划：力量队列 + 有氧/瑜伽策略 + 饮食宏量。
///
/// 不绑定日历、不自动插入休息日；有氧/瑜伽为可选恢复策略。
class PlanComposer {
  PlanComposer({
    required this.templates,
    required this.dietRules,
    this.yogaSequences = const [],
    this.classifier = const GoalClassifier(),
    this.prescription = const PrescriptionEngine(),
    this.cardioEngine = const CardioPolicyEngine(),
    this.yogaEngine = const YogaPolicyEngine(),
  });

  final List<SplitTemplateView> templates;
  final DietRulesView dietRules;
  final List<YogaSequence> yogaSequences;
  final GoalClassifier classifier;
  final PrescriptionEngine prescription;
  final CardioPolicyEngine cardioEngine;
  final YogaPolicyEngine yogaEngine;

  ActivePlan compose(UserProfile profile, {DateTime? now, String? planId}) {
    final goal = classifier.classify(profile);
    final cardio = cardioEngine.build(profile, goal);
    final yoga = yogaEngine.build(profile: profile, sequences: yogaSequences);
    final template = _pickTemplate(profile);
    final created = _dateOnly(now ?? DateTime.now());
    final macros = _macrosFor(profile: profile, goal: goal, cardio: cardio);
    final bmr = mifflinStJeor(profile);
    final tdee = bmr / 0.7;

    final sessions = _buildCycle(
      profile: profile,
      template: template,
    );

    return ActivePlan(
      id: planId ?? 'plan_${_fmt(created)}',
      goal: goal,
      templateId: template.id,
      createdDate: _fmt(created),
      cursorIndex: 0,
      trainingMacros: macros.training,
      restMacros: macros.rest,
      trainingMeals: dietRules.meals(goal, profile.trainingSlot, training: true),
      restMeals: dietRules.meals(goal, profile.trainingSlot, training: false),
      sessions: sessions,
      cardioPolicy: cardio,
      yogaPolicy: yoga,
      bmr: double.parse(bmr.toStringAsFixed(1)),
      tdee: double.parse(tdee.toStringAsFixed(1)),
      dietRulesVersion: dietRules.version,
    );
  }

  /// 仅更新有氧/瑜伽策略与饮食热量摊销，**保留**力量队列、cursor、adaptation。
  ///
  /// 适用：资料里开关瑜伽、微调有氧偏好等。场所/器械/分化/目标/基线变化应走 [compose]。
  ActivePlan updatePolicies(ActivePlan plan, UserProfile profile) {
    final cardio = cardioEngine.build(profile, plan.goal);
    final yoga = yogaEngine.build(profile: profile, sequences: yogaSequences);
    final macros = _macrosFor(
      profile: profile,
      goal: plan.goal,
      cardio: cardio,
    );
    return plan.copyWith(
      cardioPolicy: cardio,
      yogaPolicy: yoga,
      trainingMacros: macros.training,
      restMacros: macros.rest,
      trainingMeals: dietRules.meals(
        plan.goal,
        profile.trainingSlot,
        training: true,
      ),
      restMeals: dietRules.meals(
        plan.goal,
        profile.trainingSlot,
        training: false,
      ),
      dietRulesVersion: dietRules.version,
    );
  }

  /// 安全刷新饮食宏量与餐序（保留力量队列 / cursor / adaptation）。
  ///
  /// 用于 seed 升级后用户点「刷新饮食」；目标按当前档案重算。
  ActivePlan refreshDiet(ActivePlan plan, UserProfile profile) {
    final goal = classifier.classify(profile);
    final cardio = cardioEngine.build(profile, goal);
    final macros = _macrosFor(profile: profile, goal: goal, cardio: cardio);
    final bmr = mifflinStJeor(profile);
    final tdee = bmr / 0.7;
    return plan.copyWith(
      goal: goal,
      cardioPolicy: cardio,
      trainingMacros: macros.training,
      restMacros: macros.rest,
      trainingMeals: dietRules.meals(goal, profile.trainingSlot, training: true),
      restMeals: dietRules.meals(goal, profile.trainingSlot, training: false),
      bmr: double.parse(bmr.toStringAsFixed(1)),
      tdee: double.parse(tdee.toStringAsFixed(1)),
      dietRulesVersion: dietRules.version,
    );
  }

  ({MacroTargets training, MacroTargets rest}) _macrosFor({
    required UserProfile profile,
    required Goal goal,
    required CardioPolicy cardio,
  }) {
    final bmr = mifflinStJeor(profile);
    final tdee = bmr / 0.7;
    final strength =
        dietRules.strengthKcal(profile.sex, profile.experience).toDouble();
    final cardioDaily = cardio.estimateDailyKcal(profile.weightKg);
    final balanceTrain = tdee + strength + cardioDaily;
    final balanceRest = tdee + cardioDaily;
    final factor = dietRules.intakeFactor(goal);

    MacroTargets one({required bool training}) {
      final balance = training ? balanceTrain : balanceRest;
      final perKg = dietRules.macroPerKg(goal, training: training);
      final carb = profile.weightKg * perKg['carb']!;
      final protein = profile.weightKg * perKg['protein']!;
      final fat = dietRules.fatGuide(goal, profile.sex);
      return MacroTargets(
        calories: (balance * factor).round(),
        carbG: double.parse(carb.toStringAsFixed(1)),
        proteinG: double.parse(protein.toStringAsFixed(1)),
        fatG: fat,
      );
    }

    return (training: one(training: true), rest: one(training: false));
  }

  static double mifflinStJeor(UserProfile p) {
    final base = p.weightKg * 9.99 + p.heightCm * 6.25 - p.age * 4.92;
    return p.sex == Sex.male ? base + 5 : base - 161;
  }

  SplitTemplateView _pickTemplate(UserProfile profile) {
    final place = profile.place == Place.home ? 'home' : 'gym';
    final wantFour = place == 'gym' &&
        profile.daysPerWeek >= 4 &&
        profile.experience != Experience.beginner;

    final candidates = templates.where((t) {
      if (t.place != place) return false;
      if (wantFour) return t.split == '4day';
      return t.split == '3day';
    }).toList();

    if (candidates.isEmpty) {
      return templates.first;
    }
    if (wantFour) {
      return candidates.firstWhere(
        (t) => t.id.contains('shoulder'),
        orElse: () => candidates.first,
      );
    }
    return candidates.first;
  }

  List<PlannedSession> _buildCycle({
    required UserProfile profile,
    required SplitTemplateView template,
  }) {
    final sessions = <PlannedSession>[];
    for (var i = 0; i < template.days.length; i++) {
      final tplDay = template.days[i];
      final exercises = _pickExercises(tplDay, profile);
      sessions.add(
        PlannedSession(
          id: 's_$i',
          sequenceIndex: i,
          type: DayType.strength,
          title: tplDay.title,
          regions: tplDay.regions,
          exercises: exercises,
        ),
      );
    }
    return sessions;
  }

  List<PlannedExercise> _pickExercises(SplitDayView day, UserProfile profile) {
    final result = <PlannedExercise>[];
    for (final slot in day.slots) {
      result.addAll(
        prescription.pickSlotExercises(slot: slot, profile: profile),
      );
    }
    return result;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// 便于测试：从 seed JSON 字符串构建。
  static PlanComposer fromSeedJson({
    required String splitTemplatesJson,
    required String dietRulesJson,
    String? yogaJson,
  }) {
    final splitRoot = jsonDecode(splitTemplatesJson) as Map<String, dynamic>;
    final templates = (splitRoot['templates'] as List)
        .map((e) => SplitTemplateView.fromJson(e as Map<String, dynamic>))
        .toList();
    final diet = DietRulesView(jsonDecode(dietRulesJson) as Map<String, dynamic>);
    final yogaSequences = <YogaSequence>[];
    if (yogaJson != null && yogaJson.isNotEmpty) {
      final y = jsonDecode(yogaJson) as Map<String, dynamic>;
      for (final raw in (y['sequences'] as List? ?? [])) {
        yogaSequences.add(
          YogaSequence.fromJson(raw as Map<String, dynamic>),
        );
      }
    }
    return PlanComposer(
      templates: templates,
      dietRules: diet,
      yogaSequences: yogaSequences,
    );
  }
}
