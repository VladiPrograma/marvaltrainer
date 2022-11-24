import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/form/model/form_answers.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';


final CollectionReference _db = FirebaseFirestore.instance.collection("forms");

Emitter _formAnswersEmitter = Emitter((ref, emit) async{
  final query = await _db.doc(ref.watch(currentUser)?.id).get();
   emit(query.data());
});

class FormAnswerRepo{

  FormAnswers? get(Ref ref) {
    return FormAnswers.fromMap(ref.watch(_formAnswersEmitter.asyncData).data ?? {});
  }
  Future<void> add(FormAnswers form, User user) {
    return _db.doc(user.id).set(form.toMap());
  }
  Future<void> update(User user, Map<String, Object> map) {
    return _db.doc(user.id).update(map);
  }
  Future<void> delete(User user){
    return _db.doc(user.id).delete();
  }

}