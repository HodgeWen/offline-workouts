import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/goal_classifier.dart';
import '../../planning/domain/meal_plan_builder.dart';
import '../../planning/domain/models.dart';

/// 「饮食要点」：宏量摘要 + 可执行餐食克数 + 训练日/休息日切换。
class DietPointsCard extends ConsumerStatefulWidget {
  const DietPointsCard({
    super.key,
    required this.plan,
    required this.profile,
  });

  final ActivePlan plan;
  final UserProfile? profile;

  @override
  ConsumerState<DietPointsCard> createState() => _DietPointsCardState();
}

class _DietPointsCardState extends ConsumerState<DietPointsCard> {
  /// null = 尚未加载；默认训练日（今日页以力量队列为主）。
  bool _trainingDay = true;
  DayMealPlan? _dayPlan;
  int? _seedRulesVersion;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rebuild();
  }

  @override
  void didUpdateWidget(covariant DietPointsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.plan.id != widget.plan.id ||
        oldWidget.plan.trainingMacros.proteinG !=
            widget.plan.trainingMacros.proteinG ||
        oldWidget.plan.dietRulesVersion != widget.plan.dietRulesVersion) {
      _rebuild();
    }
  }

  Future<void> _rebuild() async {
    try {
      final repo = ref.read(planRepositoryProvider);
      final foods = await repo.foodRates();
      final rules = await repo.dietRulesRaw();
      final version = (rules['version'] as num?)?.toInt() ?? 0;
      final cfg = rules['mealBuilder'];
      final builder = MealPlanBuilder(
        foods: foods,
        mealBuilderConfig: cfg is Map<String, dynamic> ? cfg : null,
      );
      final macros =
          _trainingDay ? widget.plan.trainingMacros : widget.plan.restMacros;
      final meals =
          _trainingDay ? widget.plan.trainingMeals : widget.plan.restMeals;
      final day = builder.build(
        macros: macros,
        meals: meals,
        goal: widget.plan.goal,
      );
      if (!mounted) return;
      setState(() {
        _dayPlan = day;
        _seedRulesVersion = version;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  bool get _staleDiet {
    final seedV = _seedRulesVersion;
    if (seedV == null) return false;
    if (widget.plan.dietRulesVersion <= 0) return true;
    return widget.plan.dietRulesVersion < seedV;
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final plan = widget.plan;
    final profile = widget.profile;
    final macros =
        _trainingDay ? plan.trainingMacros : plan.restMacros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('饮食要点', style: text.titleLarge),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${goalLabelZh(plan.goal)} · ${macros.calories} kcal · '
                '蛋白 ${macros.proteinG.round()}g · '
                '碳水 ${macros.carbG.round()}g · '
                '脂肪约 ${macros.fatG.round()}g',
                style: text.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                templateLabelZh(plan.templateId),
                style: text.bodySmall?.copyWith(
                  color: AppTheme.slate.withValues(alpha: 0.7),
                ),
              ),
              if (profile != null) ...[
                const SizedBox(height: 4),
                Text(
                  const GoalClassifier().explainZh(profile),
                  style: text.bodySmall,
                ),
              ],
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('训练日')),
                  ButtonSegment(value: false, label: Text('休息日')),
                ],
                selected: {_trainingDay},
                onSelectionChanged: (s) {
                  setState(() => _trainingDay = s.first);
                  _rebuild();
                },
              ),
              if (_staleDiet) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '饮食规则已更新。旧计划可能仍是过期宏量（例如旧默认蛋白），请刷新饮食。',
                        style: text.bodySmall,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: profile == null
                              ? null
                              : () async {
                                  await ref
                                      .read(planRepositoryProvider)
                                      .refreshDiet(profile);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已按当前资料刷新饮食（力量进度保留）'),
                                      ),
                                    );
                                  }
                                },
                          child: const Text('刷新饮食'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text('餐食生成失败：$_error', style: text.bodySmall),
              ] else if (_dayPlan == null) ...[
                const SizedBox(height: 16),
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ] else ...[
                const SizedBox(height: 16),
                ..._dayPlan!.meals.map((m) => _mealBlock(context, m)),
                const SizedBox(height: 8),
                Text(
                  _dayPlan!.fatGuideZh,
                  style: text.bodySmall?.copyWith(
                    color: AppTheme.slate.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dayPlan!.weighTipZh,
                  style: text.bodySmall?.copyWith(
                    color: AppTheme.slate.withValues(alpha: 0.68),
                  ),
                ),
                for (final tip in _dayPlan!.tips) ...[
                  const SizedBox(height: 4),
                  Text(
                    '· $tip',
                    style: text.bodySmall?.copyWith(
                      color: AppTheme.slate.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _mealBlock(BuildContext context, PlannedMeal meal) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal.name,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '约 碳水 ${meal.carbG.round()}g · 蛋白 ${meal.proteinG.round()}g',
            style: text.bodySmall?.copyWith(
              color: AppTheme.slate.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 4),
          Text(meal.primaryLine, style: text.bodyMedium),
          if (meal.equivalents.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '或等价：${meal.equivalents.map(_stripPrefix).join('；')}',
              style: text.bodySmall?.copyWith(
                color: AppTheme.slate.withValues(alpha: 0.75),
              ),
            ),
          ],
          if (meal.tip.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              meal.tip,
              style: text.bodySmall?.copyWith(
                color: AppTheme.slate.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _stripPrefix(String s) {
    return s
        .replaceFirst('碳水等价：', '')
        .replaceFirst('蛋白等价：', '');
  }
}
