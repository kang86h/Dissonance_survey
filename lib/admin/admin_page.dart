import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:surveykit_example/admin/model/type/condition_type.dart';
import 'package:surveykit_example/admin/model/type/range_type.dart';
import 'package:surveykit_example/admin/model/type/result_field_type.dart';
import 'package:surveykit_example/admin/model/type/user_field_type.dart';
import 'package:surveykit_example/admin/model/type/value/user_gender_value.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/main/model/question_model.dart';
import '../getx/get_rx_impl.dart';

import 'admin_page_controller.dart';

class AdminPage extends GetView<AdminPageController> {
  const AdminPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: controller.rx((state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...state.conditions.toList().asMap().entries.expand((x) => [
                          if (x.key > 0) ...[
                            const SizedBox(height: 10),
                            Divider(
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton(
                                  onChanged: (field) => controller.onPressedCondition(
                                      x.key,
                                      x.value.copyWith(
                                        field: field,
                                        range: RangeType.empty,
                                        condition: field == UserFieldType.createdAt ? ConditionType.between : ConditionType.empty,
                                        value: (() {
                                          if (field == UserFieldType.createdAt) {
                                            final now = DateTime.now();
                                            return [
                                              DateTime(now.year, now.month, now.day, 0, 0, 0),
                                              DateTime(now.year, now.month, now.day, 23, 59, 59),
                                            ];
                                          }

                                          return const [];
                                        })(),
                                      )),
                                  isExpanded: true,
                                  value: x.value.field,
                                  items: [
                                    ...UserFieldType.values.where((y) => y.isDropdown).map((y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y.name),
                                        )),
                                    ...ResultFieldType.values.where((y) => y.isDropdown).map((y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y.name),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: DropdownButton<RangeType>(
                                  onChanged: x.value.field is ResultFieldType
                                      ? (range) => controller.onPressedCondition(
                                          x.key,
                                          x.value.copyWith(
                                            range: range,
                                            condition: ConditionType.empty,
                                            value: const [],
                                          ))
                                      : null,
                                  isExpanded: true,
                                  value: x.value.range,
                                  items: [
                                    ...RangeType.values.map((y) => DropdownMenuItem(
                                          value: y,
                                          child: y == RangeType.empty ? const SizedBox.shrink() : Text(y.name),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: DropdownButton<ConditionType>(
                                  onChanged: (condition) => controller.onPressedCondition(
                                      x.key,
                                      x.value.copyWith(
                                        condition: condition,
                                        value: const [],
                                      )),
                                  isExpanded: true,
                                  value: x.value.condition,
                                  items: [
                                    ...ConditionType.values.where((y) => y.isField(x.value.field)).map((y) => DropdownMenuItem(
                                          value: y,
                                          child: y == ConditionType.empty ? const SizedBox.shrink() : Text(y.name),
                                        )),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: (() {
                                  final field = x.value.field;

                                  if (field == UserFieldType.gender) {
                                    return DropdownButton<UserGenderValue>(
                                      onChanged: (value) => controller.onPressedCondition(
                                          x.key,
                                          x.value.copyWith(
                                            value: [value],
                                          )),
                                      isExpanded: true,
                                      value: x.value.value.firstOrNull,
                                      items: [
                                        ...UserGenderValue.values.map((y) => DropdownMenuItem(
                                              value: y,
                                              child: Text(y.name),
                                            )),
                                      ],
                                    );
                                  } else if (field == UserFieldType.createdAt && x.value.condition == ConditionType.between) {
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: CalendarDatePicker(
                                            onDateChanged: (value) => controller.onPressedCondition(
                                                x.key,
                                                x.value.copyWith(
                                                  value: [value, x.value.value.secondOrNull],
                                                )),
                                            firstDate: DateTime(2000, 1, 1),
                                            lastDate: DateTime(2099, 12, 31),
                                            initialDate: DateTime.now(),
                                          ),
                                        ),
                                        Expanded(
                                          child: CalendarDatePicker(
                                            onDateChanged: (value) => controller.onPressedCondition(
                                                x.key,
                                                x.value.copyWith(
                                                  value: [x.value.value.firstOrNull, value],
                                                )),
                                            firstDate: DateTime(2000, 1, 1),
                                            lastDate: DateTime(2099, 12, 31),
                                            initialDate: DateTime.now(),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    if (x.value.condition == ConditionType.between) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) => controller.onPressedCondition(
                                                  x.key,
                                                  x.value.copyWith(
                                                    value: [int.tryParse(value).elvis, x.value.value.secondOrNull],
                                                  )),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              onChanged: (value) => controller.onPressedCondition(
                                                  x.key,
                                                  x.value.copyWith(
                                                    value: [x.value.value.firstOrNull, int.tryParse(value).elvis],
                                                  )),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return TextField(
                                      onChanged: (value) => controller.onPressedCondition(
                                          x.key,
                                          x.value.copyWith(
                                            value: [int.tryParse(value).elvis],
                                          )),
                                      keyboardType: TextInputType.number,
                                    );
                                  }
                                })(),
                              ),
                              IconButton(
                                onPressed: () => controller.onPressedRemoveCondition(x.key),
                                icon: Icon(
                                  Icons.close,
                                ),
                              ),
                            ],
                          ),
                        ]),
                    IconButton(
                      onPressed: controller.onPressedAddCondition,
                      icon: Icon(
                        Icons.add,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Colors.cyan,
                      ),
                    ),
                    child: controller.userStream.rx((rx) {
                      if (rx.isNullOrEmpty) {
                        return const Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      return Table(
                        children: [
                          TableRow(
                            children: [
                              ...UserFieldType.values.map((x) => TableCell(
                                    child: Text(x.name),
                                  )),
                            ],
                          ),
                          /*
                        Row(
                        ㅁㅁㅁㅁㅁ(필드) / ㅁㅁㅁㅁㅁ(데이터 조건) 동등, 이상, 이하인 게 하나라도 있을 때
                        ㅁㅁㅁㅁㅁ(필드) / ㅁㅁㅁㅁㅁ(데이터 조건) 동등, 이상, 이하
                        +
                        )

                        확인
                        */
                          ...rx.where((x) {
                            final data = x.data();

                            return state.conditions.every((x) {
                              final first = x.value.firstOrNull;
                              final second = x.value.secondOrNull;
                              Get.log('x.value: ${x.value}');
                              Get.log('first: $first');
                              Get.log('second: $second');
                              Get.log('');

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
                              } else if (x.field == UserFieldType.createdAt &&
                                  x.condition == ConditionType.between &&
                                  first is DateTime &&
                                  second is DateTime) {
                                final timestamp = data['createdAt'];

                                if (timestamp is Timestamp) {
                                  final dateTime = timestamp.toDate();

                                  return dateTime.millisecondsSinceEpoch >= first.millisecondsSinceEpoch &&
                                      dateTime.millisecondsSinceEpoch <= (second..add(Duration(days: 1))).millisecondsSinceEpoch;
                                }
                              }

                              return true;
                            });
                          }).map((x) {
                            final data = x.data();
                            final sorted = [
                              MapEntry('id', x.id),
                              ...UserFieldType.values.where((x) => !data.keys.contains(x.name) && x.name != 'id').map((x) => MapEntry(x.name, '')),
                              ...data.entries,
                            ].sorted((a, b) => getUserFieldIndex(name: a.key).compareTo(getUserFieldIndex(name: b.key)));

                            // _sorted.indexOf(a.key): gender -> 1
                            // _sorted.indexOf(a.key): age -> 0

                            // const Iterable<String> _sorted = ['age', 'gender', 'createdAt'];

                            // print('[1, 2, 3, 4].sorted((a, b) => a.compareTo(b)): ${[1, 2, 3, 4].sorted((a, b) => a.compareTo(b))}');

                            // 'a' < 'z' = -1
                            // 'a' = 'a' = 0
                            // 'z' > 'a' = 1

                            // 문자열 비교
                            // A -> Z
                            // a -> z
                            // 가 -> 하

                            return TableRow(
                              children: [
                                ...sorted.map((y) {
                                  final value = y.value;

                                  if (value is Timestamp) {
                                    return TableCell(
                                      child: Text(value.toDate().toString()),
                                    );
                                  }

                                  return TableCell(
                                    child: Text(y.value.toString()),
                                  );
                                }),
                              ],
                            );
                          })
                        ],
                      );
                      /*
                return ListView.builder(
                  itemCount: rx.length,
                  itemBuilder: (context, index) {
                    final item = rx[index];

                    return Text(item.data().entries.map((x) => x.toString()).join('\n'));
                  },
                );
                */
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: Colors.cyan,
                      ),
                    ),
                    child: controller.resultStream.rx((rx) {
                      return Table(
                        children: [
                          ...rx.map((x) {
                            final data = x.data();

                            final sorted = (() {
                              final sorted = data.entries.sorted((a, b) => getResultFieldIndex(name: a.key).compareTo(getResultFieldIndex(name: b.key)));
                              return sorted.expand((y) {
                                final value = y.value;

                                if (value is Map<dynamic, dynamic>) {
                                  // 타입 변환
                                  final map = Map.fromEntries([
                                    ...Map<String, dynamic>.from(value).entries.map((x) {
                                      return MapEntry(
                                        x.key,
                                        [
                                          ...Iterable.castFrom(x.value),
                                        ].map((y) => QuestionModel.fromJson(y)),
                                      );
                                    }),
                                  ]);

                                  return [
                                    // value 안의 questionModel 하나씩 file을 key로 하여 풂
                                    ...map.entries
                                        .expand((z) => z.value.map((w) => MapEntry(w.file, w)))
                                        .sorted((a, b) => a.value.file.compareTo(b.value.file)),
                                  ];
                                }

                                // user_id인 경우 or createdAt인 경우
                                return [y];
                              });
                            })();

                            return TableRow(
                              children: [
                                ...sorted.map((y) {
                                  final value = y.value;

                                  // user_id인 경우
                                  if (value is String) {
                                    return TableCell(
                                      child: Text(value),
                                    );
                                    // createdAt인 경우
                                  } else if (value is Timestamp) {
                                    return TableCell(
                                      child: Text(value.toDate().toString()),
                                    );
                                    // question인 경우
                                  } else if (value is QuestionModel) {
                                    return TableCell(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Text('id: ${value.file}'),
                                          Text('score: ${value.score.toStringAsFixed(2)}'),
                                          Text('volumes: ${value.volumes.map((x) => x.toStringAsFixed(2))}'),
                                          Text('play_count: ${value.volumes.length}'),
                                          Text('totalMilliseconds: ${value.totalMilliseconds}'),
                                        ],
                                      ),
                                    );
                                  }

                                  return TableCell(
                                    child: Text(''),
                                  );
                                }),
                              ],
                            );

                            /*
                          return TableRow(
                            children: [
                              ...sorted.map((y) {
                                final value = y.value;

                                // user_id인 경우
                                if (value is String) {
                                  return TableCell(
                                    child: Text(value),
                                  );
                                  // createdAt인 경우
                                } else if (value is Timestamp) {
                                  return TableCell(
                                    child: Text(value.toDate().toString()),
                                  );
                                  // question인 경우
                                } else if (value is Map<dynamic, dynamic>) {
                                  final temp = Map<String, dynamic>.from(value);

                                  final map = Map.fromEntries([
                                    ...temp.entries.map((x) {
                                      print('x.value: ${x.value}');
                                      print('');

                                      return MapEntry(
                                        x.key,
                                        [
                                          ...Iterable.castFrom(x.value),
                                        ].map((y) => QuestionModel.fromJson(y)),
                                      );
                                    }),
                                  ]);


                                  return TableCell(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // ...map.entries.expand((x) => x.value.map((y) => Text(y.toString()))),
                                      ],
                                    ),
                                  );
                                }

                                return TableCell(
                                  child: Text(''),
                                );
                              }),
                            ],
                          );
                          */
                          })
                        ],
                      );
                      /*
                return ListView.builder(
                  itemCount: rx.length,
                  itemBuilder: (context, index) {
                    final item = rx[index];

                    return Text(item.data().entries.map((x) => x.toString()).join('\n'));
                  },
                );
                */
                    }),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

/*
  Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      child: InkWell(
                        onTap: controller.onPressedUserData,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text('User Data'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      child: InkWell(
                        onTap: controller.onPressedResultData,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: Text('Result Data'),
                        ),
                      ),
                    ),
                    */
                  ],
                ),
              ),
  */
}
