import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/router.dart';
import 'core/db/providers.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 仅用 assets/google_fonts 本地字体，禁止运行时 HTTP 拉取（避免 Web 首屏抖动）
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final path in const [
      'assets/google_fonts/OFL-Outfit.txt',
      'assets/google_fonts/OFL-Syne.txt',
    ]) {
      final license = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks(['google_fonts'], license);
    }
  });
  await initializeDateFormatting('zh_CN');
  runApp(const ProviderScope(child: WorkoutApp()));
}

class WorkoutApp extends ConsumerWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return db.when(
      // bootstrap 与正式主题共用本地字体，避免异步换字体触发 text_painter 断言
      loading: () => _BootstrapApp(
        child: const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在准备本地数据…'),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => _BootstrapApp(
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    '数据库初始化失败',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text('$e', textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  const Text(
                    '若反复失败，请在 Chrome 清除本站点数据后重试'
                    '（开发者工具 → Application → Storage → Clear site data）。',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.invalidate(appDatabaseProvider),
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          title: '离线健身',
          theme: AppTheme.light(),
          // 应用视觉以 AtmosphereBackground 浅色氛围为准，避免系统深色模式整屏变黑
          themeMode: ThemeMode.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// Web 会把浏览器 pathname 当作 initialRoute；bootstrap 阶段没有这些路由会刷错。
class _BootstrapApp extends StatelessWidget {
  const _BootstrapApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      // 忽略浏览器深链，始终只展示 bootstrap 页
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(builder: (_) => child),
      ],
      home: child,
    );
  }
}
