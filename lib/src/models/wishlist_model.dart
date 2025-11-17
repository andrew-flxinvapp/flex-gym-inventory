import 'package:isar/isar.dart';
import 'package:flex_gym_inventory/enum/app_enums.dart';

part 'wishlist_model.g.dart';

@Collection()

class Wishlist {
  Id id = Isar.autoIncrement;

  @Index()
  late String userId; // for Supabase user association

  ///Indexed fields (filtering, sorting, scoping, and searching)

  /// For alphabetical sorting and quick lookups
  @Index(caseSensitive: false)
  late String name;

  /// Filter by type
  @Index(caseSensitive: false)
  @Enumerated(EnumType.name)
  late WishlistType wishlistType;

  /// Filter by category
  @Index(caseSensitive: false)
  @Enumerated(EnumType.name)
  late EquipmentCategory category;

  /// Filter by brand
  @Index(caseSensitive: false)
  late String brand;

  /// Priorty level of the wishlist item
  @Index(caseSensitive: false)
  @Enumerated(EnumType.name)
  late WishlistPriority priority;

  /// Non-indexed fields (informational / secondary data)
  String? productUrl;
  String? notes;

  Wishlist({
    required this.userId,
    required this.name,
    required this.wishlistType,
    required this.category,
    required this.brand,
    required this.priority,
    this.productUrl,
    this.notes,
  });
}
