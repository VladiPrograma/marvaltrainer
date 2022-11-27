
import 'package:marvaltrainer/firebase/habits/model/habits.dart';

class HabitsResumeDTO{
  String id;
  String name;
  String label;
  HabitsResumeDTO({required this.id, required this.label, required this.name});

  HabitsResumeDTO.fromHabit(Habit habit):
   id = habit.id,
   name = habit.name,
   label = habit.label;

  @override
  String toString() {
    return 'HabitsResumeDTO{id: $id,name: $name, label: $label}';
  }
}