import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/exercises/presentation/exercise_image.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed 动作图在 AssetBundle 中可加载', () async {
    final data = await rootBundle.load(
      'assets/exercises/images/ek_pull-ups.png',
    );
    expect(data.lengthInBytes, greaterThan(1000));
  });

  testWidgets('ExerciseImage 渲染已知 asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: ExerciseImage(
              imagePath: 'assets/exercises/images/ek_pull-ups.png',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('配图加载失败'), findsNothing);
  });
}
