import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';

final CollectionReference _db = FirebaseFirestore.instance.collection('exercises');
Creator<int> _cont = Creator.value(8);

Emitter _exerciseStream = Emitter.stream((ref) async {
  return _db.orderBy('name').limit(ref.watch(_cont)).snapshots();
}, keepAlive: true);

final _searchByName = Emitter.arg1<QuerySnapshot, String>((ref, name, emit) async{
  final cancel = (_db.where('keywords', arrayContains: name)
      .limit(ref.watch(_cont))
      .snapshots().listen((event) => emit(event))).cancel;
  ref.onClean(cancel);
});

final _searchByTag = Emitter.arg1<QuerySnapshot, String>((ref, search, emit) async{
  final cancel = (_db.where('tags', arrayContainsAny: [search])
      .limit(ref.watch(_cont))
      .snapshots().listen((event) => emit(event))).cancel;
  ref.onClean(cancel);
});

Emitter _tagStream = Emitter.stream((ref) async {
  return _db.doc('tags').snapshots();
}, keepAlive: true);

class ExerciseRepository{

  List<Exercise> get(Ref ref) {
    var query = ref.watch(_exerciseStream.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((doc) => Exercise.fromMap(doc.data())).toList() ?? [];
  }
  void fetchMore(Ref ref, {int? n}) => ref.update<int>(_cont, (current) => current + (n ?? 8));
  int getCont(Ref ref) => ref.watch(_cont);
  void resetCont(Ref ref) => ref.update(_cont, (p0) => 8);

  List<Exercise> getByName(Ref ref, String name){
    if(name.length<3) return get(ref);
    var query = ref.watch(_searchByName(name.substring(0,3).toLowerCase()).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((doc) => Exercise.fromMap(doc.data())).toList() ?? [];
  }
  List<Exercise> getByTag(Ref ref, String search){
    if(search.isEmpty) return get(ref);
    var query = ref.watch(_searchByTag(search).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((doc) => Exercise.fromMap(doc.data())).toList() ?? [];
  }


  Future<DocumentSnapshot> getDocument(String id) =>  _db.doc(id).get();
  Future<void> add(Exercise exercise) => _db.doc(exercise.id).set(exercise.toMap());
  Future<void> update(String id, Map<String, dynamic> map) =>  _db.doc(id).update(map);
  Future<void> delete(String id) => _db.doc(id).delete();


  Tags getTags(Ref ref) {
    DocumentSnapshot? query = ref.watch(_tagStream.asyncData).data;
    return query!=null ? Tags.fromMap(query.data() as Map<String, dynamic>) : Tags.empty();
  }
  Future<void> updateTags(Map<String, Object> map) => _db.doc('tags').update(map);
}