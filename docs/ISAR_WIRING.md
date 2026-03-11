# Wiring Form Screens to Isar (Reference)

This document lists the existing form screens, Isar-related model/repository files in this repo, missing items to check, and a step-by-step process for wiring the form Save/Update flows to Isar.

## Quick summary
- Existing Isar models are present (`Gym`, `Equipment`, `Wishlist`, `UserPrefs`, etc.) with generated parts (e.g., `gym_model.g.dart`).
- Repositories use a central `IsarService` singleton accessor (`IsarService.isar`).
- `main.dart` currently opens Isar directly; to avoid a mismatch, call `IsarService.openIsar()` or otherwise ensure `IsarService._isar` is set on startup.

## Files (existing)

- Form screens (lib/src/screens):
  - [lib/src/screens/add_gym.dart](lib/src/screens/add_gym.dart)
  - [lib/src/screens/edit_gym.dart](lib/src/screens/edit_gym.dart)
  - [lib/src/screens/add_equipment.dart](lib/src/screens/add_equipment.dart)
  - [lib/src/screens/edit_equipment.dart](lib/src/screens/edit_equipment.dart)
  - [lib/src/screens/add_wishlist.dart](lib/src/screens/add_wishlist.dart)
  - [lib/src/screens/edit_wishlist.dart](lib/src/screens/edit_wishlist.dart)

- Model files (lib/src/models):
  - [lib/src/models/gym_model.dart](lib/src/models/gym_model.dart)
  - [lib/src/models/equipment_model.dart](lib/src/models/equipment_model.dart)
  - [lib/src/models/wishlist_model.dart](lib/src/models/wishlist_model.dart)
  - [lib/src/models/user_prefs_model.dart](lib/src/models/user_prefs_model.dart)
  - Generated parts: `gym_model.g.dart`, `equipment_model.g.dart`, `wishlist_model.g.dart`, etc.

- Repositories (lib/src/repositories) — these call `IsarService.isar`:
  - [lib/src/repositories/gym_repository.dart](lib/src/repositories/gym_repository.dart)
  - [lib/src/repositories/equipment_repository.dart](lib/src/repositories/equipment_repository.dart)
  - [lib/src/repositories/wishlist_repository.dart](lib/src/repositories/wishlist_repository.dart)
  - [lib/src/repositories/user_local_repository.dart](lib/src/repositories/user_local_repository.dart)

- Isar helper/service:
  - [lib/service/isar_service.dart](lib/service/isar_service.dart)

## Missing / Verify (things you need to check or add)

- Initialization alignment: `IsarService.openIsar()` exists but is not currently called everywhere — `main.dart` opens Isar directly. Ensure startup sets the `IsarService` instance (recommended: call `await IsarService.openIsar()` in `main`).
- Ensure all `*.g.dart` generated files exist and are up-to-date. If not, run build_runner.
- Save handlers in form screens: many `Save` buttons currently have `// TODO: Implement save logic`. Those need to call repositories or viewmodels that use the repositories.
- Riverpod/viewmodel refresh: after writing to Isar, update providers/viewmodels so UI reflects changes.

## Setup / How to initialize Isar (recommended)

1. Add Isar + build_runner dev deps in `pubspec.yaml` (if not present):

   - `isar` (runtime)
   - `isar_flutter_libs` (platform libs)
   - `build_runner` (dev)
   - `isar_generator` (dev)

2. Generate Isar code (run once / after model changes):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Initialize Isar on app startup — recommended change in `lib/main.dart`:

```dart
// instead of calling Isar.open(...) directly, do:
final isar = await IsarService.openIsar();
// or
await IsarService.openIsar();
// then you can use IsarService.isar in repositories

runApp(ProviderScope(child: MyApp()));
```

4. If you prefer to keep `MyApp` accepting an `Isar` instance, pass `IsarService.isar` after calling `openIsar()`.

Notes:
- `IsarService.openIsar()` handles directory setup via `path_provider` and registers schemas. Using that central method prevents duplication and ensures `IsarService.isar` is available for repositories.

## Wiring a form Save (example)

Example: wire `AddGymScreen` Save button to `GymRepository`.

1. Import the repository:

```dart
import 'package:flex_gym_inventory/src/repositories/gym_repository.dart';
```

2. In the `onPressed` for Save:

```dart
final repo = GymRepository();
if (_formKey.currentState?.validate() ?? false) {
  // collect values from controllers / fields
  final gymId = generateGymId(); // implement or use existing helper
  final created = await repo.createGym(
    gymId: gymId,
    name: nameController.text.trim(),
    userId: userId,
    location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
    gymNotes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
  );

  // update viewmodel / providers or pop with result
  Navigator.of(context).pop(created);
}
```

Notes:
- `createGym` will call repository.upsert which wraps `isar.writeTxn` — you do not need to open transactions yourself in the UI code.
- For updates use the repository `updateGym` method (pass `id` = `gym.id` from existing record).

## Example: Equipment save (high-level)

- Collect values (selected gym id, category, name, brand, model, training style, condition, purchase date, value, etc.).
- Call the `EquipmentRepository` methods (see [lib/src/repositories/equipment_repository.dart](lib/src/repositories/equipment_repository.dart)).

## Generated code & building

- If you change model annotations, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- Ensure generated files like `gym_model.g.dart`, `equipment_model.g.dart`, `wishlist_model.g.dart` exist and are committed.

## Transactions, queries, and best practices

- Use repository methods (they wrap `isar.writeTxn`). Do not use long-running write transactions on the UI thread; keep data transforms minimal in the txn.
- After writes, refresh any cached provider state. If using Riverpod, call the relevant notifier to reload lists.
- Use indexed fields for filters and sorts (models already add `@Index()` on common fields).

## Checklist for wiring each form screen

For each form screen (e.g. `AddGymScreen`, `EditGymScreen`, `AddEquipmentScreen`, ...):

- [ ] Wire the Save button to a repository/viewmodel call as shown above
- [ ] Validate the form before calling the repository
- [ ] Map form fields to model constructor arguments
- [ ] On success: update providers/viewmodels or `Navigator.pop(result)` and show success UiMessage/snackbar
- [ ] On error: show error UiMessage/snackbar and do not pop

## Recommended small code changes (priority)

1. Replace direct `Isar.open(...)` in `lib/main.dart` with `await IsarService.openIsar()` so repositories that call `IsarService.isar` won't throw.
2. For every `// TODO: Implement save logic` in form screens, add repository/viewmodel calls and provider refreshes.
3. Run build_runner to ensure generated code is in sync.

## Helpful debugging tips

- If a repository throws `Isar has not been initialized`, confirm `IsarService.openIsar()` was run on startup and before any repository calls.
- Use breakpoints or logs inside repository `upsert` / `writeTxn` blocks to verify writes happened.
- Use `isar.<collection>.getAll()` or `findAll()` temporarily to inspect saved records.

---

If you want, I can:

- Patch `lib/main.dart` to call `IsarService.openIsar()` instead of `Isar.open(...)`.
- Implement a sample Save handler for one form (e.g., `AddGymScreen`) and update its `Save` button.

Which of those would you like me to do next?
