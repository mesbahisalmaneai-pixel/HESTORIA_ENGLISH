import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/settings_controller.dart';
import '../learn/domain/cefr.dart';
import '../learn/domain/content.dart';
import 'cloud_sync.dart';
import 'progress_model.dart';

/// Overridden in main() once Firebase initialised successfully.
final firebaseReadyProvider = Provider<bool>((ref) => false);

class QuizOutcome {
  final int percent;
  final bool passed;
  final int xp;
  final Cefr? unlocked; // set when this result unlocked a new level
  const QuizOutcome({
    required this.percent,
    required this.passed,
    required this.xp,
    this.unlocked,
  });
}

class ProgressController extends Notifier<UserProgress> {
  static const _key = 'progress_v1';
  final _cloud = CloudSync();

  @override
  UserProgress build() {
    var p = const UserProgress();
    final raw = ref.read(prefsProvider).getString(_key);
    if (raw != null) {
      try {
        p = UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    if (ref.read(firebaseReadyProvider)) Future.microtask(syncFromCloud);
    return p;
  }

  Future<void> syncFromCloud() async {
    final remote = await _cloud.fetch();
    if (remote == null) return;
    final merged = UserProgress.merge(state, remote);
    state = merged;
    await ref.read(prefsProvider).setString(_key, jsonEncode(merged.toJson()));
    unawaited(_cloud.push(merged));
  }

  Future<void> _commit(UserProgress p) async {
    state = p;
    await ref.read(prefsProvider).setString(_key, jsonEncode(p.toJson()));
    if (ref.read(firebaseReadyProvider)) unawaited(_cloud.push(p));
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  UserProgress _touch(UserProgress p, int addXp) {
    final now = DateTime.now();
    final today = _fmt(now);
    var streak = p.streak;
    if (p.lastActive != today) {
      final yesterday = _fmt(now.subtract(const Duration(days: 1)));
      streak = p.lastActive == yesterday ? streak + 1 : 1;
    }
    return p.copyWith(xp: p.xp + addXp, streak: streak, lastActive: today);
  }

  Future<QuizOutcome> completeLesson(Cefr level, String lessonId, int percent) async {
    final idx = curriculum[level]!.indexWhere((l) => l.id == lessonId);
    if (idx < 0 || !state.lessonUnlocked(level, idx)) {
      return QuizOutcome(percent: percent, passed: false, xp: 0);
    }
    final passed = percent >= UserProgress.lessonPass;
    final first = !state.lessonDone(level, lessonId);
    final xp = (percent / 10).round() + (passed && first ? 20 : 0);
    var p = state;
    if (passed) {
      p = p.copyWith(lessons: {...p.lessons, '${level.code}/$lessonId'});
    }
    await _commit(_touch(p, xp));
    return QuizOutcome(percent: percent, passed: passed, xp: xp);
  }

  Future<QuizOutcome> completeTest(Cefr level, int percent) async {
    if (!state.testUnlocked(level)) {
      return QuizOutcome(percent: percent, passed: false, xp: 0);
    }
    final passed = percent >= UserProgress.testPass;
    final wasPassed = state.testPassed(level);
    final best = max(state.tests[level.code] ?? 0, percent);
    final xp = (percent / 10).round() + (passed && !wasPassed ? 100 : 0);
    final p = state.copyWith(tests: {...state.tests, level.code: best});
    await _commit(_touch(p, xp));
    return QuizOutcome(
      percent: percent,
      passed: passed,
      xp: xp,
      unlocked: passed && !wasPassed ? level.next : null,
    );
  }
}

final progressProvider =
    NotifierProvider<ProgressController, UserProgress>(ProgressController.new);
