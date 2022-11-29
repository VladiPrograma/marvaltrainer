import 'package:creator/creator.dart';
import 'package:collection/collection.dart';
import 'package:marvaltrainer/firebase/users/dto/user_active.dart';
import 'package:marvaltrainer/firebase/users/dto/user_resume.dart';
import 'package:marvaltrainer/firebase/users/model/user.dart';
import 'package:marvaltrainer/firebase/users/repository/trainer_users_repo.dart';
import 'package:marvaltrainer/firebase/users/repository/user_repo.dart';


class UserLogic{
  TrainerUserRepository trainerRepo = TrainerUserRepository();
  UserRepository userRepo = UserRepository();

  List<User>? getAll( Ref ref) => trainerRepo.get(ref);
  // List<User> getAllDocuments(Ref ref, {bool active = false}){
  //   List<User> res = [];
  //   final query = trainerRepo.getDocuments(ref);
  //   for (var doc in query.docs) {
  //     final map = doc.data() as Map<String, dynamic>;
  //     if(active && map['active']){
  //       res.add(User.fromMap(map));
  //     }
  //     if(!active){
  //       res.add(User.fromMap(map));
  //     }
  //   }
  //   return res;
  // }

  List<User>? getActive( Ref ref) => trainerRepo.get(ref).where((user) => user.active).toList();

  User? getAuthUser(Ref ref) => userRepo.get(ref);

  List<UserHomeDTO> getUserHome(Ref ref, String? filter){
    filter = filter?.toLowerCase() ?? "";
    return trainerRepo.get(ref).
    where((user) => user.name.toLowerCase().contains(filter!)
    || user.lastName.toLowerCase().contains(filter)).
    where((user) => user.active).
    map((user) =>  UserHomeDTO.fromUser(user)).
    toList();
  }
  UserHomeDTO? userHomeById(Ref ref, String userId) =>  getUserHome(ref, null).firstWhereOrNull((user) => user.id == userId );

  List<UserActiveDTO> getUserAlta(Ref ref, String? filter){
    filter = filter?.toLowerCase() ?? "";
    return trainerRepo.get(ref).
    where((user) => user.name.toLowerCase().contains(filter!)
        || user.lastName.toLowerCase().contains(filter)).
    map((user) =>  UserActiveDTO.fromUser(user)).
    toList();
  }

  User? getById(Ref ref, String userId) => getAll(ref)?.firstWhereOrNull((user) => user.id == userId);

  Future<void> add(User user) => userRepo.add(user);
  Future<void> updateImage(String id, String image) => userRepo.update(id, {'profile_image' : image});
  Future<void> updateEmail(String id, String email) => userRepo.update(id, {'email' : email});
  Future<void> updateActive(String id, bool active)  => userRepo.update(id, {'active' : active});


}