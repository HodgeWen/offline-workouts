import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/planning/domain/capacity.dart';
import 'package:workout_app/features/planning/domain/image_match.dart';
import 'package:workout_app/features/planning/domain/movement_family.dart';

void main() {
  const resolver = MovementFamilyResolver();
  const match = ImageMatchHelper();

  group('MovementFamilyResolver', () {
    test('引体族 / 俯卧撑族 / 侧平举族分类', () {
      expect(resolver.familyOf('引体向上'), MovementFamily.pullUp);
      expect(resolver.familyOf('高位下拉'), MovementFamily.pullUp);
      expect(resolver.familyOf('俯卧撑'), MovementFamily.pushUp);
      expect(resolver.familyOf('哑铃卧推'), MovementFamily.pushUp);
      expect(resolver.familyOf('哑铃侧平举'), MovementFamily.lateralRaise);
      expect(resolver.familyOf('澳式划船（桌下水平划船）'), MovementFamily.row);
    });

    test('同族继承：有引体基线时划船获得估计', () {
      const cap = CapacityBaseline(pullUpMaxReps: 6);
      final est = resolver.estimatedMaxReps('澳式划船（桌下水平划船）', cap);
      expect(est, isNotNull);
      expect(est!, greaterThanOrEqualTo(8));
    });

    test('硬上限：标准引体不超过用户 max', () {
      const cap = CapacityBaseline(pullUpMaxReps: 6);
      expect(resolver.hardMaxReps('引体向上', cap), 6);
      expect(resolver.hardMaxReps('高位下拉', cap), isNull);
    });
  });

  group('ImageMatchHelper', () {
    test('归一化去掉括号注释', () {
      expect(
        match.normalize('引体向上（可用弹力带减重）'),
        match.normalize('引体向上'),
      );
    });

    test('低于阈值不配图', () {
      expect(match.shouldShipImage(confidence: 0.7), isFalse);
      expect(match.shouldShipImage(confidence: 0.85), isTrue);
    });

    test('无别名绝不返回置信度', () {
      expect(
        match.confidenceFor(
          exerciseName: '完全不存在的动作xyz',
          curatedConfidenceByName: const {'引体向上': 1.0},
        ),
        isNull,
      );
    });
  });
}
