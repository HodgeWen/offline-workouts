import 'dart:math';

import 'exercise_equipment.dart';
import 'models.dart';
import 'movement_family.dart';
import 'plan_composer.dart';

/// 容量驱动的动作处方引擎（规则引擎，无 LLM）。
///
/// ## 组数规则
/// - 模板 slot 给出总组数区间；先取中值，再按经验缩放：
///   新手 ×0.55、有基础 ×0.85、老手 ×1.0；再均分到所选动作。
/// - 新手单动作组数上限 3；能力偏低（max≤6）时也倾向 3 组。
///
/// ## 次数规则（自重 / 近极限）
/// - maxReps == 0：优先换成更容易变体（见 [_substitute]）。
/// - maxReps 1–6：每组目标约 40–70% max，或 max-2..max-1；
///   且 repsMin 永不超过用户 max。
/// - maxReps 7–12：约 55–80% max，并贴近经典 6–12。
/// - maxReps >12：可走经典肥大 8–12（女 10–15）。
///
/// ## 负重动作
/// - 侧平举：用基线重量作起始负荷；次数按侧平举 max 定带。
/// - 其它负重：无专项基线时给默认次数带，重量留空由用户填写。
///
/// ## 器械
/// - 居家：只保留与 [UserProfile.homeEquipment] 兼容的候选；
///   缺单杠则不出引体向上。
class PrescriptionEngine {
  const PrescriptionEngine({
    this.families = const MovementFamilyResolver(),
  });

  final MovementFamilyResolver families;

  List<PlannedExercise> pickSlotExercises({
    required SplitSlotView slot,
    required UserProfile profile,
  }) {
    if (slot.exercises.isEmpty) return const [];

    final isHome = profile.place == Place.home;
    final candidates = <SlotExerciseView>[];
    for (final ex in slot.exercises) {
      if (ExerciseEquipment.isCompatible(
        exerciseName: ex.name,
        isHome: isHome,
        homeEquipment: profile.homeEquipment,
      )) {
        candidates.add(ex);
      }
    }

    // 过滤后为空：放宽到模板候选里「看起来可自重」的项，或保留第一个
    final pool = candidates.isNotEmpty
        ? candidates
        : slot.exercises.where((e) => _isFallbackBodyweight(e.name)).toList();
    final usable = pool.isNotEmpty ? pool : [slot.exercises.first];

    final pickCount = min(
      max(slot.pickMin, 1),
      min(slot.pickMax, usable.length),
    );

    final chosen = <_ResolvedCandidate>[];
    for (var i = 0; i < usable.length && chosen.length < pickCount; i++) {
      final resolved = _resolveCandidate(usable[i], profile);
      if (chosen.any((c) => c.name == resolved.name)) continue;
      chosen.add(resolved);
    }
    if (chosen.isEmpty) {
      chosen.add(_resolveCandidate(usable.first, profile));
    }

    final templateTotal =
        ((slot.setsMin + slot.setsMax) / 2).round().clamp(2, 20);
    final scaledTotal =
        _scaleSetsByExperience(templateTotal, profile.experience);
    final per = max(2, (scaledTotal / chosen.length).round());

    return chosen.map((c) {
      final volume = _prescribeVolume(
        name: c.name,
        profile: profile,
        templateSetsPerExercise: per,
      );
      final note = [
        if (c.reason.isNotEmpty) c.reason,
        if (volume.note.isNotEmpty) volume.note,
      ].join('；');
      return PlannedExercise(
        name: c.name,
        region: slot.region,
        targetSets: volume.sets,
        repsMin: volume.repsMin,
        repsMax: volume.repsMax,
        joints: c.joints,
        targetWeightKg: volume.weightKg,
        note: note,
      );
    }).toList();
  }

  _ResolvedCandidate _resolveCandidate(
    SlotExerciseView ex,
    UserProfile profile,
  ) {
    final sub = _substitute(ex.name, profile);
    if (sub != null) {
      return _ResolvedCandidate(
        name: sub.name,
        joints: ex.joints,
        reason: sub.reason,
      );
    }
    return _ResolvedCandidate(
      name: ex.name,
      joints: ex.joints,
      reason: '',
    );
  }

  /// max=0 或器械不匹配时的更容易变体。
  _SubResult? _substitute(String name, UserProfile profile) {
    final cap = profile.capacity;
    final gear = profile.homeEquipment.toSet();
    final isHome = profile.place == Place.home;

    if (name.contains('引体')) {
      final hasBar = !isHome || gear.contains(HomeEquipment.pullUpBar);
      final hasBand = !isHome || gear.contains(HomeEquipment.resistanceBand);
      if (!hasBar || cap.pullUpMaxReps == 0) {
        if (hasBar && hasBand) {
          return const _SubResult(
            name: '引体向上（可用弹力带减重）',
            reason: '引体最大次数为 0 或无单杠能力，改用弹力带辅助',
          );
        }
        if (hasBand) {
          return const _SubResult(
            name: '弹力带俯身划船',
            reason: '无单杠或尚不能引体，改用弹力带划船',
          );
        }
        return const _SubResult(
          name: '澳式划船（桌下水平划船）',
          reason: '无单杠/弹力带时用水平划船建立拉力',
        );
      }
    }

    if (name.contains('俯卧撑') &&
        !name.contains('跪姿') &&
        cap.pushUpMaxReps == 0) {
      return const _SubResult(
        name: '跪姿俯卧撑',
        reason: '标准俯卧撑暂做不到，先用跪姿建立推胸力量',
      );
    }

    if (isHome &&
        name.contains('深蹲') &&
        name.contains('哑铃') &&
        !gear.contains(HomeEquipment.dumbbell)) {
      return const _SubResult(
        name: '自重深蹲',
        reason: '未选择哑铃，改用自重深蹲',
      );
    }

    return null;
  }

  _VolumeResult _prescribeVolume({
    required String name,
    required UserProfile profile,
    required int templateSetsPerExercise,
  }) {
    final cap = profile.capacity;
    final kind = _classify(name);
    final classicMin = profile.sex == Sex.female ? 10 : 8;
    final classicMax = profile.sex == Sex.female ? 15 : 12;
    final familyMax = families.estimatedMaxReps(name, cap);

    var sets = templateSetsPerExercise;
    if (profile.experience == Experience.beginner) {
      sets = min(sets, 3);
    }

    late final int repsMin;
    late final int repsMax;
    double? weight;
    late final String note;

    switch (kind) {
      case _MovementKind.pullUp:
        final maxR = name.contains('弹力带')
            ? max(cap.pullUpMaxReps, 6)
            : (familyMax ?? cap.pullUpMaxReps);
        final band = _repsFromMax(maxR, classicMin, classicMax);
        repsMin = band.min;
        repsMax = band.max;
        if (maxR > 0 && maxR <= 6) sets = min(sets, 3);
        note = maxR <= 0
            ? '按入门可完成次数安排'
            : '按引体族容量（最大约 $maxR 次）安排可完成次数';
      case _MovementKind.pushUp:
        final maxR = name.contains('跪姿')
            ? max(cap.pushUpMaxReps, 8)
            : (familyMax ?? cap.pushUpMaxReps);
        final band = _repsFromMax(maxR, classicMin, classicMax);
        repsMin = band.min;
        repsMax = band.max;
        if (maxR > 0 && maxR <= 6) sets = min(sets, 3);
        note = maxR <= 0
            ? '俯卧撑基线为 0，按可完成变体安排'
            : '按俯卧撑族容量（最大约 $maxR 次）个性化次数';
      case _MovementKind.squatBw:
        final maxR = familyMax ?? (cap.squatMaxReps > 0 ? cap.squatMaxReps : 15);
        final band = _repsFromMax(maxR, classicMin, classicMax);
        repsMin = band.min;
        repsMax = band.max;
        if (maxR > 0 && maxR <= 6) sets = min(sets, 3);
        note = cap.squatMaxReps <= 0
            ? '未填深蹲基线，按一般入门次数'
            : '按深蹲族容量（最大约 $maxR 次）安排';
      case _MovementKind.lateralRaise:
        final maxR = familyMax ?? cap.lateralRaiseMaxReps;
        weight = cap.lateralRaiseWeightKg;
        if (maxR > 0) {
          final band = _repsFromMax(maxR, 8, 15);
          repsMin = band.min;
          repsMax = band.max;
          if (maxR <= 6) sets = min(sets, 3);
          note = weight == null
              ? '按侧平举最大 $maxR 次安排（未填重量）'
              : '起始 ${weight}kg，按侧平举最大 $maxR 次安排次数';
        } else {
          repsMin = classicMin;
          repsMax = classicMax;
          note = weight == null
              ? '未填侧平举基线，使用经典次数带'
              : '起始 ${weight}kg，次数用经典肥大区间';
        }
      case _MovementKind.weightedOther:
        if (familyMax != null && familyMax > 0 && familyMax <= 12) {
          final band = _repsFromMax(familyMax, classicMin, classicMax);
          repsMin = band.min;
          repsMax = band.max;
          note = '同族基线估计最大约 $familyMax 次；重量请按自身能力填写';
        } else {
          repsMin = classicMin;
          repsMax = classicMax;
          note = '负重动作：次数按经验水平；重量请按自身能力填写';
        }
        if (profile.experience == Experience.beginner) {
          sets = min(sets, 3);
        }
      case _MovementKind.general:
        if (name.contains('澳式') || name.contains('水平划船')) {
          final est = familyMax ?? max(cap.pullUpMaxReps, 8);
          final band = _repsFromMax(est, 6, 12);
          repsMin = band.min;
          repsMax = band.max;
          sets = min(
            sets,
            profile.experience == Experience.beginner ? 3 : sets,
          );
          note = '水平拉力替代（继承引体族估计），次数控制在可完成范围';
        } else if (familyMax != null && familyMax > 0) {
          final band = _repsFromMax(familyMax, classicMin, classicMax);
          repsMin = band.min;
          repsMax = band.max;
          if (profile.experience == Experience.beginner) {
            sets = min(sets, 3);
          }
          note = '按动作族容量估计（约 $familyMax 次）安排';
        } else {
          repsMin = classicMin;
          repsMax = classicMax;
          if (profile.experience == Experience.beginner) {
            sets = min(sets, 3);
          }
          note = profile.experience == Experience.beginner
              ? '新手减量：组数低于模板上限，次数取经典肥大带'
              : '按模板与经验水平安排';
        }
    }

    var minR = repsMin;
    var maxR = repsMax;
    // 硬约束：有明确 max 时 repsMin 不得超过 max
    final hardMax = families.hardMaxReps(name, cap);
    if (hardMax != null && hardMax > 0 && minR > hardMax) {
      minR = max(1, hardMax - 1);
      maxR = hardMax;
    }
    if (maxR < minR) maxR = minR;

    return _VolumeResult(
      sets: sets.clamp(2, 8),
      repsMin: minR,
      repsMax: maxR,
      weightKg: weight,
      note: note,
    );
  }

  /// 由最大次数推导每组目标区间。
  ({int min, int max}) _repsFromMax(
    int maxReps,
    int classicMin,
    int classicMax,
  ) {
    if (maxReps <= 0) {
      return (min: max(3, classicMin - 2), max: min(8, classicMax));
    }
    if (maxReps <= 6) {
      // 40–70% 或接近 max-1
      final lo = max(1, (maxReps * 0.4).floor());
      final hi = max(
        lo,
        min(maxReps, max(maxReps - 1, (maxReps * 0.7).round())),
      );
      final repsMax = min(maxReps, max(hi, lo));
      final repsMin = min(repsMax, max(1, min(lo, maxReps - 1)));
      return (min: repsMin, max: repsMax);
    }
    if (maxReps <= 12) {
      final lo = max(classicMin - 2, (maxReps * 0.55).round());
      final hi = min(classicMax, max(lo + 1, (maxReps * 0.8).round()));
      return (min: min(lo, maxReps), max: min(hi, maxReps));
    }
    return (
      min: classicMin,
      max: min(classicMax, max(classicMin + 2, (maxReps * 0.6).round())),
    );
  }

  int _scaleSetsByExperience(int templateTotal, Experience exp) {
    final factor = switch (exp) {
      Experience.beginner => 0.55,
      Experience.intermediate => 0.85,
      Experience.advanced => 1.0,
    };
    return max(2, (templateTotal * factor).round());
  }

  _MovementKind _classify(String name) {
    if (name.contains('引体')) return _MovementKind.pullUp;
    if (name.contains('俯卧撑')) return _MovementKind.pushUp;
    if (name.contains('侧平举')) return _MovementKind.lateralRaise;
    if (name.contains('自重深蹲') ||
        name == '自重深蹲' ||
        (name.contains('深蹲') &&
            !name.contains('哑铃') &&
            !name.contains('杠铃') &&
            !name.contains('史密斯'))) {
      return _MovementKind.squatBw;
    }
    if (name.contains('哑铃') ||
        name.contains('杠铃') ||
        name.contains('器械') ||
        name.contains('史密斯') ||
        name.contains('壶铃')) {
      return _MovementKind.weightedOther;
    }
    return _MovementKind.general;
  }

  bool _isFallbackBodyweight(String name) {
    return name.contains('俯卧撑') ||
        name.contains('弹力带') ||
        name.contains('哑铃') ||
        name.contains('自重') ||
        name.contains('卷腹');
  }
}

enum _MovementKind {
  pullUp,
  pushUp,
  squatBw,
  lateralRaise,
  weightedOther,
  general,
}

class _ResolvedCandidate {
  const _ResolvedCandidate({
    required this.name,
    required this.joints,
    required this.reason,
  });

  final String name;
  final List<String> joints;
  final String reason;
}

class _SubResult {
  const _SubResult({required this.name, required this.reason});

  final String name;
  final String reason;
}

class _VolumeResult {
  const _VolumeResult({
    required this.sets,
    required this.repsMin,
    required this.repsMax,
    required this.note,
    this.weightKg,
  });

  final int sets;
  final int repsMin;
  final int repsMax;
  final double? weightKg;
  final String note;
}
