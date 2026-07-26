import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/goal_classifier.dart';
import '../../planning/domain/meal_plan_builder.dart';
import '../../planning/domain/models.dart';
import '../../onboarding/presentation/onboarding_page.dart';
import 'capacity_settings_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _weightCtrl = TextEditingController();

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final planAsync = ref.watch(activePlanProvider);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          profileAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('资料加载失败：$e'),
            data: (profile) {
              if (profile == null) {
                return Text('尚未填写资料', style: text.bodyLarge);
              }
              if (_weightCtrl.text.isEmpty) {
                _weightCtrl.text = profile.weightKg.toString();
              }
              // Material 包裹：避免 ListTile/SwitchListTile 在 DecoratedBox 下 ink 断言
              return Material(
                color: Colors.white.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(18),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${profile.sex == Sex.male ? '男' : '女'} · '
                          '${profile.heightCm}cm · ${profile.weightKg}kg · ${profile.age}岁',
                          style: text.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${profile.place == Place.gym ? '健身房' : '居家'} · '
                          '每周约${profile.daysPerWeek}练 · '
                          '${_expLabel(profile.experience)}',
                          style: text.bodyMedium,
                        ),
                        planAsync.when(
                          data: (plan) {
                            if (plan == null) return const SizedBox.shrink();
                            final fb = plan.adaptation.lastFeedback;
                            final adapted = plan.adaptation.byExercise.length;
                            return Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '当前目标：${goalLabelZh(plan.goal)}'
                                    ' · ${templateLabelZh(plan.templateId)}'
                                    ' · 下一练序号 ${(plan.cursorIndex % (plan.sessions.isEmpty ? 1 : plan.sessions.length)) + 1}'
                                    ' · BMR ${plan.bmr}',
                                    style: text.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    const GoalClassifier().explainZh(profile),
                                    style: text.bodySmall,
                                  ),
                                  Text(
                                    '训练日饮食：${plan.trainingMacros.calories} kcal · '
                                    '蛋白 ${plan.trainingMacros.proteinG.round()}g',
                                    style: text.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '有氧：${plan.cardioPolicy.enabled ? plan.cardioPolicy.modality : '未启用'}'
                                    ' · 瑜伽：${plan.yogaPolicy.enabled ? plan.yogaPolicy.sequenceTitle : '未启用'}',
                                    style: text.bodySmall,
                                  ),
                                  Text(
                                    '负荷适应：${adapted == 0 ? '尚无微调' : '已调整 $adapted 个动作'}'
                                    '${fb == null ? '' : ' · 上次反馈 ${volumeFeedbackLabel(fb)}'}',
                                    style: text.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('瑜伽 / 恢复兴趣'),
                          subtitle: const Text('开启后今日可记恢复序列；不重置力量队列进度'),
                          value: profile.includeYoga,
                          onChanged: (v) async {
                            final next = profile.copyWith(includeYoga: v);
                            final repo = ref.read(planRepositoryProvider);
                            await repo.updatePolicies(next);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    v
                                        ? '已开启瑜伽策略（力量进度保留）'
                                        : '已关闭瑜伽策略（力量进度保留）',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          Text('更新体重', style: text.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '体重 kg',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  final w = double.tryParse(_weightCtrl.text);
                  if (w == null) return;
                  await ref.read(planRepositoryProvider).updateWeight(w);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('体重已更新（重生成计划可同步饮食）')),
                    );
                  }
                },
                child: const Text('保存'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _navTile(
            icon: Icons.fitness_center,
            title: '基线能力与器械',
            subtitle: '更新最大次数 / 居家器械，并可应用到后续训练',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CapacitySettingsPage(),
                ),
              );
            },
          ),
          _navTile(
            icon: Icons.restaurant_menu,
            title: '按当前资料刷新饮食',
            subtitle: '重算目标/宏量/餐食克数，保留力量队列进度',
            onTap: () => _refreshDiet(context),
          ),
          _navTile(
            icon: Icons.refresh,
            title: '重新填写问卷并生成计划',
            subtitle: '会重置力量队列进度；饮食也会一并按新规则生成',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingPage()),
              );
            },
          ),
          _navTile(
            icon: Icons.restaurant_outlined,
            title: '饮食等价食物',
            subtitle: '查看日常食物营养率',
            onTap: () => _showFoods(context),
          ),
          _navTile(
            icon: Icons.help_outline,
            title: '常见问题 FAQ',
            onTap: () => context.push('/profile/faq'),
          ),
          _navTile(
            icon: Icons.ios_share,
            title: '导出本地备份',
            subtitle: 'JSON 文件，纯本地分享',
            onTap: () => _export(context),
          ),
          const SizedBox(height: 20),
          Text(
            '数据全部保存在本机。按分化顺序练；休息日自己安排，不固定到星期几。',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  String _expLabel(Experience e) => switch (e) {
        Experience.beginner => '新手',
        Experience.intermediate => '有基础',
        Experience.advanced => '老手',
      };

  Future<void> _refreshDiet(BuildContext context) async {
    final profile = await ref.read(planRepositoryProvider).getProfile();
    if (profile == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先完成资料填写')),
        );
      }
      return;
    }
    final plan = await ref.read(planRepositoryProvider).refreshDiet(profile);
    if (!context.mounted) return;
    final goal = plan == null ? '' : goalLabelZh(plan.goal);
    final protein = plan?.trainingMacros.proteinG.round();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          protein == null
              ? '已刷新饮食'
              : '已刷新：$goal · 训练日蛋白约 ${protein}g（力量进度保留）',
        ),
      ),
    );
  }

  Future<void> _showFoods(BuildContext context) async {
    final db = await ref.read(appDatabaseProvider.future);
    final foods = await db.select(db.foods).get();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.foam,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    '日常食物营养率（任选等价互换）',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: foods.length,
                    itemBuilder: (_, i) {
                      final f = foods[i];
                      return ListTile(
                        title: Text(f.name),
                        subtitle: Text(
                          '${f.category} · ${f.macroHint} · 率 ${f.rate}'
                          '${f.note == null ? '' : '\n${f.note}'}',
                        ),
                        isThreeLine: f.note != null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _export(BuildContext context) async {
    try {
      final data = await ref.read(planRepositoryProvider).exportBackup();
      final bytes = Uint8List.fromList(
        utf8.encode(const JsonEncoder.withIndent('  ').convert(data)),
      );
      final name =
          'workout_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              bytes,
              mimeType: 'application/json',
              name: name,
            ),
          ],
          subject: '健身计划本地备份',
          text: '离线健身 App 备份',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败：$e')),
        );
      }
    }
  }
}
