enum QuestionType {
  none,
  q2,
  q3,
  q4,
}

extension QuestionTypeEx on QuestionType {
  String get name =>
      {
        QuestionType.q2: '2음화음(최대60점)',
        QuestionType.q3: '3음화음(최대100점)',
        QuestionType.q4: '4음화음(최대140점)',
      }[this] ??
      '';
}
