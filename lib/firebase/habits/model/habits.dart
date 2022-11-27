
class Habit {
  String id;
  String name;
  String label;
  String description;
  DateTime startDate;
  List<String> users;


  Habit({
    required this.id,
    required this.name,
    required this.label,
    required this.description,
    required this.users,
    required this.startDate,
  });
  Habit.empty()
  :     id = '',
        name = '',
        description = '',
        label = '',
        users = [],
        startDate = DateTime.now();

  Habit.fromMap(Map<String, dynamic> map)
      : id = map["id"],
        name = map["name"],
        description = map["description"],
        label = map["label"],
        users = List<String>.from(map["users"]),
        startDate = map["start_date"].toDate();

  Map<String, dynamic> toMap(){
    return {
      'id': id, // Vlad
      'name': name, // Vlad
      'label': label, // Dumitru
      'description': description, // Dumitru
      'users': users, // Dumitru
      'start_date': startDate,
    };
  }
   @override
  get hashCode => Object.hash(name, label, users, description, startDate);

  @override
  String toString() {
    return 'Habit{id: $id, name: $name, label: $label, description: $description, startDate: $startDate, users: $users}';
  }
  @override
  bool operator ==(other) => other is Habit && id == other.id;
}