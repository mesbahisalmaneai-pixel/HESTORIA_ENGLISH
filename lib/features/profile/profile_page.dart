import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings_controller.dart';
import '../progress/progress_controller.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: p.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: p.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Icon(Icons.person_rounded, size: 52, color: p.onPrimary),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(s.get('learner'),
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text('${cur.code} · ${s.get(cur.nameKey)}',
              style: tt.bodyLarge?.copyWith(color: p.muted)),
        ),
        const SizedBox(height: 28),
        Row(children: [
          Expanded(
              child: _StatCard(
                  icon: Icons.bolt_rounded,
                  value: '${progress.xp}',
                  label: s.get('xp'))),
          const SizedBox(width: 12),
          Expanded(
              child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  value: '${progress.streak}',
                  label: s.get('streak'))),
        ]),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(cur.code,
                      style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800, color: p.primary)),
                  const Spacer(),
                  Text('${(pct * 100).round()}%',
                      style: tt.labelLarge?.copyWith(color: p.muted)),
                ]),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    color: p.primary,
                    backgroundColor: p.muted.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends ConsumerWidget {
  final IconData icon;
  final String value, label;
  const _StatCard(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(settingsProvider).palette;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: p.primary, size: 28),
            const SizedBox(height: 10),
            Text(value,
                style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: tt.bodySmall?.copyWith(color: p.muted)),
          ],
        ),
      ),
    );
  }
}
