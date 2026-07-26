import 'dart:math';

import 'models.dart';

/// 根据主观反馈 + 实际完成表现，调整后续处方。
///
/// ## 主杠杆（每次反馈只优先动一个）
/// 1. 有配重（处方或实记重量 > 0）→ 优先调 **重量**（±1.25kg，至少 ±1kg）
/// 2. 否则优先调 **次数**（±1）
/// 3. 次数已触顶/触底时再调 **组数**（±1，组数夹在 2–6）
///
/// ## 反馈 × 表现联合规则
/// - 多数组实际次数 < 处方下限，或完成组数明显不足，或容量远低于处方 → **不涨**
/// - 太少 → 未欠表现时增加主杠杆
/// - 太多 → 降低主杠杆
/// - 刚好 → 仅当多数组打到处方上限时小幅渐进
/// - 无主观反馈 → 仅在打满上限时轻微加量
///
/// 状态累计在 [VolumeAdaptationState]，应用到队列中尚未完成的会话动作上。
class VolumeAdapter {
  const VolumeAdapter();

  /// 完成一次训练后：更新 adaptation，并写回 plan.sessions 中同名动作处方。
  ActivePlan adaptAfterSession({
    required ActivePlan plan,
    required PlannedSession completedSession,
    required List<LoggedExercise> logged,
    required VolumeFeedback? feedback,
  }) {
    if (feedback == null && logged.isEmpty) return plan;

    final nextMap = Map<String, ExerciseAdaptation>.from(
      plan.adaptation.byExercise,
    );

    for (final prescribed in completedSession.exercises) {
      final log = _findLog(logged, prescribed.name);
      final performance = evaluatePerformance(
        prescribed: prescribed,
        logged: log,
      );
      final hasWeight = (prescribed.targetWeightKg ?? 0) > 0 ||
          (log != null && log.sets.any((s) => s.weightKg > 0));

      final delta = _deltaForFeedback(
        feedback: feedback,
        performance: performance,
        hasWeight: hasWeight,
      );
      if (delta == null) continue;

      final prev = nextMap[prescribed.name] ?? const ExerciseAdaptation();
      nextMap[prescribed.name] = ExerciseAdaptation(
        setsDelta: (prev.setsDelta + delta.setsDelta).clamp(-3, 3),
        repsDelta: (prev.repsDelta + delta.repsDelta).clamp(-6, 6),
        weightDeltaKg:
            (prev.weightDeltaKg + delta.weightDeltaKg).clamp(-20.0, 20.0),
      );
    }

    final adaptation = VolumeAdaptationState(
      byExercise: nextMap,
      lastFeedback: feedback,
    );

    final sessions = plan.sessions.map((s) {
      final exercises = s.exercises.map((e) {
        final a = nextMap[e.name];
        if (a == null) return e;
        return applyToExercise(e, a);
      }).toList();
      return s.copyWith(exercises: exercises);
    }).toList();

    return plan.copyWith(sessions: sessions, adaptation: adaptation);
  }

  /// 将累计偏移应用到单个动作（生成/展示时也可调用）。
  PlannedExercise applyToExercise(
    PlannedExercise ex,
    ExerciseAdaptation a,
  ) {
    final sets = (ex.targetSets + a.setsDelta).clamp(2, 6);
    var repsMin = max(1, ex.repsMin + a.repsDelta);
    var repsMax = max(repsMin, ex.repsMax + a.repsDelta);
    double? weight = ex.targetWeightKg;
    if (a.weightDeltaKg != 0) {
      final base = weight ?? 0;
      final next = max(0.0, base + a.weightDeltaKg);
      weight = next > 0 ? _roundWeight(next) : null;
    }
    final note = ex.note.isEmpty
        ? '已按近期反馈微调'
        : (ex.note.contains('反馈') ? ex.note : '${ex.note}；已按近期反馈微调');
    return ex.copyWith(
      targetSets: sets,
      repsMin: repsMin,
      repsMax: repsMax,
      targetWeightKg: weight,
      note: note,
    );
  }

  /// 对比处方与实记：次数区间、组数完成度、容量。
  ExercisePerformance evaluatePerformance({
    required PlannedExercise prescribed,
    required LoggedExercise? logged,
  }) {
    if (logged == null || logged.sets.isEmpty) {
      return const ExercisePerformance(
        underperformed: false,
        hitTop: false,
        incompleteSets: false,
        lowVolume: false,
      );
    }

    final repsMin = logged.prescribedRepsMin ?? prescribed.repsMin;
    final repsMax = logged.prescribedRepsMax ?? prescribed.repsMax;
    final targetSets = logged.prescribedSets ?? prescribed.targetSets;

    final under = logged.sets.where((s) => s.reps < repsMin).length;
    final hit = logged.sets.where((s) => s.reps >= repsMax).length;
    final underperformed = under * 2 >= logged.sets.length;
    final hitTop = hit * 2 >= logged.sets.length;

    // 完成组数不足处方一半 → 视为欠量
    final incompleteSets = logged.sets.length * 2 < targetSets;

    final prescribedMin = logged.prescribedVolumeMin ??
        _prescribedVolumeMin(
          sets: targetSets,
          repsMin: repsMin,
          weightKg: logged.prescribedWeightKg ?? prescribed.targetWeightKg,
        );
    final lowVolume = prescribedMin > 0 &&
        logged.loggedVolume + 1e-6 < prescribedMin * 0.7;

    return ExercisePerformance(
      underperformed: underperformed,
      hitTop: hitTop,
      incompleteSets: incompleteSets,
      lowVolume: lowVolume,
    );
  }

  ExerciseAdaptation? _deltaForFeedback({
    required VolumeFeedback? feedback,
    required ExercisePerformance performance,
    required bool hasWeight,
  }) {
    final blockedIncrease = performance.blocksIncrease;

    if (feedback == null) {
      if (blockedIncrease || !performance.hitTop) return null;
      return _increase(hasWeight: hasWeight);
    }

    switch (feedback) {
      case VolumeFeedback.tooLittle:
        if (blockedIncrease) return null;
        return _increase(hasWeight: hasWeight);
      case VolumeFeedback.tooMuch:
        return _decrease(hasWeight: hasWeight);
      case VolumeFeedback.justRight:
        if (blockedIncrease || !performance.hitTop) return null;
        return _increase(hasWeight: hasWeight);
    }
  }

  ExerciseAdaptation _increase({required bool hasWeight}) {
    if (hasWeight) {
      return const ExerciseAdaptation(weightDeltaKg: 1.25);
    }
    return const ExerciseAdaptation(repsDelta: 1);
  }

  ExerciseAdaptation _decrease({required bool hasWeight}) {
    if (hasWeight) {
      return const ExerciseAdaptation(weightDeltaKg: -1.25);
    }
    return const ExerciseAdaptation(repsDelta: -1);
  }

  LoggedExercise? _findLog(List<LoggedExercise> logged, String name) {
    for (final e in logged) {
      if (e.name == name) return e;
    }
    return null;
  }

  double _prescribedVolumeMin({
    required int sets,
    required int repsMin,
    required double? weightKg,
  }) {
    final w = weightKg ?? 0;
    return w > 0 ? sets * repsMin * w : (sets * repsMin).toDouble();
  }

  double _roundWeight(double w) {
    // 常见小哑铃步进 1.25
    return (w * 4).round() / 4.0;
  }
}

/// 单次动作相对处方的客观表现。
class ExercisePerformance {
  const ExercisePerformance({
    required this.underperformed,
    required this.hitTop,
    required this.incompleteSets,
    required this.lowVolume,
  });

  /// 多数组次数低于处方下限。
  final bool underperformed;

  /// 多数组次数达到处方上限。
  final bool hitTop;

  /// 完成组数明显少于处方。
  final bool incompleteSets;

  /// 总容量显著低于处方下限（约 <70%）。
  final bool lowVolume;

  /// 任一欠量信号都会阻止加量。
  bool get blocksIncrease =>
      underperformed || incompleteSets || lowVolume;
}
