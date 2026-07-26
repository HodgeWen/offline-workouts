import 'capacity.dart';

/// 动作与居家器械的兼容规则（按名称启发式，不依赖完整动作库）。
class ExerciseEquipment {
  const ExerciseEquipment._();

  /// 健身房视为器械齐全。
  static bool isCompatible({
    required String exerciseName,
    required bool isHome,
    required List<HomeEquipment> homeEquipment,
  }) {
    if (!isHome) return true;
    final gear = homeEquipment.toSet();
    // 仅勾选「无器械」时只允许纯自重变体
    final bodyweightOnly =
        gear.length == 1 && gear.contains(HomeEquipment.none);

    final req = requiredEquipment(exerciseName);
    if (req.isEmpty) {
      // 未标注需求 → 默认允许（多为器械名在健身房模板里）
      return !isHome || !bodyweightOnly || _looksBodyweight(exerciseName);
    }
    if (bodyweightOnly) {
      return req.every((e) => e == HomeEquipment.none);
    }
    // 有任一所需器械，或纯自重需求即可
    return req.any((e) => e == HomeEquipment.none || gear.contains(e));
  }

  /// 推断动作所需居家器械（可多个，满足其一即可）。
  static List<HomeEquipment> requiredEquipment(String name) {
    final n = name;
    if (n.contains('引体')) {
      return const [HomeEquipment.pullUpBar];
    }
    if (n.contains('悬垂')) {
      return const [HomeEquipment.pullUpBar];
    }
    if (n.contains('弹力带')) {
      return const [HomeEquipment.resistanceBand];
    }
    if (n.contains('壶铃')) {
      return const [HomeEquipment.kettlebell];
    }
    if (n.contains('哑铃') || n.contains('高脚杯')) {
      return const [HomeEquipment.dumbbell];
    }
    if (n.contains('卧推凳') || (n.contains('卧推') && n.contains('上斜'))) {
      // 居家上斜卧推通常需要凳；无凳时靠其它候选
      return const [HomeEquipment.bench, HomeEquipment.dumbbell];
    }
    if (n.contains('俯卧撑') ||
        (n.contains('深蹲') && !n.contains('哑铃') && !n.contains('杠铃')) ||
        n.contains('跪姿') ||
        n.contains('澳式') ||
        n.contains('平板卷腹') ||
        n.contains('自重')) {
      return const [HomeEquipment.none];
    }
    if (n.contains('杠铃') ||
        n.contains('器械') ||
        n.contains('龙门') ||
        n.contains('史密斯') ||
        n.contains('蝴蝶') ||
        n.contains('哈克') ||
        n.contains('倒蹬')) {
      // 典型健身房器械：居家默认不兼容
      return const [];
    }
    return const [HomeEquipment.none];
  }

  static bool _looksBodyweight(String name) {
    return name.contains('俯卧撑') ||
        name.contains('深蹲') ||
        name.contains('卷腹') ||
        name.contains('跪姿') ||
        name.contains('澳式') ||
        name.contains('自重') ||
        name.contains('引体');
  }
}
