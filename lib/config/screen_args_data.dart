import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';

class ScreenArguments {
  final String? userId;
  final Exercise? exercise;
  final Training? training;
  ScreenArguments({this.userId, this.exercise, this.training});
}