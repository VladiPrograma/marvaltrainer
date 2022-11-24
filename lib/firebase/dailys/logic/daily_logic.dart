
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/dailys/repository/daily_repo.dart';

import '../model/daily.dart';

class DailyLogic{
  DailyRepo repo = DailyRepo();

  Daily? getLast(Ref ref){
    List<Daily> list = repo.getAll(ref);
    return list.isNotEmpty ? list[0] : null;
  }

  List<Daily> getList(Ref ref){
    return repo.getAll(ref);
  }
  void fetchMore(Ref ref, {int? n}){
    repo.fetchMore(ref, n: n);
  }
}