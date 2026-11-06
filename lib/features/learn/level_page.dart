import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/settings_controller.dart';
import '../progress/progress_controller.dart';
import 'domain/cefr.dart';
import 'domain/content.dart';

class LevelPage extends ConsumerWidget {
  final Cefr level;
  const LevelPage({super.key, required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;
    final progress = ref.watch(progressProvider);
    final tt = Theme.of(context).textTheme;
    final lessons = curriculum[level]!;
    final pct = progress.levelProgress(level);
    final totalQ = min(10, lessons.expand((l) => l.questions).length);
    final testDone = progress.testPassed(level);
    final testOpen = progress.testUnlocked(level);

    void snack(String key) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s.get(key))));

    return Scaffold(
      appBar: AppBar(title: Text('${level.code} · ${s.get(level.nameKey)}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
                gradient: p.gradient, borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(level.code,
                    style: tt.displaySmall?.copyWith(
                        color: p.onPrimary, fontWeight: FontWeight.w800)),
                Text(s.get(level.nameKey),
                    style: tt.titleMedium?.copyWith(color: p.onPrimary)),
                const SizedBox(height: 16),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: pct),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      color: p.onPrimary,
                      backgroundColor: p.onPrimary.withValues(alpha: 0.25),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${(pct * 100).round()}%',
                    style: tt.labelLarge?.copyWith(color: p.onPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(s.get('lessons'),
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (var i = 0; i < lessons.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RowCard(
                dimmed: !progress.lessonUnlocked(level, i),
                leading: _Circle(
                  active: progress.lessonDone(level, lessons[i].id) ||
                      progress.lessonUnlocked(level, i),
                  icon: progress.lessonDone(level, lessons[i].id)
                      ? Icons.check_rounded
                      : progress.lessonUnlocked(level, i)
                          ? null
                          : Icons.lock_rounded,
                  label: '${i + 1}',
                ),
                title: lessons[i].title,
                subtitle: s.fmt(
                    'questionsCount', {'n': lessons[i].questions.length}),
                onTap: () {
                  if (progress.lessonUnlocked(level, i)) {
                    context.push('/quiz/${level.code}/${lessons[i].id}');
                  } else {
                    snack('lessonLocked');
                  }
                },
              ),
            ),
          const SizedBox(height: 12),
          _RowCard(
            dimmed: !testOpen,
            leading: _Circle(
              active: testOpen,
              icon: testDone
                  ? Icons.emoji_events_rounded
                  : testOpen
                      ? Icons.flag_rounded
                      : Icons.lock_rounded,
            ),
            title: s.get('finalTest'),
            subtitle: testDone
                ? '${s.get('score')}: ${progress.tests[level.code]}%'
                : testOpen
                    ? s.fmt('questionsCount', {'n': totalQ})
                    : s.get('finalTestHint'),
            onTap: () {
              if (testOpen) {
                context.push('/quiz/${level.code}/final');
              } else {
                snack('finalTestHint');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Circle extends ConsumerWidget {
  final bool active;
  final IconData? icon;
  final String? label;
  const _Circle({required this.active, this.icon, this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(settingsProvider).palette;
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: active ? p.gradient : null,
        color: active ? null : p.muted.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: icon != null
          ? Icon(icon, color: active ? p.onPrimary : p.muted)
          : Text(label ?? '',
              style: TextStyle(
                  color: p.onPrimary, fontWeight: FontWeight.w800)),
    );
  }
}

class _RowCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool dimmed;
  final VoidCallback onTap;
  const _RowCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.dimmed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Opacity(
      opacity: dimmed ? 0.55 : 1,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: tt.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(dimmed ? Icons.lock_rounded : Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ]),
          ),
        ),
      ),
    );
  }
}
