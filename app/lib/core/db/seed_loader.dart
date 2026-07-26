import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import 'app_database.dart';

/// 与 assets/seed/meta.json 的 seedVersion 对齐；升版本会重灌只读 seed（不覆盖用户表）。
const _seedVersion = '5';

/// 首次启动 / seed 升级时把 assets 写入 Drift；永不覆盖用户表。
class SeedLoader {
  SeedLoader(this.db);

  final AppDatabase db;

  Future<void> ensureSeeded() async {
    final current = await db.metaGet('seedVersion');
    if (current == _seedVersion) return;

    final exercises =
        await _loadRoot('assets/seed/exercises.json', 'exercises');
    final templates =
        await _loadRoot('assets/seed/split_templates.json', 'templates');
    final anatomy = await _loadMap('assets/seed/anatomy.json');
    final foods = await _loadRoot('assets/seed/foods.json', 'foods');
    final cardio = await _loadRoot('assets/seed/cardio.json', 'items');
    final faq = await _loadRoot('assets/seed/faq.json', 'items');
    final dietRules = await _loadMap('assets/seed/diet_rules.json');
    final yogaRoot = await _loadMap('assets/seed/yoga.json');

    await db.transaction(() async {
      await db.delete(db.exercises).go();
      await db.delete(db.splitTemplates).go();
      await db.delete(db.anatomyRows).go();
      await db.delete(db.foods).go();
      await db.delete(db.cardioItems).go();
      await db.delete(db.faqItems).go();
      await db.delete(db.dietRulesStore).go();
      await db.delete(db.yogaSequences).go();

      await db.batch((b) {
        b.insertAll(
          db.exercises,
          [
            for (final raw in exercises)
              ExercisesCompanion.insert(
                name: (raw as Map<String, dynamic>)['name'] as String? ?? '',
                region: Value(raw['region'] as String? ?? ''),
                regionsJson: Value(jsonEncode(raw['regions'] ?? [])),
                jointsJson: Value(jsonEncode(raw['joints'] ?? [])),
                musclesJson: Value(jsonEncode(raw['muscles'] ?? [])),
                equipmentJson: Value(jsonEncode(raw['equipmentTags'] ?? [])),
                anatomyNote: Value(raw['anatomyNote'] as String?),
                source: Value(raw['source'] as String? ?? 'excel'),
                imagePath: Value(raw['imagePath'] as String?),
                cuesJson: Value(jsonEncode(raw['cues'] ?? [])),
                nameEn: Value(raw['nameEn'] as String?),
              ),
          ],
        );

        b.insertAll(
          db.splitTemplates,
          [
            for (final raw in templates)
              SplitTemplatesCompanion.insert(
                id: (raw as Map<String, dynamic>)['id'] as String,
                json: jsonEncode(raw),
              ),
          ],
        );

        b.insertAll(
          db.anatomyRows,
          [
            for (final row in (anatomy['tableA'] as List? ?? []))
              AnatomyRowsCompanion.insert(
                tableKind: 'A',
                json: jsonEncode(row),
              ),
            for (final row in (anatomy['tableB'] as List? ?? []))
              AnatomyRowsCompanion.insert(
                tableKind: 'B',
                json: jsonEncode(row),
              ),
          ],
        );

        b.insertAll(
          db.foods,
          [
            for (final raw in foods)
              FoodsCompanion.insert(
                name: (raw as Map<String, dynamic>)['name'] as String? ?? '',
                category: raw['category'] as String? ?? '',
                rate: (raw['rate'] as num?)?.toDouble() ?? 0,
                macroHint: raw['macroHint'] as String? ?? 'carb',
                note: Value(raw['note'] as String?),
              ),
          ],
        );

        b.insertAll(
          db.cardioItems,
          [
            for (final raw in cardio)
              CardioItemsCompanion.insert(
                name: (raw as Map<String, dynamic>)['name'] as String? ?? '',
                kcalPerKgPerHour:
                    (raw['kcalPerKgPerHour'] as num?)?.toDouble() ?? 0,
                category: Value(raw['category'] as String?),
              ),
          ],
        );

        b.insertAll(
          db.faqItems,
          [
            for (final raw in faq)
              FaqItemsCompanion.insert(
                goal: (raw as Map<String, dynamic>)['goal'] as String? ?? '',
                question: raw['question'] as String? ?? '',
                answer: raw['answer'] as String? ?? '',
              ),
          ],
        );

        b.insert(
          db.dietRulesStore,
          DietRulesStoreCompanion.insert(json: jsonEncode(dietRules)),
        );

        final yogaRows = <YogaSequencesCompanion>[];
        for (final raw in (yogaRoot['sequences'] as List? ?? [])) {
          final s = raw as Map<String, dynamic>;
          final id = s['id'] as String? ?? '';
          if (id.isEmpty) continue;
          yogaRows.add(
            YogaSequencesCompanion.insert(id: id, json: jsonEncode(s)),
          );
        }
        if (yogaRows.isNotEmpty) {
          b.insertAll(db.yogaSequences, yogaRows);
        }
      });
    });

    await db.rebuildExerciseFts();
    await db.metaSet('seedVersion', _seedVersion);
  }

  Future<List<dynamic>> _loadRoot(String asset, String key) async {
    final map = await _loadMap(asset);
    return (map[key] as List?) ?? [];
  }

  Future<Map<String, dynamic>> _loadMap(String asset) async {
    final raw = await rootBundle.loadString(asset);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
