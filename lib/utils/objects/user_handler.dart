import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/modules/home/home_screen.dart';
import 'package:marvaltrainer/utils/objects/user.dart';
import '../marval_arq.dart';

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


