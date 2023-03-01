import 'package:get/get.dart';
import 'package:surveykit_example/main/main_page.dart';
import 'package:surveykit_example/main/model/question_model.dart';

import '../getx/extension.dart';
import '../getx/get_model.dart';
import 'model/question_type.dart';

final DateTime defaultDateTime = DateTime(1970, 1, 1);

class MainPageModel extends GetModel {
  MainPageModel({
    required this.questions,
    required this.videoStartedAt,
    required this.videoEndedAt,
  });

  final Map<QuestionType, Iterable<QuestionModel>> questions;
  final DateTime videoStartedAt;
  final DateTime videoEndedAt;

  static final MainPageModel _empty = MainPageModel(
    questions: const {},
    videoStartedAt: defaultDateTime,
    videoEndedAt: defaultDateTime,
  );

  factory MainPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  get getPlayCount => 0;//Todo 재생 클릭할때 재생횟수 올라가도록 카운트

  int get getVideoMilliseconds =>
      videoEndedAt.difference(videoStartedAt).inMilliseconds;

  List<int> get q2ReliabilityCount {
    final current =
        questions[QuestionType.hs1q2].elvis.where((x) => x.isWarmUpCheck);
    final choice = current
        .where((x) => x.id == MainPage.q2WarmUpCheckId[MainPage.q2WarmIndex]);
    final unChosen = current
        .where((x) => x.id != MainPage.q2WarmUpCheckId[MainPage.q2WarmIndex]);
    final totalCase = choice.length * unChosen.length;
    final sub =
        choice.expand((x) => unChosen.map((y) => x.score - y.score)).toList();
    final result = sub.where((x) => x > 0).length;
    return [result, totalCase];
  }

  List<int> get q3ReliabilityCount {
    final current =
        questions[QuestionType.hs1q3].elvis.where((x) => x.isWarmUpCheck);
    final choice = current
        .where((x) => x.id == MainPage.q3WarmUpCheckId[MainPage.q3WarmIndex]);
    final unChosen = current
        .where((x) => x.id != MainPage.q3WarmUpCheckId[MainPage.q3WarmIndex]);
    final totalCase = choice.length * unChosen.length;
    final sub =
        choice.expand((x) => unChosen.map((y) => x.score - y.score)).toList();
    final result = sub.where((x) => x < 0).length;
    return [result, totalCase];
  }

  List<int> get q4ReliabilityCount {
    final current =
        questions[QuestionType.hs1q4].elvis.where((x) => x.isWarmUpCheck);
    final choice = current
        .where((x) => x.id == MainPage.q4WarmUpCheckId[MainPage.q4WarmIndex]);
    final unChosen = current
        .where((x) => x.id != MainPage.q4WarmUpCheckId[MainPage.q4WarmIndex]);
    final totalCase = choice.length * unChosen.length;
    final sub =
        choice.expand((x) => unChosen.map((y) => x.score - y.score)).toList();
    final result = sub.where((x) => x > 0).length;
    return [result, totalCase];
  }

  int get totalReliabilityCount =>
      q2ReliabilityCount[0] + q3ReliabilityCount[0] + q4ReliabilityCount[0];

  int get totalReliabilityTotalcase =>
      q2ReliabilityCount[1] + q3ReliabilityCount[1] + q4ReliabilityCount[1];

  bool get isReliability =>
      totalReliabilityCount / totalReliabilityTotalcase >= 0.8;

  Iterable<double> get q2Consistency {
    final complete = questions[QuestionType.check]
        .elvis
        .where((x) => x.file.contains(QuestionType.hs1q2.name.toUpperCase()))
        .first;
    final current =
        questions[QuestionType.hs1q2].elvis.where((x) => x.id == complete.id);
    final scores = [complete, ...current].map((x) => x.score).toList()..sort();
    return [scores[2] - scores[1], scores[0] - scores[1]];
  }

  Iterable<double> get q3Consistency {
    final complete = questions[QuestionType.check]
        .elvis
        .where((x) => x.file.contains(QuestionType.hs1q3.name.toUpperCase()))
        .first;
    final current =
        questions[QuestionType.hs1q3].elvis.where((x) => x.id == complete.id);
    final scores = [complete, ...current].map((x) => x.score).toList()..sort();
    return [scores[2] - scores[1], scores[0] - scores[1]];
  }

  Iterable<double> get q4Consistency {
    final complete = questions[QuestionType.check]
        .elvis
        .where((x) => x.file.contains(QuestionType.hs1q4.name.toUpperCase()))
        .first;
    final current =
        questions[QuestionType.hs1q4].elvis.where((x) => x.id == complete.id);
    final scores = [complete, ...current].map((x) => x.score).toList()..sort();
    return [scores[2] - scores[1], scores[0] - scores[1]];
  }

  int get q2ConsistencyCount => q2Consistency
      .map((x) => x.abs())
      .where((x) =>
          x < questions[QuestionType.hs1q2].elvis.first.maxSliderScore * 3 / 10)
      .length;

  int get q3ConsistencyCount => q3Consistency
      .map((x) => x.abs())
      .where((x) =>
          x < questions[QuestionType.hs1q3].elvis.first.maxSliderScore * 3 / 10)
      .length;

  int get q4ConsistencyCount => q4Consistency
      .map((x) => x.abs())
      .where((x) =>
          x < questions[QuestionType.hs1q4].elvis.first.maxSliderScore * 3 / 10)
      .length;

  int get totalConsistencyCount =>
      q2ConsistencyCount + q3ConsistencyCount + q4ConsistencyCount;

  bool get isConsistency => totalConsistencyCount >= 5;

  @override
  MainPageModel copyWith({
    Map<QuestionType, Iterable<QuestionModel>>? questions,
    DateTime? videoStartedAt,
    DateTime? videoEndedAt,
  }) {
    return MainPageModel(
      questions: questions ?? this.questions,
      videoStartedAt: videoStartedAt ?? this.videoStartedAt,
      videoEndedAt: videoEndedAt ?? this.videoEndedAt,
    );
  }

  Map<String, dynamic> toJson() => Map.fromEntries({
        ...questions.entries
            .where((x) => x.key != QuestionType.none)
            .map((x) => MapEntry(x.key.name, x.value.map((y) => y.toJson()))),
      });

  @override
  List<Object?> get props => [questions, videoStartedAt, videoEndedAt];

  @override
  String toString() =>
      'questions: $questions videoStartedAt: $videoStartedAt videoEndedAt: $videoEndedAt';
}
