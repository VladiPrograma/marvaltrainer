import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import '../../constants/string.dart';
import '../../config/log_msg.dart';
import '../marval_arq.dart';

class Planing{
  static final DateTime finalDate = DateTime(3000, 12, 12);

  String id;
  String uid;
  int? steps;
  DateTime endDate;
  DateTime startDate;
  DateTime lastUpdate;
  List<Map<String, dynamic>> habits;
  List<Map<String, dynamic>> activities;


  Planing({
    required this.id,
    required this.uid,
    required this.lastUpdate,
    required this.startDate,
    required this.endDate,
    required this.habits,
    required this.activities,
    this.steps
  });

  get collection => FirebaseFirestore.instance.collection("users/$uid/planing");

  Planing.create({required this.uid, required this.habits, this.steps, required this.activities})
      : id = DateTime.now().add(const Duration(days: 1)).cropTime().id,
        lastUpdate = DateTime.now().add(const Duration(days: 1)).cropTime(),
        startDate  = DateTime.now().add(const Duration(days: 1)).cropTime(),
        endDate    = finalDate;

  Planing.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        uid = map["uid"],
        steps = map["steps"],
        habits = List<Map<String, dynamic>>.from(List<dynamic>.from(map["habits"])),
        activities  = List<Map<String, dynamic>>.from(List<dynamic>.from(map["activities"])),
        lastUpdate = map["last_update"].toDate(),
        startDate = map["start_date"].toDate(),
        endDate = map["end_date"].toDate();


  static Future<Planing> getFromDB(String uid) async{
    final query = await FirebaseFirestore.instance.collection('users/$uid/planing')
        .where("end_date", isEqualTo: finalDate).get();

    if(isNull(query)|| query.docs.isEmpty){
      return createNewPlaning(uid);
    }
    final planingSnapshot = query.docs.first;
    return Planing.fromJson(planingSnapshot.data());
  }

  Future<void> setInDB(){
    // Call the user's CollectionReference to add a new user
    return collection.doc(id).set({
      'id': id, // UID
      'uid': uid, // UID
      'steps': steps, // 1012
      'habits': habits, // ["Frio", "Agradecer", "Sol"]]
      'activities': activities, // {Descanso : { icon: 'sleep', label: 'Descanso', type: 'Sleep', id: ACT_001 }}
      'last_update' : lastUpdate, // 11/07/2022
      'start_date' : startDate, // 11/07/2022
      'end_date' : endDate, // 11/07/2022
    })
    .then((value) => logSuccess("$logSuccessPrefix User Current Planing Added"))
    .catchError((error) => logError("$logErrorPrefix Failed to Add User Current Planing: $error"));
  }

  Future<void> updateInDB(Map<String, Object> map){
    // Call the user's CollectionReference to add a new user
    return collection
        .doc(id).update(map)
        .then((value) => logSuccess("$logSuccessPrefix User Planing Uploaded"))
        .catchError((error) => logError("$logErrorPrefix Failed to Upload Planing: $error"));
  }

  void updateHabits(Habit habit){
    bool exists = habits.where((element) => element["name"] == habit.name).isNotEmpty;
    if(exists){
      habits.removeWhere((element) => element["name"] == habit.name);
    }
    else{
      habits.add({"name": habit.name, "description": habit.description , "label": habit.label});
    }

    updateInDB({ "habits": habits });
  }


  @override
  String toString() {
    return ">> ID: $id"
        "\n Start Date: ${startDate.id}"
        "\n End Date: ${endDate.id}"
        "\n Steps: $steps"
        "\n Habits: $habits"
        "\n Activities: $activities"
        "\n Last Update: $lastUpdate";
  }

  static Future<Planing> getNewPlaning(String uid) async{
    DateTime currentDate = DateTime.now().add(const Duration(days: 1)).cropTime();
    Planing currentPlaning = await getFromDB(uid);
    if(DateTime.now().add(const Duration(days: 1)).cropTime() == currentPlaning.startDate){
      return currentPlaning;
    }
    currentPlaning.end();

    Planing newPlaning = Planing(
        id: currentDate.id,
        uid: uid,
        lastUpdate: currentDate,
        startDate: currentDate,
        endDate: finalDate,
        habits: currentPlaning.habits,
        activities: currentPlaning.activities
    );
    await newPlaning.setInDB();
    return newPlaning;
  }

  void end(){
    endDate = DateTime.now().add(const Duration(days: 1)).cropTime().add(const Duration(milliseconds: -1));
    updateInDB({"end_date" : endDate});
  }

  static Planing createNewPlaning(String uid){
    Planing training = Planing.create(
      uid: uid,
      habits: [],
      steps: 10000,
      activities:
      [{ "icon": 'sleep', "label": 'Descanso', "type": 'rest', "id": 'DESCANSO'},
       { "icon": 'tap', "label": 'Medidas', "type": 'table', "id": 'MEDIDAS'},
       { "icon": 'gallery', "label": 'Galeria', "images": 'Sleep', "id": 'FOTOS'},
       { "icon": 'steps', "label": 'Pasos', "type": 'steps', "id": 'PASOS'}
      ],
    );
    training.setInDB();
    return training;
  }

}


