import 'package:flutter/material.dart';
import 'package:survey_kit/src/result/step/instruction_step_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/instruction_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';

class InstructionView extends StatelessWidget {
  final InstructionStep instructionStep;
  final DateTime _startDate = DateTime.now();

  InstructionView({required this.instructionStep});

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: instructionStep,
      title: Text(
        instructionStep.title,
        style: Theme.of(context).textTheme.headline2,
        textAlign: TextAlign.center,
      ),
      resultFunction: () => InstructionStepResult(
        instructionStep.stepIdentifier,
        _startDate,
        DateTime.now(),
      ),
      child: (() {
        // 변수의 타입
        // 원시타입 -> 소문자로 시작하는 거, int, double, bool // call by value
        // 참조타입 -> 대문자로 시작하는 거, String, Widget, Text // call by reference

        /*
        int a = 10;
        int b = a;
        bool c = b == a;
        a = 15;
        // a = 15
        // b = 10

        // 객체를 만든다
        TextStyle t1 = new TextStyle(color: Colors.red, fontSize: 20);
        TextStyle t2 = t1;
        t1 = t1.copyWith(
          color: Colors.blue,
        );
        */

        // t1 blue
        // t2 blue

        /*
        if (instructionStep.content is SizedBox) {
          instructionStep.content.width;
          instructionStep.content.height;
        }

        // Widget
        final Widget sizedBox = instructionStep.content;
        if (sizedBox is SizedBox && sizedBox.height == 0 && sizedBox.width == 0) {
          // SizedBox 형변환
          sizedBox.width;
          sizedBox.height;
        }
        */

        final Widget sizedBox = instructionStep.content;
        if (sizedBox is SizedBox && sizedBox.height == 0.0 && sizedBox.width == 0.0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              instructionStep.text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          );
        }

        return instructionStep.content;

        /*
        if (instructionStep.content != const SizedBox()) {
          return instructionStep.content;
        }
        */
      })(),
      /*
      IIFE
      즉시실행함수
      true ? A : B

      1. content가 있으면 text가 아니고 content를 보여준다
      2. content가 없으면 text를 보여준다
      */
    );
  }
}
