import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_resume.dart';
import 'package:marvaltrainer/firebase/plan/model/plan.dart';
import 'package:marvaltrainer/firebase/trainings/dto/TrainingResumeDTO.dart';

final CollectionReference _db = FirebaseFirestore.instance.collection('plan');

final _planEmitter = Emitter.arg2<QuerySnapshot, String, DateTime>((ref, userId, date, emit) async{
  final cancel = ( _db.where('user_id', isEqualTo: userId)
      .orderBy('start_date', descending: true).
      limit(1).snapshots().
      listen((event) => emit(event))
  ).cancel;
  ref.onClean(cancel);
}, keepAlive: true);

class PlanRepository{

  Plan? get(Ref ref, String userId, DateTime date) {
    date = DateTime(date.year, date.month, date.day, 23, 59, 59);
    // For training only, that allows us to achieve last plan create.
    date.add(const Duration(days: 1));
    var query = ref.watch(_planEmitter(userId, date).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query!=null && query.docs.isNotEmpty ? Plan.fromMap(query.docs.first.data()) : null;
  }

  Future<void> add(Plan plan) {
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    plan.startDate = tomorrow;
    return _db.add(plan.toMap());
  }

  void addHabit(Ref ref, String userId, HabitsResumeDTO habit) async{
    Plan? plan;
    do{
       plan =  get(ref, userId, DateTime.now());
       if(plan!=null ) break;
       logInfo('Null plan');
       await Future.delayed(const Duration(milliseconds: 500));
    }while(plan == null );

    plan.habits.contains(habit) ? plan.habits.remove(habit) : plan.habits.add(habit);
    add(plan);
  }

  void addTraining(Ref ref, String userId, TrainingResumeDTO train) async{

    Plan? plan = get(ref, userId, DateTime.now());
    do{
      plan =  get(ref, userId, DateTime.now());
      if(plan!=null ) break;
      logInfo('Null plan');
      await Future.delayed(const Duration(milliseconds: 500));
    }while(plan == null );
    plan.trainings.contains(train) ? plan.trainings.remove(train) : plan.trainings.add(train);
    add(plan);
  }

}