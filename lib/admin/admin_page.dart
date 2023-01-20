import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:surveykit_example/admin/model/type/result_field_type.dart';
import 'package:surveykit_example/admin/model/type/user_field_type.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              controller.rx((state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...state.conditions.toList().asMap().entries.map((x) => Row(
                          children: [
                            Expanded(
                              child: DropdownButton(
                                onChanged: (field) => controller.onPressedCondition(x.key, x.value.copyWith(
                                  field: field,
                                )),
                                value: x.value.field,
                                items: [
                                  ...UserFieldType.values.where((x) => x.isDropdown).map((x) => DropdownMenuItem(
                                        value: x,
                                        child: Text(x.name),
                                      )),
                                  ...ResultFieldType.values.where((x) => x.isDropdown).map((x) => DropdownMenuItem(
                                        value: x,
                                        child: Text(x.name),
                                      )),
                                ],
                              ),
                            ),
                            Expanded(child: Text(x.value.range.name)),
                            Expanded(child: Text(x.value.condition.name)),
                          ],
                        )),
                    IconButton(
                      onPressed: controller.onPressedAddCondition,
                      icon: Icon(
                        Icons.add,
                      ),
                    ),
                  ],
                );
              }),
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
                        ...rx.map((x) {
                          final data = x.data();

                          /*
                    {
                      age: 11,
                      gender: 'male'
                    },

                    [
                      MapEntry('age', '11'),
                      MapEntry('gender', 'male'),
                    ]

                    {
                      gender: 'male'
                      age: 11,
                    }

                    [
                      MapEntry('gender', 'male'),
                      MapEntry('age', '11'),
                    ]
                    */
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
                                  ...map.entries.expand((z) => z.value.map((w) => MapEntry(w.file, w))).sorted((a, b) => a.value.file.compareTo(b.value.file)),
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
          ),
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
