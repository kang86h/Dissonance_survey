enum QuestionType {
  none,
  hs1q2,
  hs1q3,
  hs1q4,
  check,
  complete,
}

extension QuestionTypeEx on QuestionType {
  String get title =>
      {
        QuestionType.hs1q2: '2음화음(최대60점)',
        QuestionType.hs1q3: '3음화음(최대100점)',
        QuestionType.hs1q4: '4음화음(최대140점)',
      }[this] ??
      '';

  bool get isRandom => [QuestionType.hs1q2, QuestionType.hs1q3, QuestionType.hs1q4].contains(this);

  bool get isLength => isRandom || [QuestionType.check].contains(this);
}
