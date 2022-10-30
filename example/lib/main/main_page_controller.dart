import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../getx/get_controller.dart';
import '../getx/get_rx_impl.dart';
import 'main_page_model.dart';

class MainPageController extends GetController<MainPageModel> {
  MainPageController({
    required MainPageModel model,
  }) : super(model);

  // 1개
  final AudioPlayer audioPlayer = AudioPlayer();

  final Rx<PlayerState> playerState = PlayerState.stopped.obs;
  final Rx<double> volume = 1.0.obs;

  // 여러개
  final Iterable<String> files = ['volume.mp3', 'Q2-1.wav'];

  final TextEditingController textEditingController = TextEditingController();
  final Rx<double> score = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    audioPlayer.setSourceAsset(files.elementAt(state.index));
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
    this.score.value = min(1000, score);
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
