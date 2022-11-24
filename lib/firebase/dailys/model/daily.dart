import 'package:marvaltrainer/utils/extensions.dart';

class Daily{
  String id;
  int sleep;
  int? steps;
  double weight;
  DateTime date;
  List<String> habits;
  List<Habit> habitsFromPlaning;
  List<Activity> activities;

  Daily({
    required this.id,
    required this.date,
    required this.sleep,
    required this.weight,
    required this.habits,
    required this.habitsFromPlaning,
    required this.activities,
    required this.steps,
  });
Daily.fromMap(Map<String, dynamic> map):
  id = map['id'],
  sleep = map['sleep'],
  steps = map['steps'],
  weight = map['weight'],
  date = map['date'].toDate(),
  habits = List<String>.from(map["habits"] ?? ""),
  activities = List<Map<String, dynamic>>.from(map["activities"] ?? []).map((e) => Activity.fromMap(e)).toList(),
  habitsFromPlaning = List<Map<String, dynamic>>.from(map["habits_from_planing"] ?? []).map((e) => Habit.fromMap(e)).toList();

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'sleep' : sleep,
      'steps' : steps,
      'weight' : weight,
      'date' : date,
      'habits' : habits,
      'habits_from_planing' : habitsFromPlaning,
      'activities' : activities,
    };
  }
}

class Activity{
  String id;
  bool completed;
  String reference;
  String icon;
  String label;
  String type;

  Activity({required this.id, required this.icon, required this.label, required this.type, required this.completed, required this.reference});

  Activity.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        completed = map["completed"] ?? false,
        reference = map["reference"] ?? "",
        icon = map["icon"] ?? "",
        label = map["label"] ?? "",
        type = map["type"] ?? "";

  Map<String, dynamic> toMap(){
    return {
      'id' : id,
      'completed': completed,
      'reference': reference,
      'icon' : icon,
      'label': label,
      'type': type,
    };
  }

  @override
  String toString(){
    return 'Habit: $id [ completed: $completed, reference $reference, icon: $icon , label: $label, type $type]';
  }

}

class Habit{
  String description;
  String label;
  String name;
  String get icon => label.replaceAll(label.removeIcon(), "");

  Habit({required this.name, required this.label, required this.description});

  Habit.fromMap(Map<String, dynamic> map)
      : name = map["name"],
        label = map["label"],
        description = map["description"];

  Map<String, dynamic> toMap(){
    return {
      'name' : name,
      'label': label,
      'description': description,
    };
  }

  @override
  String toString(){
    return 'Habit: { name: $name, label: $label, desc: $description } \n';
  }
}