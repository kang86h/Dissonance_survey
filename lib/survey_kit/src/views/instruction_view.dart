import 'package:flutter/material.dart';

import '../../survey_kit.dart';

class InstructionView extends StatefulWidget {
  final InstructionStep instructionStep;

  InstructionView({required this.instructionStep});

  @override
  State<InstructionView> createState() => _InstructionViewState();
}

class _InstructionViewState extends State<InstructionView> {
  late final DateTime _startDate;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.instructionStep,
      title: Text(
        widget.instructionStep.title,
        style: Theme.of(context).textTheme.headline2,
        textAlign: TextAlign.left,
      ),
      resultFunction: () => InstructionStepResult(
        widget.instructionStep.stepIdentifier,
        _startDate,
        DateTime.now(),
      ),
      isValid: widget.instructionStep.isOptional,
      //isValid값을 isOptional로
      child: (() {
        final Widget sizedBox = widget.instructionStep.content;
        if (sizedBox is SizedBox &&
            sizedBox.height == 0.0 &&
            sizedBox.width == 0.0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Text(
              widget.instructionStep.text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.left,
            ),
          );
        }

        return widget.instructionStep.content;
      })(),
    );
  }
}
