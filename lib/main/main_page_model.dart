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

  Map<String, dynamic> toJson() => Map.fromEntries({
        ...questions.entries
            .where((x) => x.key != QuestionType.none)
            .map((x) => MapEntry(x.key.name, x.value.map((y) => y.toJson()))),
      });

  // Map<String, Iterable<Json>>

  /*
    key: [1, 2, 3, 4, 5]
    value: [0, 0, 0, 0, 0]


    // 'Q2': [],
    questions.keys.elementAt(1).name: {}, // Q2
    questions.keys.elementAt(2).name: {}, // Q3
    questions.keys.elementAt(3).name: {}, // Q4

    questions.keys.toList()[11].name: {},
    questions.keys.elementAt(10).name: {},
    (() {
      final list = questions.keys.toList();

      list.insert(5, 'E');
    })(),
    */

  /*
    Collection

    Iterable -> [
      'A',
      'B',
      'C',
    ]
    // read-only, write, delete X

    List -> {
      0: 'A',
      1: 'B',
      2: 'C',
      ....
      10: 'J',
    } = length: 10 < 11
    // read, write, delete

    Map -> {
      'A': 'A',
      1: 1,
      'C': 'C',
    }

    List<MapEntry> -> {
      0: {
        'Q2': {
          0: {},
          1: {},
        },
      }
      1: {
        1: 1,
      }
      2: {
        'C': 'C',
      }
      'A': 'A',
      1: 1,
      'C': 'C',
    }

    MapEntry -> (Key, Value) {
      'A': 'A',
    }


    question: {
      Q2: [
        0: {
          count: 0,
          file: 'Q2/Q2-1.mp3',
        }
      ],
      Q3: [
        0: {
          count: 0,
          file: 'Q3/Q3-1.mp3',
        }
      ],
      Q4: [
        0: {
          count: 0,
          file: 'Q4/Q4-1.mp3',
        }
      ],
    }
  */

  /*
  Map<String, dynamic> toJson() => {
    'id': id,
    'file': file,
    'score': score,
    'play_count': volumes.length,
    'volumes': volumes,
    'total_milliseconds': totalMilliseconds,
  };
  */

  @override
  List<Object?> get props => [questions];

  @override
  String toString() => 'questions: $questions';
}
