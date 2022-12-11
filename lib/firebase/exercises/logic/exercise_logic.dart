import 'package:creator/creator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:marvaltrainer/config/log_msg.dart';
import 'package:marvaltrainer/firebase/exercises/model/exercise.dart';
import 'package:marvaltrainer/firebase/exercises/model/tags.dart';
import 'package:marvaltrainer/firebase/exercises/repository/exercise_repository.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';

class ExerciseLogic{
  ExerciseRepository repo = ExerciseRepository();

  List<Exercise>? get( Ref ref) => repo.get(ref).toList();
  
  List<Exercise>? searchByName(Ref ref, String search){
    if(search.isEmpty) return get(ref);
    return get(ref)?.where((exercise) => exercise.name.contains(search.toCamellCase())).toList();
  }

  List<Exercise>? searchByTags(Ref ref, String search){
    if(search.isEmpty) return get(ref);
    search = search.replaceAll(' ', '');
    List<String> tags = search.split(',');
    if(tags.last.isEmpty){ tags.removeLast();}
    for(int i=0; i<tags.length; i++){
      if(tags[i].isNotEmpty){
        tags[i] = tags[i].capitalize();
      }
    }
    List<Exercise>? res = get(ref)?.where((exercise) => containsArray( exercise.tags, tags)).toList();
    if(res!= null && res.isEmpty){
      tags.removeLast();
      return get(ref)?.where((exercise) => containsArray( exercise.tags, tags)).toList();
    }
    return get(ref)?.where((exercise) => containsArray( exercise.tags, tags)).toList();
  }

  //@TODO Check this method
  Exercise? getByID(String id, Ref ref) => get(ref)?.
  firstWhereOrNull((exercise) => exercise.id == id);


  Future<void> updateTag(Exercise exercise, String tag){
    return exercise.tags.contains(tag) ?
    repo.update(exercise.id, {'tags' : FieldValue.arrayRemove([tag])}) :
    repo.update(exercise.id, {'tags' : FieldValue.arrayUnion( [tag])});
  }
  Future<void> update(Exercise exercise){
    return repo.update(exercise.id, exercise.toMap());
  }
  Future<void> add(Exercise exercise) => repo.add(exercise);
  Future<void> delete(String id) => repo.delete(id);

  Tags? getTags(Ref ref) => repo.getTags(ref);
  Future<void> addTag(String tag) =>  repo.updateTags({'values' : FieldValue.arrayUnion([tag.capitalize()])});
  Future<void> removeTag(String tag) =>  repo.updateTags({'values' : FieldValue.arrayRemove([tag])});

}