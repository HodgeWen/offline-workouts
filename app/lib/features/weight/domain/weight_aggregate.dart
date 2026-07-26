import 'weight_log.dart';

/// 将体重日志聚合成折线系列（纯函数，无 Flutter 依赖）。
///
/// - 日：最近约 30 个有记录日（按 date 升序）
/// - 周：按 ISO 周（周一为起点）取算术平均，最近约 12 周
/// - 月：按 yyyy-MM 取算术平均，最近约 12 月
/// 缺测日不计入平均。
List<WeightSeriesPoint> aggregateWeightSeries(
  List<WeightLog> logs,
  WeightPeriod period, {
  int dayLimit = 30,
  int weekLimit = 12,
  int monthLimit = 12,
}) {
  if (logs.isEmpty) return const [];

  final sorted = [...logs]..sort((a, b) => a.date.compareTo(b.date));

  return switch (period) {
    WeightPeriod.day => _aggregateDay(sorted, dayLimit),
    WeightPeriod.week => _aggregateWeek(sorted, weekLimit),
    WeightPeriod.month => _aggregateMonth(sorted, monthLimit),
  };
}

List<WeightSeriesPoint> _aggregateDay(List<WeightLog> sorted, int limit) {
  final slice =
      sorted.length <= limit ? sorted : sorted.sublist(sorted.length - limit);
  return [
    for (final log in slice)
      WeightSeriesPoint(
        label: _dayLabel(log.date),
        dateKey: log.date,
        weightKg: log.weightKg,
      ),
  ];
}

List<WeightSeriesPoint> _aggregateWeek(List<WeightLog> sorted, int limit) {
  final buckets = <String, _Bucket>{};
  for (final log in sorted) {
    final d = DateTime.parse(log.date);
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final key = _fmt(monday);
    final iso = _isoWeekKey(monday);
    final bucket = buckets.putIfAbsent(key, () => _Bucket(label: iso, dateKey: iso));
    bucket.sum += log.weightKg;
    bucket.count += 1;
  }
  return _takeLastAverages(buckets, limit);
}

List<WeightSeriesPoint> _aggregateMonth(List<WeightLog> sorted, int limit) {
  final buckets = <String, _Bucket>{};
  for (final log in sorted) {
    final key = log.date.substring(0, 7); // yyyy-MM
    final bucket = buckets.putIfAbsent(
      key,
      () => _Bucket(label: key, dateKey: key),
    );
    bucket.sum += log.weightKg;
    bucket.count += 1;
  }
  return _takeLastAverages(buckets, limit);
}

List<WeightSeriesPoint> _takeLastAverages(
  Map<String, _Bucket> buckets,
  int limit,
) {
  final keys = buckets.keys.toList()..sort();
  final slice = keys.length <= limit ? keys : keys.sublist(keys.length - limit);
  return [
    for (final key in slice)
      WeightSeriesPoint(
        label: buckets[key]!.label,
        dateKey: buckets[key]!.dateKey,
        weightKg: buckets[key]!.sum / buckets[key]!.count,
      ),
  ];
}

/// ISO 周年份 + 周序号，如 2026-W30（周一所在周）。
String _isoWeekKey(DateTime monday) {
  // ISO 周年：含该周四的那一周所属年份
  final thursday = monday.add(const Duration(days: 3));
  final yearStart = DateTime(thursday.year);
  final week = ((thursday.difference(yearStart).inDays) / 7).floor() + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

String _dayLabel(String ymd) {
  // MM-dd，便于图轴短标签
  if (ymd.length >= 10) return ymd.substring(5, 10);
  return ymd;
}

String _fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

class _Bucket {
  _Bucket({required this.label, required this.dateKey});

  final String label;
  final String dateKey;
  double sum = 0;
  int count = 0;
}
