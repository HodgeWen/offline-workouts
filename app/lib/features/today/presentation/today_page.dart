import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/models.dart';
import 'diet_points_card.dart';

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(activePlanProvider);
    final sessionAsync = ref.watch(nextSessionProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final repo = ref.watch(planRepositoryProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('今日'),
        actions: [
          TextButton(
            onPressed: () => _restToday(context, ref),
            child: const Text('今天休息'),
          ),
        ],
      ),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (plan) {
          if (plan == null) {
            return Center(
              child: Text('暂无计划，请先完成引导', style: text.bodyLarge),
            );
          }
          return sessionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败：$e')),
            data: (session) {
              if (session == null) {
                return Center(
                  child: Text('队列为空，请重新生成计划', style: text.bodyLarge),
                );
              }
              final cycleLen = plan.sessions.length;
              final dayNo = (plan.cursorIndex % cycleLen) + 1;

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    '下一练',
                    style: text.labelLarge?.copyWith(
                      color: AppTheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    session.title.isEmpty ? '力量训练' : session.title,
                    style: text.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '分化第 $dayNo / $cycleLen 练 · 组次数已按你的基线能力个性化',
                    style: text.bodyMedium?.copyWith(
                      color: AppTheme.slate.withValues(alpha: 0.72),
                    ),
                  ),
                  if (session.regions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: session.regions
                          .map(
                            (r) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                r,
                                style: text.labelLarge?.copyWith(
                                  color: AppTheme.ink,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  if (plan.cardioPolicy.enabled) ...[
                    const SizedBox(height: 16),
                    _softBlock(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_run,
                                  color:
                                      AppTheme.accent.withValues(alpha: 0.95)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '可选有氧：${plan.cardioPolicy.modality.isNotEmpty ? plan.cardioPolicy.modality : '有氧'}'
                                  ' · ${plan.cardioPolicy.minutesPerSession} 分钟',
                                  style: text.bodyMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await repo.logCardio(
                                    name: plan.cardioPolicy.modality.isNotEmpty
                                        ? plan.cardioPolicy.modality
                                        : '有氧',
                                    minutes:
                                        plan.cardioPolicy.minutesPerSession,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('已记录有氧')),
                                    );
                                  }
                                },
                                child: const Text('记一笔'),
                              ),
                            ],
                          ),
                          if (plan.cardioPolicy.guidance.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              plan.cardioPolicy.guidance,
                              style: text.bodySmall?.copyWith(
                                color: AppTheme.slate.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                          if (plan.cardioPolicy.weeklyMinutesTarget > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '每周目标约 ${plan.cardioPolicy.weeklyMinutesTarget} 分钟'
                                ' · ${plan.cardioPolicy.intensity}',
                                style: text.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (plan.yogaPolicy.enabled) ...[
                    const SizedBox(height: 12),
                    _softBlock(
                      context,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.self_improvement,
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.95)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '今日可选恢复：${plan.yogaPolicy.sequenceTitle}'
                                  ' · ${plan.yogaPolicy.durationMinutes} 分钟',
                                  style: text.bodyMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await repo.logYoga(
                                    title: plan.yogaPolicy.sequenceTitle,
                                    minutes: plan.yogaPolicy.durationMinutes,
                                    sequenceId: plan.yogaPolicy.sequenceId,
                                  );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已记录瑜伽/恢复'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('完成序列'),
                              ),
                            ],
                          ),
                          if (plan.yogaPolicy.guidance.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              plan.yogaPolicy.guidance,
                              style: text.bodySmall?.copyWith(
                                color: AppTheme.slate.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                          if (plan.yogaPolicy.poses.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              plan.yogaPolicy.poses
                                  .take(6)
                                  .map((p) => p.name)
                                  .join(' → '),
                              style: text.bodySmall,
                            ),
                            if (plan.yogaPolicy.poses.length > 6)
                              Text(
                                '…共 ${plan.yogaPolicy.poses.length} 个体式',
                                style: text.bodySmall,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (session.exercises.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text('动作清单', style: text.titleLarge),
                    const SizedBox(height: 10),
                    ...session.exercises.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 36,
                              margin: const EdgeInsets.only(top: 4, right: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name, style: text.titleMedium),
                                  Text(
                                    _prescriptionLine(e),
                                    style: text.bodySmall,
                                  ),
                                  if (e.note.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        e.note,
                                        style: text.bodySmall?.copyWith(
                                          color: AppTheme.slate
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: '查看动作',
                              icon: const Icon(Icons.open_in_new, size: 20),
                              onPressed: () => _openExercise(context, e),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  DietPointsCard(
                    plan: plan,
                    profile: profileAsync.asData?.value,
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: () => _quickComplete(context, ref, session),
                    child: const Text('完成训练'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () =>
                        context.push('/today/edit/${session.id}'),
                    child: const Text('编辑后完成'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _prescriptionLine(PlannedExercise e) {
    final weight = e.targetWeightKg == null
        ? ''
        : ' · ${e.targetWeightKg}kg';
    return '${e.region} · ${e.targetSets} 组 × ${e.repsMin}-${e.repsMax} 次$weight';
  }

  void _openExercise(BuildContext context, PlannedExercise e) {
    final id = e.exerciseId;
    if (id != null) {
      context.push('/exercises/$id');
      return;
    }
    context.push('/exercises');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('动作库中暂无「${e.name}」，已打开列表')),
    );
  }

  Future<void> _quickComplete(
    BuildContext context,
    WidgetRef ref,
    PlannedSession session,
  ) async {
    final feedback = await _askVolumeFeedback(context);
    if (!context.mounted) return;
    final exercises = session.exercises
        .map(LoggedExercise.fromPrescription)
        .toList();
    await ref.read(planRepositoryProvider).completeSession(
          session: session,
          exercises: exercises,
          volumeFeedback: feedback,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已完成；后续处方将按反馈与完成表现微调')),
      );
    }
  }

  Future<VolumeFeedback?> _askVolumeFeedback(BuildContext context) {
    return showModalBottomSheet<VolumeFeedback>(
      context: context,
      backgroundColor: AppTheme.foam,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '当前训练量如何？',
                  style: Theme.of(ctx).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  '用于微调下次组次数/重量，不会重新生成整份计划。',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                for (final f in VolumeFeedback.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, f),
                      child: Text(volumeFeedbackLabel(f)),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('跳过'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _softBlock(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: child,
    );
  }

  Future<void> _restToday(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('今天休息？'),
        content: const Text(
          '只会记下休息，不会消耗下一练。下次打开「今日」仍是同一分化日。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认休息'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(planRepositoryProvider).logRestDay();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已记录休息，队列未前进')),
      );
    }
  }
}
