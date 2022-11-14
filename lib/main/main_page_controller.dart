import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../getx/extension.dart';
import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import '../survey_kit/survey_kit.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

enum StepEvent {
  next,
  back,
}

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  final AudioPlayer audioPlayer = AudioPlayer();

  late final TextEditingController textEditingController = TextEditingController()..addListener(onListenText);
  late final SurveyController surveyController = SurveyController(
    onNextStep: (_, __) => _onStep(StepEvent.next),
    onStepBack: (_, __) => _onStep(StepEvent.back),
  );

  late final Rx<PlayerState> playerState = PlayerState.stopped.obs..bindStream(audioPlayer.onPlayerStateChanged);
  final Rx<double> volume = 1.0.obs;

  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    playerState.stream
        .where((state) => state == PlayerState.playing)
        .withLatestFrom3<QuestionType, int, double, Map>(questionType.stream, index.stream, volume.stream, (state, questionType, index, volume) {
      final question = this.state.questions[questionType].elvis.elementAt(index);
      final startedAt = question.isRecord && question.startedAt.length == question.endedAt.length ? [...question.startedAt, DateTime.now()] : null;

      return {
        QuestionType: questionType,
        int: index,
        QuestionModel: question.copyWith(
          volumes: [
            ...question.volumes,
            volume,
          ],
          startedAt: startedAt,
        ),
      };
    }).listen((map) {
      final question = map[QuestionModel];

      if (question is QuestionModel) {
        onChange(
          map[QuestionType] as QuestionType,
          map[int] as int,
          volumes: question.volumes,
          startedAt: question.startedAt,
        );
      }
    });
    onChangedVolume(1 / 2);
  }

  void _onStep(StepEvent event) async {
    var questionType = this.questionType.value;
    var index = this.index.value;
    final question = state.questions[questionType].elvis.elementAt(index);
    final endedAt = question.isRecord && question.startedAt.length > question.endedAt.length ? [...question.endedAt, DateTime.now()] : null;

    onChange(
      questionType,
      index,
      endedAt: endedAt,
    );

    final keyIndex = state.questions.keys.toList().indexOf(questionType);

    if (event == StepEvent.next) {
      if (index < state.questions[questionType].elvis.length - 1) {
        index = index + 1;
      } else if (keyIndex < state.questions.keys.length - 1) {
        questionType = state.questions.keys.elementAt(keyIndex + 1);
        index = 0;
      }
    } else if (event == StepEvent.back) {
      if (index > 0) {
        index = index - 1;
      } else if (keyIndex > 0) {
        final prevKey = state.questions.keys.elementAt(keyIndex - 1);

        questionType = prevKey;
        index = state.questions[prevKey].elvis.length - 1;
      }
    }

    this.index.value = index;
    this.questionType.value = questionType;

    final nextQuestion = state.questions[questionType].elvis.elementAt(index);
    await audioPlayer.setSourceAsset(nextQuestion.file);
    if (nextQuestion.isAutoPlay) {
      await audioPlayer.resume();
    } else {
      await audioPlayer.pause();
    }
  }

  @override
  void onClose() async {
    await audioPlayer.dispose();
    [playerState, volume].forEach((x) => x.close());
    textEditingController.dispose();
    super.onClose();
  }

  void onChangedScore(QuestionType questionType, int index, double value) {
    // 메인 페이지 모델을 변경하는 함수 -> change
    // Iterable<MapEntry(Key, Value)>
    /*
    [
      MapEntry(QuestionType.none, [
        QuestionModel(),
        QuestionModel(),
        QuestionModel(),
      ]),

      ->


      MapEntry(QuestionType.none, {
        0: QuestionModel(),
        1: QuestionModel(),
        2: QuestionModel(),
      }),


      MapEntry(QuestionType.q1, [
        QuestionModel(),
        QuestionModel(),
        QuestionModel(),
      ]),
    ],
    */

    final questionType = this.questionType.value;
    final index = this.index.value;

    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isset) {
      onChange(questionType, index, score: value);
      textEditingController.text = value.toStringAsFixed(1);
    }
  }

  void onChange(
    QuestionType questionType,
    int index, {
    String? file,
    double? score,
    double? maxSliderScore,
    double? maxTextScore,
    Iterable<double>? volumes,
    Iterable<DateTime>? startedAt,
    Iterable<DateTime>? endedAt,
  }) {
    change(
      state.copyWith(
        questions: Map.fromEntries({
          ...state.questions.entries.map((x) => MapEntry(
                x.key,
                x.key == questionType
                    ? [
                        ...x.value.toList().asMap().entries.map((z) => z.key == index
                            ? z.value.copyWith(
                                file: file,
                                score: score,
                                maxSliderScore: maxSliderScore,
                                maxTextScore: maxTextScore,
                                volumes: volumes,
                                startedAt: startedAt,
                                endedAt: endedAt,
                              )
                            : z.value),
                      ]
                    : x.value,
              )),
        }),
      ),
    );
  }

  void onChangedVolume(double value) {
    audioPlayer.setVolume(value);
    volume.value = value;
  }

  void onListenText() {
    final questionType = this.questionType.value;
    final index = this.index.value;

    final text = double.tryParse(textEditingController.value.text) ?? 0;
    // 50
    final questionModel = state.questions[questionType][index];

    if (questionModel is QuestionModel && questionModel.volumes.isset) {
      // questionModel.maxTextScore 60
      // questionModel.maxSliderScore 100 -> UI쪽에서 maxSliderScore보다 작은 값을 할당

      final maxScore = max(questionModel.maxTextScore, questionModel.maxSliderScore);
      final score = maxScore > 0 ? min(maxScore, text) : text;

      onChange(questionType, index, score: score);
      if (text != score) {
        textEditingController.text = score.toString();
        textEditingController.selection = TextSelection(
          baseOffset: score.toString().length,
          extentOffset: score.toString().length,
        );
      }
    } else {
      textEditingController.clear();
    }
  }

  void onPressedState(PlayerState state) async {
    if (state == PlayerState.playing) {
      await audioPlayer.pause();
    } else if (state == PlayerState.paused) {
      await audioPlayer.resume();
    } else {
      await audioPlayer.seek(Duration.zero);
      await audioPlayer.resume();
    }
  }
}
