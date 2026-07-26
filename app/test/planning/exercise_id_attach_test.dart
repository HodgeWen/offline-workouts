import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/exercise_id_attach.dart';
import 'package:workout_app/features/planning/domain/models.dart';

void main() {
  ActivePlan emptyPlan({required List<PlannedExercise> exercises}) {
    return ActivePlan(
      id: 'p1',
      goal: Goal.cut,
      templateId: 't',
      createdDate: '2026-01-01',
      cursorIndex: 0,
      trainingMacros: const MacroTargets(
        calories: 1800,
        carbG: 200,
        proteinG: 140,
        fatG: 50,
      ),
      restMacros: const MacroTargets(
        calories: 1600,
        carbG: 160,
        proteinG: 140,
        fatG: 50,
      ),
      trainingMeals: const [],
      restMeals: const [],
      sessions: [
        PlannedSession(
          id: 's0',
          sequenceIndex: 0,
          type: DayType.strength,
          title: '推',
          exercises: exercises,
        ),
      ],
      bmr: 1600,
      tdee: 2200,
    );
  }

  test('按名写入 exerciseId，已有相同 id 不改动', () {
    final plan = emptyPlan(
      exercises: const [
        PlannedExercise(
          name: '引体向上',
          region: '背',
          targetSets: 3,
        ),
        PlannedExercise(
          name: '跪姿俯卧撑',
          region: '胸',
          targetSets: 3,
          exerciseId: 99,
        ),
      ],
    );
    final byName = {'引体向上': 12, '跪姿俯卧撑': 99};
    expect(planNeedsExerciseIdAttach(plan, byName), isTrue);

    final attached = attachExerciseIdsToPlan(plan, byName);
    expect(attached.sessions.first.exercises[0].exerciseId, 12);
    expect(attached.sessions.first.exercises[1].exerciseId, 99);
    expect(planNeedsExerciseIdAttach(attached, byName), isFalse);
  });

  test('名不在动作库时保留 null，不做模糊匹配', () {
    final plan = emptyPlan(
      exercises: const [
        PlannedExercise(name: '不存在的动作', region: '背', targetSets: 3),
      ],
    );
    final attached = attachExerciseIdsToPlan(plan, {'引体向上': 1});
    expect(attached.sessions.first.exercises.first.exerciseId, isNull);
  });

  test('PlannedExercise / LoggedExercise JSON 往返保留 exerciseId', () {
    const pe = PlannedExercise(
      name: '自重深蹲',
      region: '腿',
      targetSets: 3,
      exerciseId: 42,
    );
    final pe2 = PlannedExercise.fromJson(pe.toJson());
    expect(pe2.exerciseId, 42);

    final log = LoggedExercise.fromPrescription(pe);
    expect(log.exerciseId, 42);
    final log2 = LoggedExercise.fromJson(log.toJson());
    expect(log2.exerciseId, 42);
  });

  test('seed 重灌后 id 变化时可重新对齐', () {
    final plan = emptyPlan(
      exercises: const [
        PlannedExercise(
          name: '引体向上',
          region: '背',
          targetSets: 3,
          exerciseId: 1,
        ),
      ],
    );
    final newIds = {'引体向上': 101};
    expect(planNeedsExerciseIdAttach(plan, newIds), isTrue);
    final attached = attachExerciseIdsToPlan(plan, newIds);
    expect(attached.sessions.first.exercises.first.exerciseId, 101);
  });
}
