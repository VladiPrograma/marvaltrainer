import 'package:creator/creator.dart';
import 'package:flutter/material.dart';
import 'package:marvaltrainer/firebase/users/dto/user_active.dart';
import 'package:marvaltrainer/firebase/users/dto/user_resume.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';
import 'package:marvaltrainer/firebase/users/repository/user_repo.dart';


class UserLogic{
  TrainerUserRepository trainerRepo = TrainerUserRepository();
  UserRepository userRepo = UserRepository();

  List<User>? getAll( Ref ref) => trainerRepo.get(ref);
  List<User> getAllDocuments(Ref ref, {bool active = false}){
    List<User> res = [];
    final query = trainerRepo.getDocuments(ref);
    for (var doc in query.docs) {
      final map = doc.data() as Map<String, dynamic>;
      if(active && map['active']){
        res.add(User.fromMap(map));
      }
      if(!active){
        res.add(User.fromMap(map));
      }
    }
    return res;
  }

  List<User>? getActive( Ref ref) => trainerRepo.get(ref).where((user) => user.active).toList();

  User? getAuthUser( BuildContext context, Ref ref) => userRepo.get(ref);

  List<UserResumeDTO> getUserHome(Ref ref, String? filter){
    filter = filter?.toLowerCase() ?? "";
    return trainerRepo.get(ref).
    where((user) => user.name.toLowerCase().contains(filter!)
    || user.lastName.toLowerCase().contains(filter)).
    where((user) => user.active).
    map((user) =>  UserResumeDTO.fromUser(user)).
    toList();
  }
  List<UserActiveDTO> getUserAlta(Ref ref, String? filter){
    filter = filter?.toLowerCase() ?? "";
    return trainerRepo.get(ref).
    where((user) => user.name.toLowerCase().contains(filter!)
        || user.lastName.toLowerCase().contains(filter)).
    map((user) =>  UserActiveDTO.fromUser(user)).
    toList();
  }

  User? getByID(String id, Ref ref) => getAll(ref)?.firstWhere((user) => user.id == id);

  Future<void> add(User user) => userRepo.add(user);
  Future<void> updateImage(String id, String image){
    return userRepo.update(id, {'profile_image' : image});
  }
  Future<void> updateEmail(String id, String email){
    return userRepo.update(id, {'email' : email});
  }
  Future<void> updateActive(String id, bool active){
    return userRepo.update(id, {'active' : active});
  }

  void select(Ref ref, User? user) => trainerRepo.select(ref, user);
  User? getSelected(Ref ref) => trainerRepo.getSelected(ref);
}