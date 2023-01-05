
import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/dailys/repository/daily_repo.dart';

import '../model/daily.dart';

class DailyLogic{
  DailyRepo repo = DailyRepo();

  bool hasMore(Ref ref) => repo.hasMore(ref);

  Daily? getLast(Ref ref, String userId){
    List<Daily> list = repo.get(ref,  userId);
    return list.isNotEmpty ? list.first : null;
  }

  List<Daily> get(Ref ref, String userId) => repo.get(ref,  userId);

  void fetchMore(Ref ref, int limit) => repo.fetchMore(ref, limit);

  void fetch(Ref ref, int n) => repo.fetch(ref, n);

}