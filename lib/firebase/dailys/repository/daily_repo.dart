import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/constants/global_variables.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';

import '../../../utils/marval_arq.dart';
import '../model/daily.dart';

Creator<int> _page = Creator.value(3);
Creator<bool> _hasMore = Creator.value(true);
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

   void fetchMore(Ref ref, int size){
     if(hasMore(ref)){
       ref.update<int>(_page, (current) => current + 3 );
     }
   }

    // Add an exact number to the fetch cont
   void fetch(Ref ref, int n) => ref.update<int>(_page, (current) => current + n);

   int getSize(Ref ref) => ref.watch(_page);

   void ifHasMore(Ref ref, int size){
     int cont = getSize(ref);
     cont<=size ? more(ref) : noMore(ref);
   }

   bool hasMore(Ref ref) => ref.watch(_hasMore);
   void  noMore(Ref ref) => ref.update(_hasMore, (p0) => false);
   void  more(Ref ref) => ref.update(_hasMore, (p0) => true);

   List<Daily> get(Ref ref, String userId){
     var query = ref.watch(_dailyStream(userId).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
     final res = query?.docs.map((e) => Daily.fromMap(e.data())).toList() ?? [];
     ifHasMore(ref, res.length);
     return res;
   }

   Future<void> add(String userId, Daily daily) =>
       FirebaseFirestore.instance.collection('users/$userId/daily/').add(daily.toMap());

   Future<void> update(String userId, String dailyId, Map<String, dynamic> map) async =>
       _db.doc("$userId/daily/$dailyId").update(map);

   Future<void> remove(String userId, String dailyId) async =>
       _db.doc("$userId/daily/$dailyId").delete();
}



