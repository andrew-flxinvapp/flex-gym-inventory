/// Utility for generating unique Gym IDs in the format GYM-0001, GYM-0002, etc.
class GymIdGenerator {
  int _lastId = 0;

  /// Returns the next gym ID in the format GYM-0001, GYM-0002, etc.
  String nextId() {
    _lastId++;
    return 'GYM-${_lastId.toString().padLeft(4, '0')}';
  }

  /// Optionally, set the last used ID (e.g., after loading from storage)
  void setLastId(int lastId) {
    _lastId = lastId;
  }

  /// Optionally, get the last used ID
  int get lastId => _lastId;
}
