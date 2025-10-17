import 'package:isar/isar.dart'; 

part 'app_state_model.g.dart';

@Collection()
class AppState {
  /// Always a single record; you overwrite it rather than adding new ones.
  Id id = 1;

  /// The active or default gym ID
  String? activeGymId;
}
