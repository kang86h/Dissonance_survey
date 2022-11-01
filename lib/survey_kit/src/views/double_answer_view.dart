import 'package:flutter/material.dart';

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

  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _doubleAnswerFormat = widget.questionStep.answerFormat as DoubleAnswerFormat;
    widget.controller?.text = widget.result?.result?.toString() ?? '';
    _checkValidation(widget.controller?.text ?? '');
    _startDate = DateTime.now();
  }

  void _checkValidation(String text) {
    setState(() {
      _isValid = text.isNotEmpty && double.tryParse(text) != null;
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
            onChanged: (value) {
              _checkValidation(value);
            },
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
