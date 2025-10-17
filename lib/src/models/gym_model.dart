import 'package:isar/isar.dart';

part 'gym_model.g.dart';

@Collection()
class Gym {
  Id id = Isar.autoIncrement;

  /// Indexed fields (filtering, sorting, and scoping)
  
  /// Human-readable unique gym identifier
  @Index(unique: true, caseSensitive: false)
  late String gymId;

  /// For alphabetical sorts and quick lookups
  @Index(caseSensitive: false)
  late String name;

  ///For date-based sorting and filtering
  @Index()
  late DateTime createdDate;

  /// Non-indexed fields (detailed information)
  String? location;
  String? gymNotes;

  Gym({
    required this.gymId,
    required this.name,
    this.location,
    this.gymNotes,
    required this.createdDate,
  });
}
