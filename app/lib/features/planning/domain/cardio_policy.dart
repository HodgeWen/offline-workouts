import 'dart:math';

import 'models.dart';

/// 有氧策略（顺序模型：不排日历日期，仅给出可选建议与热量估计）。
class CardioPolicy {
  const CardioPolicy({
    required this.enabled,
    required this.modality,
    required this.minutesPerSession,
    required this.weeklyMinutesTarget,
    required this.intensity,
    required this.guidance,
    this.kcalPerKgPerHour = 4.0,
    this.offerOnRestDays = true,
  });

  final bool enabled;
  final String modality;
  final int minutesPerSession;
  final int weeklyMinutesTarget;
  /// zone2_liss | short_liss_only | none
  final String intensity;
  final String guidance;
  final double kcalPerKgPerHour;
  final bool offerOnRestDays;

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'modality': modality,
        'minutesPerSession': minutesPerSession,
        'weeklyMinutesTarget': weeklyMinutesTarget,
        'intensity': intensity,
        'guidance': guidance,
        'kcalPerKgPerHour': kcalPerKgPerHour,
        'offerOnRestDays': offerOnRestDays,
      };

  factory CardioPolicy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CardioPolicy(
        enabled: false,
        modality: '',
        minutesPerSession: 0,
        weeklyMinutesTarget: 0,
        intensity: 'none',
        guidance: '',
      );
    }
    return CardioPolicy(
      enabled: json['enabled'] as bool? ?? false,
      modality: json['modality'] as String? ?? '',
      minutesPerSession: (json['minutesPerSession'] as num?)?.toInt() ?? 0,
      weeklyMinutesTarget: (json['weeklyMinutesTarget'] as num?)?.toInt() ?? 0,
      intensity: json['intensity'] as String? ?? 'none',
      guidance: json['guidance'] as String? ?? '',
      kcalPerKgPerHour: (json['kcalPerKgPerHour'] as num?)?.toDouble() ?? 4.0,
      offerOnRestDays: json['offerOnRestDays'] as bool? ?? true,
    );
  }

  /// 估算单次有氧消耗（kcal）≈ kcalPerKgPerHour × weight × hours
  int estimateSessionKcal(double weightKg) {
    if (!enabled || minutesPerSession <= 0) return 0;
    return (kcalPerKgPerHour * weightKg * minutesPerSession / 60.0).round();
  }

  /// 摊到每日的有氧消耗（用于饮食平衡）
  double estimateDailyKcal(double weightKg) {
    if (!enabled || weeklyMinutesTarget <= 0) return 0;
    final weekly = kcalPerKgPerHour * weightKg * weeklyMinutesTarget / 60.0;
    return weekly / 7.0;
  }
}

/// 根据目标 / 体重 / 问卷生成有氧策略。
///
/// 依据公开指南摘要（WHO 每周中等强度活动量；Zone2/LISS 可交谈强度）：
/// - 减脂：默认 Zone2，按经验给每周分钟目标；体重≥80 不强制
/// - 增肌：默认关闭；用户坚持则短时 LISS
class CardioPolicyEngine {
  const CardioPolicyEngine();

  CardioPolicy build(UserProfile profile, Goal goal) {
    final want = profile.includeCardio;
    final modality = _modality(profile.cardioPreference);

    if (goal == Goal.bulk) {
      if (!want) {
        return const CardioPolicy(
          enabled: false,
          modality: '',
          minutesPerSession: 0,
          weeklyMinutesTarget: 0,
          intensity: 'none',
          guidance: '增肌期默认减少有氧，把恢复留给力量与饮食盈余。',
          offerOnRestDays: false,
        );
      }
      final mins = min(25, max(15, profile.cardioMinutes));
      final weekly = min(60, mins * 2);
      return CardioPolicy(
        enabled: true,
        modality: modality,
        minutesPerSession: mins,
        weeklyMinutesTarget: weekly,
        intensity: 'short_liss_only',
        guidance: '你坚持开启有氧：仅短时 LISS（约 $mins 分钟），'
            '每周建议不超过 $weekly 分钟，优先安排在休息日，避免影响增肌恢复。',
        kcalPerKgPerHour: _kcalRate(profile.cardioPreference),
        offerOnRestDays: true,
      );
    }

    // cut
    if (profile.weightKg >= 80 && !want) {
      return const CardioPolicy(
        enabled: false,
        modality: '',
        minutesPerSession: 0,
        weeklyMinutesTarget: 0,
        intensity: 'none',
        guidance: '减脂以饮食缺口为主；当前体重较高，不强制有氧。'
            '可增加 NEAT（日常步数）。若仍想做，可在资料里打开「结合有氧」。',
        offerOnRestDays: true,
      );
    }

    final enabled = want || profile.weightKg < 70;
    if (!enabled) {
      return CardioPolicy(
        enabled: false,
        modality: modality,
        minutesPerSession: 0,
        weeklyMinutesTarget: 0,
        intensity: 'none',
        guidance: '减脂中等体重：有氧可选。若易饿或平台期，可自行加 Zone2 快走。',
        offerOnRestDays: true,
      );
    }

    final weekly = _weeklyForExperience(profile.experience);
    final session = profile.cardioMinutes.clamp(20, 45);

    return CardioPolicy(
      enabled: true,
      modality: modality,
      minutesPerSession: session,
      weeklyMinutesTarget: weekly,
      intensity: 'zone2_liss',
      guidance: '减脂建议 Zone2/LISS（能说话的强度）：'
          '每次约 $session 分钟，每周目标约 $weekly 分钟。'
          '不排进固定日期——休息日或力量后均可；用「记一笔」归档即可。',
      kcalPerKgPerHour: _kcalRate(profile.cardioPreference),
      offerOnRestDays: true,
    );
  }

  int _weeklyForExperience(Experience exp) => switch (exp) {
        Experience.beginner => 90,
        Experience.intermediate => 120,
        Experience.advanced => 150,
      };

  String _modality(CardioPreference p) => switch (p) {
        CardioPreference.walk => 'Zone2 快走/爬坡走',
        CardioPreference.run => 'Zone2 慢跑',
        CardioPreference.bike => '室内单车 Zone2',
        CardioPreference.swim => '游泳（轻松持续）',
        CardioPreference.other => '自选 LISS 有氧',
        CardioPreference.none => 'Zone2 快走/爬坡走',
      };

  double _kcalRate(CardioPreference p) => switch (p) {
        CardioPreference.walk => 4.0,
        CardioPreference.run => 7.0,
        CardioPreference.bike => 5.5,
        CardioPreference.swim => 7.5,
        CardioPreference.other => 5.0,
        CardioPreference.none => 4.0,
      };
}
