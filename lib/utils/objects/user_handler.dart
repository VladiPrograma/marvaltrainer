import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/utils/objects/user.dart';

class UserHandler{
  static CollectionReference usersDB = FirebaseFirestore.instance.collection("users");
  List<MarvalUser> list;

  UserHandler({required this.list});

  UserHandler.create() : list = <MarvalUser>[];

  Future<void> getFromDB() async {
    QuerySnapshot querySnapshot = await usersDB.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    for(var data in allData){
      Map<String, dynamic> map = data as Map<String, dynamic>;
      MarvalUser user = MarvalUser.fromJson(map);
      list.add(user);
    }
  }

  void addUser(MarvalUser user){
    ///@TODO add Logic for make sure that we dont add one user 2 times
    list.add(user);
  }

  @override
  String toString() {
    StringBuffer sb = StringBuffer();
    for(MarvalUser user in list){
      sb.write(user.toString());
      sb.write('\n');
    }
    return sb.toString();
  }

}


