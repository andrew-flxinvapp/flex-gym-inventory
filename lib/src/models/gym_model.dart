import 'package:isar/isar.dart';

part 'gym_model.g.dart';

@Collection()
class Gym {
  Id id = Isar.autoIncrement;
  String gymId;
  String name;
  String? location;
  String? gymNotes;
  DateTime createdDate;

  Gym({
    required this.gymId,
    required this.name,
    this.location,
    this.gymNotes,
    required this.createdDate,
  });
}
