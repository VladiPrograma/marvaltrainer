import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';

final CollectionReference _db = FirebaseFirestore.instance.collection('habits');

Emitter _habitsStream = Emitter.stream((ref) async {
  return _db.orderBy('label').snapshots();
}, keepAlive: true);


Creator<Habit?> _select = Creator((p0) => null);

class HabitsRepository{
  List<Habit> get(Ref ref) {
    var query = ref.watch(_habitsStream.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => Habit.fromMap(e.data())).toList() ?? [];
  }
  void updateSelect(Ref ref, String? id){
    Habit? habit = get(ref).firstWhere((habit) => habit.id == id);
    ref.update(_select, (p0) => habit);
  }

  Habit? getSelect(Ref ref) => ref.watch(_select);

  Future<DocumentSnapshot> getDocument(String name) =>  _db.doc(name).get();

  Future<void> add(Habit habit) {
    return _db.doc(habit.id).set(habit.toMap());
  }
  Future<void> update(String id, Map<String, Object> map) {
    return _db.doc(id).update(map);
  }
  Future<void> delete(String id){
    return _db.doc(id).delete();
  }

}