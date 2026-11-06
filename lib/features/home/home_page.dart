import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/settings_controller.dart';
import '../progress/progress_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;
    final progress = ref.watch(progressProvider);
    final cur = progress.currentLevel;
    final pct = progress.levelProgress(cur);
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(s.get('welcome'),
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: p.gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                  color: p.primary.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.get('slogan'),
                  style: tt.titleLarge?.copyWith(
                      color: p.onPrimary, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Row(children: [
                _Stat(Icons.bolt_rounded, '${progress.xp}', s.get('xp'),
                    p.onPrimary),
                const SizedBox(width: 28),
                _Stat(Icons.local_fire_department_rounded,
                    '${progress.streak}', s.get('streak'), p.onPrimary),
              ]),
              const SizedBox(height: 22),
              Text('${cur.code} · ${s.get(cur.nameKey)}',
                  style: tt.titleMedium?.copyWith(
                      color: p.onPrimary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
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
        FilledButton(
          onPressed: () => context.push('/level/${cur.code}'),
          child: Text(progress.finished
              ? s.get('allDone')
              : s.get('continueLearning')),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;
  const _Stat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(children: [
      Icon(icon, color: color, size: 30),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value,
            style: tt.titleLarge
                ?.copyWith(color: color, fontWeight: FontWeight.w800)),
        Text(label, style: tt.bodySmall?.copyWith(color: color)),
      ]),
    ]);
  }
}
