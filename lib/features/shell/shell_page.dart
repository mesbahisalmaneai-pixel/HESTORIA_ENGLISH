import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/settings_controller.dart';

class ShellPage extends ConsumerWidget {
  final StatefulNavigationShell shell;
  const ShellPage({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 24,
        title: Text('HESTORIA',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                fontSize: 20,
                color: p.text)),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 20),
            child: Tooltip(
              message: s.get('settings'),
              child: Material(
                color: p.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/settings'),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: Icon(Icons.settings_rounded,
                        color: p.primary, size: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(shell.currentIndex), child: shell),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_rounded), label: s.get('home')),
          NavigationDestination(
              icon: const Icon(Icons.menu_book_rounded), label: s.get('learn')),
          NavigationDestination(
              icon: const Icon(Icons.sports_esports_rounded),
              label: s.get('play')),
          NavigationDestination(
              icon: const Icon(Icons.person_rounded), label: s.get('profile')),
        ],
      ),
    );
  }
}
