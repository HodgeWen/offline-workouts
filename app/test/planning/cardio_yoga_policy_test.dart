import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/models.dart';

void main() {
  const cardioEngine = CardioPolicyEngine();
  const yogaEngine = YogaPolicyEngine();

  UserProfile profile({
    Sex sex = Sex.male,
    GoalPreference goal = GoalPreference.cut,
    double weight = 65,
    bool includeCardio = false,
    bool includeYoga = false,
    Experience exp = Experience.beginner,
    int cardioMinutes = 30,
  }) {
    return UserProfile(
      sex: sex,
      heightCm: 170,
      weightKg: weight,
      age: 28,
      experience: exp,
      place: Place.gym,
      daysPerWeek: 3,
      trainingSlot: TrainingSlot.afterLunch,
      includeCardio: includeCardio,
      cardioPreference: CardioPreference.walk,
      cardioMinutes: cardioMinutes,
      includeYoga: includeYoga,
      goalPreference: goal,
    );
  }

  final sequences = [
    YogaSequence(
      id: 'yoga_rest_gentle',
      title: '休息日温和恢复流',
      level: 'beginner',
      durationMinutes: 18,
      tags: const ['recovery', 'rest_day', 'women_friendly'],
      intent: '恢复',
      poses: const [
        YogaPose(id: 'p1', name: '山式', durationSec: 30),
      ],
    ),
    YogaSequence(
      id: 'yoga_hip_opener',
      title: '髋部打开（女性友好）',
      level: 'beginner',
      durationMinutes: 22,
      tags: const ['hips', 'women_focused', 'mobility'],
      intent: '髋部',
      poses: const [
        YogaPose(id: 'p2', name: '蝴蝶式', durationSec: 60),
      ],
    ),
  ];

  group('CardioPolicyEngine', () {
    test('增肌默认关闭有氧', () {
      final p = cardioEngine.build(profile(goal: GoalPreference.bulk), Goal.bulk);
      expect(p.enabled, isFalse);
      expect(p.intensity, 'none');
    });

    test('增肌用户坚持开启：短时 LISS，每周封顶', () {
      final p = cardioEngine.build(
        profile(goal: GoalPreference.bulk, includeCardio: true, cardioMinutes: 40),
        Goal.bulk,
      );
      expect(p.enabled, isTrue);
      expect(p.intensity, 'short_liss_only');
      expect(p.minutesPerSession, lessThanOrEqualTo(25));
      expect(p.weeklyMinutesTarget, lessThanOrEqualTo(60));
    });

    test('减脂轻体重默认 Zone2', () {
      final p = cardioEngine.build(profile(weight: 62), Goal.cut);
      expect(p.enabled, isTrue);
      expect(p.intensity, 'zone2_liss');
      expect(p.weeklyMinutesTarget, greaterThanOrEqualTo(90));
      expect(p.offerOnRestDays, isTrue);
    });

    test('减脂体重≥80 不强制有氧', () {
      final p = cardioEngine.build(profile(weight: 85), Goal.cut);
      expect(p.enabled, isFalse);
    });

    test('热量估计随体重与分钟变化', () {
      final p = cardioEngine.build(
        profile(weight: 60, includeCardio: true),
        Goal.cut,
      );
      expect(p.estimateSessionKcal(60), greaterThan(0));
      expect(p.estimateDailyKcal(60), greaterThan(0));
    });
  });

  group('YogaPolicyEngine', () {
    test('未开启兴趣则不提供序列', () {
      final y = yogaEngine.build(
        profile: profile(includeYoga: false),
        sequences: sequences,
      );
      expect(y.enabled, isFalse);
    });

    test('女性开启：优先女性友好/髋部序列，恢复模式', () {
      final y = yogaEngine.build(
        profile: profile(sex: Sex.female, includeYoga: true),
        sequences: sequences,
      );
      expect(y.enabled, isTrue);
      expect(y.sequenceId, 'yoga_hip_opener');
      expect(y.offerMode, 'recoveryBetweenStrength');
      expect(y.poses, isNotEmpty);
    });

    test('男性开启：休息日可选', () {
      final y = yogaEngine.build(
        profile: profile(sex: Sex.male, includeYoga: true),
        sequences: sequences,
      );
      expect(y.enabled, isTrue);
      expect(y.offerMode, 'restDayOptional');
    });
  });
}
