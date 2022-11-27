import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_resume.dart';
import 'package:marvaltrainer/firebase/habits/model/habits.dart';
import 'package:marvaltrainer/firebase/habits/repository/habits_repo.dart';

//@TODO pending to add DailyHabits.
class HabitsLogic{
  HabitsRepository repo = HabitsRepository();

  List<Habit>? getAll( Ref ref) => repo.get(ref).toList();
  List<HabitsResumeDTO> getUserHome(Ref ref, String? filter){
    filter = filter?.toLowerCase() ?? "";
    return repo.get(ref).
    where((habit) => habit.label.toLowerCase().contains(filter!)).
    map((habit) =>  HabitsResumeDTO.fromHabit(habit)).
    toList();
  }

  Habit? getByID(String id, Ref ref) => getAll(ref)?.
  firstWhere((habit) => habit.id == id,
  orElse: () => Habit.empty());

  void updateSelect(Ref ref, String? id){
    repo.updateSelect(ref, id);
  }

  Habit? getSelect(Ref ref)  => repo.getSelect(ref);
  Future<Habit?> getDocument(String id) async{
   final query = await repo.getDocument(id);
   return query.data() !=null  ? Habit.fromMap(query.data() as Map<String, dynamic>) : null;
  }

  Future<void> updateUser(Habit habit, String uid){
    return habit.users.contains(uid) ?
    repo.update(habit.id, {'users' : FieldValue.arrayRemove([uid])}) :
    repo.update(habit.id, {'users' : FieldValue.arrayUnion( [uid])});
  }
  Future<void> updateLabels(Habit habit){
    return repo.update(habit.id,
      {
      'name' : habit.name,
      'label' : habit.label,
      'description' : habit.description,
      });
  }
  Future<void> add(Habit habit){
    habit.startDate = DateTime.now();
    habit.id = habit.hashCode.toString();
    return repo.add(habit);
  }
  Future<void> delete(String id) => repo.delete(id);

}