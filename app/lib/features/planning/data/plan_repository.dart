import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart' hide YogaSequence;
import '../../weight/domain/weight_log.dart';
import '../domain/exercise_id_attach.dart';
import '../domain/goal_classifier.dart';
import '../domain/meal_plan_builder.dart';
import '../domain/models.dart';
import '../domain/plan_composer.dart';
import '../domain/prescription_engine.dart';
import '../domain/volume_adapter.dart';

class PlanRepository {
  PlanRepository(
    this.db, {
    this.volumeAdapter = const VolumeAdapter(),
  });

  final AppDatabase db;
  final VolumeAdapter volumeAdapter;

  Stream<bool> watchOnboardingDone() {
    return (db.select(db.userProfiles)..where((t) => t.id.equals(1)))
        .watchSingleOrNull()
        .map((r) => r?.onboardingDone ?? false);
  }

  Stream<UserProfile?> watchProfile() {
    return (db.select(db.userProfiles)..where((t) => t.id.equals(1)))
        .watchSingleOrNull()
        .map((r) {
      if (r == null) return null;
      return UserProfile.fromJson(jsonDecode(r.json) as Map<String, dynamic>);
    });
  }

  Stream<ActivePlan?> watchActivePlan() {
    return db.select(db.activePlans).watch().map((rows) {
      if (rows.isEmpty) return null;
      rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return ActivePlan.fromJson(
        jsonDecode(rows.first.json) as Map<String, dynamic>,
      );
    });
  }

  Future<UserProfile?> getProfile() async {
    final r = await (db.select(db.userProfiles)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    if (r == null) return null;
    return UserProfile.fromJson(jsonDecode(r.json) as Map<String, dynamic>);
  }

  Future<ActivePlan?> getActivePlan() async {
    final rows = await db.select(db.activePlans).get();
    if (rows.isEmpty) return null;
    rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ActivePlan.fromJson(
      jsonDecode(rows.first.json) as Map<String, dynamic>,
    );
  }

  Future<void> saveProfile(UserProfile profile, {bool onboardingDone = true}) async {
    await db.into(db.userProfiles).insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: const Value(1),
            json: jsonEncode(profile.toJson()),
            onboardingDone: Value(onboardingDone),
          ),
        );
  }

  /// 完整重生成：力量队列、cursor→0、adaptation 清空。
  ///
  /// 仅在场所/器械/分化/目标/基线变化，或用户明确点「重新生成计划」时使用。
  Future<ActivePlan> regeneratePlan(UserProfile profile) async {
    final composer = await _composer();
    final plan = await _withExerciseIds(composer.compose(profile));
    await _persistPlan(plan);
    await saveProfile(profile, onboardingDone: true);
    return plan;
  }

  /// 一次性/seed 后回填：按动作名写入 exerciseId（不按名导航，只在此落盘）。
  ///
  /// seed 重灌后 id 可能变化，故每次 ensure 后按名对齐当前动作库。
  Future<void> ensurePlanExerciseIds() async {
    final plan = await getActivePlan();
    if (plan == null) return;
    final byName = await _exerciseIdsByName();
    if (!planNeedsExerciseIdAttach(plan, byName)) return;
    final updated = attachExerciseIdsToPlan(plan, byName);
    await _persistPlanSessions(updated);
  }

  /// 只更新有氧/瑜伽策略（及饮食热量摊销），保留力量队列进度与负荷适应。
  Future<ActivePlan?> updatePolicies(UserProfile profile) async {
    final existing = await getActivePlan();
    if (existing == null) {
      await saveProfile(profile, onboardingDone: true);
      return null;
    }
    final composer = await _composer();
    final updated = composer.updatePolicies(existing, profile);
    await saveProfile(profile, onboardingDone: true);
    await _persistPlanSessions(updated);
    return updated;
  }

  /// 按当前资料刷新饮食宏量/餐序与目标，保留力量队列进度。
  Future<ActivePlan?> refreshDiet(UserProfile profile) async {
    final existing = await getActivePlan();
    if (existing == null) {
      return regeneratePlan(profile);
    }
    final composer = await _composer();
    final updated = composer.refreshDiet(existing, profile);
    await saveProfile(profile, onboardingDone: true);
    await _persistPlanSessions(updated);
    return updated;
  }

  Future<int> currentDietRulesVersion() async {
    final dietRow =
        await (db.select(db.dietRulesStore)..where((t) => t.id.equals(1)))
            .getSingleOrNull();
    if (dietRow == null) return 0;
    final raw = jsonDecode(dietRow.json) as Map<String, dynamic>;
    return (raw['version'] as num?)?.toInt() ?? 0;
  }

  Future<Map<String, dynamic>> dietRulesRaw() async {
    final dietRow =
        await (db.select(db.dietRulesStore)..where((t) => t.id.equals(1)))
            .getSingle();
    return jsonDecode(dietRow.json) as Map<String, dynamic>;
  }

  Future<List<FoodRate>> foodRates() async {
    final rows = await db.select(db.foods).get();
    return rows
        .map(
          (f) => FoodRate(
            name: f.name,
            category: f.category,
            rate: f.rate,
            macroHint: f.macroHint,
            note: f.note,
          ),
        )
        .toList();
  }

  Future<void> _persistPlan(ActivePlan plan) async {
    await db.transaction(() async {
      await db.delete(db.activePlans).go();
      await db.delete(db.plannedSessions).go();
      await db.into(db.activePlans).insert(
            ActivePlansCompanion.insert(
              id: plan.id,
              json: jsonEncode(plan.toJson()),
              createdAt: DateTime.now(),
            ),
          );
      for (final s in plan.sessions) {
        await db.into(db.plannedSessions).insert(
              PlannedSessionsCompanion.insert(
                id: s.id,
                planId: plan.id,
                sequenceIndex: s.sequenceIndex,
                type: s.type.name,
                json: jsonEncode(s.toJson()),
              ),
            );
      }
    });
  }

  Future<Map<String, int>> _exerciseIdsByName() async {
    final rows = await db.select(db.exercises).get();
    return {for (final e in rows) e.name: e.id};
  }

  Future<ActivePlan> _withExerciseIds(ActivePlan plan) async {
    return attachExerciseIdsToPlan(plan, await _exerciseIdsByName());
  }

  Future<PlanComposer> _composer() async {
    final tpls = await db.select(db.splitTemplates).get();
    final templates = tpls
        .map(
          (t) => SplitTemplateView.fromJson(
            jsonDecode(t.json) as Map<String, dynamic>,
          ),
        )
        .toList();
    final dietRow =
        await (db.select(db.dietRulesStore)..where((t) => t.id.equals(1)))
            .getSingle();
    final yogaRows = await db.select(db.yogaSequences).get();
    final yogaSequences = yogaRows
        .map(
          (r) => YogaSequence.fromJson(
            jsonDecode(r.json) as Map<String, dynamic>,
          ),
        )
        .toList();
    return PlanComposer(
      templates: templates,
      dietRules: DietRulesView(jsonDecode(dietRow.json) as Map<String, dynamic>),
      yogaSequences: yogaSequences,
      classifier: const GoalClassifier(),
      prescription: const PrescriptionEngine(),
    );
  }

  Future<PlannedSession?> sessionById(String id) async {
    final row = await (db.select(db.plannedSessions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return PlannedSession.fromJson(jsonDecode(row.json) as Map<String, dynamic>);
  }

  /// 队列中下一待练（由 cursor 决定，与日历无关）。
  Future<PlannedSession?> nextPendingSession() async {
    final plan = await getActivePlan();
    return plan?.nextSession;
  }

  Future<WorkoutLog?> logForSession(String sessionId) async {
    final row = await (db.select(db.workoutLogs)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
    if (row.isEmpty) return null;
    return WorkoutLog.fromJson(jsonDecode(row.first.json) as Map<String, dynamic>);
  }

  Future<List<WorkoutLog>> logsForDate(String date) async {
    final rows = await (db.select(db.workoutLogs)
          ..where((t) => t.date.equals(date))
          ..where((t) => t.status.equals(CompletionStatus.completed.name))
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
    return rows
        .map((r) => WorkoutLog.fromJson(jsonDecode(r.json) as Map<String, dynamic>))
        .toList();
  }

  Future<WorkoutLog?> logForDate(String date) async {
    final logs = await logsForDate(date);
    if (logs.isEmpty) return null;
    // 优先展示力量记录
    return logs.firstWhere(
      (l) => l.type == DayType.strength,
      orElse: () => logs.first,
    );
  }

  /// 日历：按日期汇总已完成日志类型（不读未来计划）。
  Future<Map<String, DayType>> loggedDayTypesInRange(String from, String to) async {
    final rows = await (db.select(db.workoutLogs)
          ..where((t) => t.date.isBiggerOrEqualValue(from))
          ..where((t) => t.date.isSmallerOrEqualValue(to))
          ..where((t) => t.status.equals(CompletionStatus.completed.name)))
        .get();
    final map = <String, DayType>{};
    for (final r in rows) {
      final type = DayType.values.byName(r.type);
      final prev = map[r.date];
      if (prev == null || _dayTypeRank(type) > _dayTypeRank(prev)) {
        map[r.date] = type;
      }
    }
    return map;
  }

  /// 日历色块优先级：力量 > 瑜伽 > 有氧 > 休息
  static int _dayTypeRank(DayType t) => switch (t) {
        DayType.strength => 4,
        DayType.yoga => 3,
        DayType.cardio => 2,
        DayType.rest => 1,
      };

  /// 完成力量（或可选有氧记录）：记录反馈、适配后续处方、推进队列 cursor。
  Future<void> completeSession({
    required PlannedSession session,
    required List<LoggedExercise> exercises,
    String note = '',
    DateTime? completedOn,
    bool advanceCursor = true,
    VolumeFeedback? volumeFeedback,
  }) async {
    final when = completedOn ?? DateTime.now();
    final date = _fmt(when);
    final log = WorkoutLog(
      id: 'log_${when.millisecondsSinceEpoch}',
      sessionId: session.id,
      date: date,
      type: session.type,
      status: CompletionStatus.completed,
      exercises: exercises,
      note: note,
      title: session.title,
      completedAt: when.toIso8601String(),
      volumeFeedback: volumeFeedback,
    );
    await db.transaction(() async {
      await db.into(db.workoutLogs).insertOnConflictUpdate(
            WorkoutLogsCompanion.insert(
              id: log.id,
              sessionId: log.sessionId,
              date: log.date,
              type: log.type.name,
              status: log.status.name,
              json: jsonEncode(log.toJson()),
              completedAt: when,
            ),
          );
      if (session.type == DayType.strength) {
        final plan = await getActivePlan();
        if (plan != null && plan.sessions.isNotEmpty) {
          var updated = volumeAdapter.adaptAfterSession(
            plan: plan,
            completedSession: session,
            logged: exercises,
            feedback: volumeFeedback,
          );
          if (advanceCursor) {
            final next = (updated.cursorIndex + 1) % updated.sessions.length;
            updated = updated.copyWith(cursorIndex: next);
          }
          await _persistPlanSessions(updated);
        }
      }
    });
  }

  /// 更新 ActivePlan JSON，并同步 planned_sessions 表中的动作处方。
  Future<void> _persistPlanSessions(ActivePlan plan) async {
    await (db.update(db.activePlans)..where((t) => t.id.equals(plan.id))).write(
      ActivePlansCompanion(json: Value(jsonEncode(plan.toJson()))),
    );
    for (final s in plan.sessions) {
      await (db.update(db.plannedSessions)..where((t) => t.id.equals(s.id)))
          .write(
        PlannedSessionsCompanion(json: Value(jsonEncode(s.toJson()))),
      );
    }
  }

  /// 更新基线/器械；可选把新处方应用到当前计划后续会话。
  Future<void> updateCapacityAndEquipment({
    required CapacityBaseline capacity,
    required List<HomeEquipment> homeEquipment,
    bool applyToUpcoming = false,
  }) async {
    final profile = await getProfile();
    if (profile == null) return;
    final next = profile.copyWith(
      capacity: capacity,
      homeEquipment: homeEquipment,
    );
    await saveProfile(next);
    if (!applyToUpcoming) return;
    await regeneratePlan(next);
  }

  /// 今天休息：记一条休息日志，不推进分化队列。
  Future<void> logRestDay({String note = '今天休息', DateTime? on}) async {
    final when = on ?? DateTime.now();
    final date = _fmt(when);
    final log = WorkoutLog(
      id: 'log_rest_${when.millisecondsSinceEpoch}',
      sessionId: 'rest',
      date: date,
      type: DayType.rest,
      status: CompletionStatus.completed,
      exercises: const [],
      note: note,
      title: '休息',
      completedAt: when.toIso8601String(),
    );
    await db.into(db.workoutLogs).insertOnConflictUpdate(
          WorkoutLogsCompanion.insert(
            id: log.id,
            sessionId: log.sessionId,
            date: log.date,
            type: log.type.name,
            status: log.status.name,
            json: jsonEncode(log.toJson()),
            completedAt: when,
          ),
        );
  }

  /// 随时可记的有氧（不推进力量队列）。
  Future<void> logCardio({
    required String name,
    required int minutes,
    String note = '',
    DateTime? on,
  }) async {
    final when = on ?? DateTime.now();
    final date = _fmt(when);
    final log = WorkoutLog(
      id: 'log_cardio_${when.millisecondsSinceEpoch}',
      sessionId: 'cardio',
      date: date,
      type: DayType.cardio,
      status: CompletionStatus.completed,
      exercises: const [],
      note: note.isEmpty ? '$name · $minutes 分钟' : note,
      title: name,
      completedAt: when.toIso8601String(),
    );
    await db.into(db.workoutLogs).insertOnConflictUpdate(
          WorkoutLogsCompanion.insert(
            id: log.id,
            sessionId: log.sessionId,
            date: log.date,
            type: log.type.name,
            status: log.status.name,
            json: jsonEncode(log.toJson()),
            completedAt: when,
          ),
        );
  }

  /// 记录瑜伽/恢复（不推进力量队列；日历显示为 yoga）。
  Future<void> logYoga({
    required String title,
    required int minutes,
    String sequenceId = '',
    String note = '',
    DateTime? on,
  }) async {
    final when = on ?? DateTime.now();
    final date = _fmt(when);
    final log = WorkoutLog(
      id: 'log_yoga_${when.millisecondsSinceEpoch}',
      sessionId: sequenceId.isEmpty ? 'yoga' : sequenceId,
      date: date,
      type: DayType.yoga,
      status: CompletionStatus.completed,
      exercises: const [],
      note: note.isEmpty ? '$title · $minutes 分钟' : note,
      title: title,
      completedAt: when.toIso8601String(),
    );
    await db.into(db.workoutLogs).insertOnConflictUpdate(
          WorkoutLogsCompanion.insert(
            id: log.id,
            sessionId: log.sessionId,
            date: log.date,
            type: log.type.name,
            status: log.status.name,
            json: jsonEncode(log.toJson()),
            completedAt: when,
          ),
        );
  }

  Future<Map<String, dynamic>> exportBackup() async {
    final profile = await getProfile();
    final plan = await getActivePlan();
    final logs = await db.select(db.workoutLogs).get();
    final weightLogs = await (db.select(db.weightLogs)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return {
      'version': 3,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profile?.toJson(),
      'activePlan': plan?.toJson(),
      'logs': logs
          .map((e) => jsonDecode(e.json) as Map<String, dynamic>)
          .toList(),
      'weightLogs': weightLogs
          .map(
            (e) => WeightLog(
              date: e.date,
              weightKg: e.weightKg,
              loggedAt: e.loggedAt,
            ).toJson(),
          )
          .toList(),
    };
  }

  Future<void> updateWeight(double weightKg) async {
    final profile = await getProfile();
    if (profile == null) return;
    await saveProfile(profile.copyWith(weightKg: weightKg));
  }

  /// 按日 upsert 体重；若该日 ≥ 已有最新日志日（或为首条），同步资料体重。
  Future<void> upsertWeightLog(DateTime date, double weightKg) async {
    final dateKey = _fmt(date);
    final now = DateTime.now();
    await db.into(db.weightLogs).insertOnConflictUpdate(
          WeightLogsCompanion.insert(
            date: dateKey,
            weightKg: weightKg,
            loggedAt: now,
          ),
        );

    final latest = await (db.select(db.weightLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .getSingleOrNull();
    if (latest == null || dateKey.compareTo(latest.date) >= 0) {
      await updateWeight(weightKg);
    }
  }

  Stream<List<WeightLog>> watchWeightLogs() {
    return (db.select(db.weightLogs)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch()
        .map(
          (rows) => [
            for (final r in rows)
              WeightLog(
                date: r.date,
                weightKg: r.weightKg,
                loggedAt: r.loggedAt,
              ),
          ],
        );
  }

  Future<List<WeightLog>> weightLogsInRange(DateTime from, DateTime to) async {
    final fromKey = _fmt(from);
    final toKey = _fmt(to);
    final rows = await (db.select(db.weightLogs)
          ..where((t) => t.date.isBiggerOrEqualValue(fromKey))
          ..where((t) => t.date.isSmallerOrEqualValue(toKey))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return [
      for (final r in rows)
        WeightLog(
          date: r.date,
          weightKg: r.weightKg,
          loggedAt: r.loggedAt,
        ),
    ];
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
