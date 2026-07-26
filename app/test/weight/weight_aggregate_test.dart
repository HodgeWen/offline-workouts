import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/weight/domain/weight_aggregate.dart';
import 'package:workout_app/features/weight/domain/weight_log.dart';

WeightLog _log(String date, double kg) {
  return WeightLog(
    date: date,
    weightKg: kg,
    loggedAt: DateTime.parse('${date}T08:00:00'),
  );
}

void main() {
  group('aggregateWeightSeries', () {
    test('空列表 → 空系列', () {
      expect(aggregateWeightSeries(const [], WeightPeriod.day), isEmpty);
      expect(aggregateWeightSeries(const [], WeightPeriod.week), isEmpty);
      expect(aggregateWeightSeries(const [], WeightPeriod.month), isEmpty);
    });

    test('日视图保序、点数正确', () {
      final logs = [
        _log('2026-07-03', 71),
        _log('2026-07-01', 70),
        _log('2026-07-02', 70.5),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.day);
      expect(series.length, 3);
      expect(series.map((e) => e.dateKey).toList(), [
        '2026-07-01',
        '2026-07-02',
        '2026-07-03',
      ]);
      expect(series.map((e) => e.weightKg).toList(), [70, 70.5, 71]);
      expect(series.first.label, '07-01');
    });

    test('日视图最多保留最近 dayLimit 条', () {
      final start = DateTime(2026, 5, 1);
      final logs = [
        for (var i = 0; i < 35; i++)
          _log(_ymd(start.add(Duration(days: i))), 70 + i * 0.1),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.day, dayLimit: 30);
      expect(series.length, 30);
      expect(series.first.dateKey, _ymd(start.add(const Duration(days: 5))));
      expect(series.last.dateKey, _ymd(start.add(const Duration(days: 34))));
    });

    test('同一周多天 → 算术平均', () {
      // 2026-07-20 周一，同周到 07-26
      final logs = [
        _log('2026-07-20', 70),
        _log('2026-07-22', 72),
        _log('2026-07-24', 71),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.week);
      expect(series.length, 1);
      expect(series.single.weightKg, closeTo(71, 1e-9));
      expect(series.single.dateKey, contains('-W'));
    });

    test('跨周分别聚合', () {
      final logs = [
        _log('2026-07-20', 70), // 周一 W30
        _log('2026-07-21', 72),
        _log('2026-07-27', 74), // 下周一 W31
        _log('2026-07-28', 76),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.week);
      expect(series.length, 2);
      expect(series[0].weightKg, closeTo(71, 1e-9));
      expect(series[1].weightKg, closeTo(75, 1e-9));
    });

    test('同一月跨周 → 月平均', () {
      final logs = [
        _log('2026-07-01', 70),
        _log('2026-07-15', 72),
        _log('2026-07-31', 74),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.month);
      expect(series.length, 1);
      expect(series.single.dateKey, '2026-07');
      expect(series.single.weightKg, closeTo(72, 1e-9));
    });

    test('跨月分别聚合', () {
      final logs = [
        _log('2026-06-28', 70),
        _log('2026-06-30', 72),
        _log('2026-07-01', 74),
        _log('2026-07-10', 76),
      ];
      final series = aggregateWeightSeries(logs, WeightPeriod.month);
      expect(series.length, 2);
      expect(series[0].dateKey, '2026-06');
      expect(series[0].weightKg, closeTo(71, 1e-9));
      expect(series[1].dateKey, '2026-07');
      expect(series[1].weightKg, closeTo(75, 1e-9));
    });
  });
}

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
