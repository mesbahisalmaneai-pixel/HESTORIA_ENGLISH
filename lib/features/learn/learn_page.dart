import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/settings_controller.dart';
import '../progress/progress_controller.dart';
import 'domain/cefr.dart';

/// The visual learning journey: a vertical path of CEFR levels.
/// Users cannot pick a level; they can only open levels they have unlocked.
class LearnPage extends ConsumerWidget {
  const LearnPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final tt = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(s.get('journey'),
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        for (final lv in Cefr.values)
          _JourneyNode(level: lv, isLast: lv == Cefr.c2),
      ],
    );
  }
}

class _JourneyNode extends ConsumerWidget {
  final Cefr level;
  final bool isLast;
  const _JourneyNode({required this.level, required this.isLast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;
    final progress = ref.watch(progressProvider);
    final tt = Theme.of(context).textTheme;

    final unlocked = progress.isUnlocked(level);
    final done = progress.testPassed(level);
    final isCurrent = unlocked && !done;
    final pct = progress.levelProgress(level);

    final node = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: unlocked ? p.gradient : null,
        color: unlocked ? null : p.surface,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                    color: p.primary.withValues(alpha: 0.5), blurRadius: 18)
              ]
            : null,
      ),
      child: Icon(
        done
            ? Icons.check_rounded
            : unlocked
                ? Icons.play_arrow_rounded
                : Icons.lock_rounded,
        color: unlocked ? p.onPrimary : p.muted,
      ),
    );

    final card = Opacity(
      opacity: unlocked ? 1 : 0.55,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (!unlocked) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(s.fmt(
                      'unlockHint', {'level': level.prev?.code ?? ''}))));
            } else {
              context.push('/level/${level.code}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(level.code,
                      style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800, color: p.primary)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(s.get(level.nameKey),
                          style: tt.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700))),
                  if (!unlocked) Icon(Icons.lock_rounded, color: p.muted),
                  if (done)
                    Text(s.get('completed'),
                        style: tt.labelMedium?.copyWith(color: p.primary)),
                  if (isCurrent)
                    Text(s.get('currentLevel'),
                        style: tt.labelMedium?.copyWith(color: p.secondary)),
                ]),
                const SizedBox(height: 14),
                if (unlocked) ...[
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 10,
                        color: p.primary,
                        backgroundColor: p.muted.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${(pct * 100).round()}%',
                      style: tt.labelLarge?.copyWith(color: p.muted)),
                ] else
                  Text(
                      s.fmt('unlockHint', {'level': level.prev?.code ?? ''}),
                      style: tt.bodySmall?.copyWith(color: p.muted)),
              ],
            ),
          ),
        ),
      ),
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(children: [
              node,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: done
                          ? p.primary
                          : p.muted.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: card,
            ),
          ),
        ],
      ),
    );
  }
}
