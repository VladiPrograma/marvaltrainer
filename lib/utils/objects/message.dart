import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/utils/extensions.dart';

import '../../config/log_msg.dart';
import '../../constants/global_variables.dart';
import '../../constants/string.dart';
import '../marval_arq.dart';


enum MessageType  {text, photo, audio}

class Message{
static CollectionReference chatDB = FirebaseFirestore.instance.collection("users/${authUser!.uid}/chat");

final MessageType type;
final String message;
final DateTime date;
final String user;
bool read;


Message({required this.message,
         required this.type,
         required this.user,
         required this.date,
         required this.read });

Message.create({required this.message, required this.type}):
  user = authUser!.uid,
  read = false,
  date = DateTime.now();

Message.fromJson(Map<String, dynamic> map)
    : user = map["user"],
      message = map["message"],
      read = map["read"],
      type = MessageType.values.byName(map["type"]),
      date = map["date"].toDate();

Future<void> setInDB(){
  // Call the user's CollectionReference to add a new user
  return chatDB
      .doc().set({
    'user': user, // UID
    'message': message, // Vlad es tonto
    'read': read, // Vlad es tonto
    'type': type.name, // text
    'date': date, // 11/07/2022
  })
      .then((value) => logSuccess("$logSuccessPrefix Message Added"))
      .catchError((error) => logError("$logErrorPrefix Failed to add Message: $error"));
}


Future<void> setInDBFromTrainer(){
  // Call the user's CollectionReference to add a new user
  return FirebaseFirestore.instance.collection("users/${chatUser.id}/chat")
      .doc().set({
    'user': user, // UID
    'message': message, // Vlad es tonto
    'read': read, // false
    'type': type.name, // text
    'date': date, // 11/07/2022
  })
      .then((value) => logSuccess("$logSuccessPrefix Message Added"))
      .catchError((error) => logError("$logErrorPrefix Failed to add Message: $error"));
}

Future<void> uploadInDBFromTrainer(Map<String, Object> map) async{
  // Call the user's CollectionReference to add a new user
  final path = "users/${chatUser.id}/chat";
  final query = await FirebaseFirestore.instance.collection(path)
                      .where('date', isEqualTo: date)
                      .limit(1).get();

  if(isNull(query)||query.size == 0){ return;}

  return  FirebaseFirestore.instance.collection(path)
      .doc(query.docs.first.reference.id).update(map)
      .then((value) => logSuccess("$logSuccessPrefix Message Added"))
      .catchError((error) => logError("$logErrorPrefix Failed to add Message: $error"));
}

void updateRead(){
  if(!read) {
    read = true;
    uploadInDBFromTrainer({  "read": read, });
  }
}

@override
String toString() {
  return " User_ID: $user"
      "\n Message: $message "
      "\n Type: ${type.name}"
      "\n Read: $read"
      "\n Date: ${date.toFormatStringDate} - ${date.toFormatStringHour()}";
}


}
