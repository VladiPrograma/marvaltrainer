import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
 return _queryToUserList(query).whereType<MarvalUser>().toList();
}
//Pass data from query to MarvalUser list
List _queryToUserList(var query){
 List list = [];
 for (var element in [...query.docs]){
  list.add(MarvalUser.fromJson(element.data()));
 }
 return list;
}


final authEmitter = Emitter.stream((n) => FirebaseAuth.instance.authStateChanges(), keepAlive: true);
final userEmitter = Emitter.stream((ref) async {
 final authId = await ref.watch(
     authEmitter.where((auth) => isNotNull(auth)).map((auth) => auth!.uid));
 return FirebaseFirestore.instance.collection('users').doc(authId).snapshots();
}, keepAlive: true);

MarvalUser? getUser(BuildContext context, Ref ref){
 final query = ref.watch(userEmitter.asyncData).data;
 if(isNull(query)) return null;
 return  MarvalUser.fromJson(query!.data()!);
}