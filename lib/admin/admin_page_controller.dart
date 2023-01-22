import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:surveykit_example/admin/model/type/condition_model.dart';
import 'package:surveykit_example/admin/model/type/result_field_type.dart';

import '../getx/get_controller.dart';
import 'admin_page_model.dart';

class AdminPageController extends GetController<AdminPageModel> {
  AdminPageController({
    required AdminPageModel model,
  }) : super(model);

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> userStream = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs
    ..bindStream(FirebaseFirestore.instance.collection('user').snapshots().map((x) => x.docs));

  late final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> resultStream = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs
    ..bindStream(FirebaseFirestore.instance.collection('result').snapshots().map((x) => x.docs));

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() async {
    userStream.close();
    resultStream.close();
    super.onClose();
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
