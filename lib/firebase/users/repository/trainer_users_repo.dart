import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';


final CollectionReference _db = FirebaseFirestore.instance.collection("users");

Emitter _userEmitter = Emitter.stream((ref) async {
  return _db.orderBy('name').snapshots();
}, keepAlive: true);

Creator<User?> currentUser = Creator.value(null);

class TrainerUserRepository{

  List<User> get(Ref ref) {
    var query = ref.watch(_userEmitter.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => User.fromMap(e.data())).toList() ?? [];
  }

  Future<void> add(User user) {
    return _db.doc(user.id).set(user.toMap());
  }
  Future<void> update(String id, Map<String, Object> map) {
    return _db.doc(id).update(map);
  }
  Future<void> delete(String id){
    return _db.doc(id).delete();
  }

}