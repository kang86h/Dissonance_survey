// by Antonio Bruno, Giacomo Ignesti and Massimo Martinelli

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../survey_kit.dart';

part 'double_answer_format.g.dart';

@JsonSerializable()
class DoubleAnswerFormat implements AnswerFormat {
  final double? defaultValue;
  final String hint;
  final TextEditingController? controller;

  const DoubleAnswerFormat({
    this.defaultValue,
    this.hint = '',
    this.controller,
  }) : super();

  factory DoubleAnswerFormat.fromJson(Map<String, dynamic> json) =>
      _$DoubleAnswerFormatFromJson(json);
  Map<String, dynamic> toJson() => _$DoubleAnswerFormatToJson(this);
}
