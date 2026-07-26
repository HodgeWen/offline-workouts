import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/planning/data/plan_repository.dart';
import '../../features/planning/domain/models.dart';
import '../../features/weight/domain/weight_log.dart';
import 'app_database.dart';
import 'seed_loader.dart';

const _bootstrapTimeout = Duration(seconds: 45);

/// 打开数据库并灌入 seed。失败时直接进入 error（禁用 Riverpod 自动重试，避免无限转圈）。
final appDatabaseProvider = FutureProvider<AppDatabase>(
  (ref) async {
    final db = await AppDatabase.open().timeout(
      _bootstrapTimeout,
      onTimeout: () =>
          throw TimeoutException('打开本地数据库超时', _bootstrapTimeout),
    );
    // 尽早注册，避免失败重试时泄漏多个 AppDatabase 实例
    ref.onDispose(db.close);
    await SeedLoader(db).ensureSeeded().timeout(
      _bootstrapTimeout,
      onTimeout: () =>
          throw TimeoutException('初始化预置数据超时', _bootstrapTimeout),
    );
    // seed 就绪后一次性按名回填计划中的 exerciseId（导航不再按名查库）
    await PlanRepository(db).ensurePlanExerciseIds().timeout(
      _bootstrapTimeout,
      onTimeout: () =>
          throw TimeoutException('回填动作 id 超时', _bootstrapTimeout),
    );
    return db;
  },
  retry: (retryCount, error) => null,
);

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  final db = ref.watch(appDatabaseProvider).requireValue;
  return PlanRepository(db);
});

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.watchProfile();
});

final onboardingDoneProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.watchOnboardingDone();
});

final activePlanProvider = StreamProvider<ActivePlan?>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.watchActivePlan();
});

/// 队列下一待练（随 ActivePlan.cursorIndex 变化）。
final nextSessionProvider = Provider<AsyncValue<PlannedSession?>>((ref) {
  return ref.watch(activePlanProvider).whenData((plan) => plan?.nextSession);
});

/// 体重日志（按 date 升序）。
final weightLogsProvider = StreamProvider<List<WeightLog>>((ref) {
  final repo = ref.watch(planRepositoryProvider);
  return repo.watchWeightLogs();
});
