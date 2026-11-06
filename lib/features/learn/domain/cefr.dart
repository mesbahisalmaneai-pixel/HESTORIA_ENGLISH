enum Cefr {
  a1('A1', 'beginner'),
  a2('A2', 'elementary'),
  b1('B1', 'intermediate'),
  b2('B2', 'upperInt'),
  c1('C1', 'advanced'),
  c2('C2', 'proficient');

  const Cefr(this.code, this.nameKey);
  final String code;
  final String nameKey;

  Cefr? get next => index + 1 < Cefr.values.length ? Cefr.values[index + 1] : null;
  Cefr? get prev => index > 0 ? Cefr.values[index - 1] : null;

  static Cefr? fromCode(String c) {
    for (final l in Cefr.values) {
      if (l.code == c) return l;
    }
    return null;
  }
}
