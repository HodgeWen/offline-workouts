import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/models.dart';
import 'package:workout_app/features/planning/domain/plan_composer.dart';

String _readSeed(String name) {
  final file = File('assets/seed/$name');
  if (file.existsSync()) return file.readAsStringSync();
  return File('../assets/seed/$name').readAsStringSync();
}

void main() {
  late PlanComposer composer;

  setUp(() {
    composer = PlanComposer.fromSeedJson(
      splitTemplatesJson: _readSeed('split_templates.json'),
      dietRulesJson: _readSeed('diet_rules.json'),
      yogaJson: _readSeed('yoga.json'),
    );
  });

  UserProfile profile({
    Place place = Place.gym,
    int days = 3,
    Experience exp = Experience.beginner,
    double weight = 70,
    GoalPreference goal = GoalPreference.cut,
    bool cardio = false,
    bool yoga = false,
    Sex sex = Sex.male,
  }) {
    return UserProfile(
      sex: sex,
      heightCm: 175,
      weightKg: weight,
      age: 28,
      experience: exp,
      place: place,
      daysPerWeek: days,
      trainingSlot: TrainingSlot.afterLunch,
      includeCardio: cardio,
      includeYoga: yoga,
      goalPreference: goal,
    );
  }

  test('Mifflin 公式基本正确', () {
    final p = profile();
    final bmr = PlanComposer.mifflinStJeor(p);
    expect(bmr, closeTo(1660, 5));
  });

  test('健身房新手生成三分化顺序队列', () {
    final plan = composer.compose(profile());
    expect(plan.goal, Goal.cut);
    expect(plan.templateId, 'gym_3day');
    expect(plan.cursorIndex, 0);
    expect(plan.sessions.length, 3);
    expect(plan.sessions.every((s) => s.type == DayType.strength), isTrue);
    expect(plan.sessions.any((s) => s.type == DayType.rest), isFalse);
    expect(plan.nextSession?.exercises, isNotEmpty);
    expect(plan.trainingMacros.calories, greaterThan(0));
    expect(plan.restMacros.calories, lessThan(plan.trainingMacros.calories + 1));
  });

  test('居家使用居家模板', () {
    final plan = composer.compose(profile(place: Place.home));
    expect(plan.templateId, 'home_3day');
    expect(plan.sessions.length, 3);
  });

  test('健身房有基础每周4天用四分化', () {
    final plan = composer.compose(
      profile(days: 4, exp: Experience.intermediate),
    );
    expect(plan.templateId, contains('4day'));
    expect(plan.sessions.length, greaterThanOrEqualTo(4));
  });

  test('增肌应吃系数高于减脂', () {
    final cut = composer.compose(profile(goal: GoalPreference.cut));
    final bulk = composer.compose(
      profile(goal: GoalPreference.bulk, weight: 60),
    );
    expect(
      bulk.trainingMacros.calories,
      greaterThan(cut.trainingMacros.calories),
    );
  });

  test('顺序队列不含休息日也不按日期铺开', () {
    final plan = composer.compose(profile(days: 3));
    expect(plan.sessions.every((s) => s.type == DayType.strength), isTrue);
    expect(plan.sessions.map((s) => s.sequenceIndex).toList(), [0, 1, 2]);
    expect(plan.sessions.length, lessThanOrEqualTo(6));
  });

  test('完成前进后 cursor 循环', () {
    final plan = composer.compose(profile());
    expect(plan.nextSession?.sequenceIndex, 0);
    final advanced = plan.copyWith(cursorIndex: 1);
    expect(advanced.nextSession?.sequenceIndex, 1);
    final wrap = plan.copyWith(cursorIndex: plan.sessions.length);
    expect(wrap.nextSession?.sequenceIndex, 0);
  });

  test('饮食餐序按时段生成', () {
    final plan = composer.compose(profile());
    expect(plan.trainingMeals, isNotEmpty);
    expect(
      plan.trainingMeals.any((m) => m.role == 'post' || m.name.contains('练后')),
      isTrue,
    );
  });

  test('减脂轻体重：有氧策略启用且不插入力量队列', () {
    final plan = composer.compose(profile(weight: 62));
    expect(plan.cardioPolicy.enabled, isTrue);
    expect(plan.sessions.every((s) => s.type == DayType.strength), isTrue);
  });

  test('女性开启瑜伽：计划含瑜伽策略但不进力量队列', () {
    final plan = composer.compose(
      profile(sex: Sex.female, yoga: true, weight: 58),
    );
    expect(plan.yogaPolicy.enabled, isTrue);
    expect(plan.yogaPolicy.poses, isNotEmpty);
    expect(plan.sessions.any((s) => s.type == DayType.yoga), isFalse);
  });

  test('增肌饮食蛋白/热量与目标一致', () {
    final plan = composer.compose(
      profile(goal: GoalPreference.bulk, weight: 70),
    );
    expect(plan.goal, Goal.bulk);
    // 默认约 1.6 g/kg，不再使用 2.0
    expect(plan.trainingMacros.proteinG, closeTo(112, 0.1));
    expect(plan.cardioPolicy.enabled, isFalse);
  });

  test('63kg 宏量蛋白在合理区间（约 100–115g）', () {
    final bulk = composer.compose(
      profile(goal: GoalPreference.bulk, weight: 63),
    );
    expect(bulk.goal, Goal.bulk);
    expect(bulk.trainingMacros.proteinG, inInclusiveRange(100, 115));
    expect(bulk.trainingMacros.proteinG, closeTo(63 * 1.6, 0.2));
    // 增肌练日碳水约 4.5 g/kg，避免旧版 5.0×体重虚高
    expect(bulk.trainingMacros.carbG, closeTo(63 * 4.5, 0.2));
    expect(bulk.trainingMacros.carbG, lessThan(300));

    final cut = composer.compose(
      profile(goal: GoalPreference.cut, weight: 63),
    );
    expect(cut.trainingMacros.proteinG, inInclusiveRange(100, 115));
    expect(cut.trainingMacros.proteinG, closeTo(63 * 1.8, 0.2));
    expect(cut.trainingMacros.carbG, closeTo(63 * 3.0, 0.2));
  });

  test('175/63 自动生成计划为增肌', () {
    final plan = composer.compose(
      profile(goal: GoalPreference.auto, weight: 63),
    );
    expect(plan.goal, Goal.bulk);
    expect(plan.trainingMacros.proteinG, lessThan(120));
  });

  test('updatePolicies：开关瑜伽不重置 cursor 与力量队列', () {
    final base = composer.compose(profile(yoga: false));
    final advanced = base.copyWith(
      cursorIndex: 2,
      adaptation: const VolumeAdaptationState(
        byExercise: {
          '引体向上': ExerciseAdaptation(repsDelta: 1),
        },
        lastFeedback: VolumeFeedback.tooLittle,
      ),
    );
    final sessionIds = advanced.sessions.map((s) => s.id).toList();
    final firstTitles = advanced.sessions.map((s) => s.title).toList();

    final toggled = composer.updatePolicies(
      advanced,
      profile(yoga: true, sex: Sex.female, weight: 58),
    );

    expect(toggled.cursorIndex, 2);
    expect(toggled.id, advanced.id);
    expect(toggled.sessions.map((s) => s.id).toList(), sessionIds);
    expect(toggled.sessions.map((s) => s.title).toList(), firstTitles);
    expect(toggled.adaptation.byExercise['引体向上']?.repsDelta, 1);
    expect(toggled.adaptation.lastFeedback, VolumeFeedback.tooLittle);
    expect(toggled.yogaPolicy.enabled, isTrue);

    final off = composer.updatePolicies(toggled, profile(yoga: false));
    expect(off.cursorIndex, 2);
    expect(off.yogaPolicy.enabled, isFalse);
    expect(off.adaptation.byExercise['引体向上']?.repsDelta, 1);
  });

  test('compose 全量重生成会重置 cursor（与 updatePolicies 对照）', () {
    final plan = composer.compose(profile(yoga: true));
    expect(plan.cursorIndex, 0);
    expect(plan.adaptation.byExercise, isEmpty);
  });

  test('refreshDiet：重算目标与宏量，保留 cursor 与力量队列', () {
    final stale = composer.compose(
      profile(goal: GoalPreference.cut, weight: 63),
    );
    final advanced = stale.copyWith(cursorIndex: 1);
    final refreshed = composer.refreshDiet(
      advanced,
      profile(goal: GoalPreference.auto, weight: 63),
    );
    expect(refreshed.goal, Goal.bulk);
    expect(refreshed.cursorIndex, 1);
    expect(refreshed.sessions.map((s) => s.id), advanced.sessions.map((s) => s.id));
    expect(refreshed.trainingMacros.proteinG, closeTo(63 * 1.6, 0.2));
    expect(refreshed.dietRulesVersion, greaterThanOrEqualTo(4));
  });
}
