import 'package:collection/collection.dart';
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/trainings/model/training.dart';
import 'package:marvaltrainer/firebase/trainings/model/workout.dart';

Creator<Training> _trainingCreator = Creator.value(Training.empty(), keepAlive: true);
Creator<Training> _initialTrainingCreator = Creator.value(Training.empty());
Creator<bool> _updateCreator = Creator.value(false);

// For MarvalTextFields
Creator<bool> _onChangeUpdateCreator = Creator.value(false);


class TrainingController {

  Training get(Ref ref) => ref.watch(_trainingCreator);

  void dispose(Ref ref){
    ref.dispose(_trainingCreator);
    ref.dispose(_initialTrainingCreator);
    ref.dispose(_updateCreator);
    ref.dispose(_onChangeUpdateCreator);
  }

  void initialValue(Ref ref, Training training){
    ref.update<Training>(_trainingCreator, (p0) => training);
    ref.update<Training>(_initialTrainingCreator, (p0) => Training.clone(training));
    update(ref);
  }
  void removeWorkout(Ref ref, String exerciseId){
    Training training = get(ref);
    training.workouts.removeWhere((element) => element.exercise == exerciseId);
    update(ref);
  }
  void updateWorkoutPosition(Ref ref, Training training, int newIndex, int oldIndex){
    final Workout workout = training.workouts.removeAt(oldIndex);
    training.workouts.insert(newIndex, workout);
    update(ref);
  }

  void updateUsers(Ref ref, Training training, List<String> users){
    training.users = users;
    update(ref);
  }

  void update(Ref ref) => ref.update<bool>(_updateCreator, (value) => !value);
  void getUpdates(Ref ref) => ref.watch(_updateCreator);

  void getOnChangeUpdates(Ref ref) => ref.watch(_onChangeUpdateCreator);
  void updateOnChange(Ref ref) => ref.update<bool>(_onChangeUpdateCreator, (value) => !value);

  bool hasChange(Ref ref)=> ref.watch(_initialTrainingCreator) !=  ref.watch(_trainingCreator);

  bool containsExercise(Ref ref, String exerciseId) => get(ref).workouts.map((e) => e.exercise).contains(exerciseId);

  Workout? getWorkout(Ref ref, String exerciseId) => get(ref).workouts.firstWhereOrNull((element) => element.exercise == exerciseId );

  void addWorkout( Ref ref, Workout workout){
    Training training = get(ref);
    int index = training.workouts.indexWhere((current) => current.exercise == workout.exercise);
    index!=-1 ? training.workouts[index] = workout : training.workouts.add(workout);
    ref.update<bool>(_updateCreator, (value) => !value);
  }

}