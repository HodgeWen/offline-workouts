import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// 应用元数据（seed 版本等）
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// 用户资料（单行）
@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get json => text()();
  BoolColumn get onboardingDone => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 当前生效计划
@DataClassName('ActivePlanRow')
class ActivePlans extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 计划队列会话（按 sequenceIndex 排序，不绑定日历）
@DataClassName('PlannedSessionRow')
class PlannedSessions extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  IntColumn get sequenceIndex => integer()();
  TextColumn get type => text()(); // strength|cardio|rest|yoga
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 训练日志（按实际完成日归档）
@DataClassName('WorkoutLogRow')
class WorkoutLogs extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get date => text()();
  TextColumn get type => text()();
  TextColumn get status => text()();
  TextColumn get json => text()();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 动作库
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get region => text().withDefault(const Constant(''))();
  TextColumn get regionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get jointsJson => text().withDefault(const Constant('[]'))();
  TextColumn get musclesJson => text().withDefault(const Constant('[]'))();
  TextColumn get equipmentJson => text().withDefault(const Constant('[]'))();
  TextColumn get anatomyNote => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('excel'))();
  /// 相对 asset 路径，如 assets/exercises/images/ek_pull-ups.svg；可空。
  TextColumn get imagePath => text().nullable()();
  TextColumn get cuesJson => text().withDefault(const Constant('[]'))();
  TextColumn get nameEn => text().nullable()();
}

/// 瑜伽序列（seed）
class YogaSequences extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 解剖对照扁平存储（tableKind: A=关节活动，B=肌束职责）
class AnatomyRows extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get tableKind => text()(); // A | B
  TextColumn get json => text()();
}

class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get rate => real()();
  TextColumn get macroHint => text()();
  TextColumn get note => text().nullable()();
}

class CardioItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get kcalPerKgPerHour => real()();
  TextColumn get category => text().nullable()();
}

class FaqItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goal => text()();
  TextColumn get question => text()();
  TextColumn get answer => text()();
}

class SplitTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class DietRulesStore extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// FTS5 虚表：动作搜索
@DriftAccessor(tables: [Exercises])
class ExerciseDao extends DatabaseAccessor<AppDatabase> with _$ExerciseDaoMixin {
  ExerciseDao(super.db);

  Future<List<Exercise>> search(String query, {int limit = 200}) async {
    final q = query.trim();
    if (q.isEmpty) {
      return (select(exercises)
            ..orderBy([(t) => OrderingTerm.asc(t.name)])
            ..limit(limit))
          .get();
    }
    // FTS5 特殊字符会导致 MATCH 失败；清洗后仍空则回退 LIKE。
    final ftsQuery = _ftsPrefixQuery(q);
    if (ftsQuery != null) {
      try {
        final rows = await customSelect(
          '''
          SELECT e.* FROM exercises e
          JOIN exercises_fts f ON e.id = f.rowid
          WHERE exercises_fts MATCH ?
          LIMIT ?
          ''',
          variables: [Variable.withString(ftsQuery), Variable.withInt(limit)],
          readsFrom: {exercises},
        ).get();
        return rows.map((r) => exercises.map(r.data)).toList();
      } catch (_) {
        // 回退 LIKE
      }
    }
    final pattern = '%$q%';
    return (select(exercises)
          ..where(
            (t) =>
                t.name.like(pattern) |
                t.region.like(pattern) |
                t.musclesJson.like(pattern) |
                t.jointsJson.like(pattern),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit))
        .get();
  }

  /// 生成安全的 FTS5 前缀查询；无法构造时返回 null。
  static String? _ftsPrefixQuery(String raw) {
    // 去掉 FTS5 运算符/引号，避免 MATCH 语法错误
    final cleaned = raw
        .replaceAll(RegExp(r'''["*\^\:\(\)\{\}\[\]\~\-]'''), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return null;
    final tokens = cleaned
        .split(' ')
        .where((t) => t.isNotEmpty)
        .map((t) => '$t*')
        .toList();
    if (tokens.isEmpty) return null;
    return tokens.join(' ');
  }
}

@DriftDatabase(
  tables: [
    AppMeta,
    UserProfiles,
    ActivePlans,
    PlannedSessions,
    WorkoutLogs,
    Exercises,
    AnatomyRows,
    Foods,
    CardioItems,
    FaqItems,
    SplitTemplates,
    DietRulesStore,
    YogaSequences,
  ],
  daos: [ExerciseDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _recreateExerciseFts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // schema v2：planned_sessions 改为 sequenceIndex 队列（无日历 date）
            await customStatement('DROP TABLE IF EXISTS planned_sessions;');
            await m.createTable(plannedSessions);
            await delete(activePlans).go();
          }
          if (from < 3) {
            await m.addColumn(exercises, exercises.imagePath);
            await m.addColumn(exercises, exercises.cuesJson);
            await m.addColumn(exercises, exercises.nameEn);
            await m.createTable(yogaSequences);
            await metaSet('seedVersion', '');
          }
          if (from < 4) {
            // FTS 列名必须与 content 表一致；重建索引以免升级后搜索为空
            await rebuildExerciseFts();
          }
        },
      );

  /// external-content FTS5 的列名必须与 content 表一致，否则 DELETE/rebuild 会失败。
  Future<void> _recreateExerciseFts() async {
    await customStatement('DROP TABLE IF EXISTS exercises_fts;');
    await customStatement('''
      CREATE VIRTUAL TABLE exercises_fts USING fts5(
        name, region, muscles_json, joints_json,
        content='exercises', content_rowid='id'
      );
    ''');
  }

  Future<void> rebuildExerciseFts() async {
    await _recreateExerciseFts();
    await customStatement(
      "INSERT INTO exercises_fts(exercises_fts) VALUES('rebuild');",
    );
  }

  Future<String?> metaGet(String key) async {
    final row = await (select(appMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> metaSet(String key, String value) async {
    await into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion(key: Value(key), value: Value(value)),
    );
  }

  static Future<AppDatabase> open() async {
    return AppDatabase(
      driftDatabase(
        name: 'workout',
        native: const DriftNativeOptions(shareAcrossIsolates: true),
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      ),
    );
  }
}

/// JSON 编解码小工具
String encodeJson(Object value) => jsonEncode(value);

Map<String, dynamic> decodeMap(String raw) =>
    jsonDecode(raw) as Map<String, dynamic>;
