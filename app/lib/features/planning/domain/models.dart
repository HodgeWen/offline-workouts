import 'capacity.dart';
import 'cardio_policy.dart';
import 'yoga_policy.dart';

export 'capacity.dart';
export 'cardio_policy.dart';
export 'yoga_policy.dart';

enum Sex { male, female }

enum Experience { beginner, intermediate, advanced }

enum Place { gym, home }

enum TrainingSlot {
  afterBreakfastEarly,
  afterBreakfastLate,
  beforeLunch,
  afterLunch,
  beforeDinner,
  afterDinner,
  night,
}

enum Goal { cut, bulk }

enum GoalPreference { auto, cut, bulk, preferCut, preferBulk }

/// 日类型；yoga/cardio 可作为可选恢复记录进日历历史，不强制排期。
enum DayType { strength, cardio, rest, yoga }

enum CompletionStatus { planned, completed, skipped }

enum CardioPreference { none, walk, run, bike, swim, other }

class UserProfile {
  const UserProfile({
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.age,
    required this.experience,
    required this.place,
    required this.daysPerWeek,
    required this.trainingSlot,
    this.includeCardio = false,
    this.cardioPreference = CardioPreference.none,
    this.cardioMinutes = 30,
    this.includeYoga = false,
    this.injuries = '',
    this.dietRestrictions = '',
    this.goalPreference = GoalPreference.auto,
    this.capacity = const CapacityBaseline(),
    this.homeEquipment = const [HomeEquipment.none],
  });

  final Sex sex;
  final double heightCm;
  final double weightKg;
  final int age;
  final Experience experience;
  final Place place;
  final int daysPerWeek;
  final TrainingSlot trainingSlot;
  final bool includeCardio;
  final CardioPreference cardioPreference;
  final int cardioMinutes;
  /// 瑜伽/恢复兴趣；女性引导页默认建议开启。
  final bool includeYoga;
  final String injuries;
  final String dietRestrictions;
  final GoalPreference goalPreference;
  final CapacityBaseline capacity;
  /// 居家器械多选；健身房可忽略。
  final List<HomeEquipment> homeEquipment;

  UserProfile copyWith({
    Sex? sex,
    double? heightCm,
    double? weightKg,
    int? age,
    Experience? experience,
    Place? place,
    int? daysPerWeek,
    TrainingSlot? trainingSlot,
    bool? includeCardio,
    CardioPreference? cardioPreference,
    int? cardioMinutes,
    bool? includeYoga,
    String? injuries,
    String? dietRestrictions,
    GoalPreference? goalPreference,
    CapacityBaseline? capacity,
    List<HomeEquipment>? homeEquipment,
  }) {
    return UserProfile(
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      experience: experience ?? this.experience,
      place: place ?? this.place,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      trainingSlot: trainingSlot ?? this.trainingSlot,
      includeCardio: includeCardio ?? this.includeCardio,
      cardioPreference: cardioPreference ?? this.cardioPreference,
      cardioMinutes: cardioMinutes ?? this.cardioMinutes,
      includeYoga: includeYoga ?? this.includeYoga,
      injuries: injuries ?? this.injuries,
      dietRestrictions: dietRestrictions ?? this.dietRestrictions,
      goalPreference: goalPreference ?? this.goalPreference,
      capacity: capacity ?? this.capacity,
      homeEquipment: homeEquipment ?? this.homeEquipment,
    );
  }

  Map<String, dynamic> toJson() => {
        'sex': sex.name,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'age': age,
        'experience': experience.name,
        'place': place.name,
        'daysPerWeek': daysPerWeek,
        'trainingSlot': trainingSlot.name,
        'includeCardio': includeCardio,
        'cardioPreference': cardioPreference.name,
        'cardioMinutes': cardioMinutes,
        'includeYoga': includeYoga,
        'injuries': injuries,
        'dietRestrictions': dietRestrictions,
        'goalPreference': goalPreference.name,
        'capacity': capacity.toJson(),
        'homeEquipment': homeEquipment.map((e) => e.name).toList(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        sex: Sex.values.byName(json['sex'] as String),
        heightCm: (json['heightCm'] as num).toDouble(),
        weightKg: (json['weightKg'] as num).toDouble(),
        age: (json['age'] as num).toInt(),
        experience: Experience.values.byName(json['experience'] as String),
        place: Place.values.byName(json['place'] as String),
        daysPerWeek: (json['daysPerWeek'] as num).toInt(),
        trainingSlot: TrainingSlot.values.byName(json['trainingSlot'] as String),
        includeCardio: json['includeCardio'] as bool? ?? false,
        cardioPreference: CardioPreference.values.byName(
          json['cardioPreference'] as String? ?? 'none',
        ),
        cardioMinutes: (json['cardioMinutes'] as num?)?.toInt() ?? 30,
        includeYoga: json['includeYoga'] as bool? ?? false,
        injuries: json['injuries'] as String? ?? '',
        dietRestrictions: json['dietRestrictions'] as String? ?? '',
        goalPreference: GoalPreference.values.byName(
          json['goalPreference'] as String? ?? 'auto',
        ),
        capacity: CapacityBaseline.fromJson(
          json['capacity'] as Map<String, dynamic>?,
        ),
        homeEquipment: _parseHomeEquipment(json['homeEquipment']),
      );
}

List<HomeEquipment> _parseHomeEquipment(Object? raw) {
  if (raw is! List || raw.isEmpty) return const [HomeEquipment.none];
  final parsed = <HomeEquipment>[];
  for (final e in raw) {
    final name = e as String?;
    if (name == null) continue;
    parsed.add(HomeEquipment.values.byName(name));
  }
  return parsed.isEmpty ? const [HomeEquipment.none] : parsed;
}

class MacroTargets {
  const MacroTargets({
    required this.calories,
    required this.carbG,
    required this.proteinG,
    required this.fatG,
  });

  final int calories;
  final double carbG;
  final double proteinG;
  final double fatG;

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'carbG': carbG,
        'proteinG': proteinG,
        'fatG': fatG,
      };

  factory MacroTargets.fromJson(Map<String, dynamic> json) => MacroTargets(
        calories: (json['calories'] as num).toInt(),
        carbG: (json['carbG'] as num).toDouble(),
        proteinG: (json['proteinG'] as num).toDouble(),
        fatG: (json['fatG'] as num).toDouble(),
      );
}

class MealSlot {
  const MealSlot({
    required this.name,
    required this.role,
    required this.carbShare,
    required this.proteinShare,
    this.note = '',
  });

  final String name;
  final String role;
  final double carbShare;
  final double proteinShare;
  final String note;

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'carbShare': carbShare,
        'proteinShare': proteinShare,
        'note': note,
      };

  factory MealSlot.fromJson(Map<String, dynamic> json) => MealSlot(
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? 'other',
        carbShare: (json['carbShare'] as num?)?.toDouble() ?? 0.25,
        proteinShare: (json['proteinShare'] as num?)?.toDouble() ?? 0.25,
        note: json['note'] as String? ?? '',
      );
}

class PlannedExercise {
  const PlannedExercise({
    required this.name,
    required this.region,
    required this.targetSets,
    this.repsMin = 8,
    this.repsMax = 12,
    this.joints = const [],
    this.targetWeightKg,
    this.note = '',
    this.exerciseId,
  });

  final String name;
  final String region;
  final int targetSets;
  final int repsMin;
  final int repsMax;
  final List<String> joints;
  /// 有配重动作的建议起始重量；自重可空。
  final double? targetWeightKg;
  /// 个性化说明（为何是这组次数）。
  final String note;
  /// 动作库主键；生成/回填时写入，导航详情用 id 而非按名匹配。
  final int? exerciseId;

  PlannedExercise copyWith({
    String? name,
    String? region,
    int? targetSets,
    int? repsMin,
    int? repsMax,
    List<String>? joints,
    double? targetWeightKg,
    bool clearWeight = false,
    String? note,
    int? exerciseId,
    bool clearExerciseId = false,
  }) {
    return PlannedExercise(
      name: name ?? this.name,
      region: region ?? this.region,
      targetSets: targetSets ?? this.targetSets,
      repsMin: repsMin ?? this.repsMin,
      repsMax: repsMax ?? this.repsMax,
      joints: joints ?? this.joints,
      targetWeightKg:
          clearWeight ? null : (targetWeightKg ?? this.targetWeightKg),
      note: note ?? this.note,
      exerciseId:
          clearExerciseId ? null : (exerciseId ?? this.exerciseId),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'targetSets': targetSets,
        'repsMin': repsMin,
        'repsMax': repsMax,
        'joints': joints,
        'targetWeightKg': targetWeightKg,
        'note': note,
        if (exerciseId != null) 'exerciseId': exerciseId,
      };

  factory PlannedExercise.fromJson(Map<String, dynamic> json) =>
      PlannedExercise(
        name: json['name'] as String? ?? '',
        region: json['region'] as String? ?? '',
        targetSets: (json['targetSets'] as num?)?.toInt() ?? 3,
        repsMin: (json['repsMin'] as num?)?.toInt() ?? 8,
        repsMax: (json['repsMax'] as num?)?.toInt() ?? 12,
        joints: (json['joints'] as List? ?? []).cast<String>(),
        targetWeightKg: (json['targetWeightKg'] as num?)?.toDouble(),
        note: json['note'] as String? ?? '',
        exerciseId: (json['exerciseId'] as num?)?.toInt(),
      );
}

/// 计划队列中的一次训练（不绑定日历日期）。
class PlannedSession {
  const PlannedSession({
    required this.id,
    required this.sequenceIndex,
    required this.type,
    this.title = '',
    this.regions = const [],
    this.exercises = const [],
  });

  final String id;
  /// 在分化循环中的序号（0-based）。
  final int sequenceIndex;
  final DayType type;
  final String title;
  final List<String> regions;
  final List<PlannedExercise> exercises;

  PlannedSession copyWith({List<PlannedExercise>? exercises}) {
    return PlannedSession(
      id: id,
      sequenceIndex: sequenceIndex,
      type: type,
      title: title,
      regions: regions,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sequenceIndex': sequenceIndex,
        'type': type.name,
        'title': title,
        'regions': regions,
        'exercises': exercises.map((e) => e.toJson()).toList(),
      };

  factory PlannedSession.fromJson(Map<String, dynamic> json) {
    return PlannedSession(
      id: json['id'] as String,
      sequenceIndex: (json['sequenceIndex'] as num).toInt(),
      type: DayType.values.byName(json['type'] as String),
      title: json['title'] as String? ?? '',
      regions: (json['regions'] as List? ?? []).cast<String>(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => PlannedExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 顺序队列计划：sessions 为一轮分化模板，cursor 指向下一练。
class ActivePlan {
  const ActivePlan({
    required this.id,
    required this.goal,
    required this.templateId,
    required this.createdDate,
    required this.cursorIndex,
    required this.trainingMacros,
    required this.restMacros,
    required this.trainingMeals,
    required this.restMeals,
    required this.sessions,
    this.cardioPolicy = const CardioPolicy(
      enabled: false,
      modality: '',
      minutesPerSession: 0,
      weeklyMinutesTarget: 0,
      intensity: 'none',
      guidance: '',
    ),
    this.yogaPolicy = const YogaPolicy(
      enabled: false,
      sequenceId: '',
      sequenceTitle: '',
      durationMinutes: 0,
      offerMode: 'none',
      guidance: '',
    ),
    required this.bmr,
    required this.tdee,
    this.adaptation = const VolumeAdaptationState(),
    this.dietRulesVersion = 0,
  });

  final String id;
  final Goal goal;
  final String templateId;
  /// 计划生成日（仅作记录，不用于排期）。
  final String createdDate;
  /// 下一待练在 [sessions] 中的下标；完成力量后前进并循环。
  final int cursorIndex;
  final MacroTargets trainingMacros;
  final MacroTargets restMacros;
  final List<MealSlot> trainingMeals;
  final List<MealSlot> restMeals;
  /// 一轮力量分化序列（无休息日、无日历占位）。
  final List<PlannedSession> sessions;
  final CardioPolicy cardioPolicy;
  final YogaPolicy yogaPolicy;
  final double bmr;
  final double tdee;
  final VolumeAdaptationState adaptation;
  /// 生成时 diet_rules.version；用于提示旧计划需重生成饮食。
  final int dietRulesVersion;

  PlannedSession? get nextSession {
    if (sessions.isEmpty) return null;
    final i = cursorIndex % sessions.length;
    return sessions[i];
  }

  ActivePlan copyWith({
    Goal? goal,
    int? cursorIndex,
    List<PlannedSession>? sessions,
    VolumeAdaptationState? adaptation,
    CardioPolicy? cardioPolicy,
    YogaPolicy? yogaPolicy,
    MacroTargets? trainingMacros,
    MacroTargets? restMacros,
    List<MealSlot>? trainingMeals,
    List<MealSlot>? restMeals,
    double? bmr,
    double? tdee,
    int? dietRulesVersion,
  }) {
    return ActivePlan(
      id: id,
      goal: goal ?? this.goal,
      templateId: templateId,
      createdDate: createdDate,
      cursorIndex: cursorIndex ?? this.cursorIndex,
      trainingMacros: trainingMacros ?? this.trainingMacros,
      restMacros: restMacros ?? this.restMacros,
      trainingMeals: trainingMeals ?? this.trainingMeals,
      restMeals: restMeals ?? this.restMeals,
      sessions: sessions ?? this.sessions,
      cardioPolicy: cardioPolicy ?? this.cardioPolicy,
      yogaPolicy: yogaPolicy ?? this.yogaPolicy,
      bmr: bmr ?? this.bmr,
      tdee: tdee ?? this.tdee,
      adaptation: adaptation ?? this.adaptation,
      dietRulesVersion: dietRulesVersion ?? this.dietRulesVersion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'goal': goal.name,
        'templateId': templateId,
        'createdDate': createdDate,
        'cursorIndex': cursorIndex,
        'trainingMacros': trainingMacros.toJson(),
        'restMacros': restMacros.toJson(),
        'trainingMeals': trainingMeals.map((e) => e.toJson()).toList(),
        'restMeals': restMeals.map((e) => e.toJson()).toList(),
        'sessions': sessions.map((e) => e.toJson()).toList(),
        'cardioPolicy': cardioPolicy.toJson(),
        'yogaPolicy': yogaPolicy.toJson(),
        'bmr': bmr,
        'tdee': tdee,
        'adaptation': adaptation.toJson(),
        'dietRulesVersion': dietRulesVersion,
      };

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    return ActivePlan(
      id: json['id'] as String,
      goal: Goal.values.byName(json['goal'] as String),
      templateId: json['templateId'] as String,
      createdDate: json['createdDate'] as String,
      cursorIndex: (json['cursorIndex'] as num).toInt(),
      trainingMacros: MacroTargets.fromJson(
        json['trainingMacros'] as Map<String, dynamic>,
      ),
      restMacros: MacroTargets.fromJson(
        json['restMacros'] as Map<String, dynamic>,
      ),
      trainingMeals: (json['trainingMeals'] as List? ?? [])
          .map((e) => MealSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      restMeals: (json['restMeals'] as List? ?? [])
          .map((e) => MealSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      sessions: (json['sessions'] as List? ?? [])
          .map((e) => PlannedSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      cardioPolicy: CardioPolicy.fromJson(
        json['cardioPolicy'] as Map<String, dynamic>?,
      ),
      yogaPolicy: YogaPolicy.fromJson(
        json['yogaPolicy'] as Map<String, dynamic>?,
      ),
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      adaptation: VolumeAdaptationState.fromJson(
        json['adaptation'] as Map<String, dynamic>?,
      ),
      dietRulesVersion: (json['dietRulesVersion'] as num?)?.toInt() ?? 0,
    );
  }
}

class LoggedSet {
  const LoggedSet({this.weightKg = 0, this.reps = 0});

  final double weightKg;
  final int reps;

  /// 单组容量：有配重用 kg×reps；自重用 reps（便于相对比较）。
  double get volume => weightKg > 0 ? weightKg * reps : reps.toDouble();

  Map<String, dynamic> toJson() => {'weightKg': weightKg, 'reps': reps};

  factory LoggedSet.fromJson(Map<String, dynamic> json) => LoggedSet(
        weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
        reps: (json['reps'] as num?)?.toInt() ?? 0,
      );
}

class LoggedExercise {
  const LoggedExercise({
    required this.name,
    required this.region,
    required this.sets,
    this.prescribedSets,
    this.prescribedRepsMin,
    this.prescribedRepsMax,
    this.prescribedWeightKg,
    this.exerciseId,
  });

  final String name;
  final String region;
  final List<LoggedSet> sets;

  /// 完成时快照的处方（写入 WorkoutLog JSON，供渐进与回顾）。
  final int? prescribedSets;
  final int? prescribedRepsMin;
  final int? prescribedRepsMax;
  final double? prescribedWeightKg;
  /// 动作库主键快照（与处方一致，便于回顾时跳转详情）。
  final int? exerciseId;

  /// 实际总容量（有配重 Σkg×reps；自重 Σreps）。
  double get loggedVolume =>
      sets.fold<double>(0, (sum, s) => sum + s.volume);

  /// 处方总容量下限估计（组数 × 下限次数 × 配重）。
  double? get prescribedVolumeMin {
    final setsN = prescribedSets;
    final reps = prescribedRepsMin;
    if (setsN == null || reps == null) return null;
    final w = prescribedWeightKg ?? 0;
    return w > 0 ? setsN * reps * w : (setsN * reps).toDouble();
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'sets': sets.map((e) => e.toJson()).toList(),
        if (prescribedSets != null) 'prescribedSets': prescribedSets,
        if (prescribedRepsMin != null) 'prescribedRepsMin': prescribedRepsMin,
        if (prescribedRepsMax != null) 'prescribedRepsMax': prescribedRepsMax,
        if (prescribedWeightKg != null)
          'prescribedWeightKg': prescribedWeightKg,
        if (exerciseId != null) 'exerciseId': exerciseId,
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> json) => LoggedExercise(
        name: json['name'] as String? ?? '',
        region: json['region'] as String? ?? '',
        sets: (json['sets'] as List? ?? [])
            .map((e) => LoggedSet.fromJson(e as Map<String, dynamic>))
            .toList(),
        prescribedSets: (json['prescribedSets'] as num?)?.toInt(),
        prescribedRepsMin: (json['prescribedRepsMin'] as num?)?.toInt(),
        prescribedRepsMax: (json['prescribedRepsMax'] as num?)?.toInt(),
        prescribedWeightKg: (json['prescribedWeightKg'] as num?)?.toDouble(),
        exerciseId: (json['exerciseId'] as num?)?.toInt(),
      );

  /// 从处方动作生成可编辑/快速完成用的日志草稿（含处方快照）。
  factory LoggedExercise.fromPrescription(
    PlannedExercise e, {
    List<LoggedSet>? sets,
  }) {
    return LoggedExercise(
      name: e.name,
      region: e.region,
      sets: sets ??
          List.generate(
            e.targetSets,
            (_) => LoggedSet(
              weightKg: e.targetWeightKg ?? 0,
              reps: e.repsMin,
            ),
          ),
      prescribedSets: e.targetSets,
      prescribedRepsMin: e.repsMin,
      prescribedRepsMax: e.repsMax,
      prescribedWeightKg: e.targetWeightKg,
      exerciseId: e.exerciseId,
    );
  }
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.sessionId,
    required this.date,
    required this.type,
    required this.status,
    required this.exercises,
    this.note = '',
    this.title = '',
    required this.completedAt,
    this.volumeFeedback,
  });

  final String id;
  final String sessionId;
  /// 实际完成/记录的日历日 yyyy-MM-dd。
  final String date;
  final DayType type;
  final CompletionStatus status;
  final List<LoggedExercise> exercises;
  final String note;
  final String title;
  final String completedAt;
  final VolumeFeedback? volumeFeedback;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'date': date,
        'type': type.name,
        'status': status.name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'note': note,
        'title': title,
        'completedAt': completedAt,
        'volumeFeedback': volumeFeedback?.name,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        id: json['id'] as String,
        sessionId: json['sessionId'] as String,
        date: json['date'] as String,
        type: DayType.values.byName(json['type'] as String),
        status: CompletionStatus.values.byName(json['status'] as String),
        exercises: (json['exercises'] as List? ?? [])
            .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        note: json['note'] as String? ?? '',
        title: json['title'] as String? ?? '',
        completedAt: json['completedAt'] as String? ?? '',
        volumeFeedback: json['volumeFeedback'] == null
            ? null
            : VolumeFeedback.values.byName(json['volumeFeedback'] as String),
      );
}
