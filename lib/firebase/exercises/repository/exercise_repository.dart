import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';

final CollectionReference _db = FirebaseFirestore.instance.collection('exercises');
Creator<int> _cont = Creator.value(10);

Emitter _exerciseStream = Emitter.stream((ref) async {
  return _db.orderBy('name').limit(ref.watch(_cont)).snapshots();
}, keepAlive: true);

Emitter _tagStream = Emitter.stream((ref) async {
  return _db.doc('tags').snapshots();
}, keepAlive: true);

class ExerciseRepository{

  List<Exercise> get(Ref ref) {
    var query = ref.watch(_exerciseStream.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => Exercise.fromMap(e.data())).toList() ?? [];
  }

  void fetchMore(Ref ref, {int? n}) => ref.update<int>(_cont, (current) => current + (n ?? 10));
  void resetCont(Ref ref) => ref.update(_cont, (p0) => 10);

  Future<DocumentSnapshot> getDocument(String id) =>  _db.doc(id).get();
  Future<void> add(Exercise exercise) => _db.doc(exercise.id).set(exercise.toMap());
  Future<void> update(String id, Map<String, Object> map) =>  _db.doc(id).update(map);
  Future<void> delete(String id) => _db.doc(id).delete();


  Tags getTags(Ref ref) {
    DocumentSnapshot? query = ref.watch(_tagStream.asyncData).data;
    return query!=null ? Tags.fromMap(query.data() as Map<String, dynamic>) : Tags.empty();
  }
  Future<void> updateTags(Map<String, Object> map) => _db.doc('tags').update(map);
}