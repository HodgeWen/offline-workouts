import 'capacity.dart';

/// 动作族：当精确最大次数未知时，用同族基线估计容量。
enum MovementFamily {
  pullUp,
  pushUp,
  squat,
  lateralRaise,
  hinge,
  row,
  press,
  curl,
  core,
  other,
}

/// 将动作名映射到动作族，并给出可用于处方的估计最大次数。
class MovementFamilyResolver {
  const MovementFamilyResolver();

  MovementFamily familyOf(String name) {
    final n = name;
    if (n.contains('引体') || n.contains('高位下拉') || n.contains('器械下拉')) {
      return MovementFamily.pullUp;
    }
    if (n.contains('澳式') ||
        n.contains('水平划船') ||
        n.contains('俯身划船') ||
        (n.contains('坐姿') && n.contains('划船')) ||
        n.contains('T杆') ||
        n.contains('面拉') ||
        (n.contains('划船') && !n.contains('提拉'))) {
      return MovementFamily.row;
    }
    if (n.contains('俯卧撑') ||
        n.contains('卧推') ||
        n.contains('推胸') ||
        n.contains('夹胸') ||
        n.contains('臂屈伸') && n.contains('双杠')) {
      return MovementFamily.pushUp;
    }
    if (n.contains('侧平举')) return MovementFamily.lateralRaise;
    if (n.contains('深蹲') || n.contains('箭步') || n.contains('登阶') || n.contains('哈克') || n.contains('倒蹬')) {
      return MovementFamily.squat;
    }
    if (n.contains('硬拉') ||
        n.contains('臀桥') ||
        n.contains('臀冲') ||
        n.contains('髋铰链') ||
        n.contains('早安') ||
        n.contains('腿弯举') ||
        n.contains('罗马尼亚')) {
      return MovementFamily.hinge;
    }
    if (n.contains('推举') || n.contains('前平举') || n.contains('提拉')) {
      return MovementFamily.press;
    }
    if (n.contains('弯举')) return MovementFamily.curl;
    if (n.contains('卷腹') ||
        n.contains('平板') ||
        n.contains('死虫') ||
        n.contains('鸟狗') ||
        n.contains('悬垂举腿')) {
      return MovementFamily.core;
    }
    return MovementFamily.other;
  }

  /// 估计「可用于次数处方」的最大次数；无可靠估计时返回 null。
  int? estimatedMaxReps(String name, CapacityBaseline cap) {
    final family = familyOf(name);
    switch (family) {
      case MovementFamily.pullUp:
        if (name.contains('弹力带') && !name.contains('划船')) {
          return cap.pullUpMaxReps > 0 ? cap.pullUpMaxReps : 6;
        }
        if (name.contains('引体')) {
          return cap.pullUpMaxReps > 0 ? cap.pullUpMaxReps : null;
        }
        // 高位下拉等：用引体基线的宽松估计（机器辅助更容易）
        if (cap.pullUpMaxReps > 0) {
          return (cap.pullUpMaxReps * 1.5).round().clamp(6, 15);
        }
        return null;
      case MovementFamily.row:
        // 水平拉：引体弱时仍可做较高次数
        if (cap.pullUpMaxReps > 0) {
          return (cap.pullUpMaxReps + 6).clamp(8, 20);
        }
        return 12;
      case MovementFamily.pushUp:
        if (name.contains('跪姿')) {
          return cap.pushUpMaxReps > 0 ? (cap.pushUpMaxReps + 4).clamp(8, 20) : 10;
        }
        if (name.contains('俯卧撑')) {
          return cap.pushUpMaxReps > 0 ? cap.pushUpMaxReps : null;
        }
        // 卧推等负重：不直接用俯卧撑次数当 hard max
        if (cap.pushUpMaxReps > 0) {
          return (cap.pushUpMaxReps * 0.7).round().clamp(6, 15);
        }
        return null;
      case MovementFamily.squat:
        if (name.contains('自重') ||
            (name.contains('深蹲') &&
                !name.contains('哑铃') &&
                !name.contains('杠铃') &&
                !name.contains('史密斯') &&
                !name.contains('高脚杯'))) {
          return cap.squatMaxReps > 0 ? cap.squatMaxReps : 15;
        }
        if (cap.squatMaxReps > 0) {
          return (cap.squatMaxReps * 0.6).round().clamp(6, 15);
        }
        return null;
      case MovementFamily.lateralRaise:
        return cap.lateralRaiseMaxReps > 0 ? cap.lateralRaiseMaxReps : null;
      case MovementFamily.hinge:
        if (cap.squatMaxReps > 0) {
          return (cap.squatMaxReps * 0.7).round().clamp(6, 15);
        }
        return null;
      case MovementFamily.press:
      case MovementFamily.curl:
      case MovementFamily.core:
      case MovementFamily.other:
        return null;
    }
  }

  /// 硬上限：仅对「明确自重近极限」动作生效。
  int? hardMaxReps(String name, CapacityBaseline cap) {
    if (name.contains('引体') &&
        !name.contains('弹力带') &&
        !name.contains('澳式')) {
      return cap.pullUpMaxReps > 0 ? cap.pullUpMaxReps : null;
    }
    if (name.contains('俯卧撑') && !name.contains('跪姿')) {
      return cap.pushUpMaxReps > 0 ? cap.pushUpMaxReps : null;
    }
    if (name.contains('自重深蹲') || name == '自重深蹲') {
      return cap.squatMaxReps > 0 ? cap.squatMaxReps : null;
    }
    if (name.contains('侧平举')) {
      return cap.lateralRaiseMaxReps > 0 ? cap.lateralRaiseMaxReps : null;
    }
    return null;
  }
}
