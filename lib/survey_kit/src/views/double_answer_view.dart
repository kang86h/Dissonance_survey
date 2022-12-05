import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../survey_kit.dart';

class DoubleAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final DoubleQuestionResult? result;
  TextEditingController? controller;

  DoubleAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
    this.controller,
  }) : super(key: key);

  @override
  _DoubleAnswerViewState createState() => _DoubleAnswerViewState();
}

class _DoubleAnswerViewState extends State<DoubleAnswerView> {
  late final DoubleAnswerFormat _doubleAnswerFormat;
  late final DateTime _startDate;

  late bool _isValid = (double.tryParse(widget.controller!.value.text) ?? 0) > 0;

  @override
  void initState() {
    super.initState();
    _doubleAnswerFormat = widget.questionStep.answerFormat as DoubleAnswerFormat;
    _startDate = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller?.addListener(onListenText);
      widget.controller?.text = widget.result?.result?.toString() ?? '';
    });

    Get.focusScope?.unfocus();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(onListenText);
    super.dispose();
  }

  void onListenText() {
    final text = double.tryParse(widget.controller!.value.text) ?? 0;

    setState(() {
      _isValid = text > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      textEditingController: widget.controller,
      resultFunction: () => DoubleQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: widget.controller?.text ?? '',
        result: double.tryParse(widget.controller?.text ?? '') ?? _doubleAnswerFormat.defaultValue ?? null,
      ),
      isValid: _isValid || widget.questionStep.isOptional,
      title: widget.questionStep.title.isNotEmpty
          ? Text(
              widget.questionStep.title,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            )
          : widget.questionStep.content,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: TextField(
            decoration: textFieldInputDecoration(
              hint: _doubleAnswerFormat.hint,
            ),
            controller: widget.controller!,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
