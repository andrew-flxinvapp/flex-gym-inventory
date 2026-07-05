import 'package:isar/isar.dart';

part 'account_model.g.dart';

@Collection()
class AccountEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id; // user id (Supabase)

  // Email is authoritative from Supabase auth; treat as read-only locally.
  late String email;

  // Optional phone number; starts null and can be added/verified by the user.
  String? phoneNumber;

  String? displayName;

  String? avatarUrl;

  DateTime? createdAt;

  DateTime? updatedAt;

  // Stored as a JSON string because Isar doesn't support `Map<String, dynamic>` directly.
  String? settingsJson;

  String? subscriptionStatus;

  // Subscription metadata (e.g., RevenueCat). Keep minimal fields for display and sync.
  String? subscriptionPlan;
  String? subscriptionProvider;
  DateTime? subscriptionExpiresAt;
  bool subscriptionActive = false;
  DateTime? subscriptionLastSynced;
  // Stored as a JSON string for the same reason as `settingsJson`.
  String? subscriptionMetadataJson;

  List<String> deviceIds = [];

  // Cached count of items in the user's wishlist. Kept in sync by repository logic.
  int wishlistCount = 0;
}

/// Helper extension with convenience methods for `AccountEntity`.
extension AccountEntityHelpers on AccountEntity {
  /// True when the user's subscription plan is `pro`.
  bool get isPro => (subscriptionPlan ?? '').toLowerCase() == 'pro';
}
