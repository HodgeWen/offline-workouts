import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/goal_classifier.dart';
import 'package:workout_app/features/planning/domain/models.dart';

UserProfile _profile({
  double heightCm = 175,
  double weightKg = 70,
  GoalPreference goalPreference = GoalPreference.auto,
  bool includeCardio = false,
  Sex sex = Sex.male,
}) {
  return UserProfile(
    sex: sex,
    heightCm: heightCm,
    weightKg: weightKg,
    age: 28,
    experience: Experience.beginner,
    place: Place.gym,
    daysPerWeek: 3,
    trainingSlot: TrainingSlot.afterBreakfastEarly,
    includeCardio: includeCardio,
    goalPreference: goalPreference,
  );
}

void main() {
  const classifier = GoalClassifier();

  test('显式减脂优先', () {
    expect(
      classifier.classify(_profile(goalPreference: GoalPreference.cut)),
      Goal.cut,
    );
  });

  test('显式增肌优先', () {
    expect(
      classifier.classify(_profile(goalPreference: GoalPreference.bulk)),
      Goal.bulk,
    );
  });

  test('BMI≥24 默认减脂', () {
    // 175cm / 75kg ≈ 24.5
    expect(classifier.classify(_profile(weightKg: 75)), Goal.cut);
  });

  test('BMI≤20 默认增肌', () {
    // 175cm / 60kg ≈ 19.6
    expect(classifier.classify(_profile(weightKg: 60)), Goal.bulk);
  });

  test('175/63 自动判定增肌（禁止静默减脂）', () {
    // BMI ≈ 20.57
    expect(classifier.classify(_profile(weightKg: 63)), Goal.bulk);
    expect(
      classifier.classify(_profile(weightKg: 63, sex: Sex.female)),
      Goal.bulk,
    );
    expect(
      classifier.classify(
        _profile(weightKg: 63, goalPreference: GoalPreference.cut),
      ),
      Goal.cut,
    );
  });

  test('175/85 默认减脂', () {
    // BMI ≈ 27.8
    expect(classifier.classify(_profile(weightKg: 85)), Goal.cut);
  });

  test('175/55 默认增肌', () {
    // BMI ≈ 18.0
    expect(classifier.classify(_profile(weightKg: 55)), Goal.bulk);
  });

  test('中间 BMI 看偏好', () {
    final mid = _profile(weightKg: 68); // BMI≈22.2
    expect(
      classifier.classify(
        mid.copyWith(goalPreference: GoalPreference.preferBulk),
      ),
      Goal.bulk,
    );
    expect(
      classifier.classify(
        mid.copyWith(goalPreference: GoalPreference.preferCut),
      ),
      Goal.cut,
    );
  });

  test('explainZh 含中文目标说明', () {
    final text = classifier.explainZh(_profile(weightKg: 63));
    expect(text, contains('增肌'));
    expect(text, contains('BMI'));
  });

  test('增肌默认不安排有氧，问卷可强制', () {
    final p = _profile(weightKg: 60, includeCardio: false);
    expect(classifier.shouldIncludeCardio(p, Goal.bulk), isFalse);
    expect(
      classifier.shouldIncludeCardio(
        p.copyWith(includeCardio: true),
        Goal.bulk,
      ),
      isTrue,
    );
  });

  test('减脂大体重默认不强制有氧', () {
    final p = _profile(weightKg: 85);
    expect(classifier.shouldIncludeCardio(p, Goal.cut), isFalse);
  });
}
