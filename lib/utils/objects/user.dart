import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/extensions.dart';
import '../../config/log_msg.dart';
import '../../constants/string.dart';
import '../marval_arq.dart';

import 'planing.dart';
import 'user_daily.dart';
import 'user_details.dart';

class MarvalUser{

  static CollectionReference usersDB = FirebaseFirestore.instance.collection("users");

  String id;
  String name;
  String? objective;
  String lastName;
  String work;
  String? hobbie;
  String? email;
  bool? active;
  String? profileImage;
  double lastWeight;
  double currWeight;
  DateTime update;
  DateTime lastUpdate;
  Details? details;
  Planing? currenTraining;
  Map<String, Daily>? dailys;

  MarvalUser({
    required this.id,
    required this.name,
    required this.lastName,
    required this.work,
    required this.email,
    required this.active,
    required this.hobbie,
    required this.objective,
    required this.lastWeight,
    required this.currWeight,
    required this.update,
    required this.lastUpdate,
    this.profileImage,
  });

  ///@TODO Check if i can delete "dailys"
  MarvalUser.create({String? uid, required this.name, required this.email, required this.objective})
        : id = uid ?? FirebaseAuth.instance.currentUser!.uid,
     lastName = "",
         work = "",
       hobbie = "",
       active = true,
   lastWeight = 0,
   currWeight = 0,
       dailys = <String, Daily>{},
       update = DateTime.now(),
   lastUpdate = DateTime.now();

  MarvalUser.fromJson(Map<String, dynamic> map)
          : id = map["id"],
          name = map["name"],
      lastName = map["last_name"],
        hobbie = map["hobbie"],
     objective = map["objective"],
         email = map["email"],
        active = map["active"],
          work = map["work"],
  profileImage = map["profile_image"],
    currWeight = map["curr_weight"],
    lastWeight = map["last_weight"],
        update = map["update"].toDate(),
    lastUpdate = map["last_update"].toDate(),
        dailys = <String, Daily>{};

  MarvalUser.empty()
         : id  = "",
         email = "",
          name = "",
      lastName = "",
          work = "",
        hobbie = "",
    lastWeight = 0,
    currWeight = 0,
        dailys = <String, Daily>{},
        active = true,
        update = DateTime.now(),
    lastUpdate = DateTime.now();

  Future<void> getDetails() async => details = await Details.getFromDB(id);

  Future<void> getCurrentTraining() async => currenTraining = await Planing.getFromBD(id);

  Future<void> getDaily(DateTime date) async => dailys![date.iDay()]= await Daily.getFromDB(date);

  Future<void> uploadInDB(Map<String, Object> map){
    // Call the user's CollectionReference to add a new user
    return usersDB
        .doc(id).update(map)
        .then((value) => logSuccess("$logSuccessPrefix User Uploaded"))
        .catchError((error) => logError("$logErrorPrefix Failed to Upload user: $error"));
  }

  Future<void> setInDB(){
    // Call the user's CollectionReference to add a new user
    return usersDB
        .doc(id).set({
      'id': id, // UID
      'name': name, // Vlad
      'last_name': lastName, // Dumitru
      'hobbie': hobbie, // Dumitru
      'objective': objective, // Dumitru
      'email': email, // Dumitru
      'active': active, // Dumitru
      'work': work, // Programador
      'profile_image': profileImage, // Programador
      'last_weight' : lastWeight, // 76.3
      'curr_weight' : currWeight, // 77.4
      'update' : update, // 11/06/2021
      'last_update' : lastUpdate, // 11/07/2022
    })
        .then((value) => logSuccess("$logSuccessPrefix User Added"))
        .catchError((error) => logError("$logErrorPrefix Failed to add user: $error"));
  }

  static Future<bool> existsInDB(String? uid) async{
    if(isNull(uid)){ return false;}
    DocumentSnapshot ds = await usersDB.doc(uid).get();
    return ds.exists;
  }

  static Future<bool> isNotRegistered(String? email) async{
    if(isNull(email)){ return false;}
    return  usersDB.where('email', isEqualTo: email).snapshots().isEmpty;
  }

  static Future<MarvalUser> getFromDB(String uid) async {
    DocumentSnapshot doc = await usersDB.doc(uid).get();
    Map<String, dynamic>? map  = toMap(doc);
    return MarvalUser.fromJson(map!);
  }



  @override
  String toString() {
    return " ID: $id"
        "\n Mail: $email Active: $active"
        "\n Name: $name Last Name: $lastName"
        "\n Job: $work"
        "\n Curr: $currWeight Kg  Last: $lastWeight Kg "
        "\n Update: $update Last Update: $lastUpdate"
        "\n Hobbie: $hobbie Objective: $objective"
        "\n Profile image URL: $profileImage"
        "\n Details: ${details?.toString()}"
        "\n Current Training: ${currenTraining?.toString()}"
        "\n Dailys: \n${dailys.toString()}";

  }

  ///@TODO Align this methods
  void updateWeight({required double weight, DateTime? date}){
    lastWeight = currWeight;
    currWeight = weight;

    lastUpdate = update;
    update = date ?? DateTime.now();

    if(lastWeight == 0){ lastWeight = weight; }
    uploadInDB({
      "last_weight" : lastWeight,
      "curr_weight" : currWeight,
      "last_update" : lastUpdate,
      "update" : update
    });
  }

  void updateLastWeight({required double weight, required DateTime date}){
    lastWeight = weight;
    lastUpdate = date;
    uploadInDB({
      "last_weight" : lastWeight,
      "last_update" : lastUpdate,
    });
  }



}


