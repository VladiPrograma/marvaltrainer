import 'package:creator/creator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marvaltrainer/firebase/gallery/model/gallery.dart';

Creator<int> _page = Creator.value(3);
final _db = Emitter.arg1<CollectionReference, String>((ref, userId, emit) =>
emit(FirebaseFirestore.instance.collection("users/$userId/activities")));
final _galleryStream = Emitter.arg1<QuerySnapshot, String>((ref, userId, emit) async{
  final CollectionReference db = await ref.watch(_db(userId));
  final cancel = (db.where('type', isEqualTo: '_Gallery').
    orderBy('date', descending: true).
    limit(ref.watch(_page)).snapshots().
    listen((event) => emit(event))
  ).cancel;
  ref.onClean(cancel);
});

class GalleryRepo{
  final CollectionReference _db = FirebaseFirestore.instance.collection('users/');

  void fetchMore(Ref ref, {int? n}){
    ref.update<int>(_page, (current) => current + (n ?? 3));
  }

  List<Gallery> get(Ref ref, String userId){
    var query = ref.watch(_galleryStream(userId).asyncData).data as QuerySnapshot<Map<String, dynamic>>?;
    return query?.docs.map((e) => Gallery.fromMap(e.data())).toList() ?? [];
  }

  Future<void> add(String userId, Gallery gallery) =>
      FirebaseFirestore.instance.collection('users/$userId/activities/').doc(gallery.id).set(gallery.toMap());

  Future<void> update(String userId, String galleryId, Map<String, dynamic> map) =>
      FirebaseFirestore.instance.collection('users/$userId/activities').doc(galleryId).update(map);

  Future<void> remove(String userId, String galleryId) =>
      FirebaseFirestore.instance.collection('users/$userId/activities').doc(galleryId).delete();
}



