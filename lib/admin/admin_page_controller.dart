import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surveykit_example/admin/admin_page_model.dart';
import 'package:surveykit_example/admin/model/type/condition_model.dart';
import 'package:surveykit_example/admin/model/type/condition_type.dart';
import 'package:surveykit_example/admin/model/type/range_type.dart';
import 'package:surveykit_example/admin/model/type/result_field_type.dart';
import 'package:surveykit_example/admin/model/type/user_field_type.dart';
import 'package:surveykit_example/admin/model/type/value/user_gender_value.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/getx/get_controller.dart';
import 'package:surveykit_example/getx/get_rx_impl.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:surveykit_example/main/model/question_model.dart';

class AdminPageController extends GetController<AdminPageModel> {
  AdminPageController({
    required AdminPageModel model,
  }) : super(model);

  final rx.BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> userStream = rx.BehaviorSubject()
    ..addStream(FirebaseFirestore.instance.collection('user').snapshots().map((x) => x.docs));
  final rx.BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> resultStream = rx.BehaviorSubject()
    ..addStream(FirebaseFirestore.instance.collection('result').snapshots().map((x) => x.docs));

  late final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> filterUserList = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  late final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> filterResultList = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void onPressedUserData() async {
    final userCollection = FirebaseFirestore.instance.collection('user');
    final userDoc = await userCollection.get();
    userDoc.docs.forEach((x) => print('x.data(): ${x.data()}'));
  }

  void onPressedResultData() async {
    final resultCollection = FirebaseFirestore.instance.collection('result');
    final resultDoc = await resultCollection.get();
    resultDoc.docs.forEach((x) => print('x.data(): ${x.data()}'));
  }

  void onPressedAddCondition() {
    change(state.copyWith(
      conditions: [
        ...state.conditions,
        ConditionModel.empty(),
      ],
    ));
  }

  void onPressedApplyCondition() {
    final filterUserList = userStream.value.where((x) {
      final data = x.data();

      return state.conditions.every((x) {
        final first = x.value.firstOrNull;
        final second = x.value.secondOrNull;

        if (x.field == UserFieldType.age && first is int) {
          if (x.condition == ConditionType.more_than) {
            return data['age'] >= first;
          } else if (x.condition == ConditionType.less_than) {
            return data['age'] <= first;
          } else if (x.condition == ConditionType.between && second is int) {
            return data['age'] >= first && data['age'] <= second;
          } else if (x.condition == ConditionType.equals) {
            return data['age'] == first;
          } else if (x.condition == ConditionType.not_equals) {
            return data['age'] != first;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.gender && first is UserGenderValue) {
          if (x.condition == ConditionType.equals) {
            return data['gender'] == first.name;
          } else if (x.condition == ConditionType.not_equals) {
            return data['gender'] != first.name;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.video_milliseconds && first is int) {
          if (x.condition == ConditionType.more_than) {
            return data['video_milliseconds'] >= first;
          } else if (x.condition == ConditionType.less_than) {
            return data['video_milliseconds'] <= first;
          } else if (x.condition == ConditionType.between && second is int) {
            return data['video_milliseconds'] >= first && data['video_milliseconds'] <= second;
          } else if (x.condition == ConditionType.equals) {
            return data['video_milliseconds'] == first;
          } else if (x.condition == ConditionType.not_equals) {
            return data['video_milliseconds'] != first;
          } else {
            return true;
          }
        } else if (x.field == UserFieldType.createdAt && x.condition == ConditionType.between && first is DateTime && second is DateTime) {
          final timestamp = data['createdAt'];

          if (timestamp is Timestamp) {
            final dateTime = timestamp.toDate();

            return dateTime.millisecondsSinceEpoch >= first.millisecondsSinceEpoch &&
                dateTime.millisecondsSinceEpoch <= (second..add(Duration(days: 1))).millisecondsSinceEpoch;
          }
        }

        return true;
      });
    }).toList();
    final filterResultList = resultStream.value.where((x) {
      final data = x.data();

      final questions = data.entries.map((y) => y.value).whereType<Map<dynamic, dynamic>>().expand((y) {
        final map = Map.fromEntries([
          ...Map<String, dynamic>.from(y).entries.map((x) {
            return MapEntry(
              x.key,
              [
                ...Iterable.castFrom(x.value),
              ].map((y) => QuestionModel.fromJson(y)),
            );
          }),
        ]);

        return map.entries.expand((z) => z.value.map((w) => MapEntry(w.file, w)));
      });

      return state.conditions.every((x) {
        final first = x.value.firstOrNull;
        final second = x.value.secondOrNull;

        if (x.field == ResultFieldType.score && first is num) {
          final condition = ((num score) {
            if (x.condition == ConditionType.more_than) {
              return score >= first;
            } else if (x.condition == ConditionType.less_than) {
              return score <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return score >= first && score <= second;
            } else if (x.condition == ConditionType.equals) {
              return score == first;
            } else if (x.condition == ConditionType.not_equals) {
              return score != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.score));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.score));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.score).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.score).reduce(min));
          }
        } else if (x.field == ResultFieldType.volumes && first is num) {
          final condition = ((num volume) {
            if (x.condition == ConditionType.more_than) {
              return volume >= first;
            } else if (x.condition == ConditionType.less_than) {
              return volume <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return volume >= first && volume <= second;
            } else if (x.condition == ConditionType.equals) {
              return volume == first;
            } else if (x.condition == ConditionType.not_equals) {
              return volume != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => y.value.volumes.any((z) => condition(z)));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => y.value.volumes.every((z) => condition(z)));
          } else if (x.range == RangeType.max) {
            return condition(questions.expand((x) => x.value.volumes).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.expand((x) => x.value.volumes).reduce(min));
          }
        } else if (x.field == ResultFieldType.play_count && first is int) {
          final condition = ((int playCount) {
            if (x.condition == ConditionType.more_than) {
              return playCount >= first;
            } else if (x.condition == ConditionType.less_than) {
              return playCount <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return playCount >= first && playCount <= second;
            } else if (x.condition == ConditionType.equals) {
              return playCount == first;
            } else if (x.condition == ConditionType.not_equals) {
              return playCount != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.volumes.length));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.volumes.length));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.volumes.length).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.volumes.length).reduce(min));
          }
        } else if (x.field == ResultFieldType.totalMilliseconds && first is int) {
          final condition = ((int totalMilliseconds) {
            if (x.condition == ConditionType.more_than) {
              return totalMilliseconds >= first;
            } else if (x.condition == ConditionType.less_than) {
              return totalMilliseconds <= first;
            } else if (x.condition == ConditionType.between && second is int) {
              return totalMilliseconds >= first && totalMilliseconds <= second;
            } else if (x.condition == ConditionType.equals) {
              return totalMilliseconds == first;
            } else if (x.condition == ConditionType.not_equals) {
              return totalMilliseconds != first;
            } else {
              return true;
            }
          });

          if (x.range == RangeType.any) {
            return questions.any((y) => condition(y.value.totalMilliseconds));
          } else if (x.range == RangeType.all) {
            return questions.every((y) => condition(y.value.totalMilliseconds));
          } else if (x.range == RangeType.max) {
            return condition(questions.map((x) => x.value.totalMilliseconds).reduce(max));
          } else if (x.range == RangeType.min) {
            return condition(questions.map((x) => x.value.totalMilliseconds).reduce(min));
          }
        }

        return true;
      });
    }).toList();

    final filterUserIdList = filterUserList.map((x) => x.id);
    final filterResultIdList = filterResultList.map((x) => x.data()['user_id']);

    this.filterUserList.value = filterUserList.where((x) => filterResultIdList.contains(x.id)).toList();
    this.filterResultList.value = filterResultList.where((x) => filterUserIdList.contains(x.data()['user_id'])).toList();
  }

  void onPressedRemoveCondition(int index) {
    change(state.copyWith(
      conditions: [
        ...state.conditions.toList().asMap().entries.where((x) => x.key != index).map((x) => x.value),
      ],
    ));
  }

  void onPressedCondition(int index, ConditionModel condition) {
    change(state.copyWith(
      conditions: [
        ...state.conditions.toList().asMap().entries.map((x) => x.key == index ? condition : x.value),
      ],
    ));
  }
}
