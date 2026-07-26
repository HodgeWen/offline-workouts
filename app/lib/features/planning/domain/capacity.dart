// 基线能力、居家器械与训练量反馈（随 UserProfile / WorkoutLog JSON 持久化）。

/// 居家可用器械（多选）；健身房模式不依赖此列表。
enum HomeEquipment {
  none, // 无器械（纯自重）
  dumbbell, // 哑铃
  resistanceBand, // 弹力带
  pullUpBar, // 单杠 / 门上引体杆
  bench, // 卧推凳
  kettlebell, // 壶铃
}

/// 一次训练后对「当前训练量」的主观评价。
enum VolumeFeedback { tooLittle, justRight, tooMuch }

/// 用户可测的最大次数 / 起始重量，用于动态处方。
class CapacityBaseline {
  const CapacityBaseline({
    this.pullUpMaxReps = 0,
    this.pushUpMaxReps = 0,
    this.squatMaxReps = 0,
    this.lateralRaiseMaxReps = 0,
    this.lateralRaiseWeightKg,
  });

  /// 引体向上：一次最多能做几个（可 0）。
  final int pullUpMaxReps;

  /// 俯卧撑：一次最多。
  final int pushUpMaxReps;

  /// 自重深蹲：一次最多。
  final int squatMaxReps;

  /// 哑铃侧平举：一次最多次数。
  final int lateralRaiseMaxReps;

  /// 侧平举使用重量 kg；无哑铃时可空。
  final double? lateralRaiseWeightKg;

  CapacityBaseline copyWith({
    int? pullUpMaxReps,
    int? pushUpMaxReps,
    int? squatMaxReps,
    int? lateralRaiseMaxReps,
    double? lateralRaiseWeightKg,
    bool clearLateralRaiseWeight = false,
  }) {
    return CapacityBaseline(
      pullUpMaxReps: pullUpMaxReps ?? this.pullUpMaxReps,
      pushUpMaxReps: pushUpMaxReps ?? this.pushUpMaxReps,
      squatMaxReps: squatMaxReps ?? this.squatMaxReps,
      lateralRaiseMaxReps: lateralRaiseMaxReps ?? this.lateralRaiseMaxReps,
      lateralRaiseWeightKg: clearLateralRaiseWeight
          ? null
          : (lateralRaiseWeightKg ?? this.lateralRaiseWeightKg),
    );
  }

  Map<String, dynamic> toJson() => {
        'pullUpMaxReps': pullUpMaxReps,
        'pushUpMaxReps': pushUpMaxReps,
        'squatMaxReps': squatMaxReps,
        'lateralRaiseMaxReps': lateralRaiseMaxReps,
        'lateralRaiseWeightKg': lateralRaiseWeightKg,
      };

  factory CapacityBaseline.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CapacityBaseline();
    return CapacityBaseline(
      pullUpMaxReps: (json['pullUpMaxReps'] as num?)?.toInt() ?? 0,
      pushUpMaxReps: (json['pushUpMaxReps'] as num?)?.toInt() ?? 0,
      squatMaxReps: (json['squatMaxReps'] as num?)?.toInt() ?? 0,
      lateralRaiseMaxReps: (json['lateralRaiseMaxReps'] as num?)?.toInt() ?? 0,
      lateralRaiseWeightKg:
          (json['lateralRaiseWeightKg'] as num?)?.toDouble(),
    );
  }
}

/// 跨会话的渐进调整状态（挂在 ActivePlan 上，完成训练后更新）。
class VolumeAdaptationState {
  const VolumeAdaptationState({
    this.byExercise = const {},
    this.lastFeedback,
  });

  /// 按动作名累计的组数/次数/重量偏移。
  final Map<String, ExerciseAdaptation> byExercise;
  final VolumeFeedback? lastFeedback;

  VolumeAdaptationState copyWith({
    Map<String, ExerciseAdaptation>? byExercise,
    VolumeFeedback? lastFeedback,
    bool clearFeedback = false,
  }) {
    return VolumeAdaptationState(
      byExercise: byExercise ?? this.byExercise,
      lastFeedback: clearFeedback ? null : (lastFeedback ?? this.lastFeedback),
    );
  }

  Map<String, dynamic> toJson() => {
        'byExercise': byExercise.map((k, v) => MapEntry(k, v.toJson())),
        'lastFeedback': lastFeedback?.name,
      };

  factory VolumeAdaptationState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VolumeAdaptationState();
    final raw = json['byExercise'] as Map<String, dynamic>? ?? {};
    return VolumeAdaptationState(
      byExercise: raw.map(
        (k, v) => MapEntry(
          k,
          ExerciseAdaptation.fromJson(v as Map<String, dynamic>),
        ),
      ),
      lastFeedback: json['lastFeedback'] == null
          ? null
          : VolumeFeedback.values.byName(json['lastFeedback'] as String),
    );
  }
}

class ExerciseAdaptation {
  const ExerciseAdaptation({
    this.setsDelta = 0,
    this.repsDelta = 0,
    this.weightDeltaKg = 0,
  });

  final int setsDelta;
  final int repsDelta;
  final double weightDeltaKg;

  ExerciseAdaptation copyWith({
    int? setsDelta,
    int? repsDelta,
    double? weightDeltaKg,
  }) {
    return ExerciseAdaptation(
      setsDelta: setsDelta ?? this.setsDelta,
      repsDelta: repsDelta ?? this.repsDelta,
      weightDeltaKg: weightDeltaKg ?? this.weightDeltaKg,
    );
  }

  Map<String, dynamic> toJson() => {
        'setsDelta': setsDelta,
        'repsDelta': repsDelta,
        'weightDeltaKg': weightDeltaKg,
      };

  factory ExerciseAdaptation.fromJson(Map<String, dynamic> json) =>
      ExerciseAdaptation(
        setsDelta: (json['setsDelta'] as num?)?.toInt() ?? 0,
        repsDelta: (json['repsDelta'] as num?)?.toInt() ?? 0,
        weightDeltaKg: (json['weightDeltaKg'] as num?)?.toDouble() ?? 0,
      );
}

String homeEquipmentLabel(HomeEquipment e) => switch (e) {
      HomeEquipment.none => '无器械',
      HomeEquipment.dumbbell => '哑铃',
      HomeEquipment.resistanceBand => '弹力带',
      HomeEquipment.pullUpBar => '单杠/门上引体杆',
      HomeEquipment.bench => '卧推凳',
      HomeEquipment.kettlebell => '壶铃',
    };

String volumeFeedbackLabel(VolumeFeedback f) => switch (f) {
      VolumeFeedback.tooLittle => '太少',
      VolumeFeedback.justRight => '刚好',
      VolumeFeedback.tooMuch => '太多',
    };
