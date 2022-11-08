import 'package:get/get.dart';

import 'main_page_controller.dart';
import 'main_page_model.dart';
import 'model/question_model.dart';
import 'model/question_type.dart';

class MainPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainPageController>(
      MainPageController(
        model: MainPageModel.empty().copyWith(
          questions: {
            QuestionType.none: [
              ...Iterable.generate(3, (_) => QuestionModel.empty()), //볼륨조절 전 스텝 갯수
              QuestionModel.volume(),
            ],
            QuestionType.q2: Iterable.generate(
              8,
              (i) {
                return QuestionModel.empty().copyWith(
                  file: 'Q2/Q2-${i + 1}.wav',
                  maxSliderScore: 60,
                  maxTextScore: 1000,
                );
              },
            ),
            QuestionType.q3: Iterable.generate(
              6,
              (i) {
                return QuestionModel.empty().copyWith(
                  file: 'Q3/Q3-${i + 1}.wav',
                  maxSliderScore: 100,
                  maxTextScore: 1000,
                );
              },
            ),
            QuestionType.q4: Iterable.generate(
              6,
              (i) {
                return QuestionModel.empty().copyWith(
                  file: 'Q4/Q4-${i + 1}.wav',
                  maxSliderScore: 140,
                  maxTextScore: 1000,
                );
              },
            ),
          },
        ),
      ),
    );
  }
}
