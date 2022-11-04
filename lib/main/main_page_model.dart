import 'package:surveykit_example/main/model/question_model.dart';

import '../getx/get_model.dart';
import 'model/question_type.dart';

class MainPageModel extends GetModel {
  MainPageModel({
    required this.questions,
  });

  final Map<QuestionType, Iterable<QuestionModel>> questions;

  static final MainPageModel _empty = MainPageModel(
    questions: const {},
  );

  // 메인 페이지 모델 > 맵(키 -> 퀘스천 타입, 밸류 -> 퀘스천 모델 * x)
  // 퀘스천 모델 > 파일, 점수, 최대 점수

  /*
              메인 페이지
                  ㅣ
  스텝 1,                 스텝 2
    ㅣ                     ㅣ
  스텝 1의 음악 파일     스텝 2의 음악 파일
  스텝 1의 재생 횟수     스텝 2의 재생 횟수
  스텝 1의 맥스 스코어
  */

  factory MainPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  MainPageModel copyWith({
    Map<QuestionType, Iterable<QuestionModel>>? questions,
  }) {
    return MainPageModel(
      questions: questions ?? this.questions,
    );
  }

  @override
  List<Object?> get props => [questions];

  @override
  String toString() => 'questions: $questions';
}
