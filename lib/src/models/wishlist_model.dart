import 'package:isar/isar.dart';

part 'wishlist_model.g.dart';

@Collection()

class Wishlist {
  Id id = Isar.autoIncrement;

  ///Indexed fields (filtering, sorting, scoping, and searching)

  /// For alphabetical sorting and quick lookups
  @Index(caseSensitive: false)
  late String name;

  /// Filter by type
  @Index(caseSensitive: false)
  late String wishlistType;

  /// Filter by category
  @Index(caseSensitive: false)
  late String category;

  /// Filter by brand
  @Index(caseSensitive: false)
  late String brand;

  /// Priorty level of the wishlist item
  @Index(caseSensitive: false)
  late String priority;

  /// Non-indexed fields (informational / secondary data)
  String? productUrl;
  String? notes;

  Wishlist({
    required this.name,
    required this.wishlistType,
    required this.category,
    required this.brand,
    required this.priority,
    this.productUrl,
    this.notes,
  });
} 
