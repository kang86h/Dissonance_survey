import 'package:get/get.dart';

import 'main_page_controller.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainPageController>(MainPageController(
      model: MainPageModel.empty().copyWith(
        questions: {
          QuestionType.none: [
            ...Iterable.generate(3, (_) => QuestionModel.empty()),
            QuestionModel.volume(),
          ],
          QuestionType.q2: Iterable.generate(8, (i) {
            return QuestionModel.empty().copyWith(
              file: 'Q2/Q2-${i + 1}.wav',
              maxSliderScore: 60,
              maxTextScore: 1000,
            );
          }),
        },
      ),
    ));
  }
}
