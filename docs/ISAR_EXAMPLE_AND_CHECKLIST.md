# Isar Example Model & Wiring Checklist

This short guide shows a minimal Isar model, a tiny repository example, and a checklist for wiring it into the app.

## Example model
```dart
import 'package:isar/isar.dart';

part 'example_model.g.dart';

@Collection()
class ExampleItem {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId;

  @Index()
  late String name;

  String? notes;

  DateTime createdAt = DateTime.now();
}
```

## Minimal repository
```dart
import 'package:isar/isar.dart';
import '../models/example_model.dart';
import '../../service/isar_service.dart';

class ExampleRepository {
  Future<void> upsert(ExampleItem item) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async => await isar.exampleItems.put(item));
  }

  Future<List<ExampleItem>> getAllForUser(String userId) async {
    final isar = IsarService.isar;
    return isar.exampleItems.filter().userIdEqualTo(userId).findAll();
  }
}
```

## Wiring checklist
- Add the model file (see Example model) under `lib/src/models/` and include `part 'example_model.g.dart';`.
- Add the repository under `lib/src/repositories/` (or reuse an existing repository folder).
- Register the schema in `lib/service/isar_service.dart` by importing the model and adding `ExampleItemSchema` to the `Isar.open([...])` call.
- Run code generation to produce the `*.g.dart` adapter:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- If build_runner fails, fix any missing imports or analyzer errors and re-run.
- Use the repository in your screen/viewmodel: instantiate it (or add a provider) and call `repo.upsert(...)` and `repo.getAllForUser(userId)`.
- On app startup ensure `IsarService.openIsar()` is called before any repository use (usually in `main()`).
- Add `dart analyze` and run the app to validate wiring.

## Quick test
- Insert an item via repository in a screen, then read it back and assert count > 0.

That's it — this file is intentionally compact. Expand any step when you need a fuller example.
