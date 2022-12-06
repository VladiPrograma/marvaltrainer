import 'package:creator/creator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';
import 'package:marvaltrainer/firebase/exercises/repository/exercise_repository.dart';

class ExerciseLogic{
  ExerciseRepository repo = ExerciseRepository();

  List<Exercise>? getAll( Ref ref) => repo.get(ref).toList();

  //@TODO Check this method
  Exercise? getByID(String id, Ref ref) => getAll(ref)?.
  firstWhereOrNull((exercise) => exercise.id == id);


  Future<void> updateTag(Exercise exercise, String tag){
    return exercise.tags.contains(tag) ?
    repo.update(exercise.id, {'tags' : FieldValue.arrayRemove([tag])}) :
    repo.update(exercise.id, {'tags' : FieldValue.arrayUnion( [tag])});
  }
  Future<void> update(Exercise exercise){
    return repo.update(exercise.id,
      {
      'name' : exercise.name,
      'image_url' : exercise.imageUrl,
      'description' : exercise.description,
      });
  }
  Future<void> add(Exercise exercise) => repo.add(exercise);
  Future<void> delete(String id) => repo.delete(id);

  Tags? getTags(Ref ref) => repo.getTags(ref);
  Future<void> addTag(String tag) =>  repo.updateTags({'values' : FieldValue.arrayUnion([tag.capitalize()])});
  Future<void> removeTag(String tag) =>  repo.updateTags({'values' : FieldValue.arrayRemove([tag])});

}