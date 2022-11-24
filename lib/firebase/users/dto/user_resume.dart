import '../model/user.dart';

class UserResumeDTO{
  String id;
  String name;
  String lastName;
  String hobbie;
  String job;
  String objective;
  String? img;
  double? weight;
  double? lastWeight;

  UserResumeDTO({required this.id, required this.objective, required this.name, required this.lastName, required this.hobbie, required this.job, this.img, this.weight, this.lastWeight});

  UserResumeDTO.fromUser(User user):
      id = user.id,
      name = user.name,
      lastName = user.lastName,
      objective = user.objective,
      hobbie = user.hobbie,
      job = user.work,
      img = user.profileImage,
      weight = user.currWeight,
      lastWeight = user.lastWeight;


  @override
  String toString() {
    return 'UserResumeDTO{ UID: $id, name: $name, lastName: $lastName, objective: $objective,  hobbie: $hobbie, job: $job, img: ${img ?? 'none'} }';
  }
}