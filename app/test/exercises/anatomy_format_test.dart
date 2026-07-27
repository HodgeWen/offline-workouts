import 'package:flutter_test/flutter_test.dart';
import 'package:workout_app/features/exercises/domain/anatomy_format.dart';

void main() {
  group('formatAnatomyCopy', () {
    test('嵌套全角冒号改为中点层级，分号换行', () {
      expect(
        formatAnatomyCopy('肩关节外展：大臂：内→外；肘关节屈：肘关节：打直→折叠'),
        '肩关节外展 · 大臂 · 内→外\n肘关节屈 · 肘关节 · 打直→折叠',
      );
    });

    test('单层冒号也统一为中点', () {
      expect(
        formatAnatomyCopy('主要目标肌：胸大肌、肩前束'),
        '主要目标肌 · 胸大肌、肩前束',
      );
    });

    test('无冒号文案保持原样', () {
      expect(
        formatAnatomyCopy('髋铰链后链主训，居家哑铃替代杠铃 RDL。'),
        '髋铰链后链主训，居家哑铃替代杠铃 RDL。',
      );
    });

    test('空串与空白', () {
      expect(formatAnatomyCopy(''), '');
      expect(formatAnatomyCopy('   '), '   ');
    });

    test('兼容半角冒号与分号', () {
      expect(
        formatAnatomyCopy('主肌群: 胸: 上胸; 协同: 三头'),
        '主肌群 · 胸 · 上胸\n协同 · 三头',
      );
    });
  });
}
