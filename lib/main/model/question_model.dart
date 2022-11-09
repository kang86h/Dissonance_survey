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
  });

  final int id;
  final String file;
  final double score;
  final double maxSliderScore;
  final double maxTextScore;
  final Iterable<double> volumes;
  final bool isAutoPlay;

  double get sliderScore => min(score, maxSliderScore);

  static final QuestionModel _empty = QuestionModel(
    id: 0,
    file: '',
    score: 0,
    maxSliderScore: 0,
    maxTextScore: 0,
    volumes: const [],
    isAutoPlay: false,
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
  }) {
    return QuestionModel(
      id: id ?? this.id,
      file: file ?? this.file,
      score: score ?? this.score,
      maxSliderScore: maxSliderScore ?? this.maxSliderScore,
      maxTextScore: maxTextScore ?? this.maxTextScore,
      volumes: volumes ?? this.volumes,
      isAutoPlay: isAutoPlay ?? this.isAutoPlay,
    );
  }

  @override
  List<Object?> get props => [id, file, score, maxSliderScore, maxTextScore, volumes, isAutoPlay];

  @override
  String toString() =>
      'id: $id file: $file score: $score maxSliderScore: $maxSliderScore maxTextScore: $maxTextScore volumes: $volumes isAutoPlay: $isAutoPlay';
}
