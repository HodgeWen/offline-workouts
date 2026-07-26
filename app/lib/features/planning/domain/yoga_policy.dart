import 'models.dart';

/// 单个体式（来自 seed yoga.json）。
class YogaPose {
  const YogaPose({
    required this.id,
    required this.name,
    this.nameSa = '',
    this.durationSec = 40,
    this.breathCue = '',
    this.cues = const [],
    this.focus = const [],
  });

  final String id;
  final String name;
  final String nameSa;
  final int durationSec;
  final String breathCue;
  final List<String> cues;
  final List<String> focus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameSa': nameSa,
        'durationSec': durationSec,
        'breathCue': breathCue,
        'cues': cues,
        'focus': focus,
      };

  factory YogaPose.fromJson(Map<String, dynamic> json) => YogaPose(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        nameSa: json['nameSa'] as String? ?? '',
        durationSec: (json['durationSec'] as num?)?.toInt() ?? 40,
        breathCue: json['breathCue'] as String? ?? '',
        cues: (json['cues'] as List? ?? []).cast<String>(),
        focus: (json['focus'] as List? ?? []).cast<String>(),
      );
}

class YogaSequence {
  const YogaSequence({
    required this.id,
    required this.title,
    required this.level,
    required this.durationMinutes,
    required this.tags,
    required this.intent,
    required this.poses,
  });

  final String id;
  final String title;
  final String level;
  final int durationMinutes;
  final List<String> tags;
  final String intent;
  final List<YogaPose> poses;

  factory YogaSequence.fromJson(Map<String, dynamic> json) => YogaSequence(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        level: json['level'] as String? ?? 'beginner',
        durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 15,
        tags: (json['tags'] as List? ?? []).cast<String>(),
        intent: json['intent'] as String? ?? '',
        poses: (json['poses'] as List? ?? [])
            .map((e) => YogaPose.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// 瑜伽/恢复策略：不插入力量队列，作为「今日可选」。
class YogaPolicy {
  const YogaPolicy({
    required this.enabled,
    required this.sequenceId,
    required this.sequenceTitle,
    required this.durationMinutes,
    required this.offerMode,
    required this.guidance,
    this.poses = const [],
    this.tags = const [],
  });

  final bool enabled;
  final String sequenceId;
  final String sequenceTitle;
  final int durationMinutes;
  /// restDayOptional | recoveryBetweenStrength | none
  final String offerMode;
  final String guidance;
  final List<YogaPose> poses;
  final List<String> tags;

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'sequenceId': sequenceId,
        'sequenceTitle': sequenceTitle,
        'durationMinutes': durationMinutes,
        'offerMode': offerMode,
        'guidance': guidance,
        'poses': poses.map((e) => e.toJson()).toList(),
        'tags': tags,
      };

  factory YogaPolicy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const YogaPolicy(
        enabled: false,
        sequenceId: '',
        sequenceTitle: '',
        durationMinutes: 0,
        offerMode: 'none',
        guidance: '',
      );
    }
    return YogaPolicy(
      enabled: json['enabled'] as bool? ?? false,
      sequenceId: json['sequenceId'] as String? ?? '',
      sequenceTitle: json['sequenceTitle'] as String? ?? '',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      offerMode: json['offerMode'] as String? ?? 'none',
      guidance: json['guidance'] as String? ?? '',
      poses: (json['poses'] as List? ?? [])
          .map((e) => YogaPose.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (json['tags'] as List? ?? []).cast<String>(),
    );
  }
}

/// 瑜伽编排引擎。
///
/// - 女性默认开启兴趣（可关）；男性需显式开启
/// - 不强制日期：休息日可选，或力量间隙恢复
/// - 按标签挑选序列（髋部打开 / 温和力量 / 经期友好等）
class YogaPolicyEngine {
  const YogaPolicyEngine();

  YogaPolicy build({
    required UserProfile profile,
    required List<YogaSequence> sequences,
    String? preferSequenceId,
  }) {
    final interested = profile.includeYoga;
    if (!interested || sequences.isEmpty) {
      return YogaPolicy(
        enabled: false,
        sequenceId: '',
        sequenceTitle: '',
        durationMinutes: 0,
        offerMode: 'none',
        guidance: interested
            ? '暂无可用瑜伽序列数据。'
            : '未开启瑜伽。可在资料中打开「瑜伽/恢复兴趣」；'
                '女性默认建议开启作为休息日可选恢复。',
      );
    }

    final seq = _pick(profile, sequences, preferSequenceId);
    final offerMode = profile.sex == Sex.female
        ? 'recoveryBetweenStrength'
        : 'restDayOptional';

    final sexHint = profile.sex == Sex.female
        ? '作为力量训练之间的恢复选项（今日可选，不推进分化队列）。'
        : '建议放在休息日作为可选恢复，不推进分化队列。';

    return YogaPolicy(
      enabled: true,
      sequenceId: seq.id,
      sequenceTitle: seq.title,
      durationMinutes: seq.durationMinutes,
      offerMode: offerMode,
      guidance: '${seq.intent} $sexHint',
      poses: seq.poses,
      tags: seq.tags,
    );
  }

  YogaSequence _pick(
    UserProfile profile,
    List<YogaSequence> sequences,
    String? preferSequenceId,
  ) {
    if (preferSequenceId != null) {
      for (final s in sequences) {
        if (s.id == preferSequenceId) return s;
      }
    }

    bool has(YogaSequence s, String tag) => s.tags.contains(tag);

    // 伤病含髋/腰时优先温和恢复
    final injuries = profile.injuries.toLowerCase();
    if (injuries.contains('腰') || injuries.contains('髋')) {
      final rest = sequences.where((s) => has(s, 'recovery')).toList();
      if (rest.isNotEmpty) return rest.first;
    }

    if (profile.sex == Sex.female) {
      final hips = sequences.where((s) => has(s, 'women_focused') || has(s, 'hips')).toList();
      if (hips.isNotEmpty) return hips.first;
    }

    if (profile.experience == Experience.beginner) {
      final easy = sequences.where((s) => has(s, 'recovery') || has(s, 'rest_day')).toList();
      if (easy.isNotEmpty) return easy.first;
    }

    return sequences.first;
  }
}
