import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';

import '../../../utils/marval_arq.dart';
import '../model/daily.dart';

Creator<int> _page = Creator.value(3);
final _db = Emitter.arg1<CollectionReference, String>((ref, userId, emit) =>
    emit(FirebaseFirestore.instance.collection("users/$userId/daily")));

final _dailyStream = Emitter.arg1<QuerySnapshot, String>((ref, userId, emit) async{
  final CollectionReference db = await ref.watch(_db(userId));
  final cancel = (db.orderBy('date', descending: true).
  limit(ref.watch(_page)).snapshots().
  listen((event) => emit(event))
  ).cancel;
  ref.onClean(cancel);
});

class DailyRepo{
   final CollectionReference _db = FirebaseFirestore.instance.collection('users/');
   void fetchMore(Ref ref, {int? n}){
     ref.update<int>(_page, (current) => current + (n ?? 3));
   }
   List<Daily> get(Ref ref, String userId){
     var query = ref.watch(_dailyStream(userId).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
     return query?.docs.map((e) => Daily.fromMap(e.data())).toList() ?? [];
   }
   Future<void> add(String userId, Daily daily) {
     return FirebaseFirestore.instance.collection('users/$userId/daily/').add(daily.toMap());
   }
   Future<void> update(String userId, String dailyId, Map<String, dynamic> map) async{
    _db.doc("$userId/daily/$dailyId").update(map);
  }
   Future<void> remove(String userId, String dailyId) async{
    _db.doc("$userId/daily/$dailyId").delete();
  }
}



