import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/core/db/app_database.dart';
import 'package:workout_app/core/db/seed_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ensureSeeded 完成并重建 FTS', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await SeedLoader(db).ensureSeeded();
    expect(await db.metaGet('seedVersion'), '5');

    final exercises = await db.select(db.exercises).get();
    expect(exercises, isNotEmpty);

    // 第二次应 no-op
    await SeedLoader(db).ensureSeeded();
    expect((await db.select(db.exercises).get()).length, exercises.length);

    final hits = await db.exerciseDao.search('卧推');
    expect(hits, isA<List>());
  });
}
