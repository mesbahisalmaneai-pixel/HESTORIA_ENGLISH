import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_page.dart';
import '../features/learn/domain/cefr.dart';
import '../features/learn/domain/content.dart';
import '../features/learn/learn_page.dart';
import '../features/learn/level_page.dart';
import '../features/learn/quiz_page.dart';
import '../features/play/play_page.dart';
import '../features/profile/profile_page.dart';
import '../features/settings/settings_page.dart';
import '../features/progress/progress_controller.dart';
import '../features/shell/shell_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // Progression guard: locked levels/lessons/tests can never be opened,
    // even by deep link or manual navigation.
    redirect: (context, state) {
      final seg = state.uri.pathSegments;
      if (seg.length >= 2 && (seg[0] == 'level' || seg[0] == 'quiz')) {
        final level = Cefr.fromCode(seg[1]);
        final p = ref.read(progressProvider);
        if (level == null || !p.isUnlocked(level)) return '/learn';
        if (seg[0] == 'quiz') {
          if (seg.length != 3) return '/level/${level.code}';
          if (seg[2] == 'final') {
            if (!p.testUnlocked(level)) return '/level/${level.code}';
          } else {
            final idx = curriculum[level]!.indexWhere((l) => l.id == seg[2]);
            if (idx < 0 || !p.lessonUnlocked(level, idx)) {
              return '/level/${level.code}';
            }
          }
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/level/:code',
        builder: (_, state) =>
            LevelPage(level: Cefr.fromCode(state.pathParameters['code']!)!),
      ),
      GoRoute(
        path: '/quiz/:code/:lesson',
        builder: (_, state) => QuizPage(
          level: Cefr.fromCode(state.pathParameters['code']!)!,
          lessonId: state.pathParameters['lesson']!,
        ),
      ),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellPage(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, __) => const HomePage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/learn', builder: (_, __) => const LearnPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/play', builder: (_, __) => const PlayPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
});
