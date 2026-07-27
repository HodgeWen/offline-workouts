/// 将解剖文案中的嵌套冒号格式化为可读层级。
///
/// 例：`肩关节外展：大臂：内→外；肘关节屈：肘关节：打直→折叠`
/// → 两行：`肩关节外展 · 大臂 · 内→外` / `肘关节屈 · 肘关节 · 打直→折叠`
String formatAnatomyCopy(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return raw;

  final clauses = text
      .split(RegExp(r'[；;]'))
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty);

  final formatted = <String>[];
  for (final clause in clauses) {
    final parts = clause
        .split(RegExp(r'[：:]'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) continue;
    if (parts.length == 1) {
      formatted.add(parts.first);
    } else {
      formatted.add(parts.join(' · '));
    }
  }
  return formatted.join('\n');
}
