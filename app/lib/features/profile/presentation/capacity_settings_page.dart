import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/models.dart';

/// 更新基线能力与居家器械，可选重新生成后续训练处方。
class CapacitySettingsPage extends ConsumerStatefulWidget {
  const CapacitySettingsPage({super.key});

  @override
  ConsumerState<CapacitySettingsPage> createState() =>
      _CapacitySettingsPageState();
}

class _CapacitySettingsPageState extends ConsumerState<CapacitySettingsPage> {
  bool _loading = true;
  bool _busy = false;
  bool _applyUpcoming = true;
  Place _place = Place.gym;
  final Set<HomeEquipment> _homeGear = {HomeEquipment.none};

  final _pullUp = TextEditingController();
  final _pushUp = TextEditingController();
  final _squat = TextEditingController();
  final _lateralReps = TextEditingController();
  final _lateralKg = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(planRepositoryProvider).getProfile();
    if (!mounted) return;
    if (p != null) {
      _place = p.place;
      _homeGear
        ..clear()
        ..addAll(p.homeEquipment);
      if (_homeGear.isEmpty) _homeGear.add(HomeEquipment.none);
      _pullUp.text = '${p.capacity.pullUpMaxReps}';
      _pushUp.text = '${p.capacity.pushUpMaxReps}';
      _squat.text = '${p.capacity.squatMaxReps}';
      _lateralReps.text = '${p.capacity.lateralRaiseMaxReps}';
      _lateralKg.text = p.capacity.lateralRaiseWeightKg?.toString() ?? '';
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _pullUp.dispose();
    _pushUp.dispose();
    _squat.dispose();
    _lateralReps.dispose();
    _lateralKg.dispose();
    super.dispose();
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

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      final capacity = CapacityBaseline(
        pullUpMaxReps: int.tryParse(_pullUp.text.trim()) ?? 0,
        pushUpMaxReps: int.tryParse(_pushUp.text.trim()) ?? 0,
        squatMaxReps: int.tryParse(_squat.text.trim()) ?? 0,
        lateralRaiseMaxReps: int.tryParse(_lateralReps.text.trim()) ?? 0,
        lateralRaiseWeightKg: double.tryParse(_lateralKg.text.trim()),
      );
      await ref.read(planRepositoryProvider).updateCapacityAndEquipment(
            capacity: capacity,
            homeEquipment: _place == Place.home
                ? _homeGear.toList()
                : const [HomeEquipment.none],
            applyToUpcoming: _applyUpcoming,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _applyUpcoming ? '已保存并应用到后续训练' : '已保存基线（未重生成计划）',
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('基线能力与器械')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    '根据一次最大次数生成可完成的组次数；居家会过滤不匹配的器械动作。',
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pullUp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '引体向上：一次最多',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pushUp,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '俯卧撑：一次最多',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: '侧平举重量 kg（可空）',
                    ),
                  ),
                  if (_place == Place.home) ...[
                    const SizedBox(height: 20),
                    Text('居家器械', style: text.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: HomeEquipment.values.map((e) {
                        return FilterChip(
                          label: Text(homeEquipmentLabel(e)),
                          selected: _homeGear.contains(e),
                          onSelected: (v) => _toggleGear(e, v),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('应用到后续训练'),
                    subtitle: const Text('按新基线重新生成分化队列与组次数'),
                    value: _applyUpcoming,
                    onChanged: (v) => setState(() => _applyUpcoming = v),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _save,
                    child: Text(_busy ? '保存中…' : '保存'),
                  ),
                ],
              ),
      ),
    );
  }
}
