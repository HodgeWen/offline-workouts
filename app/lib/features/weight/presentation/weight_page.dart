import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/weight_aggregate.dart';
import '../domain/weight_log.dart';

class WeightPage extends ConsumerStatefulWidget {
  const WeightPage({super.key});

  @override
  ConsumerState<WeightPage> createState() => _WeightPageState();
}

class _WeightPageState extends ConsumerState<WeightPage> {
  final _weightCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  WeightPeriod _period = WeightPeriod.day;
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefillFromProfile());
  }

  void _prefillFromProfile() {
    if (_prefilled || !mounted) return;
    final profile = ref.read(userProfileProvider).asData?.value;
    if (profile == null) return;
    _prefilled = true;
    _weightCtrl.text = _trimNum(profile.weightKg);
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(weightLogsProvider);
    final text = Theme.of(context).textTheme;
    // 资料异步就绪后再预填一次
    ref.listen(userProfileProvider, (_, _) => _prefillFromProfile());

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('分析 · 体重')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('录入今日体重', style: text.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              // 日期按钮需足够宽度，避免 yyyy-MM-dd 被挤成竖排换行
              Flexible(
                flex: 5,
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.calendar_today_outlined, size: 18),
                  label: Text(
                    _fmt(_selectedDate),
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 6,
                child: TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: '体重 kg',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : () => _save(context),
            child: Text(_saving ? '保存中…' : '保存'),
          ),
          const SizedBox(height: 28),
          Text('趋势', style: text.titleLarge),
          const SizedBox(height: 10),
          SegmentedButton<WeightPeriod>(
            segments: const [
              ButtonSegment(value: WeightPeriod.day, label: Text('日')),
              ButtonSegment(value: WeightPeriod.week, label: Text('周')),
              ButtonSegment(value: WeightPeriod.month, label: Text('月')),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 16),
          logsAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('加载失败：$e'),
            data: (logs) {
              final series = aggregateWeightSeries(logs, _period);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WeightChart(series: series),
                  const SizedBox(height: 24),
                  Text('近期记录', style: text.titleMedium),
                  const SizedBox(height: 8),
                  if (logs.isEmpty)
                    Text('暂无记录，先录入一条吧', style: text.bodyMedium)
                  else
                    ...logs.reversed.take(14).map((log) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(log.date),
                        trailing: Text(
                          '${_trimNum(log.weightKg)} kg',
                          style: text.titleMedium?.copyWith(
                            color: AppTheme.primary,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime.parse(log.date);
                            _weightCtrl.text = _trimNum(log.weightKg);
                          });
                        },
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);

    // 若该日已有记录，带入输入框
    final logs = ref.read(weightLogsProvider).asData?.value;
    if (logs == null) return;
    final key = _fmt(picked);
    for (final log in logs) {
      if (log.date == key) {
        _weightCtrl.text = _trimNum(log.weightKg);
        return;
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    final w = double.tryParse(_weightCtrl.text.trim());
    if (w == null || w < 30 || w > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入 30–250 之间的有效体重')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(planRepositoryProvider).upsertWeightLog(_selectedDate, w);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('体重已保存')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _trimNum(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.series});

  final List<WeightSeriesPoint> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          '暂无体重数据',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final weights = series.map((e) => e.weightKg).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final pad = ((maxW - minW).abs() < 1 ? 1.0 : (maxW - minW) * 0.15)
        .clamp(0.5, 5.0);
    final minY = (minW - pad).clamp(0.0, double.infinity);
    final maxY = maxW + pad;

    final spots = [
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].weightKg),
    ];

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.08),
        ),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          minX: 0,
          maxX: (series.length - 1).toDouble().clamp(0, double.infinity),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ((maxY - minY) / 4).clamp(0.5, 10),
            getDrawingHorizontalLine: (v) => FlLine(
              color: AppTheme.primary.withValues(alpha: 0.08),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(v == v.roundToDouble() ? 0 : 1),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: _bottomInterval(series.length),
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i < 0 || i >= series.length) {
                    return const SizedBox.shrink();
                  }
                  // 避免过密：只画间隔点与首尾
                  if (i != 0 &&
                      i != series.length - 1 &&
                      i % _bottomInterval(series.length).round() != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      series[i].label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) {
                return [
                  for (final t in touched)
                    LineTooltipItem(
                      '${series[t.spotIndex].label}\n'
                      '${t.y.toStringAsFixed(1)} kg',
                      TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                ];
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.25,
              color: AppTheme.primary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: series.length <= 20,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: AppTheme.primary,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static double _bottomInterval(int n) {
    if (n <= 6) return 1;
    if (n <= 12) return 2;
    if (n <= 24) return 4;
    return (n / 6).ceilToDouble();
  }
}
