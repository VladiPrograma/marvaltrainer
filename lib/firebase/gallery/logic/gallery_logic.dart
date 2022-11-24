import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/gallery/model/gallery.dart';
import 'package:marvaltrainer/firebase/gallery/repository/gallery_repo.dart';


class GalleryLogic{
  GalleryRepo repo = GalleryRepo();

  Gallery? getLast(Ref ref){
    List<Gallery> list = repo.getAll(ref);
    return list.isNotEmpty ? list[0] : null;
  }

  List<Gallery> getList(Ref ref){
    return repo.getAll(ref);
  }

  void fetchMore(Ref ref, {int? n}){
    repo.fetchMore(ref, n: n);
  }
}