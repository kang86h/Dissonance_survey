import 'dart:math';

import '../../getx/get_model.dart';

class QuestionModel extends GetModel {
  QuestionModel({
    required this.id,
    required this.file,
    required this.score,
    required this.maxSliderScore,
    required this.maxTextScore,
    required this.volumes,
    required this.isAutoPlay,
    required this.isRecord,
    required this.startedAt,
    required this.endedAt,
    required this.totalMilliseconds,
  });

  final int id;
  final String file;
  final double score;
  final double maxSliderScore;
  final double maxTextScore;
  final Iterable<double> volumes;
  final bool isAutoPlay;
  final bool isRecord;
  final Iterable<DateTime> startedAt;
  final Iterable<DateTime> endedAt;
  final int totalMilliseconds;

  double get sliderScore => min(score, maxSliderScore);

  int get getTotalMilliseconds {
    // 예외처리 Exception -> 에러가 발생

    // NullPointerException
    // [1, 2, 3].length > 5 ? [5] : null

    // [1, 2, 3].reduce((a, c) => a + c);
    // a: 1, c: 2
    // a: 3, c: 3
    // 6

    // [1, 2, 3].fold(100, (a, c) => a + c);
    // a: 100, c: 1
    // a: 101, c: 2
    // a: 103, c: 3
    // 106

    // [].reduce((a, c) => a + c);
    // [].fold(Duration.zero, (a, c) => a + c); -> 기본값

    final length = min(startedAt.length, endedAt.length);
    final total =
        Iterable.generate(length, (i) => endedAt.elementAt(i).difference(startedAt.elementAt(i))).fold<Duration>(Duration.zero, (a, c) => a + c);
    return total.inMilliseconds;
  }

  static final QuestionModel _empty = QuestionModel(
    id: 0,
    file: '',
    score: 0,
    maxSliderScore: 0,
    maxTextScore: 0,
    volumes: const [],
    isAutoPlay: false,
    isRecord: false,
    startedAt: const [],
    endedAt: const [],
    totalMilliseconds: 0,
  );

  static final QuestionModel _volume = _empty.copyWith(
    file: 'volume.mp3',
    isAutoPlay: true,
  );

  factory QuestionModel.empty() => _empty;

  factory QuestionModel.volume() => _volume;

  @override
  bool get isEmpty => this == _empty;

  @override
  QuestionModel copyWith({
    int? id,
    String? file,
    double? score,
    double? maxSliderScore,
    double? maxTextScore,
    Iterable<double>? volumes,
    bool? isAutoPlay,
    bool? isRecord,
    Iterable<DateTime>? startedAt,
    Iterable<DateTime>? endedAt,
    int? totalMilliseconds,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      file: file ?? this.file,
      score: score ?? this.score,
      maxSliderScore: maxSliderScore ?? this.maxSliderScore,
      maxTextScore: maxTextScore ?? this.maxTextScore,
      volumes: volumes ?? this.volumes,
      isAutoPlay: isAutoPlay ?? this.isAutoPlay,
      isRecord: isRecord ?? this.isRecord,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalMilliseconds: totalMilliseconds ?? this.totalMilliseconds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        file,
        score,
        maxSliderScore,
        maxTextScore,
        volumes,
        isAutoPlay,
        isRecord,
        startedAt,
        endedAt,
        totalMilliseconds,
      ];

  Map<String, dynamic> toJson() => {
        'file': file,
        'score': score,
        'play_count': volumes.length,
        'volumes': volumes,
        'total_milliseconds': getTotalMilliseconds,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> map) => _empty.copyWith(
        file: map['file'],
        score: double.tryParse(map['score'].toString()) ?? 0.0,
        volumes: [
          ...Iterable.castFrom(map['volumes'] ?? []).map((x) => double.tryParse(x.toString()) ?? 0.0),
        ],
        totalMilliseconds: int.tryParse(map['total_milliseconds'].toString()) ?? 0,
      );

  @override
  String toString() =>
      'id: $id file: $file score: $score maxSliderScore: $maxSliderScore maxTextScore: $maxTextScore volumes: $volumes isAutoPlay: $isAutoPlay isRecord: $isRecord startedAt: $startedAt endedAt: $endedAt totalMilliseconds: $totalMilliseconds';
}
