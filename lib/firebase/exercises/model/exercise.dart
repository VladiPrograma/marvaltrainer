
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:marvaltrainer/utils/extensions.dart';
import 'package:marvaltrainer/utils/marval_arq.dart';

class Exercise {
  String id;
  String name;
  String description;
  String link;
  String imageUrl;
  List<String> tags;


  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.link,
    required this.tags,
  });

  Exercise.create(this.name, this.link, this.description, this.imageUrl, this.tags)
  :     id = Timestamp.now().microsecondsSinceEpoch.toString();


  Exercise.empty()
  :     id = '',
        name = '',
        description = '',
        imageUrl = '',
        link = '',
        tags = [];

  Exercise.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        description = map["description"],
        imageUrl = map["image_url"],
        link = map["link"],
        tags = List<String>.from(map["tags"]).sorted();

  Map<String, dynamic> toMap(){
    return {
      'id': id, // Vlad
      'name': name.normalize(), // Vlad
      'image_url': imageUrl, // Dumitru
      'link': link, // Dumitru
      'description': description.normalize(), // Dumitru
      'tags': tags,
      'keywords' : getKeywords(name.toLowerCase())
    };
  }
   @override
  get hashCode => Object.hash(name, description, link, tags, imageUrl);

  @override
  String toString() {
    return 'Exercise {id: $id, name: $name, description: $description, tags: $tags image : $imageUrl link: $link}';
  }

  @override
  bool operator ==(other) => other is Exercise && id == other.id;
}