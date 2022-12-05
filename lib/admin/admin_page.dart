import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:surveykit_example/getx/extension.dart';
import 'package:surveykit_example/main/model/question_model.dart';
import '../getx/get_rx_impl.dart';

import 'admin_page_controller.dart';

const List<String> _sortedUser = ['id', 'age', 'gender', 'createdAt'];
const List<String> _sortedResult = ['user_id', 'question', 'createdAt'];

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
                    return Table(
                      children: [
                        TableRow(
                          children: [
                            ..._sortedUser.map((x) => TableCell(
                                  child: Text(x),
                                )),
                          ],
                        ),
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
                          print('0 data.entries: ${data.entries}');
                          // final sorted = data.entries.sorted((a, b) => _sorted.indexOf(a.key).compareTo(_sorted.indexOf(b.key)));
                          final sorted = [
                            MapEntry('id', x.id),
                            ...data.entries,
                          ].sorted((a, b) => _sortedUser.indexOf(a.key).compareTo(_sortedUser.indexOf(b.key)));

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
                          print('sorted: ${sorted}');

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
                                  child: Text(y.value),
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
                            final sorted = data.entries.sorted((a, b) => _sortedResult.indexOf(a.key).compareTo(_sortedResult.indexOf(b.key)));
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
                                        Text('score: ${value.score}'),
                                        Text('volumes: ${value.volumes}'),
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
