/// 名称归一化与配图匹配置信度辅助（纯 Dart，供单测与工具逻辑对齐）。
class ImageMatchHelper {
  const ImageMatchHelper();

  /// 去掉括号注释、空白、全角符号，便于别名比对。
  String normalize(String name) {
    var s = name.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'[（(].*?[）)]'), '');
    s = s.replaceAll(RegExp(r'[\s_/·••]+'), '');
    s = s.replaceAll('又叫', '');
    return s;
  }

  /// 人工映射置信度是否达到可出图阈值。
  bool shouldShipImage({
    required double confidence,
    double minConfidence = 0.85,
  }) {
    return confidence >= minConfidence;
  }

  /// 在别名表中查找；未命中返回 null（绝不自动瞎配）。
  double? confidenceFor({
    required String exerciseName,
    required Map<String, double> curatedConfidenceByName,
  }) {
    if (curatedConfidenceByName.containsKey(exerciseName)) {
      return curatedConfidenceByName[exerciseName];
    }
    final n = normalize(exerciseName);
    for (final entry in curatedConfidenceByName.entries) {
      if (normalize(entry.key) == n) return entry.value;
    }
    return null;
  }
}
