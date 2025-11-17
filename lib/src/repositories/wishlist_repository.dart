// lib/src/repositories/wishlist_repository.dart
import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/service/isar_service.dart';
import 'package:flex_gym_inventory/src/models/wishlist_model.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

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

  /// Create a new wishlist item and insert it.
  Future<Wishlist> createWishlist({
    required String userId,
    required String name,
    required WishlistType wishlistType,
    required EquipmentCategory category,
    required String brand,
    required WishlistPriority priority,
    String? productUrl,
    String? notes,
  }) async {
    final item = Wishlist(
      userId: userId,
      name: name,
      wishlistType: wishlistType,
      category: category,
      brand: brand,
      priority: priority,
      productUrl: productUrl,
      notes: notes,
    );
    await upsert(item);
    return item;
  }

  /// Update an existing wishlist item by Isar id.
  Future<Wishlist?> updateWishlist({
    required int id,
    String? name,
    WishlistType? wishlistType,
    EquipmentCategory? category,
    String? brand,
    WishlistPriority? priority,
    String? productUrl,
    String? notes,
  }) async {
    final isar = IsarService.isar;
    final item = await isar.wishlists.get(id);
    if (item == null) return null;
    if (name != null) item.name = name;
    if (wishlistType != null) item.wishlistType = wishlistType;
    if (category != null) item.category = category;
    if (brand != null) item.brand = brand;
    if (priority != null) item.priority = priority;
    if (productUrl != null) item.productUrl = productUrl;
    if (notes != null) item.notes = notes;
    await upsert(item);
    return item;
  }

  /// Delete a wishlist item by Isar id and return the deleted item.
  Future<Wishlist?> deleteWishlist(int id) async {
    final isar = IsarService.isar;
    final item = await isar.wishlists.get(id);
    if (item == null) return null;
    await isar.writeTxn(() async {
      await isar.wishlists.delete(id);
    });
    return item;
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
    WishlistType? wishlistType,
    EquipmentCategory? category,
    String? brand,
    WishlistPriority? priority,            // single priority filter
    List<WishlistPriority>? priorities,    // multi-priority filter
    WishlistSort sort = WishlistSort.nameAsc,
    List<String>? priorityOrder, // optional custom sort precedence (labels)
  }) async {
    final isar = IsarService.isar;

    // Base fetch (indexed filters first)
  var items = await isar.wishlists
    .filter()
    .optional(wishlistType != null, (q) => q.wishlistTypeEqualTo(wishlistType!))
    .optional(category != null, (q) => q.categoryEqualTo(category!))
    .optional(brand != null && brand.isNotEmpty, (q) => q.brandEqualTo(brand!))
    .optional(priority != null, (q) => q.priorityEqualTo(priority!))
    .findAll();

    // Multi-priority filter (local)
    if (priorities != null && priorities.isNotEmpty) {
      final set = priorities.map((p) => p.name.toLowerCase()).toSet();
      items = items.where((w) => set.contains(w.priority.name.toLowerCase())).toList();
    }

    // Text search (local, case-insensitive)
    if (search != null && search.trim().isNotEmpty) {
      final q = search.toLowerCase().trim();
      items = items.where((w) {
        final n = w.name.toLowerCase();
        final b = w.brand.toLowerCase();
        final c = w.category.name.toLowerCase();
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
        final ra = ranks[a.priority.label.toLowerCase()] ?? 9999;
        final rb = ranks[b.priority.label.toLowerCase()] ?? 9999;
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
