import 'dart:math';

import '../learn/domain/cefr.dart';
import '../learn/domain/content.dart';

/// The single source of truth for a learner. The current level is NEVER stored
/// or chosen by the user: it is derived from which final tests were passed.
class UserProgress {
  static const lessonPass = 60; // % needed to complete a lesson
  static const testPass = 70; // % needed to pass a level's final test

  final int xp;
  final int streak;
  final String lastActive; // yyyy-MM-dd
  final Set<String> lessons; // "A1/l1"
  final Map<String, int> tests; // "A1" -> best percent

  const UserProgress({
    this.xp = 0,
    this.streak = 0,
    this.lastActive = '',
    this.lessons = const {},
    this.tests = const {},
  });

  // ---- Derived state (the progression rules live here) ----
  bool lessonDone(Cefr l, String id) => lessons.contains('${l.code}/$id');
  bool testPassed(Cefr l) => (tests[l.code] ?? 0) >= testPass;

  /// A1 is always open. Any other level opens only after the previous level's
  /// final test was passed.
  bool isUnlocked(Cefr l) => l == Cefr.a1 || testPassed(l.prev!);

  bool lessonUnlocked(Cefr l, int idx) {
    if (!isUnlocked(l)) return false;
    if (idx == 0) return true;
    return lessonDone(l, curriculum[l]![idx - 1].id);
  }

  bool allLessonsDone(Cefr l) =>
      curriculum[l]!.every((x) => lessonDone(l, x.id));

  bool testUnlocked(Cefr l) => isUnlocked(l) && allLessonsDone(l);

  Cefr get currentLevel {
    for (final l in Cefr.values) {
      if (!testPassed(l)) return l;
    }
    return Cefr.c2;
  }

  bool get finished => Cefr.values.every(testPassed);

  double levelProgress(Cefr l) {
    final list = curriculum[l]!;
    final done = list.where((x) => lessonDone(l, x.id)).length +
        (testPassed(l) ? 1 : 0);
    return done / (list.length + 1);
  }

  // ---- Persistence ----
  UserProgress copyWith({
    int? xp,
    int? streak,
    String? lastActive,
    Set<String>? lessons,
    Map<String, int>? tests,
  }) =>
      UserProgress(
        xp: xp ?? this.xp,
        streak: streak ?? this.streak,
        lastActive: lastActive ?? this.lastActive,
        lessons: lessons ?? this.lessons,
        tests: tests ?? this.tests,
      );

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'streak': streak,
        'lastActive': lastActive,
        'lessons': lessons.toList(),
        'tests': tests,
      };

  factory UserProgress.fromJson(Map<String, dynamic> j) => UserProgress(
        xp: (j['xp'] as num?)?.toInt() ?? 0,
        streak: (j['streak'] as num?)?.toInt() ?? 0,
        lastActive: j['lastActive'] as String? ?? '',
        lessons: ((j['lessons'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        tests: ((j['tests'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), (v as num).toInt())),
      );

  /// Offline/online merge: never lose progress made on either side.
  static UserProgress merge(UserProgress a, UserProgress b) {
    final later = a.lastActive.compareTo(b.lastActive) >= 0 ? a : b;
    final tests = <String, int>{...a.tests};
    b.tests.forEach((k, v) => tests[k] = max(tests[k] ?? 0, v));
    return UserProgress(
      xp: max(a.xp, b.xp),
      streak: later.streak,
      lastActive: later.lastActive,
      lessons: {...a.lessons, ...b.lessons},
      tests: tests,
    );
  }
}
