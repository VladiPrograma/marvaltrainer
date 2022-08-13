import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:marvaltrainer/utils/objects/user_handler.dart';

import '../utils/marval_arq.dart';
import '../utils/objects/user.dart';

/// - - - FIREBASE AUTH - - -  */
late User authUser;
late MarvalUser chatUser;

UserHandler handler = UserHandler.create();
Map<String, Emitter> chatEmitterMap = {};


/// - - - -  USERS HANDLER - - -  - */
final handlerEmitter = Emitter.stream((ref) async {
 return FirebaseFirestore.instance.collection('users')
     .where('active', isEqualTo: true)
     .orderBy('update', descending: false)
     .snapshots();
});


List<MarvalUser>? getUserList(Ref ref){
 final query = ref.watch(handlerEmitter.asyncData).data;
 if(isNull(query)||query!.size==0){ return null; }
 return queryToData(query).whereType<MarvalUser>().toList();
}

//Pass data from querySnapshot to Messages
List queryToData(var query){
 List list = [];
 for (var element in [...query.docs]){
  list.add(MarvalUser.fromJson(element.data()));
 }
 return list;
}