import 'package:isar/isar.dart';
import '../src/models/app_state_model.dart';
import '../src/models/gym_model.dart';

/// Manages the user's active/defualt gym.
/// Stores a single AppState row (id=1)
/// Scopes the rest of the app (lists, filters, exports) to the active gym.
class ActiveGymService {
  ActiveGymService(this.isar);
  final Isar isar;

  /// Returns the active gymId. If non is set or it's invalid.
  /// Falls back to the first gym and persists it.
  Future<String> getActiveGymId() async {
    final state = await isar.appState.get(1);
    final saved = state?.activeGymId;

    if (saved != null && saved.isNotEmpty) {
      // Ensure it still exists (gym could have been deleted)
      final exists = await isar.gyms.where().gymIdEqualTo(saved).findFirst();
      if (exists != null) return saved;
    }

    // Fallback: pick first gym 
    final firstGym = await isar.gyms.where().gymIdEqualTo(saved).findFirst();
    if (firstGym == null) {
      throw StateError('No gyms exist yet. Create a gym first.');
    }

    await setActiveGymId(firstGym.gymId);
    return firstGym.gymId;
  }

  /// Returns the full active Gym object (null if none available)
  
}