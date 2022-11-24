import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/measures/model/measures.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';
import '../../../utils/marval_arq.dart';

Emitter _measureEmitter = Emitter((ref, emit) async{
  CollectionReference? db = ref.watch(_db.asyncData).data;
  if(isNull(db)) emit(null);
  emit(await db!.where('type', isEqualTo: '_Measures').orderBy('date', descending: true).limit(ref.watch(_page)).get());
});
Creator<int> _page = Creator.value(2);
Emitter<CollectionReference?> _db = Emitter((ref, emit){
  String? id = ref.watch(currentUser)?.id;
  isNull(id) ? emit(null) :
  emit(FirebaseFirestore.instance.collection("users/$id/activities"));
});

class MeasuresRepo{
  final CollectionReference _db = FirebaseFirestore.instance.collection('users/');
  void fetchMore(Ref ref, {int? n}){
    ref.update<int>(_page, (current) => current + (n ?? 3));
  }
  List<Measures> getAll(Ref ref){
    var query = ref.watch(_measureEmitter.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => Measures.fromMap(e.data())).toList() ?? [];
  }
  Future<void> add(String userID, Measures measure) async{
    FirebaseFirestore.instance.collection('users/$userID/activities/').add(measure.toMap());
  }
  Future<void> update(String userID, String id, Map<String, dynamic> map) async{
    _db.doc("$userID/activities/$id").update(map);
  }
  Future<void> remove(String userID, String id) async{
    _db.doc("$userID/activities/$id").delete();
  }
}



