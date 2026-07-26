import 'models.dart';

/// 按动作名把动作库 id 写入计划（纯函数，便于测试与一次性回填）。
///
/// 不在运行时做模糊匹配：名对不上则保留 null，由 seed/计划生成保证名称一致。
ActivePlan attachExerciseIdsToPlan(
  ActivePlan plan,
  Map<String, int> nameToId,
) {
  if (nameToId.isEmpty) return plan;
  final sessions = plan.sessions.map((s) {
    final exercises = s.exercises.map((e) {
      final id = nameToId[e.name];
      if (id == null || id == e.exerciseId) return e;
      return e.copyWith(exerciseId: id);
    }).toList();
    return s.copyWith(exercises: exercises);
  }).toList();
  return plan.copyWith(sessions: sessions);
}

/// 是否仍有可解析但尚未写入的 exerciseId（用于判断是否需要落盘）。
bool planNeedsExerciseIdAttach(
  ActivePlan plan,
  Map<String, int> nameToId,
) {
  for (final s in plan.sessions) {
    for (final e in s.exercises) {
      final id = nameToId[e.name];
      if (id != null && e.exerciseId != id) return true;
    }
  }
  return false;
}
