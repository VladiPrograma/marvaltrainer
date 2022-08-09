import 'package:cloud_firestore/cloud_firestore.dart';

import    '../marval_arq.dart';
import '../../config/log_msg.dart';
import '../../utils/extensions.dart';

import '../../constants/string.dart';
import '../../constants/global_variables.dart';

class Daily {

  static CollectionReference dailyDB = FirebaseFirestore.instance.collection("users/${authUser!.uid}/daily");

  String   id;
  DateTime day;
  int      sleep;
  double   weight;
  Map      activities;
  List<String> habits;

  Daily({
    required this.id,
    required this.day,
    required this.sleep,
    required this.weight,
    required this.habits,
    required this.activities
  });

  Daily.create({required this.day})
      : id = day.id(),
        sleep = 0,
        weight = 0,
        habits = [],
        activities = {};

  Daily.fromJson(Map<String, dynamic> map)
      : id = map["id"],
        day = map["day"].toDate(),
        sleep = map["sleep"],
        weight = map["weight"],
        activities = map["activities"],
        habits = List<String>.from(map["habits"]);

  Future<void> setInDB() {
    // Call the user's CollectionReference to add a new user
    return dailyDB.doc(id).set({
      'id': id, // UID
      'day': day, // 12/05/2022
      'sleep': sleep, //1
      'weight': weight, // 75.5
      'habits': habits, // [Sol, Frio, Agradecer]
      'activities': activities, // {}
    }).then((value) => logSuccess("$logSuccessPrefix User Daily  Added"))
        .catchError((error) => logError("$logErrorPrefix Failed to add User Daily : $error"));
  }

  Future<void> uploadInDB(Map<String, Object> map) {
    // Call the user's CollectionReference to add a new user
    return dailyDB.doc(id).update(map)
        .then((value) => logSuccess("$logSuccessPrefix User Daily Uploaded"))
        .catchError((error) => logError("$logErrorPrefix Failed to Upload User Daily : $error"));
  }

  static Future<bool> existsInDB(DateTime date) async {
    if (isNull(authUser)) { return false; }
    DocumentSnapshot ds = await dailyDB.doc(date.id).get();
    return ds.exists;
  }

  static Future<Daily> getFromDB(DateTime date) async {
    DocumentSnapshot doc = await dailyDB.doc(date.id).get();
    Map<String, dynamic>? map = toMap(doc);
    return Daily.fromJson(map!);
  }

  @override
  String toString() {
    return " ID: $id"
        "\n Day: $day"
        "\n Sleep: $sleep/5"
        "\n Weight: $weight Kg"
        "\n Habits: $habits"
        "\n Activities: $activities";
  }

  void updateWeight(double value) {
    weight = value;
    uploadInDB({
      "weight": weight,
    });
  }

  void updateSleep(int value) {
    sleep = value;
    uploadInDB({
      "sleep": sleep,
    });
  }

  void updateHabits(String value) {
    if (habits.contains(value)) {
      habits.remove(value);
    } else {
      habits.add(value);
    }
    uploadInDB({
      "habits": habits,
    });
  }

  void updateActivities(String type, Map value) {
    activities[type] = value;
    uploadInDB({"activities": activities});
  }
}
