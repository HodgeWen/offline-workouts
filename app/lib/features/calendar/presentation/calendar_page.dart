import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../planning/domain/models.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _month;
  Map<String, DayType> _loggedTypes = {};
  String? _selected;
  List<WorkoutLog> _selectedLogs = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selected = _fmt(now);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonth());
  }

  Future<void> _loadMonth() async {
    final repo = ref.read(planRepositoryProvider);
    final first = DateTime(_month.year, _month.month, 1);
    final last = DateTime(_month.year, _month.month + 1, 0);
    final map = await repo.loggedDayTypesInRange(_fmt(first), _fmt(last));
    if (!mounted) return;
    setState(() => _loggedTypes = map);
    if (_selected != null) await _selectDate(_selected!);
  }

  Future<void> _selectDate(String date) async {
    final logs = await ref.read(planRepositoryProvider).logsForDate(date);
    if (!mounted) return;
    setState(() {
      _selected = date;
      _selectedLogs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(DateFormat('yyyy年M月').format(_month)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _month = DateTime(_month.year, _month.month - 1);
              });
              _loadMonth();
            },
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _month = DateTime(_month.year, _month.month + 1);
              });
              _loadMonth();
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            '训练历史',
            style: text.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '只显示已记录的训练/有氧/休息，空白日即未练。',
            style: text.bodyMedium?.copyWith(
              color: AppTheme.slate.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          _legend(scheme),
          const SizedBox(height: 14),
          _monthGrid(scheme),
          const SizedBox(height: 20),
          if (_selected != null) _detail(context),
        ],
      ),
    );
  }

  Widget _legend(ColorScheme scheme) {
    Widget item(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        item(AppTheme.dayTypeColor('strength', scheme), '力量'),
        item(AppTheme.dayTypeColor('cardio', scheme), '有氧'),
        item(AppTheme.dayTypeColor('rest', scheme), '休息'),
      ],
    );
  }

  Widget _monthGrid(ColorScheme scheme) {
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = (first.weekday + 6) % 7;
    final total = lead + daysInMonth;
    final rows = (total / 7).ceil();
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map(
                (e) => Expanded(
                  child: Center(
                    child: Text(
                      e,
                      style: text.labelLarge?.copyWith(
                        color: AppTheme.slate.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        ...List.generate(rows, (r) {
          return Row(
            children: List.generate(7, (c) {
              final idx = r * 7 + c;
              final dayNum = idx - lead + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 48));
              }
              final date = _fmt(DateTime(_month.year, _month.month, dayNum));
              final type = _loggedTypes[date];
              final selected = _selected == date;
              final color = type == null
                  ? Colors.transparent
                  : AppTheme.dayTypeColor(type.name, scheme);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectDate(date),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: type == null
                            ? Colors.white.withValues(alpha: 0.28)
                            : color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppTheme.ink
                              : (type == null
                                  ? AppTheme.primary.withValues(alpha: 0.06)
                                  : Colors.transparent),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: text.titleMedium?.copyWith(
                            color: type == null
                                ? AppTheme.slate.withValues(alpha: 0.55)
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Widget _detail(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_selected!, style: text.titleLarge),
          const SizedBox(height: 10),
          if (_selectedLogs.isEmpty)
            Text(
              '这一天没有训练记录',
              style: text.bodyMedium?.copyWith(
                color: AppTheme.slate.withValues(alpha: 0.65),
              ),
            )
          else
            ..._selectedLogs.map((log) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(log),
                      style: text.titleMedium,
                    ),
                    if (log.exercises.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...log.exercises.take(8).map(
                            (e) => Text(
                              '· ${e.name}（${e.sets.length} 组）',
                              style: text.bodyMedium,
                            ),
                          ),
                    ],
                    if (log.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(log.note, style: text.bodySmall),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  String _label(WorkoutLog log) {
    return switch (log.type) {
      DayType.strength =>
        log.title.isEmpty ? '力量训练' : log.title,
      DayType.cardio => log.title.isEmpty ? '有氧' : log.title,
      DayType.rest => '休息',
      DayType.yoga => '瑜伽',
    };
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
