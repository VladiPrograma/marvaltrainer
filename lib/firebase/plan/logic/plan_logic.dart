import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/habits/dto/habits_resume.dart';
import 'package:marvaltrainer/firebase/plan/model/plan.dart';
import 'package:marvaltrainer/firebase/plan/repository/plan_repo.dart';
import 'package:marvaltrainer/firebase/trainings/dto/TrainingResumeDTO.dart';


class PlanLogic{
  final PlanRepository _planRepo = PlanRepository();

  Plan? get(Ref ref, String userId, DateTime date) => _planRepo.get(ref, userId, date);

  Future<void> add(Plan plan) => _planRepo.add(plan);
  void addHabit(Ref ref, String userId, HabitsResumeDTO habit) => _planRepo.addHabit(ref, userId, habit);
  void addTraining(Ref ref, String userId, TrainingResumeDTO train) => _planRepo.addTraining(ref, userId, train);
}