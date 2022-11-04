import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../getx/extension.dart';
import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import '../survey_kit/survey_kit.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  final AudioPlayer audioPlayer = AudioPlayer();

  late final TextEditingController textEditingController = TextEditingController()..addListener(onListenText);
  late final SurveyController surveyController = SurveyController(
    onNextStep: _onNextStep,
    onStepBack: _onStepBack,
  );

  late final Rx<PlayerState> playerState = PlayerState.stopped.obs..bindStream(audioPlayer.onPlayerStateChanged);
  final Rx<double> volume = 1.0.obs;

  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // audioPlayer.setSourceAsset(files.elementAt(state.index));
    // questionType이 바뀌거나 또는, index가 바뀌거나
    rx.Rx.combineLatest2<QuestionType, int, QuestionModel>(
            questionType.stream, index.stream, (questionType, index) => state.questions[questionType]!.elementAt(index))
        .startWith(QuestionModel.empty())
        .listen((question) async {
      await audioPlayer.pause();
      await audioPlayer.setSourceAsset(question.file);
    });

    onChangedVolume(1 / 2);
  }

  void _onNextStep(BuildContext context, QuestionResult Function() resultFunction) async {
    var index = this.index.value;
    var questionType = this.questionType.value;

    if (index < state.questions[questionType]!.length - 1) {
      index++;
    } else {
      final keyIndex = state.questions.keys.toList().indexOf(questionType);
      if (keyIndex < state.questions.keys.length - 1) {
        final nextKey = state.questions.keys.elementAt(keyIndex + 1);

        index = 0;
        questionType = nextKey;
      }
    }

    if (questionType == QuestionType.none && index == state.questions[QuestionType.none]!.length - 1) {
      await audioPlayer.resume();
    }

    this.index.value = index;
    this.questionType.value = questionType;
  }

  void _onStepBack(BuildContext context, QuestionResult Function()? resultFunction) async {
    var index = this.index.value;
    var questionType = this.questionType.value;

    if (index > 0) {
      index--;
    } else {
      final keyIndex = state.questions.keys.toList().indexOf(questionType);
      if (keyIndex > 0) {
        final prevKey = state.questions.keys.elementAt(keyIndex - 1);

        index = state.questions[prevKey]!.length - 1;
        questionType = prevKey;
      }
    }

    this.index.value = index;
    this.questionType.value = questionType;

    if (questionType == QuestionType.none && index == state.questions[QuestionType.none]!.length - 1) {
      await Future.delayed(Duration(milliseconds: 300));
      await audioPlayer.resume();
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

    onChange(questionType, index, score: value);
    textEditingController.text = value.toStringAsFixed(1);
  }

  void onChange(
    QuestionType questionType,
    int index, {
    String? file,
    double? score,
    double? maxSliderScore,
    double? maxTextScore,
    int? playCount,
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
                                playCount: playCount,
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

    if (questionModel is QuestionModel) {
      // questionModel.maxTextScore 60
      // questionModel.maxSliderScore 100 -> UI쪽에서 maxSliderScore보다 작은 값을 할당

      final maxScore = max(questionModel.maxTextScore, questionModel.maxSliderScore);
      final score = maxScore > 0 ? min(maxScore, text) : text;

      if (questionModel.score != score) {
        onChange(questionType, index, score: score);
        textEditingController.text = score.toString();
        textEditingController.selection = TextSelection(
          baseOffset: score.toString().length,
          extentOffset: score.toString().length,
        );
      }
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
