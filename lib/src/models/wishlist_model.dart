import 'package:isar/isar.dart';

part 'wishlist_model.g.dart';

@Collection()

class Wishlist {
  Id id = Isar.autoIncrement;
  String name;
  String wishlistType;
  String? category;
  String? brand;
  String? productUrl;
  String? notes;
  DateTime createdDate;

  Wishlist({
    required this.name,
    required this.wishlistType,
    this.category,
    this.brand,
    this.productUrl,
    this.notes,
    required this.createdDate,
  });
} 
