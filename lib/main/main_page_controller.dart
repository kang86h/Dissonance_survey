import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import '../survey_kit/survey_kit.dart';
import 'main_page_model.dart';

enum QuestionType {
  none,
  q2,
  q3,
  q4,
}

extension QuestionTypeEx on QuestionType {
  String get name =>
      {
        QuestionType.q2: 'ㅇㅇㅇ',
        QuestionType.q3: 'ㅁㅁㅁ',
        QuestionType.q4: 'ㅅㅅㅅ',
      }[this] ??
      '';
}

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  // 1개
  late final SurveyController surveyController = SurveyController(
    onNextStep: _onNextStep,
  );

  final AudioPlayer audioPlayer = AudioPlayer();

  final Rx<PlayerState> playerState = PlayerState.stopped.obs;
  final Rx<double> volume = 1.0.obs;

  // 여러개
  final Map<QuestionType, Iterable<String>> files = {
    QuestionType.none: ['volume.mp3'],
    QuestionType.q2: Iterable.generate(2, (i) => 'Q2/Q2-${i + 1}.wav'),
    QuestionType.q3: Iterable.generate(6, (i) => 'Q3/Q3-${i + 1}.wav'),
    QuestionType.q4: Iterable.generate(6, (i) => 'Q4/Q4-${i + 1}.wav'),
  };

  final Map<QuestionType, Iterable<double>> maxScores = {
    QuestionType.none: [100],
    QuestionType.q2: [100, 0],
  };

  final Rx<QuestionType> questionType = QuestionType.none.obs;
  final Rx<int> index = 0.obs;

  final TextEditingController textEditingController = TextEditingController();
  final Rx<double> score = 0.0.obs;

  // key: none
  // index: 0

  // key: q2
  // index: 0
  void _onNextStep(BuildContext context, QuestionResult Function() resultFunction) {
    // index: 0
    // length - 1: 0
    if (index.value < files[questionType.value]!.length - 1) {
      index.value++;
    } else {
      final keyIndex = files.keys.toList().indexOf(questionType.value); // 0
      if (keyIndex < files.keys.length - 1) {
        final nextKey = files.keys.elementAt(keyIndex + 1);
        index.value = 0;
        questionType.value = nextKey;
      }
      // complete
    }
  }

  @override
  void onInit() {
    super.onInit();
    // audioPlayer.setSourceAsset(files.elementAt(state.index));
    // questionType이 바뀌거나 또는, index가 바뀌거나
    rx.Rx.combineLatest2<QuestionType, int, String>(questionType.stream, index.stream, (questionType, index) => files[questionType]!.elementAt(index))
        .listen((file) async {
      textEditingController.text = '0.0';
      await audioPlayer.pause();
      await audioPlayer.setSourceAsset(file);
    });

    textEditingController.addListener(onListenText);
    playerState.bindStream(audioPlayer.onPlayerStateChanged);
  }

  @override
  void onClose() async {
    await audioPlayer.dispose();
    [playerState, volume].forEach((x) => x.close());
    textEditingController.dispose();
    score.close();
    super.onClose();
  }

  void onChangedScore(double value) {
    score.value = value;
    textEditingController.text = value.toStringAsFixed(1);
  }

  void onChangedVolume(double value) {
    audioPlayer.setVolume(value);
    volume.value = value;
  }

  void onListenText() {
    final score = double.tryParse(textEditingController.value.text) ?? 0;
    final maxScore = maxScores[questionType.value]?.elementAt(index.value) ?? 0;

    this.score.value = maxScore > 0 ? min(maxScore, score) : score;
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
