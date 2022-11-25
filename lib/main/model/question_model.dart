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
    required this.sliderlengthratio,
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
  final double sliderlengthratio;

  double get sliderScore => min(score, maxSliderScore);

  int get totalMilliseconds {
    final length = min(startedAt.length, endedAt.length);
    final total = Iterable.generate(length,
            (i) => endedAt.elementAt(i).difference(startedAt.elementAt(i)))
        .reduce((a, c) => a + c);
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
    sliderlengthratio: 0,
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
    double? sliderlengthratio,
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
      sliderlengthratio: sliderlengthratio ?? this.sliderlengthratio,
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
        sliderlengthratio,
      ];

  Map<String, dynamic> toJson() => {
    'file': file,
    'score': score,
    'play_count': volumes.length,
    'volumes': volumes,
    'total_milliseconds': totalMilliseconds,
  };

  @override
  String toString() =>
      'id: $id file: $file score: $score maxSliderScore: $maxSliderScore maxTextScore: $maxTextScore volumes: $volumes isAutoPlay: $isAutoPlay isRecord: $isRecord startedAt: $startedAt endedAt: $endedAt sliderlengthratio: $sliderlengthratio';
}
