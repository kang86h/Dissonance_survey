import '../getx/get_model.dart';

class MainPageModel extends GetModel {
  MainPageModel({
    required this.index,
  });

  final int index;

  static final MainPageModel _empty = MainPageModel(
    index: 0,
  );

  factory MainPageModel.empty() => _empty;

  @override
  bool get isEmpty => this == _empty;

  @override
  MainPageModel copyWith({
    int? index,
  }) {
    return MainPageModel(
      index: index ?? this.index,
    );
  }

  @override
  List<Object?> get props => [index];

  @override
  String toString() => 'index: $index';
}
