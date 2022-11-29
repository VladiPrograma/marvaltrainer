import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/measures/model/measures.dart';
import 'package:marvaltrainer/firebase/measures/repository/measures_repo.dart';


class MeasuresLogic{
  MeasuresRepo repo = MeasuresRepo();

  Measures? getLast(Ref ref, String userId){
    List<Measures> list = repo.get(ref, userId);
    return list.isNotEmpty ? list[0] : null;
  }
  List<Measures> getList(Ref ref, String userId) => repo.get(ref, userId);
  void fetchMore(Ref ref, {int? n}) => repo.fetchMore(ref, n: n);
}