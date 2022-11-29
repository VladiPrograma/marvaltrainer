import 'package:creator/creator.dart';
import 'package:marvaltrainer/firebase/gallery/model/gallery.dart';
import 'package:marvaltrainer/firebase/gallery/repository/gallery_repo.dart';


class GalleryLogic{
  GalleryRepo repo = GalleryRepo();
  void fetchMore(Ref ref, {int? n}){
    repo.fetchMore(ref, n: n);
  }
  List<Gallery> get(Ref ref, String userId) => repo.get(ref,userId);

  Gallery? getLast(Ref ref, String userId){
    List<Gallery> list = get(ref, userId);
    return list.isNotEmpty ? list[0] : null;
  }

}