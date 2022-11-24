import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/measures/model/measures.dart';
import 'package:marvaltrainer/firebase/measures/repository/measures_repo.dart';


class MeasuresLogic{
  MeasuresRepo repo = MeasuresRepo();

  Measures? getLast(Ref ref){
    List<Measures> list = repo.getAll(ref);
    return list.isNotEmpty ? list[0] : null;
  }

  List<Measures> getList(Ref ref){
    return repo.getAll(ref);
  }

  void fetchMore(Ref ref, {int? n}){
    repo.fetchMore(ref, n: n);
  }
}