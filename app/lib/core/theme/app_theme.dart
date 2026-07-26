import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 视觉方向：冷绿墨色 + 琥珀点缀，运动感排版，非扁平灰底。
class AppTheme {
  static const Color ink = Color(0xFF0B2E24);
  static const Color primary = Color(0xFF147A5F);
  static const Color accent = Color(0xFFE2A33A);
  static const Color mist = Color(0xFFE6F0EC);
  static const Color slate = Color(0xFF1C2833);
  static const Color foam = Color(0xFFF4F8F6);

  static ThemeData? _lightCached;
  static ThemeData? _darkCached;

  static ThemeData light() => _lightCached ??= _buildLight();

  static ThemeData dark() => _darkCached ??= _buildDark();

  static ThemeData _buildLight() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      secondary: accent,
      surface: foam,
      onPrimary: Colors.white,
      onSecondary: ink,
    );
    final scheme = baseScheme.copyWith(
      surfaceContainerLowest: Colors.white.withValues(alpha: 0.72),
      surfaceContainerLow: mist.withValues(alpha: 0.85),
      outlineVariant: const Color(0xFFB7C9C1),
    );

    final display = GoogleFonts.syneTextTheme();
    final body = GoogleFonts.outfitTextTheme();
    final textTheme = body.copyWith(
      displayLarge: display.displayLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -1.2,
      ),
      displayMedium: display.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
        letterSpacing: -0.6,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineSmall: display.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: body.bodyLarge?.copyWith(color: slate, height: 1.45),
      bodyMedium: body.bodyMedium?.copyWith(color: slate, height: 1.4),
      bodySmall: body.bodySmall?.copyWith(
        color: slate.withValues(alpha: 0.72),
      ),
      labelLarge: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: foam,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: display.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: ink,
          fontSize: 20,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.92),
        indicatorColor: primary.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : slate.withValues(alpha: 0.65),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : slate.withValues(alpha: 0.65),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: primary.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: mist,
        selectedColor: primary.withValues(alpha: 0.16),
        labelStyle: GoogleFonts.outfit(fontSize: 13, color: ink),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.78),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: primary.withValues(alpha: 0.18),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.55),
        thickness: 1,
      ),
    );
  }

  static ThemeData _buildDark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: const Color(0xFF3DB892),
      secondary: accent,
    );
    final textTheme = GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme);
    final titleStyle = GoogleFonts.syne(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: scheme.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: titleStyle,
      ),
    );
  }

  static Color dayTypeColor(String type, ColorScheme scheme) {
    return switch (type) {
      'strength' => primary,
      'cardio' => accent,
      'rest' => const Color(0xFF7A8B84),
      'yoga' => const Color(0xFF4A6FA5),
      _ => scheme.outlineVariant,
    };
  }
}

/// 氛围背景：柔和冷绿渐变 + 轻量斜纹，避免单色灰底。
class AtmosphereBackground extends StatelessWidget {
  const AtmosphereBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF7FBF9),
                Color(0xFFE6F0EC),
                Color(0xFFDCE8E3),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        // 隔离斜纹重绘，避免与前台列表滚动互相牵连
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _GrainPainter()),
          ),
        ),
        child,
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final paint = Paint()
      ..color = const Color(0xFF0B2E24).withValues(alpha: 0.03)
      ..strokeWidth = 1;
    // Chrome 预览下加密斜纹成本高，步长略加大
    const step = 40.0;
    for (var x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
