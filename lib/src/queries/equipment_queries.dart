import 'package:isar/isar.dart';
import '../models/equipment_model.dart';

/// Query helper for filtering equipment by category only.
extension EquipmentQueries on Isar {
  Future<List<Equipment>> filterEquipmentByCategory({
    required String category,
  }) async {
    // Returns all equipment matching the given category.
    // Notes:
    // - This performs an exact match against the generated `categoryEqualTo` query.
    // - Case-insensitive matching requires a dedicated lowercased field in the model
    //   or additional client-side filtering; this function does not attempt that.
    // - If `category` is empty or only whitespace, we return an empty list so the
    //   UI can show an empty state like "No Results Found".

    final q = category.trim();
    if (q.isEmpty) return <Equipment>[];

    return await equipments
        .where()
        .categoryEqualTo(q)
        .findAll();
  }
}