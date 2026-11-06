import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings_controller.dart';
import '../../core/theme/app_palette.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final p = settings.palette;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.get('settings'),
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          _SectionTitle(p: p, icon: Icons.palette_rounded, title: s.get('theme')),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: AppPalette.all.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final pal = AppPalette.all[i];
                return _ThemeCard(
                  pal: pal,
                  selected: pal.id == settings.themeId,
                  onTap: () => ctrl.setTheme(pal.id),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          _SectionTitle(
              p: p, icon: Icons.translate_rounded, title: s.get('language')),
          const SizedBox(height: 14),
          _LanguagePicker(p: p, current: settings.lang, onChanged: ctrl.setLang),
          const SizedBox(height: 32),
          _SectionTitle(
              p: p, icon: Icons.info_outline_rounded, title: s.get('about')),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(children: [
                Row(children: [
                  Text(s.get('version'),
                      style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text('0.2.0', style: tt.bodyLarge?.copyWith(color: p.muted)),
                ]),
                const Divider(height: 28),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(s.get('slogan'),
                      style: tt.bodyMedium?.copyWith(color: p.muted)),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final AppPalette p;
  final IconData icon;
  final String title;
  const _SectionTitle({required this.p, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: p.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: p.primary, size: 22),
      ),
      const SizedBox(width: 12),
      Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    ]);
  }
}

class _ThemeCard extends StatelessWidget {
  final AppPalette pal;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeCard(
      {required this.pal, required this.selected, required this.onTap});

  Widget _line(double w, Color c) => Container(
        height: 6,
        width: w,
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(3)),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1 : 0.95,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 112,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: pal.bg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? pal.primary : pal.muted.withValues(alpha: 0.3),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: pal.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 10,
                width: 50,
                decoration: BoxDecoration(
                    gradient: pal.gradient,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: pal.surface,
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _line(44, pal.text.withValues(alpha: 0.7)),
                      const SizedBox(height: 6),
                      _line(28, pal.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Text(pal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: pal.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 16, color: pal.primary),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final AppPalette p;
  final String current;
  final ValueChanged<String> onChanged;
  const _LanguagePicker(
      {required this.p, required this.current, required this.onChanged});

  Widget _option(String label, String code) {
    final sel = current == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: sel ? p.gradient : null,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: sel ? p.onPrimary : p.muted)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: p.surface, borderRadius: BorderRadius.circular(22)),
      child: Row(children: [
        _option('English', 'en'),
        _option('العربية', 'ar'),
      ]),
    );
  }
}
