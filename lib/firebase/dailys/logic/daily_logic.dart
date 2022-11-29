
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/dailys/repository/daily_repo.dart';

import '../model/daily.dart';

class DailyLogic{
  DailyRepo repo = DailyRepo();

  Daily? getLast(Ref ref, String userId){
    List<Daily> list = repo.get(ref,  userId);
    return list.isNotEmpty ? list.first : null;
  }
  List<Daily> get(Ref ref, String userId) => repo.get(ref,  userId);
  void fetchMore(Ref ref, {int? n}) =>  repo.fetchMore(ref, n: n);
}