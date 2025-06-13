
class Gym {
  final String id;
  final String name;
  final String? location;
  final String? gymNotes;
  final DateTime createdDate;

  Gym({
    required this.id,
    required this.name,
    this.location,
    this.gymNotes,
    required this.createdDate,
  });

  factory Gym.fromMap(Map<String, dynamic> map) {
    return Gym(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      gymNotes: map['gymNotes'],
      createdDate: DateTime.parse(map['createdDate']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'gymNotes': gymNotes,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}