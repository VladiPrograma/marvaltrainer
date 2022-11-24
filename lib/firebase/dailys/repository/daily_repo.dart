import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';

import '../../../utils/marval_arq.dart';
import '../model/daily.dart';

Emitter _dailyEmitter = Emitter((ref, emit) async{
  CollectionReference? db = ref.watch(_dailyDB.asyncData).data;
  if(isNull(db)) emit(null);
  emit(await db!.orderBy('date', descending: true).limit(ref.watch(_page)).get());
});
Creator<int> _page = Creator.value(3);
Emitter<CollectionReference?> _dailyDB = Emitter((ref, emit){
  String? id = ref.watch(currentUser)?.id;
  isNull(id) ? emit(null) :
  emit(FirebaseFirestore.instance.collection("users/$id/daily"));
});

class DailyRepo{
   final CollectionReference _db = FirebaseFirestore.instance.collection('users/');
   void fetchMore(Ref ref, {int? n}){
     ref.update<int>(_page, (current) => current + (n ?? 3));
   }
   List<Daily> getAll(Ref ref){
     var query = ref.watch(_dailyEmitter.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
     return query?.docs.map((e) => Daily.fromMap(e.data())).toList() ?? [];
   }
   Future<void> add(String userID, Daily daily) async{
     FirebaseFirestore.instance.collection('users/$userID/daily/').add(daily.toMap());
   }
   Future<void> update(String userID, String id, Map<String, dynamic> map) async{
    _db.doc("$userID/daily/$id").update(map);
  }
   Future<void> remove(String userID, String id) async{
    _db.doc("$userID/daily/$id").delete();
  }
}



