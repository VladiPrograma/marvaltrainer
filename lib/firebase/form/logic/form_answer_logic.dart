import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/form/model/form_answers.dart';
import 'package:marvaltrainer/firebase/form/repository/form_answers_repo.dart';


class FormAnswersLogic{
  FormAnswerRepo repo = FormAnswerRepo();

  FormAnswers? get( Ref ref) {
    return repo.get(ref);
  }

  List<String> getAnswers(Ref ref){
    return repo.get(ref)?.form.values.toList() ?? [];
  }
  List<String> getQuestions(Ref ref){
    return repo.get(ref)?.form.keys.toList() ?? [];
  }

}