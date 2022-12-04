import 'package:surveykit_example/admin/model/adminsetting.dart';

import '../getx/get_model.dart';

class AdminPageModel extends GetModel {
  AdminPageModel({
    required this.adminsetting,
  });

  final Iterable adminsetting;
  static final AdminPageModel _empty = AdminPageModel(
    adminsetting: const {},
  );


  factory AdminPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  AdminPageModel copyWith({
    Iterable? adminsetting,
  }) {
    return AdminPageModel(
      adminsetting: adminsetting ?? this.adminsetting,
    );
  }
  @override
  List<Object?> get props => [adminsetting];

  @override
  String toString() => 'adminsetting: $adminsetting';
}