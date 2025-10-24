import 'package:isar/isar.dart';

part 'user_prefs_model.g.dart';

/// Local per-user preferences stored in Isar.
/// - One row per Supabase user (enforced via unique index on [userId]).
/// - [defaultGymCode] is nullable: null means no default selected yet.
@collection
class UserPrefs {
  /// Isar internal primary key.
  Id id = Isar.autoIncrement;

  /// Supabase auth user id (e.g., 'c4f5...').
  /// Unique so we only ever have one prefs row per signed-in user.
  @Index(unique: true, replace: true, caseSensitive: true)
  late String userId;

  /// Your external, human-readable gym code (e.g., 'GYM-0001').
  /// Keep this aligned with your Gym.gymCode field.
  String? defaultGymId;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // -------Convenience helpers-------

  void touch() => updatedAt = DateTime.now();

  UserPrefs copyWith({
    String? userId,
    String? defaultGymId = _sentinelString,
  }) {
    final c = UserPrefs()
      ..id = id
      ..userId = userId ?? this.userId
      ..defaultGymId = 
        (defaultGymId == _sentinelString) ? this.defaultGymId : defaultGymId
      ..createdAt = createdAt
      ..updatedAt = DateTime.now();

    return c; 
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userId' : userId,
    'defaultGymId' : defaultGymId,
    'createdAt' : createdAt.toIso8601String(),
    'updatedAt' : updatedAt.toIso8601String(), 
  };

  static UserPrefs fromJson(Map<String, dynamic> json) {
    final prefs = UserPrefs()
      ..id = (json['id'] as int?) ?? Isar.autoIncrement
      ..userId = json['userId'] as String
      ..defaultGymId = json['defaultGymId'] as String?
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String);

    return prefs;
  }
}

// Private sentinel to allow nullable copyWith parameters.
const String _sentinelString = '__SENTINEL__';