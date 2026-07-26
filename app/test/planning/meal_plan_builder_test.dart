import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/meal_plan_builder.dart';
import 'package:workout_app/features/planning/domain/models.dart';
import 'package:workout_app/features/planning/domain/plan_composer.dart';

String _readSeed(String name) {
  final file = File('assets/seed/$name');
  if (file.existsSync()) return file.readAsStringSync();
  return File('../assets/seed/$name').readAsStringSync();
}

void main() {
  late PlanComposer composer;
  late MealPlanBuilder builder;

  setUp(() {
    composer = PlanComposer.fromSeedJson(
      splitTemplatesJson: _readSeed('split_templates.json'),
      dietRulesJson: _readSeed('diet_rules.json'),
    );
    builder = MealPlanBuilder.fromFoodsJson(
      _readSeed('foods.json'),
      mealBuilderConfig: composer.dietRules.mealBuilderConfig(),
    );
  });

  UserProfile bulk63() => const UserProfile(
        sex: Sex.male,
        heightCm: 175,
        weightKg: 63,
        age: 28,
        experience: Experience.beginner,
        place: Place.home,
        daysPerWeek: 3,
        trainingSlot: TrainingSlot.afterLunch,
        goalPreference: GoalPreference.auto,
      );

  test('63kg 增肌练日：蛋白约 1.6g/kg，餐食含米饭/鸡胸克数', () {
    final plan = composer.compose(bulk63());
    expect(plan.goal, Goal.bulk);
    expect(plan.trainingMacros.proteinG, closeTo(63 * 1.6, 0.2));
    expect(plan.trainingMacros.proteinG, isNot(closeTo(63 * 2.0, 0.2)));

    final day = builder.build(
      macros: plan.trainingMacros,
      meals: plan.trainingMeals,
      goal: plan.goal,
    );

    expect(day.meals, isNotEmpty);
    expect(day.fatGuideZh, contains('脂肪'));
    expect(day.weighTipZh, contains('生米'));

    final post = day.meals.firstWhere((m) => m.role == 'post');
    // 练后碳水约 283.5*0.292≈83g → 米饭(0.3) ≈ 275g
    expect(post.primaryLine, contains('米饭'));
    expect(post.primaryLine, contains('鸡胸'));
    final riceMatch = RegExp(r'米饭（一般）\s*约(\d+)g').firstMatch(post.primaryLine);
    expect(riceMatch, isNotNull);
    final riceG = int.parse(riceMatch!.group(1)!);
    expect(riceG, inInclusiveRange(240, 320));

    final chickenMatch =
        RegExp(r'鸡胸肉（生）\s*约(\d+)g').firstMatch(post.primaryLine);
    expect(chickenMatch, isNotNull);
    final chickenG = int.parse(chickenMatch!.group(1)!);
    expect(chickenG, inInclusiveRange(100, 160));

    expect(post.equivalents, isNotEmpty);
    expect(
      post.equivalents.any((e) => e.contains('馒头') || e.contains('生米')),
      isTrue,
    );
  });

  test('早饭给出鸡蛋枚数+牛奶+主食，而非食物1-7', () {
    final plan = composer.compose(bulk63());
    final day = builder.build(
      macros: plan.trainingMacros,
      meals: plan.trainingMeals,
      goal: plan.goal,
    );
    final breakfast = day.meals.firstWhere((m) => m.name.contains('早饭'));
    expect(breakfast.primaryLine, contains('鸡蛋'));
    expect(breakfast.primaryLine, contains('枚'));
    expect(breakfast.primaryLine, contains('牛奶'));
    expect(breakfast.primaryLine, isNot(contains('食物 1')));
    expect(breakfast.equivalents.join(), isNot(contains('食物1-7')));
  });

  test('减脂计划同样生成可读克数餐食', () {
    final plan = composer.compose(
      bulk63().copyWith(goalPreference: GoalPreference.cut),
    );
    expect(plan.goal, Goal.cut);
    final day = builder.build(
      macros: plan.trainingMacros,
      meals: plan.trainingMeals,
      goal: plan.goal,
    );
    expect(day.meals.every((m) => m.primaryLine.isNotEmpty), isTrue);
    expect(day.meals.any((m) => m.primaryLine.contains('约')), isTrue);
  });

  test('templateLabelZh 隐藏开发者 id', () {
    expect(templateLabelZh('home_3day'), '居家三分化');
    expect(templateLabelZh('gym_3day'), '健身房三分化');
  });

  test('compose 写入 dietRulesVersion', () {
    final plan = composer.compose(bulk63());
    expect(plan.dietRulesVersion, greaterThanOrEqualTo(4));
  });
}
