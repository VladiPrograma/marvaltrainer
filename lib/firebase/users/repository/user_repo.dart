import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:marvaltrainer/firebase/users/model/user.dart';

final CollectionReference _db = FirebaseFirestore.instance.collection("users");

Emitter _authEmitter = Emitter.stream((ref) => Firebase.FirebaseAuth.instance.authStateChanges());

final _userEmitter = Emitter.stream((ref) async {
  final authId = await ref.watch(
      _authEmitter.where((auth) => auth != null).map((auth) => auth!.uid));
  return _db.doc(authId).snapshots();
}, keepAlive: true);

class UserRepository{

  User? get(Ref ref) {
    var query = ref.watch(_userEmitter.asyncData).data;
    return query?.data() !=null  ? User.fromMap(query!.data() as Map<String, dynamic>) : null;
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