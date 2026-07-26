import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/goal_classifier.dart';
import '../../planning/domain/models.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  static const _totalSteps = 5;

  final _page = PageController();
  int _step = 0;
  bool _busy = false;

  Sex _sex = Sex.male;
  final _height = TextEditingController(text: '175');
  final _weight = TextEditingController(text: '70');
  final _age = TextEditingController(text: '28');
  Experience _exp = Experience.beginner;
  Place _place = Place.gym;
  int _days = 3;
  TrainingSlot _slot = TrainingSlot.afterBreakfastEarly;
  final Set<HomeEquipment> _homeGear = {HomeEquipment.none};
  bool _cardio = false;
  CardioPreference _cardioPref = CardioPreference.walk;
  int _cardioMin = 30;
  bool _yoga = false;
  GoalPreference _goalPref = GoalPreference.auto;
  final _injuries = TextEditingController();
  final _diet = TextEditingController();

  final _pullUp = TextEditingController(text: '0');
  final _pushUp = TextEditingController(text: '0');
  final _squat = TextEditingController(text: '0');
  final _lateralReps = TextEditingController(text: '0');
  final _lateralKg = TextEditingController();

  @override
  void dispose() {
    _page.dispose();
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    _injuries.dispose();
    _diet.dispose();
    _pullUp.dispose();
    _pushUp.dispose();
    _squat.dispose();
    _lateralReps.dispose();
    _lateralKg.dispose();
    super.dispose();
  }

  CapacityBaseline _capacity() {
    return CapacityBaseline(
      pullUpMaxReps: int.tryParse(_pullUp.text.trim()) ?? 0,
      pushUpMaxReps: int.tryParse(_pushUp.text.trim()) ?? 0,
      squatMaxReps: int.tryParse(_squat.text.trim()) ?? 0,
      lateralRaiseMaxReps: int.tryParse(_lateralReps.text.trim()) ?? 0,
      lateralRaiseWeightKg: double.tryParse(_lateralKg.text.trim()),
    );
  }

  Future<void> _submit() async {
    final height = double.tryParse(_height.text.trim());
    final weight = double.tryParse(_weight.text.trim());
    final age = int.tryParse(_age.text.trim());
    if (height == null || weight == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写有效的身高、体重与年龄')),
      );
      return;
    }
    if (height < 100 || height > 250 || weight < 30 || weight > 250 || age < 12 || age > 90) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('身高/体重/年龄超出合理范围，请检查')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final profile = UserProfile(
        sex: _sex,
        heightCm: height,
        weightKg: weight,
        age: age,
        experience: _exp,
        place: _place,
        daysPerWeek: _days,
        trainingSlot: _slot,
        includeCardio: _cardio,
        cardioPreference: _cardioPref,
        cardioMinutes: _cardioMin,
        includeYoga: _yoga,
        injuries: _injuries.text.trim(),
        dietRestrictions: _diet.text.trim(),
        goalPreference: _goalPref,
        capacity: _capacity(),
        homeEquipment: _place == Place.home
            ? _homeGear.toList()
            : const [HomeEquipment.none],
      );
      final repo = ref.read(planRepositoryProvider);
      await repo.regeneratePlan(profile);
      if (mounted) context.go('/today');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成计划失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _goNext() async {
    if (_step < _totalSteps - 1) {
      await _page.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      await _submit();
    }
  }

  void _toggleGear(HomeEquipment e, bool selected) {
    setState(() {
      if (e == HomeEquipment.none) {
        if (selected) {
          _homeGear
            ..clear()
            ..add(HomeEquipment.none);
        } else {
          _homeGear.remove(HomeEquipment.none);
        }
        return;
      }
      _homeGear.remove(HomeEquipment.none);
      if (selected) {
        _homeGear.add(e);
      } else {
        _homeGear.remove(e);
      }
      if (_homeGear.isEmpty) _homeGear.add(HomeEquipment.none);
    });
  }

  String _goalHint() {
    final height = double.tryParse(_height.text.trim()) ?? 175;
    final weight = double.tryParse(_weight.text.trim()) ?? 70;
    final age = int.tryParse(_age.text.trim()) ?? 28;
    final preview = UserProfile(
      sex: _sex,
      heightCm: height,
      weightKg: weight,
      age: age,
      experience: _exp,
      place: _place,
      daysPerWeek: _days,
      trainingSlot: _slot,
      goalPreference: _goalPref,
    );
    return const GoalClassifier().explainZh(preview);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('建立计划 ${_step + 1}/$_totalSteps'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _totalSteps,
                  minHeight: 6,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _stepBody(_introAndBasics(text)),
                  _stepBody(_bodyTraining(text)),
                  _stepBody(_bodyCapacity(text)),
                  _stepBody(_bodyCardioGoal(text)),
                  _stepBody(_bodyExtra(text)),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _page.previousPage(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutCubic,
                                ),
                        child: const Text('上一步'),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _busy ? null : _goNext,
                      child: Text(
                        _busy
                            ? '生成中…'
                            : (_step < _totalSteps - 1 ? '下一步' : '生成计划'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody(Widget child) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [child],
    );
  }

  Widget _introAndBasics(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('按分化顺序练', style: text.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '按分化顺序练；休息日自己安排，不固定到星期几。'
          '「今日」始终显示队列里的下一练，完成才前进。',
          style: text.bodyLarge?.copyWith(
            color: AppTheme.slate.withValues(alpha: 0.78),
          ),
        ),
        const SizedBox(height: 24),
        Text('身体数据', style: text.titleLarge),
        const SizedBox(height: 12),
        SegmentedButton<Sex>(
          segments: const [
            ButtonSegment(value: Sex.male, label: Text('男')),
            ButtonSegment(value: Sex.female, label: Text('女')),
          ],
          selected: {_sex},
          onSelectionChanged: (s) => setState(() {
            _sex = s.first;
            // 女性默认建议开启瑜伽/恢复兴趣（可关）
            if (_sex == Sex.female) _yoga = true;
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _height,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '身高 (cm)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weight,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '体重 (kg)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _age,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '年龄'),
        ),
        const SizedBox(height: 16),
        Text(
          '本工具仅供个人/朋友参考，不构成医疗建议。',
          style: text.bodySmall,
        ),
      ],
    );
  }

  Widget _bodyTraining(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('训练条件', style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '每周可练天数用于选择三分化/四分化模板，不会把训练钉死在日历上。',
          style: text.bodyMedium?.copyWith(
            color: AppTheme.slate.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        DropdownMenu<Experience>(
          initialSelection: _exp,
          label: const Text('经验'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: Experience.beginner, label: '新手'),
            DropdownMenuEntry(value: Experience.intermediate, label: '有基础'),
            DropdownMenuEntry(value: Experience.advanced, label: '老手'),
          ],
          onSelected: (v) => setState(() => _exp = v ?? _exp),
        ),
        const SizedBox(height: 12),
        SegmentedButton<Place>(
          segments: const [
            ButtonSegment(value: Place.gym, label: Text('健身房')),
            ButtonSegment(value: Place.home, label: Text('居家')),
          ],
          selected: {_place},
          onSelectionChanged: (s) => setState(() => _place = s.first),
        ),
        if (_place == Place.home) ...[
          const SizedBox(height: 16),
          Text('居家器械（可多选）', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(
            '只安排与所选器械匹配的动作；没有单杠就不会出现引体向上。',
            style: text.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HomeEquipment.values.map((e) {
              final selected = _homeGear.contains(e);
              return FilterChip(
                label: Text(homeEquipmentLabel(e)),
                selected: selected,
                onSelected: (v) => _toggleGear(e, v),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        Text('每周可练天数：$_days', style: text.titleMedium),
        Slider(
          value: _days.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          label: '$_days',
          onChanged: (v) => setState(() => _days = v.round()),
        ),
        const SizedBox(height: 8),
        DropdownMenu<TrainingSlot>(
          initialSelection: _slot,
          label: const Text('偏好训练时段（饮食排餐）'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(
              value: TrainingSlot.afterBreakfastEarly,
              label: '早饭后（早起）',
            ),
            DropdownMenuEntry(
              value: TrainingSlot.afterBreakfastLate,
              label: '早饭后（晚起）',
            ),
            DropdownMenuEntry(
              value: TrainingSlot.beforeLunch,
              label: '午饭前',
            ),
            DropdownMenuEntry(
              value: TrainingSlot.afterLunch,
              label: '午饭后',
            ),
            DropdownMenuEntry(
              value: TrainingSlot.beforeDinner,
              label: '晚饭前',
            ),
            DropdownMenuEntry(
              value: TrainingSlot.afterDinner,
              label: '晚饭后',
            ),
            DropdownMenuEntry(value: TrainingSlot.night, label: '夜里'),
          ],
          onSelected: (v) => setState(() => _slot = v ?? _slot),
        ),
      ],
    );
  }

  Widget _bodyCapacity(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('基线能力', style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '填「一次最多能做几个」。组数与次数会按你的能力生成，'
          '不会再固定给新手开 4×8–12 引体。可填 0。',
          style: text.bodyMedium?.copyWith(
            color: AppTheme.slate.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pullUp,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '引体向上：一次最多能做几个',
            helperText: '0 表示还做不了，会换成弹力带/水平划船等',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pushUp,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '俯卧撑：一次最多',
            helperText: '0 会优先安排跪姿俯卧撑',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _squat,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '深蹲（自重）：一次最多',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lateralReps,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '哑铃侧平举：一次最多次数',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _lateralKg,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '侧平举使用重量 (kg，可空)',
            helperText: '没有哑铃可留空',
          ),
        ),
      ],
    );
  }

  Widget _bodyCardioGoal(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('有氧与目标', style: text.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '有氧是可选补充，不会被排进日历日期；可在训练后或休息日随时记录。',
          style: text.bodyMedium?.copyWith(
            color: AppTheme.slate.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('结合有氧'),
          subtitle: const Text('增肌默认关闭；减脂按体重规则建议'),
          value: _cardio,
          onChanged: (v) => setState(() => _cardio = v),
        ),
        if (_cardio) ...[
          DropdownMenu<CardioPreference>(
            initialSelection: _cardioPref,
            label: const Text('有氧偏好'),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: CardioPreference.walk, label: '快走'),
              DropdownMenuEntry(value: CardioPreference.run, label: '跑步'),
              DropdownMenuEntry(value: CardioPreference.bike, label: '骑行'),
              DropdownMenuEntry(value: CardioPreference.swim, label: '游泳'),
              DropdownMenuEntry(value: CardioPreference.other, label: '其他'),
            ],
            onSelected: (v) => setState(() => _cardioPref = v ?? _cardioPref),
          ),
          const SizedBox(height: 8),
          Text('单次有氧时长：$_cardioMin 分钟', style: text.titleMedium),
          Slider(
            value: _cardioMin.toDouble(),
            min: 15,
            max: 60,
            divisions: 9,
            label: '$_cardioMin',
            onChanged: (v) => setState(() => _cardioMin = v.round()),
          ),
        ],
        const SizedBox(height: 12),
        DropdownMenu<GoalPreference>(
          initialSelection: _goalPref,
          label: const Text('目标偏好'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: GoalPreference.auto, label: '自动判定'),
            DropdownMenuEntry(value: GoalPreference.cut, label: '明确减脂'),
            DropdownMenuEntry(value: GoalPreference.bulk, label: '明确增肌'),
            DropdownMenuEntry(
              value: GoalPreference.preferCut,
              label: '中间体重·更在意减脂',
            ),
            DropdownMenuEntry(
              value: GoalPreference.preferBulk,
              label: '中间体重·更在意围度',
            ),
          ],
          onSelected: (v) => setState(() => _goalPref = v ?? _goalPref),
        ),
        const SizedBox(height: 8),
        Text(
          _goalHint(),
          style: text.bodySmall,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('瑜伽 / 恢复兴趣'),
          subtitle: Text(
            _sex == Sex.female
                ? '女性默认建议开启：休息日或力量间隙可选恢复序列（不钉日历）'
                : '开启后提供休息日可选瑜伽序列，不推进力量队列',
          ),
          value: _yoga,
          onChanged: (v) => setState(() => _yoga = v),
        ),
      ],
    );
  }

  Widget _bodyExtra(TextTheme text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('其他备注', style: text.headlineSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _injuries,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: '伤病 / 需要避开的动作（可选）',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _diet,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: '忌口（可选）',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '完成后将按你的基线能力与器械离线生成个性化组次数，并给出饮食宏量。'
          '休息日不固定到星期几，由你决定要不要练。',
          style: text.bodyMedium,
        ),
      ],
    );
  }
}
