// lib/src/repositories/wishlist_repository.dart
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';

/// Basic sort modes that map cleanly to your fields.
enum WishlistSort { nameAsc, nameDesc, brandAsc, brandDesc }

class WishlistRepository {
  // -------------------- Create / Update / Delete -----------------------------

  /// Insert or replace a wishlist item.
  Future<void> upsert(Wishlist item) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.wishlists.put(item);
    });
  }

  /// Delete by Isar id.
  Future<void> deleteByIsarId(int isarId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.wishlists.delete(isarId);
    });
  }

  // -------------------- Lookups ---------------------------------------------

  /// Get by Isar id.
  Future<Wishlist?> getByIsarId(int isarId) async {
    final isar = IsarService.isar;
    return isar.wishlists.get(isarId);
  }

  // -------------------- List (search / filter / sort) ------------------------

  /// Returns all wishlist items with optional text search, filters, and sorting.
  ///
  /// - `search` checks name/brand/category (case-insensitive).
  /// - `wishlistType`, `category`, `brand`, `priority` map to your indexed fields.
  /// - `priorities` lets you filter multiple priorities at once.
  /// - `priorityOrder` (optional) lets you sort by a custom priority ranking
  ///    e.g., `['High','Medium','Low']` (ties break by name).
  Future<List<Wishlist>> getAll({
    String? search,
    String? wishlistType,
    String? category,
    String? brand,
    String? priority,            // single priority filter
    List<String>? priorities,    // multi-priority filter
    WishlistSort sort = WishlistSort.nameAsc,
    List<String>? priorityOrder, // optional custom sort precedence
  }) async {
    final isar = IsarService.isar;

    // Base fetch (indexed filters first)
    var items = await isar.wishlists
        .filter()
        .optional(wishlistType != null && wishlistType.isNotEmpty,
            (q) => q.wishlistTypeEqualTo(wishlistType!))
        .optional(category != null && category.isNotEmpty,
            (q) => q.categoryEqualTo(category!))
        .optional(brand != null && brand.isNotEmpty,
            (q) => q.brandEqualTo(brand!))
        .optional(priority != null && priority.isNotEmpty,
            (q) => q.priorityEqualTo(priority!))
        .findAll();

    // Multi-priority filter (local)
    if (priorities != null && priorities.isNotEmpty) {
      final set = priorities.map((p) => p.toLowerCase()).toSet();
      items = items.where((w) => set.contains(w.priority.toLowerCase())).toList();
    }

    // Text search (local, case-insensitive)
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items = items.where((w) {
        final n = w.name.toLowerCase();
        final b = w.brand.toLowerCase();
        final c = w.category.toLowerCase();
        return n.contains(q) || b.contains(q) || c.contains(q);
      }).toList();
    }

    // Sorting
    int brandCmp(Wishlist a, Wishlist b) =>
        a.brand.toLowerCase().compareTo(b.brand.toLowerCase());

    int nameCmp(Wishlist a, Wishlist b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase());

    // Optional: custom priority order (e.g., High > Medium > Low)
    if (priorityOrder != null && priorityOrder.isNotEmpty) {
      final ranks = <String, int>{};
      for (var i = 0; i < priorityOrder.length; i++) {
        ranks[priorityOrder[i].toLowerCase()] = i;
      }
      items.sort((a, b) {
        final ra = ranks[a.priority.toLowerCase()] ?? 9999;
        final rb = ranks[b.priority.toLowerCase()] ?? 9999;
        final r = ra.compareTo(rb);
        if (r != 0) return r;
        return nameCmp(a, b); // tie-breaker
      });
      // If custom priorityOrder is provided, we consider that the primary sort
      // and skip the generic sort switch below.
      return items;
    }

    switch (sort) {
      case WishlistSort.nameAsc:
        items.sort(nameCmp);
        break;
      case WishlistSort.nameDesc:
        items.sort((a, b) => nameCmp(b, a));
        break;
      case WishlistSort.brandAsc:
        items.sort(brandCmp);
        break;
      case WishlistSort.brandDesc:
        items.sort((a, b) => brandCmp(b, a));
        break;
    }

    return items;
  }

  // -------------------- Stats ------------------------------------------------

  /// Total number of wishlist items.
  Future<int> countAll() async {
    final isar = IsarService.isar;
    return isar.wishlists.where().count();
  }
}
