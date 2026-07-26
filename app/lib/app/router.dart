import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/db/providers.dart';
import '../features/calendar/presentation/calendar_page.dart';
import '../features/exercises/presentation/exercise_detail_page.dart';
import '../features/exercises/presentation/exercises_page.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/profile/presentation/faq_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/today/presentation/edit_complete_page.dart';
import '../features/today/presentation/today_page.dart';
import 'shell_scaffold.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _GoRouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/today',
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboarding = ref.read(onboardingDoneProvider);
      final goingOnboarding = state.matchedLocation == '/onboarding';
      final done = onboarding.asData?.value;
      if (done == null) return null;
      if (!done && !goingOnboarding) return '/onboarding';
      if (done && goingOnboarding) return '/today';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/today',
                builder: (context, state) => const TodayPage(),
                routes: [
                  GoRoute(
                    path: 'edit/:sessionId',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => EditCompletePage(
                      sessionId: state.pathParameters['sessionId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/exercises',
                builder: (context, state) => const ExercisesPage(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '');
                      if (id == null) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('动作详情')),
                          body: const Center(child: Text('无效的动作链接')),
                        );
                      }
                      return ExerciseDetailPage(exerciseId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'faq',
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => const FaqPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _GoRouterRefresh extends ChangeNotifier {
  _GoRouterRefresh(this.ref) {
    _sub = ref.listen(onboardingDoneProvider, (_, _) => notifyListeners());
  }

  final Ref ref;
  late final ProviderSubscription<AsyncValue<bool>> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
