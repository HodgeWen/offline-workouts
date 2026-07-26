import 'models.dart';

/// 问卷 → 增肌/减脂 规则判定（纯 Dart，无 Flutter 依赖）。
///
/// 规则：
/// - 显式「明确减脂/明确增肌」始终优先
/// - BMI≥24 → 减脂；BMI≤20 → 增肌
/// - 中间区看「更在意减脂还是围度」；未表态时 BMI≤22 默认增肌
///   （正常偏瘦如 175cm/63kg≈20.6 禁止静默减脂）
class GoalClassifier {
  const GoalClassifier();

  /// 中国成人常用 BMI 超重线。
  static const double cutBmi = 24;

  /// 偏瘦 / 增肌默认线。
  static const double bulkBmi = 20;

  /// 正常偏瘦～正常中下：自动判定仍偏增肌，避免静默减脂。
  static const double leanBulkAutoBmi = 22;

  Goal classify(UserProfile profile) {
    switch (profile.goalPreference) {
      case GoalPreference.cut:
        return Goal.cut;
      case GoalPreference.bulk:
        return Goal.bulk;
      case GoalPreference.auto:
      case GoalPreference.preferCut:
      case GoalPreference.preferBulk:
        break;
    }

    final bmi = bmiOf(profile);

    if (bmi >= cutBmi) return Goal.cut;
    if (bmi <= bulkBmi) return Goal.bulk;

    // 中间区：看偏好问题「更在意减脂还是围度」
    if (profile.goalPreference == GoalPreference.preferBulk) {
      return Goal.bulk;
    }
    if (profile.goalPreference == GoalPreference.preferCut) {
      return Goal.cut;
    }

    // auto：BMI≤22 默认增肌；22–24 偏减脂（更接近超重线）
    if (bmi <= leanBulkAutoBmi) return Goal.bulk;
    return Goal.cut;
  }

  static double bmiOf(UserProfile profile) {
    final heightM = profile.heightCm / 100.0;
    return profile.weightKg / (heightM * heightM);
  }

  /// 中文说明，供问卷/资料页展示判定依据。
  String explainZh(UserProfile profile) {
    final goal = classify(profile);
    final goalLabel = goal == Goal.cut ? '减脂' : '增肌';
    final bmi = bmiOf(profile);
    final bmiText = bmi.toStringAsFixed(1);

    switch (profile.goalPreference) {
      case GoalPreference.cut:
        return '你选择了明确减脂，目标为$goalLabel（BMI $bmiText）。';
      case GoalPreference.bulk:
        return '你选择了明确增肌，目标为$goalLabel（BMI $bmiText）。';
      case GoalPreference.preferCut:
        return 'BMI $bmiText 处于中间区，你更在意减脂 → 目标$goalLabel。';
      case GoalPreference.preferBulk:
        return 'BMI $bmiText 处于中间区，你更在意围度 → 目标$goalLabel。';
      case GoalPreference.auto:
        if (bmi >= cutBmi) {
          return 'BMI $bmiText ≥ $cutBmi，自动判定为$goalLabel。';
        }
        if (bmi <= bulkBmi) {
          return 'BMI $bmiText ≤ $bulkBmi，自动判定为$goalLabel。';
        }
        if (bmi <= leanBulkAutoBmi) {
          return 'BMI $bmiText 正常偏瘦，未选减脂偏好 → 默认$goalLabel（可改「更在意减脂」）。';
        }
        return 'BMI $bmiText 接近超重线，未选偏好 → 默认$goalLabel（可改「更在意围度」）。';
    }
  }

  /// 是否默认安排有氧（可被问卷强制覆盖）。
  bool shouldIncludeCardio(UserProfile profile, Goal goal) {
    if (profile.includeCardio) return true;
    if (goal == Goal.bulk) return false;
    // 减脂：体重很高时资料倾向饮食缺口为主、不必强制有氧
    if (profile.weightKg >= 80) return false;
    if (profile.weightKg >= 70) return false;
    return true;
  }
}
