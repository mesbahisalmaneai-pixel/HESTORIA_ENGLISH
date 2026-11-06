import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/settings_controller.dart';
import '../progress/progress_controller.dart';
import '../progress/progress_model.dart';
import 'domain/cefr.dart';
import 'domain/content.dart';

class _Q {
  final String prompt;
  final List<String> options;
  final int correct;
  _Q(this.prompt, this.options, this.correct);
}

/// Plays one lesson (lessonId = 'l1'...) or the level's final test ('final').
class QuizPage extends ConsumerStatefulWidget {
  final Cefr level;
  final String lessonId;
  const QuizPage({super.key, required this.level, required this.lessonId});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);

  late List<_Q> _qs;
  int _i = 0;
  int? _picked;
  int _right = 0;
  QuizOutcome? _outcome;
  bool _saving = false;

  bool get _isFinal => widget.lessonId == 'final';

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final rnd = Random();
    final lessons = curriculum[widget.level]!;
    List<Question> source;
    if (_isFinal) {
      source = lessons.expand((l) => l.questions).toList();
      source.shuffle(rnd);
      if (source.length > 10) source = source.sublist(0, 10);
    } else {
      source = lessons.firstWhere((l) => l.id == widget.lessonId).questions;
    }
    _qs = source.map((q) {
      final opts = [q.correct, ...q.wrong];
      opts.shuffle(rnd);
      return _Q(q.prompt, opts, opts.indexOf(q.correct));
    }).toList();
    _i = 0;
    _picked = null;
    _right = 0;
    _outcome = null;
    _saving = false;
  }

  void _pick(int idx) {
    if (_picked != null) return;
    setState(() {
      _picked = idx;
      if (idx == _qs[_i].correct) _right++;
    });
  }

  void _next() {
    if (_i < _qs.length - 1) {
      setState(() {
        _i++;
        _picked = null;
      });
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final percent = (_right * 100 / _qs.length).round();
    final c = ref.read(progressProvider.notifier);
    final out = _isFinal
        ? await c.completeTest(widget.level, percent)
        : await c.completeLesson(widget.level, widget.lessonId, percent);
    if (!mounted) return;
    setState(() => _outcome = out);
  }

  void _exit() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/learn');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _outcome == null ? _questionView(context) : _resultView(context),
      ),
    );
  }

  Widget _questionView(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;
    final tt = Theme.of(context).textTheme;
    final q = _qs[_i];
    final last = _i == _qs.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(children: [
        Row(children: [
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: _exit),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(
                  begin: 0,
                  end: (_i + (_picked != null ? 1 : 0)) / _qs.length),
              duration: const Duration(milliseconds: 400),
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
          ),
          const SizedBox(width: 12),
          Text('${_i + 1}/${_qs.length}',
              style: tt.labelLarge?.copyWith(color: p.muted)),
        ]),
        const SizedBox(height: 28),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: ListView(
              key: ValueKey(_i),
              children: [
                Text(q.prompt,
                    textDirection: TextDirection.ltr,
                    style: tt.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 28),
                for (var idx = 0; idx < q.options.length; idx++)
                  _option(p, q, idx),
              ],
            ),
          ),
        ),
        FilledButton(
          onPressed: _picked == null || _saving ? null : _next,
          child: Text(last ? s.get('finish') : s.get('next')),
        ),
      ]),
    );
  }

  Widget _option(dynamic p, _Q q, int idx) {
    final answered = _picked != null;
    final isRight = idx == q.correct;
    final isPicked = idx == _picked;
    Color border = p.muted.withValues(alpha: 0.25);
    Color fill = p.surface;
    if (answered && isRight) {
      border = _green;
      fill = _green.withValues(alpha: 0.15);
    } else if (answered && isPicked) {
      border = _red;
      fill = _red.withValues(alpha: 0.15);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: answered ? null : () => _pick(idx),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Expanded(
                    child: Text(q.options[idx],
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600))),
                if (answered && isRight)
                  const Icon(Icons.check_circle_rounded, color: _green),
                if (answered && isPicked && !isRight)
                  const Icon(Icons.cancel_rounded, color: _red),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultView(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final p = ref.watch(settingsProvider).palette;
    final tt = Theme.of(context).textTheme;
    final o = _outcome!;
    final need = _isFinal ? UserProgress.testPass : UserProgress.lessonPass;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(o.passed ? Icons.emoji_events_rounded : Icons.refresh_rounded,
              size: 96, color: o.passed ? p.primary : p.muted),
          const SizedBox(height: 16),
          Text(o.passed ? s.get('passed') : s.get('failed'),
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${o.percent}%',
              style: tt.displayMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: p.primary)),
          const SizedBox(height: 8),
          if (o.xp > 0)
            Text(s.fmt('xpEarned', {'n': o.xp}),
                style: tt.titleMedium?.copyWith(color: p.secondary)),
          if (!o.passed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(s.fmt('failedHint', {'n': need}),
                  style: tt.bodyMedium?.copyWith(color: p.muted)),
            ),
          if (o.unlocked != null)
            Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  gradient: p.gradient,
                  borderRadius: BorderRadius.circular(18)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.lock_open_rounded, color: p.onPrimary),
                const SizedBox(width: 10),
                Text(s.fmt('levelUnlocked', {'level': o.unlocked!.code}),
                    style: tt.titleMedium?.copyWith(
                        color: p.onPrimary, fontWeight: FontWeight.w800)),
              ]),
            ),
          const Spacer(),
          if (o.unlocked != null)
            FilledButton(
                onPressed: () => context.go('/learn'),
                child: Text(s.get('toJourney')))
          else
            FilledButton(onPressed: _exit, child: Text(s.get('backToLevel'))),
          if (!o.passed) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              onPressed: () => setState(_build),
              child: Text(s.get('retry')),
            ),
          ],
        ],
      ),
    );
  }
}
