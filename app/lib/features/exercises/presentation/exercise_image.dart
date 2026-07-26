import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 动作示意图：统一 asset 路径加载，失败时可见占位（勿静默吞掉）。
///
/// Flutter Web 下 key 为 `assets/...`，运行时 URL 为 `assets/assets/...`，
/// 由框架拼接；此处保持与 seed `imagePath`、pubspec 一致即可。
class ExerciseImage extends StatelessWidget {
  const ExerciseImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.contain,
    this.borderRadius = 12,
    this.memCacheWidth,
  });

  final String imagePath;
  final BoxFit fit;
  final double borderRadius;

  /// 解码后缓存宽度（逻辑像素×dpr 由调用方换算，或直接传物理像素）。
  /// 列表缩略图务必设置，避免 Chrome 全尺寸解码卡顿。
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final path = imagePath.trim();
    if (path.isEmpty) {
      return const _ExerciseImagePlaceholder(message: '暂无配图');
    }
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheW = memCacheWidth == null
        ? null
        : (memCacheWidth! * dpr).round().clamp(1, 4096);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ColoredBox(
        color: Colors.white,
        child: Image.asset(
          path,
          fit: fit,
          filterQuality: FilterQuality.low,
          cacheWidth: cacheW,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('ExerciseImage load failed: $path → $error');
            return const _ExerciseImagePlaceholder(message: '配图加载失败');
          },
        ),
      ),
    );
  }
}

class _ExerciseImagePlaceholder extends StatelessWidget {
  const _ExerciseImagePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.mist.withValues(alpha: 0.65),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.slate.withValues(alpha: 0.45),
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
