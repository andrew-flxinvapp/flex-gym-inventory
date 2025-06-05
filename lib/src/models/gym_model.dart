import 'package:hive/hive.dart';

part 'gym_model.g.dart';

@HiveType(typeId: 8)
class Gym extends HiveObject {
    @HiveField(0)
    final String id;

    @HiveField(1)
    final String name;

    @HiveField(2)
    final String? location;

    @HiveField(3)
    final String? gymNotes;

    @HiveField(4)
    final DateTime createdDate;

    Gym({
        required this.id,
        required this.name,
        this.location,
        this.gymNotes,
        required this.createdDate,
    });
}