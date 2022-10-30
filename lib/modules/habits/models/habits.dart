import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../config/log_msg.dart';
import '../../../constants/string.dart';


class Habit {

  static CollectionReference habitsDB = FirebaseFirestore.instance.collection("habits");
  String name;
  String label;
  String description;
  List<String> users;

  Habit({
    required this.name,
    required this.label,
    required this.description,
    required this.users,
  });

  Habit.create({
    required this.name,
    required this.label,
    required this.description,
  }) : users = [];

  Habit.fromJson({required Map<String, dynamic> map}) :
      name = map["name"],
      label = map["label"],
      description = map["description"],
      users = List<String>.from(map["users"]);


  Future<void> setInDB() {
    return habitsDB.doc(name).set({
      'name': name, // Frio
      'label': label, // Frio
      'description': description, // El frio es bueno para la circulacion
      'users': users, // [{user1}, {user2}]
    }).then((value) {
      logSuccess("$logSuccessPrefix Habit Added");
    }).catchError((error) {
      logError("$logErrorPrefix Failed to add Habit: $error");
    });
  }

  Future<void> deleteFromDB() {
    return habitsDB.doc(name).delete()
       .then((value) {
       logSuccess("$logSuccessPrefix Habit Deleted");
     }).catchError((error) {
       logError("$logErrorPrefix Failed to delete Habit: $error");
    });
  }


  Future<void> uploadInDB(Map<String, Object> map) {
    // Call the user's CollectionReference to add a new user
    return habitsDB
        .doc(name).update(map)
        .then((value) => logSuccess("$logSuccessPrefix Habit Uploaded"))
        .catchError((error) =>
        logError("$logErrorPrefix Failed to Upload Habit: $error"));
  }

  void updateUsers(String uid){
    if(!users.remove(uid)){  users.add(uid); }
    uploadInDB({  "users": users, });
  }

  @override
  String toString() {
    return " Name: $name"
        "\n Label: $label "
        "\n Desc: $description "
        "\n Users: $users";
  }


}