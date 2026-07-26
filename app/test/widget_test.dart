import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/goal_classifier.dart';
import 'package:workout_app/features/planning/domain/models.dart';

void main() {
  test('smoke: GoalClassifier 可解析基本画像', () {
    const profile = UserProfile(
      sex: Sex.male,
      heightCm: 175,
      weightKg: 70,
      age: 28,
      place: Place.gym,
      daysPerWeek: 4,
      experience: Experience.beginner,
      trainingSlot: TrainingSlot.afterBreakfastEarly,
    );
    final goal = const GoalClassifier().classify(profile);
    expect(goal, isA<Goal>());
  });
}
