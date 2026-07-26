import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/models.dart';
import 'package:workout_app/features/planning/domain/plan_composer.dart';
import 'package:workout_app/features/planning/domain/prescription_engine.dart';
import 'package:workout_app/features/planning/domain/volume_adapter.dart';

void main() {
  const engine = PrescriptionEngine();
  const adapter = VolumeAdapter();

  UserProfile profile({
    Experience exp = Experience.beginner,
    Place place = Place.gym,
    List<HomeEquipment> gear = const [HomeEquipment.none],
    CapacityBaseline capacity = const CapacityBaseline(),
  }) {
    return UserProfile(
      sex: Sex.male,
      heightCm: 175,
      weightKg: 70,
      age: 28,
      experience: exp,
      place: place,
      daysPerWeek: 3,
      trainingSlot: TrainingSlot.afterLunch,
      capacity: capacity,
      homeEquipment: gear,
    );
  }

  SplitSlotView pullSlot({List<String>? names}) {
    final list = names ??
        const ['引体向上', '高位下拉', '器械下拉'];
    return SplitSlotView(
      region: '背',
      pickMin: 1,
      pickMax: 1,
      setsMin: 6,
      setsMax: 8,
      exercises: list
          .map((n) => SlotExerciseView(name: n, joints: const ['肩', '肘']))
          .toList(),
    );
  }

  SplitSlotView pushSlot() {
    return SplitSlotView(
      region: '胸',
      pickMin: 1,
      pickMax: 1,
      setsMin: 6,
      setsMax: 8,
      exercises: const [
        SlotExerciseView(name: '俯卧撑', joints: ['肩', '肘']),
      ],
    );
  }

  group('PrescriptionEngine', () {
    test('max=0 引体：健身房替换为弹力带辅助或水平划船', () {
      final out = engine.pickSlotExercises(
        slot: pullSlot(),
        profile: profile(
          capacity: const CapacityBaseline(pullUpMaxReps: 0),
        ),
      );
      expect(out, isNotEmpty);
      expect(out.first.name, isNot(equals('引体向上')));
      expect(
        out.first.name.contains('弹力带') || out.first.name.contains('澳式'),
        isTrue,
      );
      expect(out.first.repsMin, lessThanOrEqualTo(out.first.repsMax));
    });

    test('max=6 新手引体：次数不超过 max，组数偏少', () {
      final out = engine.pickSlotExercises(
        slot: pullSlot(),
        profile: profile(
          capacity: const CapacityBaseline(pullUpMaxReps: 6),
        ),
      );
      final pull = out.firstWhere((e) => e.name.contains('引体'));
      expect(pull.repsMin, lessThanOrEqualTo(6));
      expect(pull.repsMax, lessThanOrEqualTo(6));
      expect(pull.repsMin, lessThanOrEqualTo(pull.repsMax));
      expect(pull.targetSets, lessThanOrEqualTo(3));
      expect(pull.note, isNotEmpty);
    });

    test('居家无单杠：不处方标准引体向上', () {
      final out = engine.pickSlotExercises(
        slot: pullSlot(
          names: const ['引体向上（可用弹力带减重）', '弹力带俯身划船', '单边哑铃划船'],
        ),
        profile: profile(
          place: Place.home,
          gear: const [HomeEquipment.resistanceBand],
          capacity: const CapacityBaseline(pullUpMaxReps: 6),
        ),
      );
      expect(out.every((e) => !e.name.startsWith('引体向上')), isTrue);
      expect(out.any((e) => e.name.contains('弹力带')), isTrue);
    });

    test('俯卧撑 max=0 → 跪姿俯卧撑', () {
      final out = engine.pickSlotExercises(
        slot: pushSlot(),
        profile: profile(
          capacity: const CapacityBaseline(pushUpMaxReps: 0),
        ),
      );
      expect(out.first.name, contains('跪姿'));
    });

    test('侧平举带起始重量', () {
      final slot = SplitSlotView(
        region: '肩中束',
        pickMin: 1,
        pickMax: 1,
        setsMin: 5,
        setsMax: 5,
        exercises: const [
          SlotExerciseView(name: '哑铃/龙门架侧平举', joints: ['肩']),
        ],
      );
      final out = engine.pickSlotExercises(
        slot: slot,
        profile: profile(
          capacity: const CapacityBaseline(
            lateralRaiseMaxReps: 10,
            lateralRaiseWeightKg: 6,
          ),
        ),
      );
      expect(out.first.targetWeightKg, 6);
      expect(out.first.repsMax, lessThanOrEqualTo(10));
    });

    test('新手总组数显著低于老手', () {
      final slot = pullSlot();
      final beginner = engine.pickSlotExercises(
        slot: slot,
        profile: profile(
          exp: Experience.beginner,
          capacity: const CapacityBaseline(pullUpMaxReps: 12),
        ),
      );
      final advanced = engine.pickSlotExercises(
        slot: slot,
        profile: profile(
          exp: Experience.advanced,
          capacity: const CapacityBaseline(pullUpMaxReps: 12),
        ),
      );
      final bSets = beginner.fold<int>(0, (s, e) => s + e.targetSets);
      final aSets = advanced.fold<int>(0, (s, e) => s + e.targetSets);
      expect(bSets, lessThan(aSets));
    });
  });

  group('VolumeAdapter', () {
    PlannedSession sessionWith(PlannedExercise ex) {
      return PlannedSession(
        id: 's_0',
        sequenceIndex: 0,
        type: DayType.strength,
        title: 'Day1',
        exercises: [ex],
      );
    }

    ActivePlan planWith(PlannedSession s) {
      return ActivePlan(
        id: 'p',
        goal: Goal.cut,
        templateId: 'gym_3day',
        createdDate: '2026-07-26',
        cursorIndex: 0,
        trainingMacros: const MacroTargets(
          calories: 2000,
          carbG: 200,
          proteinG: 140,
          fatG: 60,
        ),
        restMacros: const MacroTargets(
          calories: 1800,
          carbG: 180,
          proteinG: 140,
          fatG: 60,
        ),
        trainingMeals: const [],
        restMeals: const [],
        sessions: [s, s.copyWith(exercises: s.exercises)],
        bmr: 1600,
        tdee: 2200,
      );
    }

    test('太少 → 自重优先加次数', () {
      final ex = const PlannedExercise(
        name: '引体向上',
        region: '背',
        targetSets: 3,
        repsMin: 4,
        repsMax: 5,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final logged = [
        LoggedExercise(
          name: '引体向上',
          region: '背',
          sets: const [
            LoggedSet(reps: 5),
            LoggedSet(reps: 5),
            LoggedSet(reps: 5),
          ],
        ),
      ];
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: logged,
        feedback: VolumeFeedback.tooLittle,
      );
      final adapted = next.sessions.first.exercises.first;
      expect(adapted.repsMin, greaterThan(ex.repsMin));
      expect(next.adaptation.lastFeedback, VolumeFeedback.tooLittle);
    });

    test('太多 → 降次数或重量', () {
      final ex = const PlannedExercise(
        name: '哑铃/龙门架侧平举',
        region: '肩中束',
        targetSets: 3,
        repsMin: 10,
        repsMax: 12,
        targetWeightKg: 8,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise(
            name: ex.name,
            region: ex.region,
            sets: const [
              LoggedSet(weightKg: 8, reps: 8),
              LoggedSet(weightKg: 8, reps: 7),
            ],
          ),
        ],
        feedback: VolumeFeedback.tooMuch,
      );
      final adapted = next.sessions.first.exercises.first;
      expect(adapted.targetWeightKg, lessThan(8));
    });

    test('刚好但未打满上限 → 不加量', () {
      final ex = const PlannedExercise(
        name: '俯卧撑',
        region: '胸',
        targetSets: 3,
        repsMin: 8,
        repsMax: 12,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise(
            name: '俯卧撑',
            region: '胸',
            sets: const [
              LoggedSet(reps: 9),
              LoggedSet(reps: 8),
              LoggedSet(reps: 8),
            ],
          ),
        ],
        feedback: VolumeFeedback.justRight,
      );
      expect(next.sessions.first.exercises.first.repsMin, ex.repsMin);
      expect(next.sessions.first.exercises.first.repsMax, ex.repsMax);
    });

    test('太少但多数组低于处方下限 → 不涨', () {
      final ex = const PlannedExercise(
        name: '引体向上',
        region: '背',
        targetSets: 3,
        repsMin: 5,
        repsMax: 6,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise(
            name: '引体向上',
            region: '背',
            sets: const [
              LoggedSet(reps: 3),
              LoggedSet(reps: 2),
              LoggedSet(reps: 2),
            ],
          ),
        ],
        feedback: VolumeFeedback.tooLittle,
      );
      expect(next.sessions.first.exercises.first.repsMin, ex.repsMin);
    });

    test('刚好且打满上限 → 加量', () {
      final ex = const PlannedExercise(
        name: '俯卧撑',
        region: '胸',
        targetSets: 3,
        repsMin: 8,
        repsMax: 12,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise.fromPrescription(
            ex,
            sets: const [
              LoggedSet(reps: 12),
              LoggedSet(reps: 12),
              LoggedSet(reps: 12),
            ],
          ),
        ],
        feedback: VolumeFeedback.justRight,
      );
      expect(next.sessions.first.exercises.first.repsMin, greaterThan(ex.repsMin));
    });

    test('太少但组数明显不足 → 不涨', () {
      final ex = const PlannedExercise(
        name: '引体向上',
        region: '背',
        targetSets: 4,
        repsMin: 5,
        repsMax: 6,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise.fromPrescription(
            ex,
            sets: const [
              LoggedSet(reps: 6),
            ],
          ),
        ],
        feedback: VolumeFeedback.tooLittle,
      );
      expect(next.sessions.first.exercises.first.repsMin, ex.repsMin);
    });

    test('有配重：打满上限 + 太少 → 加重量', () {
      final ex = const PlannedExercise(
        name: '哑铃弯举',
        region: '肱二头',
        targetSets: 3,
        repsMin: 8,
        repsMax: 10,
        targetWeightKg: 10,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise.fromPrescription(
            ex,
            sets: const [
              LoggedSet(weightKg: 10, reps: 10),
              LoggedSet(weightKg: 10, reps: 10),
              LoggedSet(weightKg: 10, reps: 10),
            ],
          ),
        ],
        feedback: VolumeFeedback.tooLittle,
      );
      expect(next.sessions.first.exercises.first.targetWeightKg, greaterThan(10));
    });

    test('容量远低于处方（配重偏轻）→ 不涨', () {
      final ex = const PlannedExercise(
        name: '哑铃弯举',
        region: '肱二头',
        targetSets: 3,
        repsMin: 8,
        repsMax: 12,
        targetWeightKg: 12,
      );
      final session = sessionWith(ex);
      final plan = planWith(session);
      // 次数在区间内，但重量过轻导致容量 < 处方 70%
      final next = adapter.adaptAfterSession(
        plan: plan,
        completedSession: session,
        logged: [
          LoggedExercise.fromPrescription(
            ex,
            sets: const [
              LoggedSet(weightKg: 4, reps: 10),
              LoggedSet(weightKg: 4, reps: 10),
              LoggedSet(weightKg: 4, reps: 10),
            ],
          ),
        ],
        feedback: VolumeFeedback.tooLittle,
      );
      expect(next.sessions.first.exercises.first.targetWeightKg, 12);
    });

    test('LoggedExercise 处方快照参与容量计算', () {
      final log = LoggedExercise.fromPrescription(
        const PlannedExercise(
          name: '哑铃弯举',
          region: '肱二头',
          targetSets: 3,
          repsMin: 8,
          repsMax: 10,
          targetWeightKg: 10,
        ),
        sets: const [
          LoggedSet(weightKg: 10, reps: 8),
          LoggedSet(weightKg: 10, reps: 8),
          LoggedSet(weightKg: 10, reps: 8),
        ],
      );
      expect(log.prescribedSets, 3);
      expect(log.loggedVolume, 240);
      expect(log.prescribedVolumeMin, 240);
      final json = log.toJson();
      final roundTrip = LoggedExercise.fromJson(json);
      expect(roundTrip.prescribedRepsMax, 10);
      expect(roundTrip.loggedVolume, 240);
    });
  });
}
