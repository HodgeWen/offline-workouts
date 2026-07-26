/// 每日体重日志领域模型。
class WeightLog {
  const WeightLog({
    required this.date,
    required this.weightKg,
    required this.loggedAt,
  });

  /// yyyy-MM-dd
  final String date;
  final double weightKg;
  final DateTime loggedAt;

  Map<String, dynamic> toJson() => {
        'date': date,
        'weightKg': weightKg,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      date: json['date'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}

/// 折线周期粒度。
enum WeightPeriod { day, week, month }

/// 聚合后的折线数据点。
class WeightSeriesPoint {
  const WeightSeriesPoint({
    required this.label,
    required this.dateKey,
    required this.weightKg,
  });

  /// 图上展示用标签
  final String label;

  /// 分组键（日=yyyy-MM-dd，周=yyyy-Www，月=yyyy-MM）
  final String dateKey;
  final double weightKg;
}
