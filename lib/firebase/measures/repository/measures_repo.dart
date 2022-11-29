import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/measures/model/measures.dart';

Creator<int> _page = Creator.value(3);
final _db = Emitter.arg1<CollectionReference, String>((ref, userId, emit) =>
    emit(FirebaseFirestore.instance.collection("users/$userId/activities")));
final _measureStream = Emitter.arg1<QuerySnapshot, String>((ref, userId, emit) async{
  final CollectionReference db = await ref.watch(_db(userId));
  final cancel = (db.where('type', isEqualTo: '_Measures').
     orderBy('date', descending: true).
     limit(ref.watch(_page)).snapshots().
     listen((event) => emit(event))
     ).cancel;
  ref.onClean(cancel);
});

class MeasuresRepo{
  final CollectionReference _db = FirebaseFirestore.instance.collection('users/');
  void fetchMore(Ref ref, {int? n}) =>
      ref.update<int>(_page, (current) => current + (n ?? 3));

  List<Measures> get(Ref ref, String userId){
    var query = ref.watch(_measureStream(userId).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => Measures.fromMap(e.data())).toList() ?? [];
  }
  Future<void> add(String userID, Measures measure) =>
      FirebaseFirestore.instance.collection('users/$userID/activities/').add(measure.toMap());

  Future<void> update(String userId, String measureId, Map<String, dynamic> map) =>
      FirebaseFirestore.instance.collection("users/$userId/activities").doc(measureId).update(map);

  Future<void> remove(String userId, String measureId) =>
      FirebaseFirestore.instance.collection("users/$userId/activities").doc(measureId).delete();
}



