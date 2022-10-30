import 'dart:js';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:survey_kit/survey_kit.dart';

import '../getx/get_rx_impl.dart';
import 'main_page_controller.dart';

class MainPage extends GetView<MainPageController> {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Task>(
          future: getSampleTask(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              final task = snapshot.data!;
              return SurveyKit(
                onResult: (SurveyResult result) {
                  print(result.finishReason);
                  Navigator.pushNamed(context, '/');
                },
                task: task,
                showProgress: true,
                localizations: {
                  'cancel': 'Cancel',
                  'next': 'Next',
                },
                themeData: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colors.cyan,
                  ).copyWith(
                    onPrimary: Colors.white,
                  ),
                  primaryColor: Colors.cyan,
                  backgroundColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    color: Colors.white,
                    iconTheme: IconThemeData(
                      color: Colors.cyan,
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.cyan,
                    ),
                  ),
                  iconTheme: const IconThemeData(
                    color: Colors.cyan,
                  ),
                  textSelectionTheme: TextSelectionThemeData(
                    cursorColor: Colors.cyan,
                    selectionColor: Colors.cyan,
                    selectionHandleColor: Colors.cyan,
                  ),
                  cupertinoOverrideTheme: CupertinoThemeData(
                    primaryColor: Colors.cyan,
                  ),
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(
                        Size(150.0, 60.0),
                      ),
                      side: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> state) {
                          if (state.contains(MaterialState.disabled)) {
                            return BorderSide(
                              color: Colors.grey,
                            );
                          }
                          return BorderSide(
                            color: Colors.cyan,
                          );
                        },
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      textStyle: MaterialStateProperty.resolveWith(
                        (Set<MaterialState> state) {
                          if (state.contains(MaterialState.disabled)) {
                            return Theme.of(context).textTheme.button?.copyWith(
                                  color: Colors.grey,
                                );
                          }
                          return Theme.of(context).textTheme.button?.copyWith(
                                color: Colors.cyan,
                              );
                        },
                      ),
                    ),
                  ),
                  textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.button?.copyWith(
                              color: Colors.cyan,
                            ),
                      ),
                    ),
                  ),
                  textTheme: TextTheme(
                    headline2: TextStyle(
                      fontSize: 28.0,
                      color: Colors.black,
                    ),
                    headline5: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                    bodyText2: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                    subtitle1: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                surveyProgressbarConfiguration: SurveyProgressConfiguration(
                  backgroundColor: Colors.white,
                ),
              );
            }
            return CircularProgressIndicator.adaptive();
          },
        ),
      ),
    );
  }

  InstructionStep getStart() {
    return InstructionStep(
      title: '이 설문조사는 화음을 듣고 불협화도 점수를 매기는 조사입니다',
      text: '참여자분들께서는 약 3초간 화음을 듣고 화음의 불협화도 점수를 매겨주시면 됩니다\n'
          '협화적인 화음일수록 낮은 점수를, 불협화적인 화음일수록 높은 점수를 매기세요\n'
          '점수는 숫자로 기입하시거나, 슬라이더에서 위치를 조절하셔서 매기세요\n'
          '화음에 사용된 음의 갯수에따라 최고점이 다릅니다\n'
          '(2음화음 최대 60점, 3음화음 최대 100점, 4음화음 최대 140점)\n',
      buttonText: '시작',
    );
  }

  QuestionStep getGenderStep() {
    return QuestionStep(
      title: '당신의 성별은 무엇인가요?',
      isOptional: false,
      answerFormat: SingleChoiceAnswerFormat(
        textChoices: [
          TextChoice(text: '남성', value: 'Male'),
          TextChoice(text: '여성', value: 'Female'),
        ],
      ),
    );
  }

  QuestionStep getAgeStep() {
    return QuestionStep(
        title: '당신의 나이는 어떻게 되십니까?',
        answerFormat: IntegerAnswerFormat(),
        isOptional: false);
  }

  QuestionStep getVolume() {
    return QuestionStep(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 128),
        child: Column(
          children: [
            Text(
              '테스트에 적절한 볼륨으로 조절해주세요',
              style: TextStyle(
                fontSize: 30,
                color: Colors.black,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                  border: Border.all(
                width: 2,
                color: Colors.cyan,
              )),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('재생',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            )),
                        ObxValue<Rx<PlayerState>>((rx) {
                          return InkWell(
                            onTap: () => controller.onPressedState(rx.value),
                            child: Icon(
                              rx.value == PlayerState.playing
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              size: 48,
                            ),
                          );
                        }, controller.playerState),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '볼륨조절',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Icon(
                          Icons.volume_up_rounded,
                          size: 48,
                        ),
                        ObxValue<Rx<double>>((rx) {
                          return Slider(
                            onChanged: controller.onChangedVolume,
                            min: 0,
                            max: 1,
                            value: rx.value,
                          ); // score
                        }, controller.volume),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      answerFormat: DoubleAnswerFormat(
        controller: controller.textEditingController,
      ),
    );
  }

  QuestionStep getMainStep() {
    return QuestionStep(
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 128),
          child: Column(
            children: [
              Text(
                '지금 들려주는 화음을 듣고 점수를 매겨주세요',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                  color: Colors.black,
                )),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('재생',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              )),
                          ObxValue<Rx<PlayerState>>((rx) {
                            return InkWell(
                              onTap: () => controller.onPressedState(rx.value),
                              child: Icon(
                                rx.value == PlayerState.playing
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                size: 48,
                              ),
                            );
                          }, controller.playerState),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            '볼륨조절',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Icon(
                            Icons.volume_up_rounded,
                            size: 48,
                          ),
                          ObxValue<Rx<double>>((rx) {
                            return Slider(
                              onChanged: controller.onChangedVolume,
                              min: 0,
                              max: 1,
                              value: rx.value,
                            ); // score
                          }, controller.volume),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text('불협화도 점수',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      )),
                  ObxValue<Rx<double>>((rx) {
                    return Slider(
                      onChanged: controller.onChangedScore,
                      min: 0,
                      max: 100,
                      value: rx.value,
                    ); // score
                  }, controller.score),
                ],
              ),
            ],
          ),
        ),
        answerFormat: DoubleAnswerFormat(
          controller: controller.textEditingController,
        ),
        isOptional: true);
  }

  Future<Task> getSampleTask() async {
    return NavigableTask(
      id: TaskIdentifier(),
      steps: [
        getStart(),
        getGenderStep(),
        getAgeStep(),
        getVolume(),
        getMainStep(),
      ],
    );
  }
}
/*

class _MyAppState extends State<App> {
  @override
  void initState() {
    super.initState();

    final first = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final second = first.copyWith(
      fontSize: 15,
    );
    // fontsize: 15, fontWeight: bold

    /*
    final bool? a = null;
    final bool b = true;

    final c = a.elvis;
    final d = a ?? false;
    final e = a ?? false;

    final int a = 10;
    final int? b = null;
    final int c = a + b.elvis;
    final int d = a + (b ?? 0);
    final int e = a + (b ?? 0);
    final int f = a + (b ?? 0);

    build(context);
    dispose();
    */
    audioPlayer.setSourceAsset('Q1.wav');
    textEditingController.addListener(onListenText);
    playerState.bindStream(audioPlayer.onPlayerStateChanged);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    textEditingController.dispose();
    [playerState, volume, score].forEach((x) => x.close());
    super.dispose();
  }

  void onListenVideo() {
    /*
    final isPlaying = videoPlayerController.value.isPlaying;
    this.isPlaying.value = isPlaying;

    final volume = videoPlayerController.value.volume;
    this.volume.value = volume;
    */
  }

  void onListenText() {
    final score = double.tryParse(textEditingController.value.text) ?? 0;
    this.score.value = min(1000, score);
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/main',
      getPages: [
        GetPage(name: '/main', page: () => MainPage(), binding: MainPageBinding()),
      ],
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.center,
            child: FutureBuilder<Task>(
              future: getSampleTask(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
                  final task = snapshot.data!;
                  return SurveyKit(
                    onResult: (SurveyResult result) {
                      print(result.finishReason);
                      Navigator.pushNamed(context, '/');
                    },
                    task: task,
                    showProgress: true,
                    localizations: {
                      'cancel': 'Cancel',
                      'next': 'Next',
                    },
                    themeData: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.cyan,
                      ).copyWith(
                        onPrimary: Colors.white,
                      ),
                      primaryColor: Colors.cyan,
                      backgroundColor: Colors.white,
                      appBarTheme: const AppBarTheme(
                        color: Colors.white,
                        iconTheme: IconThemeData(
                          color: Colors.cyan,
                        ),
                        titleTextStyle: TextStyle(
                          color: Colors.cyan,
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.cyan,
                      ),
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: Colors.cyan,
                        selectionColor: Colors.cyan,
                        selectionHandleColor: Colors.cyan,
                      ),
                      cupertinoOverrideTheme: CupertinoThemeData(
                        primaryColor: Colors.cyan,
                      ),
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            Size(150.0, 60.0),
                          ),
                          side: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return BorderSide(
                                  color: Colors.grey,
                                );
                              }
                              return BorderSide(
                                color: Colors.cyan,
                              );
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          textStyle: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Theme.of(context).textTheme.button?.copyWith(
                                      color: Colors.grey,
                                    );
                              }
                              return Theme.of(context).textTheme.button?.copyWith(
                                    color: Colors.cyan,
                                  );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.button?.copyWith(
                                  color: Colors.cyan,
                                ),
                          ),
                        ),
                      ),
                      textTheme: TextTheme(
                        headline2: TextStyle(
                          fontSize: 28.0,
                          color: Colors.black,
                        ),
                        headline5: TextStyle(
                          fontSize: 24.0,
                          color: Colors.black,
                        ),
                        bodyText2: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                        subtitle1: TextStyle(
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    surveyProgressbarConfiguration: SurveyProgressConfiguration(
                      backgroundColor: Colors.white,
                    ),
                  );
                }
                return CircularProgressIndicator.adaptive();
              },
            ),
          ),
        ),
      ),
    );
  }

  // 페이지 안에 스텝이 여러개
  //
  Future<Task> getSampleTask() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        QuestionStep(
          content: Column(
            children: [
              Text(
                '지금 들려주는 화음을 듣고 점수를 매겨주세요',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                    border: Border.all(
                  width: 2,
                  color: Colors.black,
                )),
                child: Row(
                  children: [
                    ObxValue<Rx<PlayerState>>((rx) {
                      return InkWell(
                        onTap: () async {
                          if (rx.value == PlayerState.playing) {
                            await audioPlayer.pause();
                          } else if (rx.value == PlayerState.paused) {
                            await audioPlayer.resume();
                          } else {
                            await audioPlayer.seek(Duration.zero);
                            await audioPlayer.resume();
                          }
                        },
                        child: Icon(
                          rx.value == PlayerState.playing ? Icons.pause_circle_outline : Icons.play_circle_outline,
                          size: 32,
                        ),
                      );
                    }, playerState),
                    ObxValue<Rx<double>>((rx) {
                      return Slider(
                        onChanged: (double value) {
                          // videoPlayerController.setVolume(value);
                        },
                        min: 0,
                        max: 1,
                        value: rx.value,
                      ); // score
                    }, volume),
                  ],
                ),
              ),
              ObxValue<Rx<double>>((rx) {
                return Slider(
                  onChanged: (double value) {
                    rx.value = value;
                    textEditingController.text = value.toStringAsFixed(1);
                  },
                  min: 0,
                  max: 1000,
                  value: rx.value,
                ); // score
              }, score),
            ],
          ),
          answerFormat: DoubleAnswerFormat(
            controller: textEditingController,
          ),
          buttonText: '다음으로',
        ),
        QuestionStep(
          title: 'Select your body type',
          answerFormat: ScaleAnswerFormat(
            step: 1,
            minimumValue: 1,
            maximumValue: 5,
            defaultValue: 3,
            minimumValueDescription: '1',
            maximumValueDescription: '5',
          ),
        ),
        QuestionStep(
          title: 'Known allergies',
          text: 'Do you have any allergies that we should be aware of?',
          isOptional: false,
          answerFormat: MultipleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'Penicillin', value: 'Penicillin'),
              TextChoice(text: 'Latex', value: 'Latex'),
              TextChoice(text: 'Pet', value: 'Pet'),
              TextChoice(text: 'Pollen', value: 'Pollen'),
            ],
          ),
        ),
        QuestionStep(
          title: 'Done?',
          text: 'We are done, do you mind to tell us more about yourself?',
          isOptional: true,
          answerFormat: SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'Yes', value: 'Yes'),
              TextChoice(text: 'No', value: 'No'),
            ],
            defaultSelection: TextChoice(text: 'No', value: 'No'),
          ),
        ),
        QuestionStep(
          title: 'When did you wake up?',
          answerFormat: TimeAnswerFormat(
            defaultValue: TimeOfDay(
              hour: 12,
              minute: 0,
            ),
          ),
        ),
        QuestionStep(
          title: 'When was your last holiday?',
          answerFormat: DateAnswerFormat(
            minDate: DateTime.utc(1970),
            defaultDate: DateTime.now(),
            maxDate: DateTime.now(),
          ),
        ),
        CompletionStep(
          stepIdentifier: StepIdentifier(id: '321'),
          text: 'Thanks for taking the survey, we will contact you soon!',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[6].stepIdentifier,
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          switch (input) {
            case "Yes":
              return task.steps[0].stepIdentifier;
            case "No":
              return task.steps[7].stepIdentifier;
            default:
              return null;
          }
        },
      ),
    );
    return Future.value(task);
  }
}

*/
