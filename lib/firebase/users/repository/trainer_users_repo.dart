import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';


final CollectionReference _db = FirebaseFirestore.instance.collection("users");

Emitter _userStream = Emitter.stream((ref) async {
  return _db.orderBy('name').snapshots();
}, keepAlive: true);

Emitter _userEmitter = Emitter((ref, emit) => _db.get(), keepAlive: true);

Creator<User?> _user = Creator.value(null);

class TrainerUserRepository{

  List<User> get(Ref ref) {
    var query = ref.watch(_userStream.asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => User.fromMap(e.data())).toList() ?? [];
  }

  QuerySnapshot getDocuments(Ref ref){
    return  ref.watch(_userEmitter.asyncData).data;
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

  void select(Ref ref, User? user){
    ref.update<User?>(_user, (p0) => user);
  }
  User? getSelected(Ref ref){
    return ref.watch(_user);
  }
}