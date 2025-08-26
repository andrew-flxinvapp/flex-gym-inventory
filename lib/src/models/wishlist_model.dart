import 'package:isar/isar.dart';

part 'wishlist_model.g.dart';

@Collection()

class Wishlist {
  Id id = Isar.autoIncrement;
  String name;
  String wishlistType;
  String category;
  String brand;
  String priority;
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
