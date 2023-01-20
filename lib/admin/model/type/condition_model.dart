import 'dart:math';

import 'package:surveykit_example/admin/model/type/condition_type.dart';
import 'package:surveykit_example/admin/model/type/range_type.dart';
import 'package:surveykit_example/getx/get_model.dart';

class ConditionModel extends GetModel {
  ConditionModel({
    required this.condition,
    required this.range,
    required this.field,
  });

  final ConditionType condition;
  final RangeType range;
  final dynamic field;

  static final ConditionModel _empty = ConditionModel(
    condition: ConditionType.values.first,
    range: RangeType.values.first,
    field: null,
  );

  factory ConditionModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  ConditionModel copyWith({
    ConditionType? condition,
    RangeType? range,
    dynamic field,
  }) {
    return ConditionModel(
      condition: condition ?? this.condition,
      range: range ?? this.range,
      field: field ?? this.field,
    );
  }

  @override
  List<Object?> get props => [condition, range, field];

  @override
  String toString() => 'condition: $condition range: $range field: $field';
}
