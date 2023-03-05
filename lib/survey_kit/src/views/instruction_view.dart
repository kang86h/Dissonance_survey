import 'package:flutter/material.dart';

import '../../survey_kit.dart';

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
        textAlign: TextAlign.left,
      ),
      resultFunction: () => InstructionStepResult(
        instructionStep.stepIdentifier,
        _startDate,
        DateTime.now(),
      ),
      isValid: instructionStep.isOptional,//isValid값을 isOptional로
      child: (() {
        final Widget sizedBox = instructionStep.content;
        if (sizedBox is SizedBox &&
            sizedBox.height == 0.0 &&
            sizedBox.width == 0.0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              instructionStep.text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
            ),
          );
        }

        return instructionStep.content;
      })(),
    );
  }
}
