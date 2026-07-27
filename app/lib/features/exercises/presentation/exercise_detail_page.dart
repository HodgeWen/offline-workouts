import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/anatomy_format.dart';
import 'exercise_image.dart';

class ExerciseDetailPage extends ConsumerStatefulWidget {
  const ExerciseDetailPage({super.key, required this.exerciseId});

  final int exerciseId;

  @override
  ConsumerState<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends ConsumerState<ExerciseDetailPage> {
  late final Future<_Detail> _future = _load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_Detail>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          // 根 navigator 页需自带氛围背景，否则透明 Scaffold 会透出系统深色窗体
          return AtmosphereBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(title: const Text('动作详情')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '加载失败：${snap.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        if (!snap.hasData) {
          return AtmosphereBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(title: const Text('动作详情')),
              body: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final d = snap.data!;
        return AtmosphereBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(title: Text(d.name)),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                if (d.imagePath != null && d.imagePath!.isNotEmpty) ...[
                  AspectRatio(
                    aspectRatio: 1.2,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 与列表一致限制解码宽度，避免大图全尺寸解码卡顿
                        final logicalW = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : MediaQuery.sizeOf(context).width;
                        return ExerciseImage(
                          imagePath: d.imagePath!,
                          memCacheWidth: logicalW.ceil().clamp(1, 2048),
                        );
                      },
                    ),
                  ),
                  if (d.imageAttribution.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 12),
                      child: Text(
                        d.imageAttribution,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    const SizedBox(height: 12),
                ],
                _section(context, '部位', d.regions.join('、').ifEmpty('未标注')),
                _section(context, '器械', d.equipment.join('、').ifEmpty('综合')),
                if (d.nameEn.isNotEmpty) _section(context, '英文名', d.nameEn),
                _section(context, '关节活动', d.joints.join('、').ifEmpty('未标注')),
                _section(context, '目标肌群', d.muscles.join('、').ifEmpty('见解剖说明')),
                if (d.cues.isNotEmpty)
                  _section(
                    context,
                    '动作要点',
                    d.cues.map((c) => '· $c').join('\n'),
                  ),
                _section(
                  context,
                  '解剖学说明',
                  formatAnatomyCopy(
                    d.anatomyNote.ifEmpty('暂无详细解剖说明，可结合下方关节活动对照。'),
                  ),
                ),
                if (d.relatedJoints.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '相关关节活动',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...d.relatedJoints.map(
                    (r) => Card(
                      child: ListTile(
                        title: Text('${r['joint']}${r['action']}'),
                        subtitle: Text(
                          [
                            if (r['description'] != null)
                              formatAnatomyCopy('${r['description']}'),
                            if (r['example'] != null) '示例 · ${r['example']}',
                            if ((r['muscles'] as List?)?.isNotEmpty == true)
                              '肌肉 · ${(r['muscles'] as List).join('、')}',
                          ].whereType<String>().join('\n'),
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  ),
                ],
                if (d.relatedMuscles.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '肌束职责与推荐动作',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...d.relatedMuscles.map(
                    (r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${r['muscle']}'),
                      subtitle: Text(
                        '${r['joint']}${r['action']}'
                        '${r['example'] != null ? ' · ${r['example']}' : ''}',
                      ),
                    ),
                  ),
                ],
                if (d.relatedExercises.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('相关动作', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: d.relatedExercises
                        .map((n) => Chip(label: Text(n)))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }

  Future<_Detail> _load() async {
    final db = await ref.read(appDatabaseProvider.future);
    final ex = await (db.select(db.exercises)
          ..where((t) => t.id.equals(widget.exerciseId)))
        .getSingleOrNull();
    if (ex == null) {
      throw StateError('找不到该动作（id=${widget.exerciseId}）');
    }
    final joints = _decodeList(ex.jointsJson);
    final muscles = _decodeList(ex.musclesJson);
    final regions = _decodeList(ex.regionsJson);
    if (regions.isEmpty && ex.region.isNotEmpty) regions.add(ex.region);
    final equipment = _decodeList(ex.equipmentJson);

    // 解剖对照表很小（约 40 行），一次读入后在内存匹配即可。
    final anatomy = await db.select(db.anatomyRows).get();
    final relatedJoints = <Map<String, dynamic>>[];
    final relatedMuscles = <Map<String, dynamic>>[];
    for (final row in anatomy) {
      final map = jsonDecode(row.json) as Map<String, dynamic>;
      if (row.tableKind == 'A') {
        final action = '${map['joint'] ?? ''}${map['action'] ?? ''}';
        final hit = joints.any(
          (j) =>
              j.contains('${map['action']}') ||
              action.contains(j.replaceAll(RegExp(r'\[.*?\]'), '')),
        );
        final muscleHit = ((map['muscles'] as List?) ?? []).any(
          (m) => muscles.any((x) => '$m'.contains(x) || x.contains('$m')),
        );
        if (hit || muscleHit) relatedJoints.add(map);
      } else {
        final m = map['muscle'] as String? ?? '';
        if (muscles.any((x) => m.contains(x) || x.contains(m))) {
          relatedMuscles.add(map);
        }
      }
    }

    final related = await (db.select(db.exercises)
          ..where((t) => t.region.equals(ex.region))
          ..where((t) => t.id.isNotValue(ex.id))
          ..limit(8))
        .get();

    final cues = _decodeList(ex.cuesJson);
    final imagePath = ex.imagePath;
    final attribution = imagePath == null || imagePath.isEmpty
        ? ''
        : '示意图：Everkinetic（CC-BY-SA 4.0）';

    return _Detail(
      name: ex.name,
      nameEn: ex.nameEn ?? '',
      regions: regions,
      joints: joints,
      muscles: muscles,
      equipment: equipment,
      anatomyNote: ex.anatomyNote ?? '',
      cues: cues,
      imagePath: imagePath,
      imageAttribution: attribution,
      relatedJoints: relatedJoints.take(6).toList(),
      relatedMuscles: relatedMuscles.take(8).toList(),
      relatedExercises: related.map((e) => e.name).toList(),
    );
  }

  List<String> _decodeList(String raw) {
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }
}

class _Detail {
  _Detail({
    required this.name,
    required this.nameEn,
    required this.regions,
    required this.joints,
    required this.muscles,
    required this.equipment,
    required this.anatomyNote,
    required this.cues,
    required this.imagePath,
    required this.imageAttribution,
    required this.relatedJoints,
    required this.relatedMuscles,
    required this.relatedExercises,
  });

  final String name;
  final String nameEn;
  final List<String> regions;
  final List<String> joints;
  final List<String> muscles;
  final List<String> equipment;
  final String anatomyNote;
  final List<String> cues;
  final String? imagePath;
  final String imageAttribution;
  final List<Map<String, dynamic>> relatedJoints;
  final List<Map<String, dynamic>> relatedMuscles;
  final List<String> relatedExercises;
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
