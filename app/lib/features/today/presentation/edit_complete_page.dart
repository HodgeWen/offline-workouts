import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/models.dart';

class EditCompletePage extends ConsumerStatefulWidget {
  const EditCompletePage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<EditCompletePage> createState() => _EditCompletePageState();
}

class _EditCompletePageState extends ConsumerState<EditCompletePage> {
  PlannedSession? _session;
  List<_EditableExercise> _items = [];
  bool _loading = true;
  VolumeFeedback? _feedback;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final e in _items) {
      for (final s in e.sets) {
        s.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _load() async {
    final session =
        await ref.read(planRepositoryProvider).sessionById(widget.sessionId);
    if (!mounted) return;
    if (session == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _session = session;
      _items = session.exercises
          .map(
            (e) => _EditableExercise(
              name: e.name,
              region: e.region,
              sets: List.generate(
                e.targetSets,
                (_) => _SetDraft(
                  weight: e.targetWeightKg?.toString() ?? '',
                  reps: '${e.repsMin}',
                ),
              ),
            ),
          )
          .toList();
      _loading = false;
    });
  }

  Future<void> _save() async {
    final session = _session;
    if (session == null) return;
    final repo = ref.read(planRepositoryProvider);
    final prescribedByName = {
      for (final e in session.exercises) e.name: e,
    };
    final exercises = _items.map((e) {
      final planned = prescribedByName[e.name];
      final sets = e.sets
          .map(
            (s) => LoggedSet(
              weightKg: double.tryParse(s.weight) ?? 0,
              reps: int.tryParse(s.reps) ?? 0,
            ),
          )
          .toList();
      if (planned != null) {
        return LoggedExercise.fromPrescription(planned, sets: sets);
      }
      return LoggedExercise(name: e.name, region: e.region, sets: sets);
    }).toList();
    await repo.completeSession(
      session: session,
      exercises: exercises,
      volumeFeedback: _feedback,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存；后续处方将按反馈与完成表现微调')),
      );
      context.go('/today');
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AtmosphereBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('编辑后完成')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _session == null
                ? const Center(child: Text('找不到该训练日'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    children: [
                      Text(_session!.title, style: text.headlineSmall),
                      const SizedBox(height: 8),
                      Text(
                        '可增删组数、改配重与次数；少做或多做都可以。完成后分化队列前进。',
                        style: text.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Text('当前训练量', style: text.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final f in VolumeFeedback.values)
                            ChoiceChip(
                              label: Text(volumeFeedbackLabel(f)),
                              selected: _feedback == f,
                              onSelected: (v) => setState(
                                () => _feedback = v ? f : null,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ..._items.asMap().entries.map((entry) {
                        final i = entry.key;
                        final ex = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(ex.name, style: text.titleMedium),
                                  ),
                                  IconButton(
                                    tooltip: '加一组',
                                    onPressed: () => setState(
                                      () => ex.sets.add(
                                        _SetDraft(weight: '', reps: '8'),
                                      ),
                                    ),
                                    icon: const Icon(Icons.add),
                                  ),
                                ],
                              ),
                              Text(ex.region, style: text.bodySmall),
                              const SizedBox(height: 8),
                              ...ex.sets.asMap().entries.map((se) {
                                final si = se.key;
                                final s = se.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text('第${si + 1}组'),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: s.weightCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: '配重kg',
                                            isDense: true,
                                          ),
                                          onChanged: (v) => s.weight = v,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: s.repsCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: '次数',
                                            isDense: true,
                                          ),
                                          onChanged: (v) => s.reps = v,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: ex.sets.length <= 1
                                            ? null
                                            : () => setState(() {
                                                  final removed =
                                                      ex.sets.removeAt(si);
                                                  removed.dispose();
                                                }),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (_items.length > 1)
                                TextButton(
                                  onPressed: () => setState(() {
                                    final removed = _items.removeAt(i);
                                    for (final s in removed.sets) {
                                      s.dispose();
                                    }
                                  }),
                                  child: const Text('移除该动作'),
                                ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _save,
                        child: const Text('保存为已完成'),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _EditableExercise {
  _EditableExercise({
    required this.name,
    required this.region,
    required this.sets,
  });

  final String name;
  final String region;
  final List<_SetDraft> sets;
}

class _SetDraft {
  _SetDraft({required String weight, required String reps})
      : weight = weight,
        reps = reps,
        weightCtrl = TextEditingController(text: weight),
        repsCtrl = TextEditingController(text: reps);

  String weight;
  String reps;
  final TextEditingController weightCtrl;
  final TextEditingController repsCtrl;

  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
  }
}
